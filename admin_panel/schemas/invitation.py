from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class InvitationCreate(BaseModel):
    email: EmailStr
    role_id: int | None = None


class InvitationAccept(BaseModel):
    token: str = Field(min_length=20)
    password: str = Field(min_length=6, max_length=128)
    first_name: str | None = Field(None, max_length=255)
    last_name: str | None = Field(None, max_length=255)


class InvitationPublic(BaseModel):
    """What the accept page sees before submitting — no PII beyond what's needed."""

    email: EmailStr
    role_name: str | None = None
    inviter_name: str | None = None
    expires_at: datetime


class InvitationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: EmailStr
    role_id: int | None = None
    role_name: str | None = None
    invited_by_id: int | None = None
    inviter_name: str | None = None
    status: Literal["pending", "accepted", "revoked", "expired"]
    expires_at: datetime
    used_at: datetime | None = None
    revoked_at: datetime | None = None
    created_at: datetime
