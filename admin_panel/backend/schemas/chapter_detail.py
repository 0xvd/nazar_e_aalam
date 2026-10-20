"""ChapterDetail (verse) request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class ChapterDetailBase(BaseModel):
    verse_number: int = Field(..., ge=1)
    verse_key: str = Field(..., max_length=10)
    arabic_name: str
    english_transliteration: str | None = None
    hizb_number: int
    rub_el_hizb_number: int
    ruku_number: int
    manzil_number: int
    sajdah_number: int
    page_number: int
    juz_number: int


class ChapterDetailCreate(ChapterDetailBase):
    pass


class ChapterDetailUpdate(BaseModel):
    verse_number: int | None = Field(None, ge=1)
    verse_key: str | None = Field(None, max_length=10)
    arabic_name: str | None = None
    english_transliteration: str | None = None
    hizb_number: int | None = None
    rub_el_hizb_number: int | None = None
    ruku_number: int | None = None
    manzil_number: int | None = None
    sajdah_number: int | None = None
    page_number: int | None = None
    juz_number: int | None = None


class ChapterDetailRead(ChapterDetailBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    chapter_id: int