"""
Administrator (admin user) endpoints.

Custom router — not the generic factory — because of password hashing,
email uniqueness, and self-protection guards.

All routes require an authenticated admin (`require_admin`). The list
is scoped to `is_admin=True`, so promoting/demoting is done via PATCH
on a single record rather than a separate "create regular user" flow.

Self-protection:
  - an admin cannot demote themselves
  - an admin cannot delete themselves
"""
from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from database import db
from database.models import User, Role
from dependencies.auth import require_admin
from schemas.administrator import (
    AdministratorCreate,
    AdministratorRead,
    AdministratorUpdate,
)
from schemas.common import Page
from security.passwords import hash_password

router = APIRouter(prefix="/administrators", tags=["administrators"])


def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


# --------------------------------------------------------------------------- #
#  GET /administrators — paginated list
# --------------------------------------------------------------------------- #

@router.get("", response_model=Page[AdministratorRead])
def list_administrators(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=500),
    search: str | None = Query(None, max_length=200),
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
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
        session.execute(
            base.order_by(User.id).offset(skip).limit(limit)
        ).scalars().all()
    )
    return Page[AdministratorRead].build(
        [AdministratorRead.model_validate(u) for u in items],
        total=total,
        skip=skip,
        limit=limit,
    )


# --------------------------------------------------------------------------- #
#  GET /administrators/{admin_id}
# --------------------------------------------------------------------------- #

@router.get("/{admin_id}", response_model=AdministratorRead)
def get_administrator(
    admin_id: int,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    user = session.get(User, admin_id)
    if user is None:                                # ← was: user is None or not user.is_admin
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")
    return user

# --------------------------------------------------------------------------- #
#  POST /administrators — create (always admin)
# --------------------------------------------------------------------------- #

@router.post(
    "",
    response_model=AdministratorRead,
    status_code=status.HTTP_201_CREATED,
)
def create_administrator(
    body: AdministratorCreate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    if body.role_ids:
        roles = session.execute(select(Role).where(Role.id.in_(body.role_ids))).scalars().all()
        user.roles = list(roles)

    email = body.email.lower().strip()

    existing = session.execute(
        select(User).where(User.email == email)
    ).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already in use")

    user = User(
        email=email,
        password=hash_password(body.password),
        first_name=body.first_name,
        last_name=body.last_name,
        is_admin=True,
        email_verified_at=_utcnow_naive(),
    )
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


# --------------------------------------------------------------------------- #
#  PATCH /administrators/{admin_id} — partial update
# --------------------------------------------------------------------------- #

@router.patch("/{admin_id}", response_model=AdministratorRead)
def update_administrator(
    admin_id: int,
    body: AdministratorUpdate,
    current: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    
    target = session.get(User, admin_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")

    data = body.model_dump(exclude_unset=True)
    if not data:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "No fields to update")

    if body.role_ids is not None:
        roles = session.execute(select(Role).where(Role.id.in_(body.role_ids))).scalars().all()
        target.roles = list(roles)
        data.pop("role_ids", None)   # don't setattr it

    # Self-protection: cannot demote yourself
    if data.get("is_admin") is False and target.id == current.id:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "You cannot demote yourself"
        )

    # Email uniqueness (case-insensitive, excluding self)
    if "email" in data and data["email"] is not None:
        new_email = data["email"].lower().strip()
        dup = session.execute(
            select(User).where(User.email == new_email, User.id != target.id)
        ).scalar_one_or_none()
        if dup is not None:
            raise HTTPException(status.HTTP_409_CONFLICT, "Email already in use")
        data["email"] = new_email

    # Password rotation — always rehash
    if "password" in data and data["password"] is not None:
        data["password"] = hash_password(data["password"])

    for field, value in data.items():
        setattr(target, field, value)

    session.commit()
    session.refresh(target)
    return target


# --------------------------------------------------------------------------- #
#  DELETE /administrators/{admin_id}
# --------------------------------------------------------------------------- #

@router.delete("/{admin_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_administrator(
    admin_id: int,
    current: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> None:
    if admin_id == current.id:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "You cannot delete yourself"
        )
    target = session.get(User, admin_id)
    if target is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Administrator not found")

    session.delete(target)
    session.commit()