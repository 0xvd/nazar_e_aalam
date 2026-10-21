"""Composite response for GET /chapters/{n}/verses-full."""
from __future__ import annotations

from pydantic import BaseModel

from schemas.chapter import ChapterRead
from schemas.chapter_detail import ChapterDetailRead
from schemas.verse_translation import VerseTranslationRead


class VerseWithTranslations(ChapterDetailRead):
    """A single verse with every translation inlined."""

    translations: list[VerseTranslationRead] = []


class ChapterVersesResponse(BaseModel):
    chapter: ChapterRead
    total_verses: int
    verses: list[VerseWithTranslations]