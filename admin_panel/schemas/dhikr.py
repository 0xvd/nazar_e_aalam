"""Schemas for Dhikr campaigns + submissions."""
from __future__ import annotations

from datetime import date, datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


CampaignStatus = Literal["upcoming", "active", "past"]


# ---- Admin: campaign CRUD ----

class CampaignCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = None
    slug: str = Field(min_length=1, max_length=100, pattern=r"^[a-z0-9-]+$")
    starts_on: date
    ends_on: date


class CampaignUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=255)
    description: str | None = None
    starts_on: date | None = None
    ends_on: date | None = None
    is_active: bool | None = None


class CampaignOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    description: str | None = None
    slug: str
    starts_on: date
    ends_on: date
    is_active: bool
    created_at: datetime


# ---- Public: config API for the app ----

class PublicCampaign(BaseModel):
    """What the mobile app sees — no internal flags."""
    model_config = ConfigDict(from_attributes=True)   # ← ADD THIS

    id: int
    title: str
    slug: str
    description: str | None = None
    starts_on: date
    ends_on: date


class DhikrConfig(BaseModel):
    """
    The app calls this every 6-8 hours (cache this response).

    `active` is the campaign the app should show a banner for RIGHT NOW.
    `upcoming` is the next scheduled campaign (for pre-caching).
    `is_open` tells the app whether submissions will be accepted.
    """
    is_open: bool
    active: PublicCampaign | None = None
    upcoming: PublicCampaign | None = None
    server_time: datetime


# ---- Public: submission ----

class DhikrSubmitRequest(BaseModel):
    campaign_id: int
    full_name: str | None = Field(default=None, max_length=255)
    phone: str | None = Field(default=None, max_length=20)
    count: int = Field(ge=1, le=100_000)


class DhikrSubmitResponse(BaseModel):
    submission_id: int
    campaign_id: int
    count: int
    created_at: datetime


# ---- Admin: submission listing ----

class SubmissionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    campaign_id: int
    user_id: int
    device_uuid: str | None = None
    full_name: str | None = None
    phone: str | None = None
    count: int
    status: str
    admin_note: str | None = None
    handled_at: datetime | None = None
    created_at: datetime


class SubmissionListOut(BaseModel):
    total: int
    items: list[SubmissionOut]


class SubmissionStatsOut(BaseModel):
    campaign_id: int
    campaign_title: str
    total_submissions: int
    total_dhikrs: int
    pending: int
    handled: int
    rejected: int


class SubmissionStatusUpdate(BaseModel):
    status: Literal["pending", "handled", "rejected"]
    admin_note: str | None = None