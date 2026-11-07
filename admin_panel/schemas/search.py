from __future__ import annotations

from pydantic import BaseModel


class SearchHit(BaseModel):
    type: str
    id: int
    title: str
    subtitle: str | None = None
    page: str


class SearchResponse(BaseModel):
    query: str
    results: list[SearchHit]
