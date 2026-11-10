from __future__ import annotations

from config import ENV
from database import db
from database.models import User
from dependencies.auth import require_admin
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

router = APIRouter(prefix="/debug", tags=["debug"])


@router.get("/env")
def dump_env(_: User = Depends(require_admin)) -> dict:
    """All config, with secrets masked. Same as ENV.dump(safe=True)."""
    return ENV.dump(safe=True)


@router.get("/routes")
def list_routes(_: User = Depends(require_admin)) -> dict:
    """All registered routes — useful when you're not sure if a router loaded."""
    from main import app

    out = []
    for r in app.routes:
        if hasattr(r, "methods"):
            for m in sorted(r.methods):
                out.append({"method": m, "path": r.path})
    return {"count": len(out), "routes": out}


@router.get("/db")
def db_snapshot(
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> dict:
    """Row counts across the schema — quick sanity after seeding/importing."""
    tables = [
        "users",
        "refresh_tokens",
        "roles",
        "permissions",
        "duas",
        "dhikrs",
        "wallpapers",
        "sifat_names",
        "haram_codes",
        "translators",
        "chapters",
        "chapter_translations",
        "chapter_details",
        "verse_translations",
        "settings",
        "prayer_times",
        "reciters",
        "reciter_suras",
        "bulk_sura_imports",
        "invitations",
        "otp_challenges",
    ]
    counts: dict[str, int | str] = {}
    for t in tables:
        try:
            n = session.execute(text(f"SELECT COUNT(*) FROM {t}")).scalar()
            counts[t] = n
        except Exception as e:  # noqa: BLE001
            counts[t] = f"ERR: {type(e).__name__}"
    return {"tables": counts}


@router.get("/ping")
def ping() -> dict:
    return {"pong": True, "env": ENV.APP_ENV}


@router.get("/peek-otp")
def peek_otp(email: str) -> dict:
    """
    DEV-ONLY. Returns the plaintext OTP for `email` from the process-local
    cache populated by `routes.auth._issue_otp` / `resend_otp`.

    Why in-memory and not the DB? The `OtpChallenge.otp_hash` column stores
    only SHA-256(otp) — it's designed to be unrecoverable. The `_LAST_OTP`
    cache is a dev-only affordance so tests can complete the real flow
    end-to-end without needing to open the actual email.

    Not registered in production (main.py gates /debug behind ENV.is_debug()).
    """
    from routes.auth import _LAST_OTP

    key = email.lower().strip()
    otp = _LAST_OTP.get(key)
    return {"otp": otp, "exists": otp is not None}
