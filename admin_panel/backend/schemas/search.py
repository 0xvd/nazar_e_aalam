"""Global search schemas."""
from __future__ import annotations
from pydantic import BaseModel


class SearchHit(BaseModel):
    type: str
    id: int
    title: str
    subtitle: str | None = None
    page: str  # nav page to jump to


class SearchResponse(BaseModel):
    query: str
    results: list[SearchHit]