from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from database import db
from database.models import Dhikr, Dua, Reciter, Translator, User, Wallpaper
from dependencies.auth import require_admin
from schemas.search import SearchHit, SearchResponse

router = APIRouter(prefix="/search", tags=["search"])


def _hit(kind: str, id_: int, title: str, subtitle: str | None, page: str) -> SearchHit:
    return SearchHit(type=kind, id=id_, title=title, subtitle=subtitle, page=page)


@router.get("", response_model=SearchResponse)
def search(
    q: str = Query(..., min_length=1, max_length=100),
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    like = f"%{q.strip()}%"
    results: list[SearchHit] = []

    for d in session.execute(
        select(Dua)
        .where(
            or_(
                Dua.en_short_name.ilike(like),
                Dua.ar_short_name.ilike(like),
                Dua.en_full_name.ilike(like),
            )
        )
        .limit(4)
    ).scalars():
        results.append(
            _hit(
                "dua",
                d.id,
                d.en_short_name or d.ar_short_name or f"Dua #{d.id}",
                None,
                "Duas",
            )
        )

    for d in session.execute(
        select(Dhikr)
        .where(
            or_(
                Dhikr.en_short_name.ilike(like),
                Dhikr.ar_short_name.ilike(like),
                Dhikr.en_full_name.ilike(like),
            )
        )
        .limit(4)
    ).scalars():
        results.append(
            _hit(
                "dhikr",
                d.id,
                d.en_short_name or d.ar_short_name or f"Dhikr #{d.id}",
                None,
                "Dhikrs",
            )
        )

    for w in session.execute(
        select(Wallpaper).where(Wallpaper.name.ilike(like)).limit(4)
    ).scalars():
        results.append(_hit("wallpaper", w.id, w.name, None, "Wallpapers"))

    for r in session.execute(
        select(Reciter)
        .where(or_(Reciter.name.ilike(like), Reciter.slug.ilike(like)))
        .limit(4)
    ).scalars():
        results.append(_hit("reciter", r.id, r.name, r.slug, "Reciters"))

    for t in session.execute(
        select(Translator)
        .where(or_(Translator.full_name.ilike(like), Translator.short_name.ilike(like)))
        .limit(3)
    ).scalars():
        results.append(_hit("translator", t.id, t.full_name, t.language, "Translators"))

    for u in session.execute(
        select(User)
        .where(
            or_(
                User.email.ilike(like),
                User.first_name.ilike(like),
                User.last_name.ilike(like),
            )
        )
        .limit(3)
    ).scalars():
        name = f"{u.first_name or ''} {u.last_name or ''}".strip() or u.email
        results.append(_hit("admin", u.id, name, u.email, "Administrators"))

    return SearchResponse(query=q, results=results[:20])
