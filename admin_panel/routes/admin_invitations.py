from __future__ import annotations

import hashlib
import secrets
from datetime import UTC, datetime, timedelta

from config import ENV
from database import db
from database.models import Invitation, RefreshToken, Role, User
from dependencies.auth import require_permission
from fastapi import APIRouter, Depends, HTTPException, status
from schemas.invitation import InvitationCreate, InvitationOut
from services.email_service import render_template, send_email
from sqlalchemy import select
from sqlalchemy.orm import Session

router = APIRouter(prefix="/admin/invitations", tags=["admin-invitations"])

INVITE_TTL_HOURS = 48


def _utcnow_naive() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


def _hash_token(raw: str) -> str:
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def _display_name(user: User | None) -> str:
    if user is None:
        return "An administrator"
    full = f"{user.first_name or ''} {user.last_name or ''}".strip()
    return full or user.email


def _serialize(inv: Invitation) -> InvitationOut:
    return InvitationOut(
        id=inv.id,
        email=inv.email,
        role_id=inv.role_id,
        role_name=inv.role.name if inv.role else None,
        invited_by_id=inv.invited_by_id,
        inviter_name=_display_name(inv.invited_by),
        status=inv.status,
        expires_at=inv.expires_at,
        used_at=inv.used_at,
        revoked_at=inv.revoked_at,
        created_at=inv.created_at,
    )


def _send_invite_email(inv: Invitation, raw_token: str, inviter: User) -> None:
    accept_url = (
        f"{ENV.APP_URL.rstrip('/')}/panel/pages/accept-invite.html?token={raw_token}"
    )
    html = render_template(
        "invite.html",
        inviter_name=_display_name(inviter),
        role_name=inv.role.name if inv.role else "Administrator",
        accept_url=accept_url,
    )
    try:
        send_email(
            to=inv.email,
            subject="You're invited to the Nazar-e-Aalam admin panel",
            html_body=html,
        )
    except Exception:
        pass


@router.post("", response_model=InvitationOut, status_code=status.HTTP_201_CREATED)
def create_invitation(
    body: InvitationCreate,
    session: Session = Depends(db.get_db),
    current: User = Depends(require_permission("invitations:write")),
) -> InvitationOut:
    email = body.email.lower().strip()

    exists = session.execute(
        select(User).where(User.email == email)
    ).scalar_one_or_none()
    if exists is not None:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            "This email already has an account. Use a different address.",
        )

    pending = session.execute(
        select(Invitation).where(
            Invitation.email == email,
            Invitation.used_at.is_(None),
            Invitation.revoked_at.is_(None),
            Invitation.expires_at > _utcnow_naive(),
        )
    ).scalar_one_or_none()
    if pending is not None:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            "A pending invitation already exists for this email. Resend or revoke it first.",
        )

    role = None
    if body.role_id is not None:
        role = session.get(Role, body.role_id)
        if role is None:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "Role not found")

    raw_token = secrets.token_urlsafe(32)
    inv = Invitation(
        email=email,
        token_hash=_hash_token(raw_token),
        role_id=role.id if role else None,
        invited_by_id=current.id,
        expires_at=_utcnow_naive() + timedelta(hours=INVITE_TTL_HOURS),
    )
    session.add(inv)
    session.flush()

    _send_invite_email(inv, raw_token, current)
    session.commit()
    session.refresh(inv)
    return _serialize(inv)


@router.get("", response_model=list[InvitationOut])
def list_invitations(
    status_filter: str | None = None,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("invitations:read")),
) -> list[InvitationOut]:
    stmt = select(Invitation).order_by(Invitation.id.desc())
    rows = list(session.execute(stmt).scalars().all())
    if status_filter:
        rows = [r for r in rows if r.status == status_filter]
    return [_serialize(r) for r in rows]


@router.post("/{invitation_id}/resend", response_model=InvitationOut)
def resend_invitation(
    invitation_id: int,
    session: Session = Depends(db.get_db),
    current: User = Depends(require_permission("invitations:write")),
) -> InvitationOut:
    inv = session.get(Invitation, invitation_id)
    if inv is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Invitation not found")
    if inv.status == "accepted":
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invitation already used")
    if inv.status == "revoked":
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invitation was revoked")

    raw_token = secrets.token_urlsafe(32)
    inv.token_hash = _hash_token(raw_token)
    inv.expires_at = _utcnow_naive() + timedelta(hours=INVITE_TTL_HOURS)
    _send_invite_email(inv, raw_token, current)
    session.commit()
    session.refresh(inv)
    return _serialize(inv)


@router.delete("/{invitation_id}", response_model=InvitationOut)
def revoke_invitation(
    invitation_id: int,
    session: Session = Depends(db.get_db),
    current: User = Depends(require_permission("invitations:write")),
) -> InvitationOut:
    inv = session.get(Invitation, invitation_id)
    if inv is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Invitation not found")
    if inv.status == "accepted":
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invitation already used")
    if inv.status == "revoked":
        return _serialize(inv)

    inv.revoked_at = _utcnow_naive()
    html = render_template("invite_revoked.html", email=inv.email)
    try:
        send_email(
            to=inv.email,
            subject="Your Nazar-e-Aalam admin invitation was cancelled",
            html_body=html,
        )
    except Exception:
        pass

    session.commit()
    session.refresh(inv)
    return _serialize(inv)


@router.post(
    "/reinvite/{user_id}",
    response_model=InvitationOut,
    status_code=status.HTTP_201_CREATED,
)
def reinvite_user(
    user_id: int,
    session: Session = Depends(db.get_db),
    current: User = Depends(require_permission("invitations:write")),
) -> InvitationOut:
    """
    Re-invite an existing admin. Invalidates their current refresh tokens,
    creates a fresh Invitation, and emails a new accept link.

    The admin's account itself stays intact — only their ability to be
    considered 'active' is reset until they accept the new invite and
    set a new password (or re-confirm).
    """
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
    if not user.is_admin:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Not an admin")

    session.execute(
        RefreshToken.__table__.update()
        .where(RefreshToken.user_id == user.id, RefreshToken.revoked.is_(False))
        .values(revoked=True, revoked_at=_utcnow_naive())
    )

    session.execute(
        Invitation.__table__.update()
        .where(
            Invitation.email == user.email,
            Invitation.used_at.is_(None),
            Invitation.revoked_at.is_(None),
        )
        .values(revoked_at=_utcnow_naive())
    )

    raw_token = secrets.token_urlsafe(32)
    inv = Invitation(
        email=user.email,
        token_hash=_hash_token(raw_token),
        role_id=user.roles[0].id if user.roles else None,
        invited_by_id=current.id,
        expires_at=_utcnow_naive() + timedelta(hours=INVITE_TTL_HOURS),
    )
    session.add(inv)
    session.flush()

    _send_invite_email(inv, raw_token, current)
    session.commit()
    session.refresh(inv)
    return _serialize(inv)
