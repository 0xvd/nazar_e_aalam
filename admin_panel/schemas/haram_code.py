"""HaramCode request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class HaramCodeBase(BaseModel):
    code: str | None = None
    name: str | None = None
    description: str | None = None
    status_info: str | None = None


class HaramCodeCreate(HaramCodeBase):
    pass


class HaramCodeUpdate(HaramCodeBase):
    pass


class HaramCodeRead(HaramCodeBase):
    model_config = ConfigDict(from_attributes=True)

    id: int