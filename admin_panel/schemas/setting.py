from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class SettingRead(BaseModel):
    """A single setting row. Never exposes settingable_* — internal."""

    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    value: str | None = None
    context: str | None = None
    created_at: datetime
    updated_at: datetime


class SettingUpsert(BaseModel):
    """PUT body for one setting. Value stored as-is, may be null."""

    value: str | None = None


class SettingMapResponse(BaseModel):
    """Flat name→value map, ready for frontend consumption."""

    context: str
    count: int
    values: dict[str, str | None]


class SettingListResponse(BaseModel):
    context: str
    count: int
    items: list[SettingRead]


class SettingBulkUpsert(BaseModel):
    """PUT /settings/bulk body — upsert many settings at once."""

    values: dict[str, str | None]


class SettingBulkResult(BaseModel):
    context: str
    created: int
    updated: int
    items: list[SettingRead]
