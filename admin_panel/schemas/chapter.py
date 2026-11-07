from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class ChapterBase(BaseModel):
    arabic_name: str = Field(..., min_length=1, max_length=255)
    verses_count: int = Field(..., ge=1)
    revelation_place: str = Field(..., max_length=255)
    revelation_order: str = Field(..., max_length=255)
    bismillah_pre: bool = True


class ChapterCreate(ChapterBase):
    pass


class ChapterUpdate(BaseModel):
    arabic_name: str | None = Field(None, min_length=1, max_length=255)
    verses_count: int | None = Field(None, ge=1)
    revelation_place: str | None = Field(None, max_length=255)
    revelation_order: str | None = Field(None, max_length=255)
    bismillah_pre: bool | None = None


class ChapterRead(ChapterBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
