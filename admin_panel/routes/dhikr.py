"""
Dhikr campaign config + submission endpoints.

Public:
  GET  /dhikr/config             — what the app calls every 6-8h
  POST /dhikr/submit             — submit dhikrs for the current campaign
"""
from __future__ import annotations

from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy import and_, or_
from sqlalchemy.orm import Session

from cache import rate_limiter
from config import ENV
from database import db
from database.models import DeviceProfile, DhikrCampaign, DhikrSubmission, User
from dependencies.auth import get_current_user
from schemas.dhikr import (
    DhikrConfig,
    DhikrSubmitRequest,
    DhikrSubmitResponse,
    PublicCampaign,
)

router = APIRouter(prefix="/dhikr", tags=["dhikr"])


def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _client_ip(request: Request) -> str:
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def _campaign_state(c: DhikrCampaign, today: date) -> str:
    if today < c.starts_on:
        return "upcoming"
    if today > c.ends_on:
        return "past"
    return "active"


# --------------------------------------------------------------------------- #
#  GET /dhikr/config
# --------------------------------------------------------------------------- #

@router.get("/config", response_model=DhikrConfig)
def get_config(session: Session = Depends(db.get_db)) -> DhikrConfig:
    today = date.today()

    # Active campaign: is_active=True AND today within [starts_on, ends_on]
    active = (
        session.query(DhikrCampaign)
        .filter(
            DhikrCampaign.is_active.is_(True),
            DhikrCampaign.starts_on <= today,
            DhikrCampaign.ends_on >= today,
        )
        .order_by(DhikrCampaign.starts_on.desc())
        .first()
    )

    # Upcoming: nearest future campaign that is is_active=True
    upcoming = (
        session.query(DhikrCampaign)
        .filter(
            DhikrCampaign.is_active.is_(True),
            DhikrCampaign.starts_on > today,
        )
        .order_by(DhikrCampaign.starts_on.asc())
        .first()
    )

    return DhikrConfig(
        is_open=active is not None,
        active=PublicCampaign.model_validate(active) if active else None,
        upcoming=PublicCampaign.model_validate(upcoming) if upcoming else None,
        server_time=_utcnow_naive(),
    )


# --------------------------------------------------------------------------- #
#  POST /dhikr/submit
# --------------------------------------------------------------------------- #

@router.post("/submit", response_model=DhikrSubmitResponse)
def submit_dhikr(
    body: DhikrSubmitRequest,
    request: Request,
    user: User = Depends(get_current_user),
    session: Session = Depends(db.get_db),
) -> DhikrSubmitResponse:
    # ---- Rate limit: prevent spam (5 submissions/min/ip) ----
    if ENV.RATE_LIMIT_ENABLED:
        allowed, _ = rate_limiter.hit(
            f"dhikr-submit:{_client_ip(request)}",
            limit=5,
            window=60,
        )
        if not allowed:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many submissions. Please wait.",
            )

    # ---- Verify device not revoked ----
    device = (
        session.query(DeviceProfile)
        .filter_by(user_id=user.id, revoked=False)
        .first()
    )
    if user.is_admin is False and device is None:
        # Guest without an active device — block
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your device is not registered or has been deactivated.",
        )

    # ---- Look up campaign ----
    campaign = session.get(DhikrCampaign, body.campaign_id)
    if campaign is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown campaign_id {body.campaign_id}.",
        )

    # ---- Campaign must be open right now ----
    today = date.today()
    if not campaign.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This Dhikr campaign is not currently active.",
        )
    if not (campaign.starts_on <= today <= campaign.ends_on):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"Dhikr campaign is not open today "
                f"(opens {campaign.starts_on}, closes {campaign.ends_on})."
            ),
        )

    # ---- Persist ----
    sub = DhikrSubmission(
        campaign_id=campaign.id,
        user_id=user.id,
        device_uuid=device.device_uuid if device else None,
        full_name=(body.full_name or "").strip() or None,
        phone=(body.phone or "").strip() or None,
        count=body.count,
    )
    session.add(sub)
    session.commit()
    session.refresh(sub)

    return DhikrSubmitResponse(
        submission_id=sub.id,
        campaign_id=sub.campaign_id,
        count=sub.count,
        created_at=sub.created_at,
    )