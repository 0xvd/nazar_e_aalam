from __future__ import annotations

from datetime import UTC, date, datetime

from fastapi import APIRouter, Depends, HTTPException, Request, status
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
    return datetime.now(UTC).replace(tzinfo=None)


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


@router.get("/config", response_model=DhikrConfig)
def get_config(session: Session = Depends(db.get_db)) -> DhikrConfig:
    today = date.today()

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


@router.post("/submit", response_model=DhikrSubmitResponse)
def submit_dhikr(
    body: DhikrSubmitRequest,
    request: Request,
    user: User = Depends(get_current_user),
    session: Session = Depends(db.get_db),
) -> DhikrSubmitResponse:

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

    device = (
        session.query(DeviceProfile).filter_by(user_id=user.id, revoked=False).first()
    )
    if user.is_admin is False and device is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your device is not registered or has been deactivated.",
        )

    campaign = session.get(DhikrCampaign, body.campaign_id)
    if campaign is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown campaign_id {body.campaign_id}.",
        )

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
