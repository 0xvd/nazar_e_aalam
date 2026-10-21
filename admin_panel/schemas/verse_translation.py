"""VerseTranslation request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class VerseTranslationBase(BaseModel):
    translator_id: int
    verse_number: int = Field(..., ge=1)
    translate_name: str


class VerseTranslationCreate(VerseTranslationBase):
    pass


class VerseTranslationUpdate(BaseModel):
    translator_id: int | None = None
    verse_number: int | None = Field(None, ge=1)
    translate_name: str | None = None


class VerseTranslationRead(VerseTranslationBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    chapter_id: int
    chapter_detail_id: int