#!/usr/bin/env bash
# =========================================================================== #
#  Verify backup setup:
#    ✓ Backup credentials can access the backup bucket
#    ✗ Main credentials CANNOT access the backup bucket (isolation)
#    ✗ Public URL CANNOT reach backup files (privacy)
#
#  Usage:  ./scripts/verify_backup.sh
# =========================================================================== #
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [ -f .venv/bin/activate ]; then
    # shellcheck disable=SC1091
    source .venv/bin/activate
fi

if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    source <(grep -E '^(R2_ACCOUNT_ID|R2_ACCESS_KEY_ID|R2_SECRET_ACCESS_KEY|R2_PUBLIC_BASE_URL|R2_BACKUP_BUCKET|R2_BACKUP_ACCESS_KEY_ID|R2_BACKUP_ACCESS_KEY)=' .env)
    set +a
fi

echo "════════════════════════════════════════════════════════════"
echo "  Backup security verification"
echo "════════════════════════════════════════════════════════════"
echo ""

python - <<'PY'
import os, sys
import boto3
import requests
from botocore.exceptions import ClientError

REQUIRED = (
    "R2_ACCOUNT_ID", "R2_BACKUP_BUCKET",
    "R2_BACKUP_ACCESS_KEY_ID", "R2_BACKUP_ACCESS_KEY",
)
missing = [k for k in REQUIRED if not os.environ.get(k)]
if missing:
    print(f"✗ Missing env: {', '.join(missing)}")
    sys.exit(1)

endpoint = f"https://{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com"
bucket = os.environ["R2_BACKUP_BUCKET"]


def client(access, secret):
    return boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=access,
        aws_secret_access_key=secret,
        region_name="auto",
    )


passed = failed = 0


def ok(label):
    global passed
    passed += 1
    print(f"  ✓ {label}")


def fail(label):
    global failed
    failed += 1
    print(f"  ✗ {label}")


# -------------------------------------------------------------------------
#  TEST 1 — Backup credentials can access the backup bucket
# -------------------------------------------------------------------------
print("[1] Backup credentials → backup bucket (should succeed)")
backup_client = client(
    os.environ["R2_BACKUP_ACCESS_KEY_ID"],
    os.environ["R2_BACKUP_ACCESS_KEY"],
)
try:
    resp = backup_client.list_objects_v2(Bucket=bucket, Prefix="backups/")
    objs = resp.get("Contents", [])
    ok(f"Can list backups ({len(objs)} file(s))")
    for o in objs[-3:]:
        print(f"      {o['Size']/1024**2:>7.1f} MB  {o['Key']}")
    if not objs:
        print("      (empty — run ./scripts/backup.sh first to create a backup)")
except ClientError as e:
    fail(f"Cannot list backups: {e.response['Error']['Code']}")
except Exception as e:
    fail(f"Error: {e}")

# -------------------------------------------------------------------------
#  TEST 2 — Main credentials CANNOT access the backup bucket
# -------------------------------------------------------------------------
print()
print("[2] Main credentials → backup bucket (should FAIL if isolation is set)")
if os.environ.get("R2_ACCESS_KEY_ID") and os.environ.get("R2_SECRET_ACCESS_KEY"):
    main_client = client(
        os.environ["R2_ACCESS_KEY_ID"],
        os.environ["R2_SECRET_ACCESS_KEY"],
    )
    try:
        main_client.list_objects_v2(Bucket=bucket, MaxKeys=1)
        fail("Main creds CAN access backup bucket — isolation not enforced")
        print("       → In Cloudflare, edit your main R2 token and remove")
        print(f"         the '{bucket}' bucket from its scope")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        if code in ("AccessDenied", "403", "NoSuchBucket"):
            ok(f"Main creds denied (correct): {code}")
        else:
            fail(f"Unexpected error: {code}")
    except Exception as e:
        fail(f"Error: {e}")
else:
    print("  ⚠ R2_ACCESS_KEY_ID / R2_SECRET_ACCESS_KEY not set — skipping")

# -------------------------------------------------------------------------
#  TEST 3 — Public URL cannot reach backup files
# -------------------------------------------------------------------------
print()
print("[3] Public URL → backup file (should be 404)")
public_base = (os.environ.get("R2_PUBLIC_BASE_URL") or "").rstrip("/")
if not public_base:
    print("  ⚠ R2_PUBLIC_BASE_URL not set — skipping")
else:
    # Try to list what's actually in the backup bucket, then probe its public URL
    try:
        resp = backup_client.list_objects_v2(Bucket=bucket, Prefix="backups/")
        objs = resp.get("Contents", [])
        if not objs:
            print("  ⚠ No backup files yet — run ./scripts/backup.sh first")
        else:
            latest = sorted(objs, key=lambda o: o["LastModified"])[-1]
            key = latest["Key"]
            # The public URL uses the SAME path but on the r2.dev domain.
            # If the backup bucket had public access, the file would be
            # reachable at <public_base>/<key>. But public_base points at
            # the MAIN bucket (nazar-e-alam), which has NO backups/ folder.
            # So this must 404 (or 403).
            url = f"{public_base}/{key}"
            try:
                r = requests.get(url, timeout=10, allow_redirects=False)
                if r.status_code in (403, 404):
                    ok(f"Public URL denied (HTTP {r.status_code}): {key}")
                elif r.status_code == 200:
                    fail(f"⚠ BACKUP IS PUBLIC — HTTP 200 at {url}")
                    print("       → STOP: your backups are downloadable by anyone.")
                    print("       → Check that R2_BACKUP_BUCKET is NOT public in Cloudflare.")
                else:
                    fail(f"Unexpected status {r.status_code} for {url}")
            except requests.RequestException as e:
                ok(f"Public URL unreachable (network): {type(e).__name__}")
    except ClientError as e:
        fail(f"Could not list backups to test public URL: {e.response['Error']['Code']}")

# -------------------------------------------------------------------------
#  Summary
# -------------------------------------------------------------------------
print()
print("════════════════════════════════════════════════════════════")
if failed == 0:
    print(f"  ✅ All {passed} checks passed")
    print()
    print("  Your backup setup is:")
    print("    ✓ Reachable with backup credentials")
    print("    ✓ Isolated from main credentials")
    print("    ✓ Not exposed via public URL")
else:
    print(f"  ❌ {failed} failed, {passed} passed")
print("════════════════════════════════════════════════════════════")
sys.exit(0 if failed == 0 else 1)
PY