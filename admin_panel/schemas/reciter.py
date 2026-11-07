from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class ReciterBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    position: int | None = None
    profile_picture: str | None = None
    bitrate: str | None = None


class ReciterCreate(ReciterBase):
    slug: str = Field(..., min_length=1, max_length=100, pattern=r"^[a-z0-9-]+$")
    total_ayahs: int = 6236
    base_ayah_url: str | None = None


class ReciterUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=100)
    position: int | None = None
    profile_picture: str | None = None
    bitrate: str | None = None
    base_ayah_url: str | None = None


class ReciterRead(ReciterBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    slug: str
    total_ayahs: int
    base_ayah_url: str | None = None
