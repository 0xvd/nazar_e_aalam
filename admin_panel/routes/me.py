from __future__ import annotations

import io
import uuid

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from config import ENV
from database import db
from database.models import Setting, User
from dependencies.auth import get_current_user
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from schemas.me import MeResponse, MeUpdate, PasswordChange, RoleBrief
from security.passwords import hash_password, verify_password
from sqlalchemy import select
from sqlalchemy.orm import Session

router = APIRouter(prefix="/me", tags=["me"])

_ALLOWED = {"image/jpeg", "image/png", "image/webp"}
_MAX_BYTES = 5 * 1024 * 1024
_EXT = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}


def _avatar_context(user_id: int) -> str:
    return f"user:{user_id}"


def _read_avatar(session: Session, user_id: int) -> str | None:
    row = session.execute(
        select(Setting).where(
            Setting.context == _avatar_context(user_id),
            Setting.name == "avatar",
        )
    ).scalar_one_or_none()
    return row.value if row else None


def _write_avatar(session: Session, user_id: int, url: str | None) -> None:
    ctx = _avatar_context(user_id)
    row = session.execute(
        select(Setting).where(Setting.context == ctx, Setting.name == "avatar")
    ).scalar_one_or_none()
    if url is None:
        if row:
            session.delete(row)
    elif row:
        row.value = url
    else:
        session.add(Setting(name="avatar", value=url, context=ctx))
    session.commit()


def _r2():
    return boto3.client(
        "s3",
        endpoint_url=f"https://{ENV.R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
        aws_access_key_id=ENV.R2_ACCESS_KEY_ID,
        aws_secret_access_key=ENV.R2_SECRET_ACCESS_KEY,
        region_name="auto",
    )


@router.get("", response_model=MeResponse)
def get_me(
    session: Session = Depends(db.get_db),
    user: User = Depends(get_current_user),
):
    return _serialize(session, user)


@router.patch("", response_model=MeResponse)
def update_me(
    body: MeUpdate,
    session: Session = Depends(db.get_db),
    user: User = Depends(get_current_user),
):
    data = body.model_dump(exclude_unset=True)

    if data.get("new_password"):
        if not data.get("current_password") or not verify_password(
            data["current_password"], user.password or ""
        ):
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST, "Current password is incorrect"
            )
        user.password = hash_password(data["new_password"])

    if data.get("email"):
        new_email = data["email"].lower().strip()
        dup = session.execute(
            select(User).where(User.email == new_email, User.id != user.id)
        ).scalar_one_or_none()
        if dup:
            raise HTTPException(status.HTTP_409_CONFLICT, "Email already in use")
        user.email = new_email

    for field in ("first_name", "last_name"):
        if field in data:
            setattr(user, field, data[field] or None)

    session.commit()
    session.refresh(user)
    return _serialize(session, user)


@router.post("/avatar", response_model=MeResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    session: Session = Depends(db.get_db),
    user: User = Depends(get_current_user),
):
    if file.content_type not in _ALLOWED:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Only JPEG, PNG, or WebP allowed (got {file.content_type})",
        )

    data = await file.read()
    if len(data) > _MAX_BYTES:
        raise HTTPException(
            status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            f"Max 5 MB (got {len(data) / 1024**2:.1f} MB)",
        )

    key = f"avatars/{user.id}-{uuid.uuid4().hex[:12]}.{_EXT[file.content_type]}"

    try:
        _r2().upload_fileobj(
            io.BytesIO(data),
            ENV.R2_BUCKET,
            key,
            ExtraArgs={
                "ContentType": file.content_type,
                "CacheControl": "public, max-age=31536000, immutable",
            },
        )
    except (BotoCoreError, ClientError) as e:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            f"R2 upload failed: {e}",
        ) from e

    base = (ENV.R2_PUBLIC_BASE_URL or "").rstrip("/")
    if not base:
        raise HTTPException(500, "R2_PUBLIC_BASE_URL not configured")

    url = f"{base}/{key}"
    _write_avatar(session, user.id, url)
    return _serialize(session, user)


@router.delete("/avatar", response_model=MeResponse)
def clear_avatar(
    session: Session = Depends(db.get_db),
    user: User = Depends(get_current_user),
):
    _write_avatar(session, user.id, None)
    return _serialize(session, user)


@router.post("/password", status_code=status.HTTP_204_NO_CONTENT)
def change_password(
    body: PasswordChange,
    session: Session = Depends(db.get_db),
    user: User = Depends(get_current_user),
) -> None:
    if not verify_password(body.current_password, user.password or ""):
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "Current password is incorrect"
        )
    if body.current_password == body.new_password:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, "New password must differ from current"
        )
    user.password = hash_password(body.new_password)
    session.commit()


def _serialize(session: Session, user: User) -> MeResponse:
    return MeResponse(
        id=user.id,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        is_admin=user.is_admin,
        avatar=_read_avatar(session, user.id),
        created_at=user.created_at,
        roles=[
            RoleBrief(
                id=r.id,
                name=r.name,
                permissions=list(r.permissions_json or []),
            )
            for r in (user.roles or [])
        ],
    )
