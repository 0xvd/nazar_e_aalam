from __future__ import annotations

from math import ceil
from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class PageMeta(BaseModel):
    total: int
    skip: int
    limit: int
    pages: int


class Page(BaseModel, Generic[T]):
    items: list[T]
    meta: PageMeta

    @classmethod
    def build(cls, items: list[T], *, total: int, skip: int, limit: int) -> Page[T]:
        return cls(
            items=items,
            meta=PageMeta(
                total=total,
                skip=skip,
                limit=limit,
                pages=ceil(total / limit) if limit else 1,
            ),
        )
