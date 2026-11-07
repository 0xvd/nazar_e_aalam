from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, EmailStr, Field


class MeResponse(BaseModel):
    id: int
    email: EmailStr
    first_name: str | None = None
    last_name: str | None = None
    is_admin: bool
    avatar: str | None = None
    created_at: datetime


class MeUpdate(BaseModel):
    first_name: str | None = Field(None, max_length=255)
    last_name: str | None = Field(None, max_length=255)
    email: EmailStr | None = None
    current_password: str | None = None
    new_password: str | None = Field(None, min_length=6, max_length=128)


class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(min_length=6, max_length=128)
