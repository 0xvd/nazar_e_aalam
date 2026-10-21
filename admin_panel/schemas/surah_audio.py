"""Composite schemas for the Quran-audio endpoints."""
from __future__ import annotations

from pydantic import BaseModel


class ReciterMini(BaseModel):
    id: int
    slug: str
    name: str
    bitrate: str | None = None
    profile_picture: str | None = None


class SurahMeta(BaseModel):
    number: int
    arabic_name: str | None = None
    verses_count: int
    revelation_place: str | None = None
    revelation_order: str | None = None
    bismillah_pre: bool = True


class SurahAudioResponse(BaseModel):
    """Response for GET /reciters/{slug}/surah/{surah}.

    Flutter plays: f"{host}/{ayah_list[i]}" for i in 0..len(ayah_list)-1.
    `ayah_list[i]` is ayah number `i+1`.
    """

    reciter: ReciterMini
    surah: SurahMeta
    host: str
    ayah_list: list[str]


class SurahSummary(BaseModel):
    number: int
    arabic_name: str | None = None
    verses_count: int
    revelation_place: str | None = None


class SurahsListResponse(BaseModel):
    """Response for GET /reciters/{slug}/surahs — all 114 surahs, no ayahs."""

    reciter: ReciterMini
    host: str
    surahs: list[SurahSummary]