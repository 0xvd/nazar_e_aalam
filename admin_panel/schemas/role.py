from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class PermissionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    group_name: str


class RoleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    alias: str | None = None
    is_admin: bool
    is_default: bool
    created_at: datetime


class RoleCreate(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    alias: str | None = Field(None, max_length=100)
    is_admin: bool = True
    is_default: bool = False


class RoleUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=50)
    alias: str | None = None
    is_admin: bool | None = None
    is_default: bool | None = None
