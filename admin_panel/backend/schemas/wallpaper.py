"""Wallpaper request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class WallpaperBase(BaseModel):
    name: str
    image: str


class WallpaperCreate(WallpaperBase):
    """`name` and `image` are NOT NULL in the DB, so both are required."""


class WallpaperUpdate(BaseModel):
    name: str | None = None
    image: str | None = None


class WallpaperRead(WallpaperBase):
    model_config = ConfigDict(from_attributes=True)

    id: int