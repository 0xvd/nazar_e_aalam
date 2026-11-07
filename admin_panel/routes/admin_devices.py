"""
Admin endpoints for viewing and revoking device registrations.
"""
from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import db
from database.models import DeviceProfile, User
from dependencies.auth import require_admin
from schemas.auth import DeviceOut

router = APIRouter(prefix="/administrators", tags=["admin-devices"])


def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


@router.get("/{user_id}/devices", response_model=list[DeviceOut])
def list_user_devices(
    user_id: int,
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
):
    rows = (
        session.query(DeviceProfile)
        .filter(DeviceProfile.user_id == user_id)
        .order_by(DeviceProfile.created_at.desc())
        .all()
    )
    return [DeviceOut.model_validate(r) for r in rows]


@router.post("/{user_id}/devices/{device_uuid}/revoke", status_code=status.HTTP_204_NO_CONTENT)
def revoke_device(
    user_id: int,
    device_uuid: str,
    _: User = Depends(require_admin),
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