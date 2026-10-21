"""
Alembic runtime helpers.

- `current_revision()` / `head_revision()` — read via alembic API
- `is_up_to_date()` — True if DB matches the latest migration
- `assert_up_to_date()` — raises if not (called from prod lifespan)

Does NOT run `upgrade` — that happens via systemd ExecStartPre before the
app starts. Running it inside 4 gunicorn workers would race.
"""
from __future__ import annotations

from pathlib import Path

from alembic.config import Config
from alembic.script import ScriptDirectory
from sqlalchemy import text

from config import ENV
from database import db

_ROOT = Path(__file__).resolve().parent.parent


def _config() -> Config:
    cfg = Config(str(_ROOT / "alembic.ini"))
    cfg.set_main_option("sqlalchemy.url", ENV.DATABASE_URL)
    return cfg


def head_revision() -> str | None:
    """Latest revision defined in alembic/versions/."""
    script = ScriptDirectory.from_config(_config())
    return script.get_current_head()


def current_revision() -> str | None:
    """Revision currently applied to the DB."""
    try:
        with db.engine.connect() as conn:
            row = conn.execute(
                text("SELECT version_num FROM alembic_version LIMIT 1")
            ).first()
            return row[0] if row else None
    except Exception:
        return None


def is_up_to_date() -> bool:
    return current_revision() == head_revision()


def assert_up_to_date() -> None:
    """Prod startup: fail fast if migrations are pending."""
    current = current_revision()
    head = head_revision()
    if current == head:
        return
    raise RuntimeError(
        f"\n"
        f"  ✗ Database schema is out of sync with migrations.\n"
        f"      Current: {current or '(none)'}\n"
        f"      Head:    {head}\n\n"
        f"  Fix before starting:\n"
        f"      alembic upgrade head\n"
    )


def status_line() -> str:
    """One-line summary for logging."""
    cur = current_revision() or "(none)"
    head = head_revision() or "(none)"
    marker = "✓" if cur == head else "⚠"
    return f"{marker} schema revision: current={cur} head={head}"