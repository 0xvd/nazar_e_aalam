from __future__ import annotations

from datetime import UTC, datetime

from database import db
from database.models import Invitation, Role, User
from dependencies.auth import require_permission
from fastapi import APIRouter, Depends, HTTPException, Query, status
from schemas.administrator import (
    AdministratorCreate,
    AdministratorRead,
    AdministratorUpdate,
)
from schemas.common import Page
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

router = APIRouter(prefix="/administrators", tags=["administrators"])


def _utcnow_naive() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


def _pending_emails(session: Session, emails: list[str]) -> set[str]:
    """
    Return the subset of `emails` that currently have an unexpired,
    unaccepted, unrevoked invitation row.
    """
    if not emails:
        return set()
    rows = (
        session.execute(
            select(Invitation.email).where(
                Invitation.email.in_(emails),
                Invitation.used_at.is_(None),
                Invitation.revoked_at.is_(None),
                Invitation.expires_at > _utcnow_naive(),
            )
        )
        .scalars()
        .all()
    )
    return set(rows)


def _serialize(user: User, pending: bool) -> AdministratorRead:
    dto = AdministratorRead.model_validate(user)
    dto.has_pending_invite = pending
    return dto


@router.get("", response_model=Page[AdministratorRead])
def list_administrators(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
    search: str | None = Query(None, max_length=200),
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("administrators:read")),
):
    base = select(User).where(User.is_admin.is_(True))
    if search:
        like = f"%{search.strip()}%"
        base = base.where(
            or_(
                User.email.ilike(like),
                User.first_name.ilike(like),
                User.last_name.ilike(like),
            )
        )

    total = session.execute(
        select(func.count()).select_from(base.subquery())
    ).scalar_one()

    items = list(
        session.execute(base.order_by(User.id).offset(skip).limit(limit))
        .scalars()
        .all()
    )

    pending = _pending_emails(session, [u.email for u in items])

    return Page[AdministratorRead].build(
        [_serialize(u, u.email in pending) for u in items],
        total=total,
        skip=skip,
        limit=limit,
    )


@router.get("/{admin_id}", response_model=AdministratorRead)
def get_administrator(
    admin_id: int,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("administrators:read")),
):
    user = session.get(User, admin_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")

    pending = session.execute(
        select(Invitation).where(
            Invitation.email == user.email,
            Invitation.used_at.is_(None),
            Invitation.revoked_at.is_(None),
            Invitation.expires_at > _utcnow_naive(),
        )
    ).scalar_one_or_none()

    return _serialize(user, pending is not None)


@router.post(
    "",
    response_model=AdministratorRead,
    status_code=status.HTTP_201_CREATED,
    include_in_schema=False,
)
def create_administrator(
    body: AdministratorCreate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("administrators:write")),
):
    """Direct admin creation is disabled — use POST /admin/invitations."""
    raise HTTPException(
        status.HTTP_410_GONE,
        "Direct admin creation is disabled. Use POST /admin/invitations.",
    )


@router.patch("/{admin_id}", response_model=AdministratorRead)
def update_administrator(
    admin_id: int,
    body: AdministratorUpdate,
    current: User = Depends(require_permission("administrators:write")),
    session: Session = Depends(db.get_db),
):
    target = session.get(User, admin_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")

    data = body.model_dump(exclude_unset=True)
    if not data:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "No fields to update")

    if body.role_ids is not None:
        roles = (
            session.execute(select(Role).where(Role.id.in_(body.role_ids)))
            .scalars()
            .all()
        )
        target.roles = list(roles)
        data.pop("role_ids", None)

    if data.get("is_admin") is False and target.id == current.id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You cannot demote yourself")

    for field, value in data.items():
        setattr(target, field, value)

    session.commit()
    session.refresh(target)

    pending = session.execute(
        select(Invitation).where(
            Invitation.email == target.email,
            Invitation.used_at.is_(None),
            Invitation.revoked_at.is_(None),
            Invitation.expires_at > _utcnow_naive(),
        )
    ).scalar_one_or_none()

    return _serialize(target, pending is not None)


@router.delete("/{admin_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_administrator(
    admin_id: int,
    current: User = Depends(require_permission("administrators:write")),
    session: Session = Depends(db.get_db),
) -> None:
    if admin_id == current.id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "You cannot delete yourself")
    target = session.get(User, admin_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")

    session.delete(target)
    session.commit()
