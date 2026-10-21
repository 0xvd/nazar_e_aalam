#!/usr/bin/env bash
# =========================================================================== #
#  Nazar-e-Aalam — one-shot setup script
#
#  Usage:  sudo bash setup.sh
#
#  What it does:
#    1. Installs system packages (Python, MySQL client libs, build tools)
#    2. Creates .venv and installs Python dependencies
#    3. Copies .env.example → .env (if missing)
#    4. Prompts for missing values, then runs the Quran audio sync
# =========================================================================== #
set -euo pipefail

# ---- require root ----------------------------------------------------------
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    echo "✗ Run as root:  sudo bash setup.sh"
    exit 1
fi

REAL_USER="${SUDO_USER:-root}"
if [ "$REAL_USER" = "root" ]; then
    echo "✗ Run with sudo from your normal user (not as root directly)"
    exit 1
fi
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================"
echo "  Nazar-e-Aalam setup"
echo "  Project:  $PROJECT_DIR"
echo "  User:     $REAL_USER"
echo "============================================================"

# ---- 1. System packages ----------------------------------------------------
echo ""
echo "→ Installing system packages…"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
# ---- Detect existing DB server (never remove it) ---------------------------
HAVE_MYSQL_SERVER=""
if dpkg -l 2>/dev/null | grep -qE '^ii\s+(mariadb-server|mysql-server)'; then
    HAVE_MYSQL_SERVER="yes"
    echo "  → MySQL/MariaDB server already installed — will preserve it"
fi

apt-get update -qq

# Base packages — no DB conflicts
apt-get install -y \
    python3 python3-pip python3-venv python3-dev \
    default-libmysqlclient-dev build-essential pkg-config \
    curl git \
    | grep -E '^(Setting up|Get:|Selecting previously)' || true

# Client — pick the metapackage that matches what's already installed.
# `default-mysql-client` maps to mariadb-client on Ubuntu and never
# removes mariadb-server. NEVER install `mysql-client` directly — it
# pulls `mysql-client-8.0` which conflicts with `mariadb-server`.
if [ -n "$HAVE_MYSQL_SERVER" ]; then
    if ! command -v mysql &>/dev/null && ! command -v mariadb &>/dev/null; then
        echo "  → Installing default-mysql-client (safe for your DB server)"
        apt-get install -y default-mysql-client
    else
        echo "  → DB client already available — skipping"
    fi
else
    echo "  ⚠ No DB server detected"
    echo "    If you plan to use MySQL, install one manually:"
    echo "      sudo apt install mariadb-server    (recommended)"
    echo "      sudo apt install mysql-server      (Oracle build)"
fi

# ---- 2. Python venv --------------------------------------------------------
echo ""
echo "→ Creating Python virtual environment…"
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    sudo -u "$REAL_USER" -H bash -c "cd '$PROJECT_DIR' && python3 -m venv .venv"
    echo "✓ venv created"
else
    echo "✓ venv already exists — reusing"
fi

echo ""
echo "→ Installing Python dependencies…"
sudo -u "$REAL_USER" -H bash -c "
    cd '$PROJECT_DIR' &&
    .venv/bin/pip install --upgrade pip --quiet &&
    .venv/bin/pip install -r requirements.txt --quiet
"
echo "✓ Python dependencies installed"

# ---- 3. .env ---------------------------------------------------------------
echo ""
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo "→ Creating .env from .env.example…"
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    chown "$REAL_USER:$REAL_USER" "$PROJECT_DIR/.env"
    echo "✓ .env created — YOU MUST EDIT IT before running the server"
    echo ""
    echo "  Open in your editor:"
    echo "    nano $PROJECT_DIR/.env"
    echo ""
    echo "  At minimum, set:"
    echo "    DATABASE_URL          (MySQL connection)"
    echo "    JWT_SIGNING_KEY       (generate: python -c 'import secrets; print(secrets.token_urlsafe(64))')"
    echo "    R2_ACCOUNT_ID         (Cloudflare dashboard)"
    echo "    R2_ACCESS_KEY_ID      (R2 API token)"
    echo "    R2_SECRET_ACCESS_KEY  (R2 API token)"
    echo "    R2_BUCKET             (nazar-e-alam-audio)"
    echo "    R2_PUBLIC_BASE_URL    (https://pub-xxx.r2.dev)"
    echo ""
    read -r -p "  Press Enter once you have edited .env (or Ctrl+C to abort)…"
else
    echo "✓ .env already exists — skipping"
fi

# ---- 4. Database -----------------------------------------------------------
echo ""
echo "→ Checking database connection…"
DB_OK=$(sudo -u "$REAL_USER" -H bash -c "
    cd '$PROJECT_DIR' &&
    .venv/bin/python -c '
from config import ENV
from sqlalchemy import create_engine, text
try:
    e = create_engine(ENV.DATABASE_URL)
    with e.connect() as c:
        c.execute(text(\"SELECT 1\"))
    print(\"ok\")
except Exception as ex:
    print(f\"error: {ex}\")
' 2>&1
" || echo "error: python failed")

if echo "$DB_OK" | grep -q "^ok$"; then
    echo "✓ Database reachable"
    echo ""
    echo "→ Creating tables + seeding…"
    sudo -u "$REAL_USER" -H bash -c "
        cd '$PROJECT_DIR' &&
        .venv/bin/python -c 'from database import init_db; init_db()' &&
        .venv/bin/python -m tools.seed_chapters &&
        .venv/bin/python -m tools.seed_reciters
    " || echo "⚠ Seed failed — fix DB then rerun manually"
else
    echo "⚠ Database unreachable:"
    echo "$DB_OK" | head -3
    echo "  Fix DATABASE_URL in .env, then run:"
    echo "    source .venv/bin/activate"
    echo "    python -c 'from database import init_db; init_db()'"
fi

# ---- 5. R2 verification ----------------------------------------------------
echo ""
echo "→ Checking R2 configuration…"
R2_OK=$(sudo -u "$REAL_USER" -H bash -c "
    cd '$PROJECT_DIR' &&
    .venv/bin/python -m tools.sync_quran --test 2>&1
" || echo "error")

if echo "$R2_OK" | grep -q "Done. If all 5 checks pass"; then
    echo "✓ R2 configured and reachable"
    echo ""
    read -r -p "→ Download Quran audio now (~3 GB, 15-30 min)? [y/N] " DO_SYNC
    if [[ "$DO_SYNC" =~ ^[Yy]$ ]]; then
        echo ""
        echo "→ Starting Quran sync (Ctrl+C to pause, rerun to resume)…"
        sudo -u "$REAL_USER" -H bash -c "
            cd '$PROJECT_DIR' &&
            .venv/bin/python -m tools.sync_quran
        "
    else
        echo "  Skipped — run later with: python -m tools.sync_quran"
    fi
else
    echo "⚠ R2 not fully configured"
    echo "$R2_OK" | grep "^✗" | head -3
    echo "  Run: python -m tools.sync_quran --test  (after fixing .env)"
fi

# ---- 6. Final instructions -------------------------------------------------
echo ""
echo "============================================================"
echo "  ✅ Setup complete"
echo "============================================================"
echo ""
echo "  Next steps:"
echo "    1. cd $PROJECT_DIR"
echo "    2. source .venv/bin/activate"
echo "    3. python -m tools.sync_quran --check   # verify config"
echo "    4. uvicorn main:app --reload            # start server"
echo ""
echo "  API docs: http://localhost:8000/docs"
echo "  Health:   http://localhost:8000/health"
echo ""