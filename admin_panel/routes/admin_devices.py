from __future__ import annotations

from datetime import UTC, datetime

from database import db
from database.models import DeviceProfile, User
from dependencies.auth import require_permission
from fastapi import APIRouter, Depends, HTTPException, status
from schemas.auth import DeviceOut
from sqlalchemy.orm import Session

router = APIRouter(prefix="/administrators", tags=["admin-devices"])


def _utcnow_naive() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


@router.get("/{user_id}/devices", response_model=list[DeviceOut])
def list_user_devices(
    user_id: int,
    _: User = Depends(require_permission("devices:read")),
    session: Session = Depends(db.get_db),
):

    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    rows = (
        session.query(DeviceProfile)
        .filter(DeviceProfile.user_id == user_id)
        .order_by(DeviceProfile.created_at.desc())
        .all()
    )
    return [DeviceOut.model_validate(r) for r in rows]


@router.post(
    "/{user_id}/devices/{device_uuid}/revoke",
    status_code=status.HTTP_204_NO_CONTENT,
)
def revoke_device(
    user_id: int,
    device_uuid: str,
    _: User = Depends(require_permission("devices:write")),
    session: Session = Depends(db.get_db),
) -> None:
    profile = (
        session.query(DeviceProfile)
        .filter_by(user_id=user_id, device_uuid=device_uuid)
        .one_or_none()
    )
    if profile is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Device not found")
    if profile.revoked:
        return
    profile.revoked = True
    profile.revoked_at = _utcnow_naive()
    session.commit()
