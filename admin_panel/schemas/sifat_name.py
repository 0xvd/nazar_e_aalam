from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class SifatNameBase(BaseModel):
    position: int | None = None
    name: str | None = None
    ar_name: str | None = None
    translated_name: str | None = None
    meaning: str | None = None
    name_benefits: str | None = None


class SifatNameCreate(SifatNameBase):
    pass


class SifatNameUpdate(SifatNameBase):
    """All fields already default to None; router applies only sent fields."""


class SifatNameRead(SifatNameBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
