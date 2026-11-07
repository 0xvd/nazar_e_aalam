from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class AdministratorCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=128)
    first_name: str | None = Field(None, max_length=255)
    last_name: str | None = Field(None, max_length=255)
    role_ids: list[int] = Field(default_factory=list)


class AdministratorUpdate(BaseModel):
    email: EmailStr | None = None
    password: str | None = Field(None, min_length=6, max_length=128)
    first_name: str | None = Field(None, max_length=255)
    last_name: str | None = Field(None, max_length=255)
    is_admin: bool | None = None
    role_ids: list[int] | None = None


class AdministratorRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: EmailStr
    first_name: str | None = None
    last_name: str | None = None
    is_admin: bool
    email_verified_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    roles: list[RoleBrief] = []


class RoleBrief(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    alias: str | None = None
