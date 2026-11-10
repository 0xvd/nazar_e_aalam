from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class RoleRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    description: str | None = None
    is_admin: bool = False
    is_default: bool = False
    permissions: list[str] = []
    user_count: int = 0
    created_at: datetime


class RoleCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    description: str | None = Field(None, max_length=255)
    permissions: list[str] = Field(default_factory=list)
    is_admin: bool = False
    is_default: bool = False


class RoleUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=50)
    description: str | None = Field(None, max_length=255)
    permissions: list[str] | None = None
    is_admin: bool | None = None
    is_default: bool | None = None


class PermissionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    group_name: str
