"""
Reciter endpoints.

CRUD via the generic factory — GET/POST/PATCH/DELETE /reciters.

Plus two audio endpoints designed for the Flutter app:

  GET /reciters/{slug}/surah/{surah}   → host + ayah_list for one surah
  GET /reciters/{slug}/surahs          → host + all 114 surahs (no ayahs)

Flutter builds play URLs as:  f"{host}/{ayah_list[i]}"
"""
from __future__ import annotations

from fastapi import Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from config import ENV
from database import db
from database.models import Chapter, Reciter
from routes.base_router import make_crud_router
from schemas.reciter import ReciterCreate, ReciterRead, ReciterUpdate
from schemas.surah_audio import (
    ReciterMini,
    SurahAudioResponse,
    SurahMeta,
    SurahSummary,
    SurahsListResponse,
)
from tools.sync_quran import AYAH_COUNTS

# --------------------------------------------------------------------------- #
#  Standard CRUD
# --------------------------------------------------------------------------- #

router = make_crud_router(
    model=Reciter,
    prefix="/reciters",
    tag="reciters",
    create_schema=ReciterCreate,
    update_schema=ReciterUpdate,
    read_schema=ReciterRead,
    order_by="position",
    search_fields=("name", "slug"),
)


# --------------------------------------------------------------------------- #
#  Helpers
# --------------------------------------------------------------------------- #

def _require_reciter(session: Session, slug: str) -> Reciter:
    rec = session.execute(
        select(Reciter).where(Reciter.slug == slug)
    ).scalar_one_or_none()
    if rec is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND, f"Reciter '{slug}' not found"
        )
    return rec


def _check_surah(surah: int) -> int:
    if not 1 <= surah <= 114:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Surah must be between 1 and 114 (got {surah})",
        )
    return surah


def _chapter(session: Session, surah: int) -> Chapter | None:
    return session.execute(
        select(Chapter).where(Chapter.id == surah)
    ).scalar_one_or_none()


def _reciter_mini(rec: Reciter) -> ReciterMini:
    return ReciterMini(
        id=rec.id,
        slug=rec.slug,
        name=rec.name,
        bitrate=rec.bitrate,
        profile_picture=rec.profile_picture,
    )


def _host() -> str:
    """R2 public base — must not have a trailing slash."""
    host = (ENV.R2_PUBLIC_BASE_URL or "").rstrip("/")
    if not host:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "Audio host is not configured (R2_PUBLIC_BASE_URL missing)",
        )
    return host


# --------------------------------------------------------------------------- #
#  GET /reciters/{slug}/surah/{surah}
# --------------------------------------------------------------------------- #

@router.get(
    "/{slug}/surah/{surah}",
    response_model=SurahAudioResponse,
    summary="Get every ayah path for one surah of a reciter",
)
def get_surah_audio(
    slug: str,
    surah: int,
    response: Response,
    session: Session = Depends(db.get_db),
) -> SurahAudioResponse:
    _check_surah(surah)
    rec = _require_reciter(session, slug)
    ch = _chapter(session, surah)

    count = AYAH_COUNTS[surah - 1]
    prefix = f"reciters/{rec.slug}/ayahs/"
    ayah_list = [
        f"{prefix}{surah:03d}{ayah:03d}.mp3"
        for ayah in range(1, count + 1)
    ]

    # Content is effectively static → safe to cache at CDN / client for 1 day.
    response.headers["Cache-Control"] = "public, max-age=86400"

    return SurahAudioResponse(
        reciter=_reciter_mini(rec),
        surah=SurahMeta(
            number=surah,
            arabic_name=ch.arabic_name if ch else None,
            verses_count=count,
            revelation_place=ch.revelation_place if ch else None,
            revelation_order=ch.revelation_order if ch else None,
            bismillah_pre=ch.bismillah_pre if ch else True,
        ),
        host=_host(),
        ayah_list=ayah_list,
    )


# --------------------------------------------------------------------------- #
#  GET /reciters/{slug}/surahs
# --------------------------------------------------------------------------- #

@router.get(
    "/{slug}/surahs",
    response_model=SurahsListResponse,
    summary="List all 114 surahs for a reciter (no ayahs)",
)
def list_surahs_for_reciter(
    slug: str,
    response: Response,
    session: Session = Depends(db.get_db),
) -> SurahsListResponse:
    rec = _require_reciter(session, slug)

    chapters_by_id = {
        c.id: c
        for c in session.execute(select(Chapter)).scalars().all()
    }

    surahs = [
        SurahSummary(
            number=n,
            arabic_name=(
                chapters_by_id[n].arabic_name if n in chapters_by_id else None
            ),
            verses_count=AYAH_COUNTS[n - 1],
            revelation_place=(
                chapters_by_id[n].revelation_place
                if n in chapters_by_id else None
            ),
        )
        for n in range(1, 115)
    ]

    response.headers["Cache-Control"] = "public, max-age=86400"

    return SurahsListResponse(
        reciter=_reciter_mini(rec),
        host=_host(),
        surahs=surahs,
    )