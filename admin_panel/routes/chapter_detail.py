from __future__ import annotations

from database import db
from database.models import Chapter, ChapterDetail, VerseTranslation
from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from schemas.chapter import ChapterRead
from schemas.chapter_detail import (
    ChapterDetailCreate,
    ChapterDetailRead,
    ChapterDetailUpdate,
)
from schemas.chapter_verses import ChapterVersesResponse, VerseWithTranslations
from schemas.verse_translation import VerseTranslationRead
from sqlalchemy import select
from sqlalchemy.orm import Session

from routes.base_router import make_crud_router

crud_router = make_crud_router(
    model=ChapterDetail,
    prefix="/chapters/{chapter_id}/verses",
    tag="chapter-verses",
    create_schema=ChapterDetailCreate,
    update_schema=ChapterDetailUpdate,
    read_schema=ChapterDetailRead,
    order_by="verse_number",
    search_fields=("arabic_name", "english_transliteration"),
    extra_filters={"chapter_id": "chapter_id"},
)


composite_router = APIRouter(prefix="/chapters", tags=["chapter-verses"])


@composite_router.get(
    "/{chapter_id}/verses-full",
    response_model=ChapterVersesResponse,
    summary="Get all verses of a chapter with inline translations",
)
def get_verses_full(
    chapter_id: int,
    response: Response,
    translator_id: int | None = Query(
        None, description="Filter translations to a single translator"
    ),
    session: Session = Depends(db.get_db),
) -> ChapterVersesResponse:
    chapter = session.get(Chapter, chapter_id)
    if chapter is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Chapter not found")

    verse_stmt = (
        select(ChapterDetail)
        .where(ChapterDetail.chapter_id == chapter_id)
        .order_by(ChapterDetail.verse_number)
    )
    verses = list(session.execute(verse_stmt).scalars().all())

    trans_stmt = select(VerseTranslation).where(
        VerseTranslation.chapter_id == chapter_id
    )
    if translator_id is not None:
        trans_stmt = trans_stmt.where(VerseTranslation.translator_id == translator_id)
    trans_stmt = trans_stmt.order_by(VerseTranslation.verse_number)
    translations = list(session.execute(trans_stmt).scalars().all())

    by_verse: dict[int, list[VerseTranslationRead]] = {}
    for t in translations:
        by_verse.setdefault(t.chapter_detail_id, []).append(
            VerseTranslationRead.model_validate(t)
        )

    items = []
    for v in verses:
        item = VerseWithTranslations.model_validate(v)
        item.translations = by_verse.get(v.id, [])
        items.append(item)

    response.headers["Cache-Control"] = "public, max-age=300"

    return ChapterVersesResponse(
        chapter=ChapterRead.model_validate(chapter),
        total_verses=len(verses),
        verses=items,
    )
