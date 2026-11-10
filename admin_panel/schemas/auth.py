from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=10)


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    is_admin: bool


class LoginResponse(TokenPair):
    user: UserOut


class DeviceRegisterRequest(BaseModel):
    device_uuid: str = Field(min_length=8, max_length=64)
    platform: Literal["ios", "android"] | None = None
    device_model: str | None = Field(default=None, max_length=100)
    os_version: str | None = Field(default=None, max_length=50)
    app_version: str | None = Field(default=None, max_length=50)


class DeviceRegisterResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: int
    is_new_user: bool


class DeviceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    device_uuid: str
    platform: str | None = None
    device_model: str | None = None
    os_version: str | None = None
    app_version: str | None = None
    revoked: bool
    last_seen_at: datetime | None = None
    created_at: datetime


class OtpChallengeResponse(BaseModel):
    """Returned by POST /auth/login when the account has 2FA enabled."""

    challenge_token: str
    method: Literal["email_otp"] = "email_otp"
    email_hint: str
    expires_in: int
    attempts_left: int


class VerifyOtpRequest(BaseModel):
    challenge_token: str = Field(min_length=20)
    otp: str = Field(min_length=4, max_length=8)


class ResendOtpRequest(BaseModel):
    challenge_token: str = Field(min_length=20)
