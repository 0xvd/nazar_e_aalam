"""Dhikr request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class DhikrBase(BaseModel):
    position: int | None = None
    en_short_name: str | None = None
    en_full_name: str | None = None
    ar_short_name: str | None = None
    ar_full_name: str | None = None


class DhikrCreate(DhikrBase):
    pass


class DhikrUpdate(BaseModel):
    position: int | None = None
    en_short_name: str | None = None
    en_full_name: str | None = None
    ar_short_name: str | None = None
    ar_full_name: str | None = None


class DhikrRead(DhikrBase):
    model_config = ConfigDict(from_attributes=True)

    id: int