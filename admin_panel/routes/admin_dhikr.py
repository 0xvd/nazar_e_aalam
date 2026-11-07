"""Admin endpoints for Dhikr campaigns + submissions."""
from __future__ import annotations

from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from database import db
from database.models import DhikrCampaign, DhikrSubmission, User
from dependencies.auth import require_admin
from schemas.dhikr import (
    CampaignCreate,
    CampaignOut,
    CampaignUpdate,
    SubmissionListOut,
    SubmissionOut,
    SubmissionStatsOut,
    SubmissionStatusUpdate,
)

router = APIRouter(prefix="/admin/dhikr", tags=["admin-dhikr"])


def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


# --------------------------------------------------------------------------- #
#  Campaign CRUD
# --------------------------------------------------------------------------- #

@router.get("/campaigns", response_model=list[CampaignOut])
def list_campaigns(
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    rows = session.query(DhikrCampaign).order_by(DhikrCampaign.starts_on.desc()).all()
    return [CampaignOut.model_validate(r) for r in rows]


@router.post("/campaigns", response_model=CampaignOut, status_code=status.HTTP_201_CREATED)
def create_campaign(
    body: CampaignCreate,
    admin: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    if body.ends_on < body.starts_on:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "ends_on must be >= starts_on")

    if session.query(DhikrCampaign).filter_by(slug=body.slug).first():
        raise HTTPException(status.HTTP_409_CONFLICT, f"slug '{body.slug}' already exists")

    c = DhikrCampaign(
        title=body.title,
        description=body.description,
        slug=body.slug,
        starts_on=body.starts_on,
        ends_on=body.ends_on,
        is_active=False,
        created_by_id=admin.id,
    )
    session.add(c)
    session.commit()
    session.refresh(c)
    return CampaignOut.model_validate(c)


@router.patch("/campaigns/{campaign_id}", response_model=CampaignOut)
def update_campaign(
    campaign_id: int,
    body: CampaignUpdate,
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    c = session.get(DhikrCampaign, campaign_id)
    if c is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Campaign not found")

    data = body.model_dump(exclude_unset=True)
    if "starts_on" in data and "ends_on" in data and data["ends_on"] < data["starts_on"]:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "ends_on must be >= starts_on")

    for k, v in data.items():
        setattr(c, k, v)
    session.commit()
    session.refresh(c)
    return CampaignOut.model_validate(c)


@router.delete("/campaigns/{campaign_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_campaign(
    campaign_id: int,
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    c = session.get(DhikrCampaign, campaign_id)
    if c is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Campaign not found")

    submission_count = (
        session.query(DhikrSubmission)
        .filter_by(campaign_id=campaign_id)
        .count()
    )
    if submission_count > 0:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "code": "campaign_has_submissions",
                "message": (
                    f"This campaign has {submission_count} submission(s) "
                    f"and cannot be deleted. Disable it instead to stop new "
                    f"submissions while preserving the records."
                ),
                "submission_count": submission_count,
                "campaign_id": campaign_id,
                "suggested_action": "disable",
            },
        )
    session.delete(c)
    session.commit()

@router.post("/campaigns/{campaign_id}/toggle", response_model=CampaignOut)
def toggle_campaign(
    campaign_id: int,
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    c = session.get(DhikrCampaign, campaign_id)
    if c is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Campaign not found")
    c.is_active = not c.is_active
    session.commit()
    session.refresh(c)
    return CampaignOut.model_validate(c)


# --------------------------------------------------------------------------- #
#  Submissions
# --------------------------------------------------------------------------- #

@router.get("/campaigns/{campaign_id}/submissions", response_model=SubmissionListOut)
def list_submissions(
    campaign_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    status_filter: str | None = Query(None, pattern="^(pending|handled|rejected)$"),
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    if session.get(DhikrCampaign, campaign_id) is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Campaign not found")

    q = session.query(DhikrSubmission).filter_by(campaign_id=campaign_id)
    if status_filter:
        q = q.filter_by(status=status_filter)

    total = q.count()
    rows = (
        q.order_by(DhikrSubmission.created_at.desc())
        .offset(skip).limit(limit).all()
    )
    return SubmissionListOut(
        total=total,
        items=[SubmissionOut.model_validate(r) for r in rows],
    )


@router.get("/campaigns/{campaign_id}/stats", response_model=SubmissionStatsOut)
def campaign_stats(
    campaign_id: int,
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    c = session.get(DhikrCampaign, campaign_id)
    if c is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Campaign not found")

    base = session.query(DhikrSubmission).filter_by(campaign_id=campaign_id)
    total = base.count()
    total_dhikrs = session.query(func.coalesce(func.sum(DhikrSubmission.count), 0)) \
        .filter(DhikrSubmission.campaign_id == campaign_id).scalar()

    pending = base.filter_by(status="pending").count()
    handled = base.filter_by(status="handled").count()
    rejected = base.filter_by(status="rejected").count()

    return SubmissionStatsOut(
        campaign_id=campaign_id,
        campaign_title=c.title,
        total_submissions=total,
        total_dhikrs=int(total_dhikrs or 0),
        pending=pending,
        handled=handled,
        rejected=rejected,
    )


@router.patch("/submissions/{submission_id}", response_model=SubmissionOut)
def update_submission_status(
    submission_id: int,
    body: SubmissionStatusUpdate,
    admin: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    sub = session.get(DhikrSubmission, submission_id)
    if sub is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Submission not found")

    sub.status = body.status
    sub.admin_note = body.admin_note
    if body.status in ("handled", "rejected"):
        sub.handled_by_id = admin.id
        sub.handled_at = _utcnow_naive()
    else:
        sub.handled_by_id = None
        sub.handled_at = None
    session.commit()
    session.refresh(sub)
    return SubmissionOut.model_validate(sub)