"""
Dev-only introspection endpoints. Not registered in staging/production.
"""
from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from config import ENV
from database import db
from database.models import User
from dependencies.auth import require_admin

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
        "users", "refresh_tokens", "roles", "permissions",
        "duas", "dhikrs", "wallpapers", "sifat_names", "haram_codes",
        "translators", "chapters", "chapter_translations",
        "chapter_details", "verse_translations",
        "settings", "prayer_times",
        "reciters", "reciter_suras", "bulk_sura_imports",
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