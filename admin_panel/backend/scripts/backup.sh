#!/usr/bin/env bash
# =========================================================================== #
#  Nazar-e-Aalam — MySQL backup (local + R2 offsite, split credentials)
#
#  Env vars used:
#    DATABASE_URL              (required)
#    BACKUP_DIR                (default: ./backups)
#    BACKUP_RETENTION_DAYS     (default: 30)
#    R2_ACCOUNT_ID             (required for R2 upload)
#    R2_BACKUP_BUCKET          (required for R2 upload)
#    R2_BACKUP_ACCESS_KEY_ID   (required for R2 upload)
#    R2_BACKUP_ACCESS_KEY      (required for R2 upload)
#
#  Usage:
#    ./scripts/backup.sh
#    ./scripts/backup.sh --retention 7
#    ./scripts/backup.sh --label pre-deploy
# =========================================================================== #
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Activate venv for boto3
if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

# Load .env
if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source <(grep -E '^(DATABASE_URL|BACKUP_DIR|BACKUP_RETENTION_DAYS|R2_ACCOUNT_ID|R2_BACKUP_BUCKET|R2_BACKUP_ACCESS_KEY_ID|R2_BACKUP_ACCESS_KEY)=' .env)
    set +a
fi

DATABASE_URL="${DATABASE_URL:-}"
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_ROOT/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
LABEL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --retention) RETENTION_DAYS="$2"; shift 2 ;;
        --label)     LABEL="_$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$DATABASE_URL" ]; then
    echo "✗ DATABASE_URL not set"
    exit 1
fi

# ---- Parse DATABASE_URL ---------------------------------------------------
URL_NO_SCHEME="${DATABASE_URL#mysql+pymysql://}"
URL_NO_SCHEME="${URL_NO_SCHEME#mysql+mysqldb://}"
CREDS="${URL_NO_SCHEME%%@*}"
HOSTDB="${URL_NO_SCHEME#*@}"
DB_USER="${CREDS%%:*}"
DB_PASS="${CREDS#*:}"
HOSTPORT="${HOSTDB%%/*}"
DB_NAME="${HOSTDB#*/}"
DB_HOST="${HOSTPORT%%:*}"
DB_PORT="${HOSTPORT#*:}"
if [ "$DB_PORT" = "$DB_HOST" ]; then DB_PORT="3306"; fi
DB_NAME="${DB_NAME%%\?*}"

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="nazar_e_alam_${TIMESTAMP}${LABEL}.sql.gz"
FILEPATH="$BACKUP_DIR/$FILENAME"

# ---- Dump -----------------------------------------------------------------
echo "→ Backing up $DB_NAME to $FILENAME"

export MYSQL_PWD="$DB_PASS"
mysqldump \
    --user="$DB_USER" --host="$DB_HOST" --port="$DB_PORT" \
    --single-transaction --quick --routines --triggers --events \
    --default-character-set=utf8mb4 \
    "$DB_NAME" | gzip -9 > "$FILEPATH"
unset MYSQL_PWD

SIZE=$(du -h "$FILEPATH" | cut -f1)
echo "✓ Local backup: $FILENAME ($SIZE)"

# ---- Archive logs --------------------------------------------------------
LOG_DIR="${LOG_DIR:-$PROJECT_ROOT/logs}"
LOG_TAR=""
if [ -d "$LOG_DIR" ] && [ -n "$(ls -A "$LOG_DIR" 2>/dev/null)" ]; then
    LOG_TAR="$BACKUP_DIR/nazar_logs_${TIMESTAMP}${LABEL}.tar.gz"
    echo "→ Archiving logs…"
    tar -czf "$LOG_TAR" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")" 2>/dev/null
    LOG_SIZE=$(du -h "$LOG_TAR" | cut -f1)
    echo "✓ Logs archived: $(basename "$LOG_TAR") ($LOG_SIZE)"
fi

# ---- Upload to R2 private bucket -----------------------------------------
# ---- Upload to R2 private bucket -----------------------------------------
if [ -n "${R2_BACKUP_BUCKET:-}" ] && [ -n "${R2_ACCOUNT_ID:-}" ] \
   && [ -n "${R2_BACKUP_ACCESS_KEY_ID:-}" ] && [ -n "${R2_BACKUP_ACCESS_KEY:-}" ]; then
    echo "→ Uploading to R2 (bucket: $R2_BACKUP_BUCKET)…"

    # Build list of files to upload
    UPLOAD_FILES="$FILEPATH"
    [ -n "$LOG_TAR" ] && UPLOAD_FILES="$UPLOAD_FILES $LOG_TAR"

    if python - $UPLOAD_FILES <<'PY'
import os, sys
from pathlib import Path
import boto3

try:
    client = boto3.client(
        "s3",
        endpoint_url=f"https://{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=os.environ["R2_BACKUP_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_BACKUP_ACCESS_KEY"],
        region_name="auto",
    )
    uploaded = 0
    for arg in sys.argv[1:]:
        path = Path(arg)
        if not path.exists():
            print(f"  ⚠ Missing file: {path}", file=sys.stderr)
            continue
        # Route logs to a different prefix so lifecycle rules can differ
        prefix = "backups/logs/" if path.name.startswith("nazar_logs_") else "backups/"
        key = f"{prefix}{path.name}"
        client.upload_file(
            str(path),
            os.environ["R2_BACKUP_BUCKET"],
            key,
            ExtraArgs={
                "ContentType": "application/gzip",
                "CacheControl": "private, no-store",
            },
        )
        print(f"✓ Uploaded → s3://{os.environ['R2_BACKUP_BUCKET']}/{key}")
        uploaded += 1
    sys.exit(0 if uploaded > 0 else 1)
except Exception as e:
    print(f"✗ Upload failed: {e}", file=sys.stderr)
    sys.exit(1)
PY
    then
        echo "  (local files preserved regardless)"
    else
        echo "  ⚠ R2 upload failed — local files are safe in $BACKUP_DIR"
    fi
else
    echo "⚠ R2 backup credentials not set — skipping offsite upload"
fi

# ---- Prune local backups --------------------------------------------------
if [ "$RETENTION_DAYS" -gt 0 ]; then
    DELETED=$(find "$BACKUP_DIR" -name "nazar_e_alam_*.sql.gz" -type f \
        -mtime "+$RETENTION_DAYS" -print -delete | wc -l)
    [ "$DELETED" -gt 0 ] && echo "✓ Pruned $DELETED local backup(s) > $RETENTION_DAYS days"
fi

# ---- Summary --------------------------------------------------------------
echo ""
echo "Recent local backups:"
ls -lh "$BACKUP_DIR"/nazar_e_alam_*.sql.gz 2>/dev/null | tail -5 || true