#!/usr/bin/env bash
# Full stack audit — confirms every subsystem is wired and working.
set -uo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

PASS=0; FAIL=0; WARN=0
ok()   { echo -e "  \033[0;32m✓\033[0m $*"; PASS=$((PASS+1)); }
err()  { echo -e "  \033[0;31m✗\033[0m $*"; FAIL=$((FAIL+1)); }
warn() { echo -e "  \033[0;33m⚠\033[0m $*"; WARN=$((WARN+1)); }
hdr()  { echo -e "\n\033[1;36m═══ $* ═══\033[0m"; }

# ---- 1. Python imports ----
hdr "Python modules"
python -c "from config import ENV" 2>/dev/null && ok "config.ENV loads" || err "config.ENV failed"
python -c "from database import db, Base, init_db" 2>/dev/null && ok "database loads" || err "database failed"
python -c "from main import app" 2>/dev/null && ok "main.app imports" || err "main.app failed"
python -c "from tools.migrate import current_revision, head_revision" 2>/dev/null && ok "tools.migrate loads" || err "tools.migrate failed"
python -c "from tools.chand import get_effective_hijri" 2>/dev/null && ok "tools.chand loads" || err "tools.chand failed"
python -c "from tools.prayer_calc import calculate" 2>/dev/null && ok "tools.prayer_calc loads" || err "tools.prayer_calc failed"
python -c "from tools.backup_scheduler import get_state" 2>/dev/null && ok "tools.backup_scheduler loads" || err "tools.backup_scheduler failed"

# ---- 2. Env vars ----
hdr "Environment"
python -c "
from config import ENV
missing = []
for k in ('DATABASE_URL','JWT_SIGNING_KEY','R2_ACCOUNT_ID','R2_ACCESS_KEY_ID',
          'R2_SECRET_ACCESS_KEY','R2_BUCKET','R2_PUBLIC_BASE_URL',
          'R2_BACKUP_BUCKET','R2_BACKUP_ACCESS_KEY_ID','R2_BACKUP_ACCESS_KEY'):
    if not getattr(ENV, k, None):
        missing.append(k)
if missing:
    print('MISSING:', ', '.join(missing)); exit(1)
print('ok')
" >/dev/null 2>&1 && ok "All required env vars present" || err "Missing env vars"

# ---- 3. Alembic state ----
hdr "Alembic"
CUR=$(python -c "from tools.migrate import current_revision; print(current_revision() or '')" 2>/dev/null)
HEAD=$(python -c "from tools.migrate import head_revision; print(head_revision() or '')" 2>/dev/null)
if [ "$CUR" = "$HEAD" ] && [ -n "$CUR" ]; then
    ok "Schema at head ($CUR)"
else
    err "Schema mismatch: current=$CUR head=$HEAD → run 'alembic upgrade head'"
fi

# ---- 4. Database connectivity ----
hdr "Database"
python -c "
from sqlalchemy import text
from database import db
with db.engine.connect() as c:
    c.execute(text('SELECT 1'))
print('ok')
" 2>/dev/null && ok "MySQL reachable" || err "MySQL unreachable"

for t in users duas chapters reciters prayer_times settings; do
    CNT=$(mysql -u root nazar_e_alam -e "SELECT COUNT(*) FROM $t;" 2>/dev/null | tail -1 || echo "")
    if [ -n "$CNT" ]; then
        ok "Table '$t': $CNT rows"
    else
        err "Table '$t': query failed (mysql CLI may need -p)"
    fi
done

# ---- 5. Logs ----
hdr "Logs"
[ -f logs/app.log ] && ok "logs/app.log exists ($(wc -l < logs/app.log) lines)" || warn "logs/app.log missing"
[ -f logs/error.log ] && ok "logs/error.log exists ($(wc -l < logs/error.log) lines)" || warn "logs/error.log missing"
grep -q "uvicorn.access" logs/app.log 2>/dev/null && ok "Uvicorn logs routed to app.log" || warn "No uvicorn.access in app.log (start server to test)"

# ---- 6. Backups ----
hdr "Backups"
LOCAL_COUNT=$(ls backups/nazar_e_alam_*.sql.gz 2>/dev/null | wc -l)
[ "$LOCAL_COUNT" -gt 0 ] && ok "Local DB backups: $LOCAL_COUNT" || err "No local DB backups"
LOG_COUNT=$(ls backups/nazar_logs_*.tar.gz 2>/dev/null | wc -l)
[ "$LOG_COUNT" -gt 0 ] && ok "Log archives: $LOG_COUNT" || warn "No log archives yet"
[ -x scripts/backup.sh ] && ok "scripts/backup.sh executable" || err "scripts/backup.sh not executable"
[ -x scripts/verify_backup.sh ] && ok "scripts/verify_backup.sh executable" || err "scripts/verify_backup.sh not executable"
[ -x scripts/verify_restore.py ] && ok "scripts/verify_restore.py executable" || err "scripts/verify_restore.py not executable"

# ---- 7. Nginx ----
hdr "Nginx"
if command -v nginx >/dev/null 2>&1; then
    ok "nginx installed ($(nginx -v 2>&1 | head -1))"
    [ -f /etc/nginx/conf.d/rate-limits.conf ] && ok "Rate-limit zones configured" || warn "rate-limits.conf missing — run scripts/setup-nginx.sh"
    [ -f /etc/nginx/conf.d/blocklist.conf ] && ok "Blocklist file exists" || warn "blocklist.conf missing"
    if sudo -n nginx -t >/dev/null 2>&1; then
        ok "nginx config valid"
    else
        warn "nginx config invalid or requires sudo password"
    fi
else
    warn "nginx not installed — needed for production"
fi
[ -x scripts/setup-nginx.sh ] && ok "scripts/setup-nginx.sh executable" || err "setup-nginx.sh not executable"
[ -x scripts/nginx-rules.sh ] && ok "scripts/nginx-rules.sh executable" || err "nginx-rules.sh not executable"

# ---- 8. Systemd ----
hdr "Systemd"
if [ -f /etc/systemd/system/nazar-e-alam.service ]; then
    ok "Service file installed"
    if systemctl is-active --quiet nazar-e-alam; then
        ok "Service is running"
    else
        warn "Service installed but not running (using uvicorn?)"
    fi
    if systemctl is-enabled --quiet nazar-e-alam 2>/dev/null; then
        ok "Service enabled on boot"
    else
        warn "Service not enabled on boot"
    fi
else
    warn "Service not installed — run 'sudo cp systemd/nazar-e-alam.service /etc/systemd/system/'"
fi

# ---- 9. Sync state ----
hdr "Quran audio sync"
if [ -f sync_state.json ]; then
    python -c "
import json
d = json.load(open('sync_state.json'))
done = [k for k, v in d.get('reciters', {}).items() if not v.get('interrupted')]
partial = [k for k, v in d.get('reciters', {}).items() if v.get('interrupted')]
print(f'Complete: {len(done)}')
for k in done: print(f'  ✓ {k}')
for k in partial: print(f'  ⚠ {k} (interrupted)')
" 2>/dev/null || warn "Cannot parse sync_state.json"
    PARTIAL=$(find downloads -name "*.part" 2>/dev/null | wc -l)
    [ "$PARTIAL" -gt 0 ] && warn "$PARTIAL .part file(s) in downloads — previous sync interrupted"
else
    warn "sync_state.json missing — run 'python -m tools.sync_quran'"
fi

# ---- 10. Requirements ----
hdr "Requirements"
REQ_MISSING=""
for pkg in fastapi uvicorn sqlalchemy pymysql bcrypt pyjwt python-dotenv \
           requests boto3 hijridate beautifulsoup4 alembic gunicorn uvicorn_worker; do
    python -c "import ${pkg//-/_}" 2>/dev/null || REQ_MISSING="$REQ_MISSING $pkg"
done
if [ -z "$REQ_MISSING" ]; then
    ok "All required packages importable"
else
    err "Missing packages:$REQ_MISSING"
fi

# ---- 11. Tests ----
hdr "Test suite"
if [ -x tests.sh ]; then
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q 200; then
        ok "Server responding — run ./tests.sh for full suite"
    else
        warn "Server not running — start with 'uvicorn main:app --reload'"
    fi
fi

# ---- Summary ----
echo ""
echo "═══════════════════════════════════════════════════════"
echo -e "  \033[0;32m✓ $PASS passed\033[0m   \033[0;33m⚠ $WARN warnings\033[0m   \033[0;31m✗ $FAIL failed\033[0m"
echo "═══════════════════════════════════════════════════════"
[ "$FAIL" -eq 0 ]