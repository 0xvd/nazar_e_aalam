from __future__ import annotations

from database import db
from database.models import Role, User
from dependencies.auth import require_permission
from fastapi import APIRouter, Depends, HTTPException, status
from schemas.role import RoleCreate, RoleRead, RoleUpdate
from sqlalchemy import func, select
from sqlalchemy.orm import Session

router = APIRouter(prefix="/roles", tags=["roles"])


VALID_PERMISSIONS = {
    "duas:read",
    "duas:write",
    "dhikrs:read",
    "dhikrs:write",
    "sifat:read",
    "sifat:write",
    "haram-codes:read",
    "haram-codes:write",
    "wallpapers:read",
    "wallpapers:write",
    "reciters:read",
    "reciters:write",
    "chapters:read",
    "chapters:write",
    "administrators:read",
    "administrators:write",
    "invitations:read",
    "invitations:write",
    "roles:read",
    "roles:write",
    "devices:read",
    "devices:write",
    "prayer-times:read",
    "prayer-times:write",
    "hijri:read",
    "hijri:write",
    "dhikr-campaigns:read",
    "dhikr-campaigns:write",
    "settings:read",
    "settings:write",
    "backup:read",
    "backup:write",
    "sync:read",
    "sync:write",
    "uploads:read",
    "uploads:write",
}


def _serialize(role: Role, user_count: int) -> RoleRead:
    return RoleRead(
        id=role.id,
        name=role.name,
        description=role.description,
        is_admin=role.is_admin,
        is_default=role.is_default,
        permissions=list(role.permissions_json or []),
        user_count=user_count,
        created_at=role.created_at,
    )


def _validate_permissions(codes: list[str]) -> list[str]:
    bad = [c for c in codes if c not in VALID_PERMISSIONS]
    if bad:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Unknown permission(s): {', '.join(bad)}",
        )

    return sorted(set(codes))


@router.get("", response_model=list[RoleRead])
def list_roles(
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("roles:read")),
):
    counts = dict(
        session.execute(
            select(Role.id, func.count(User.id)).join(Role.users).group_by(Role.id)
        ).all()
    )
    rows = session.execute(select(Role).order_by(Role.id)).scalars().all()
    return [_serialize(r, counts.get(r.id, 0)) for r in rows]


@router.post("", response_model=RoleRead, status_code=status.HTTP_201_CREATED)
def create_role(
    body: RoleCreate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("roles:write")),
):
    dup = session.execute(
        select(Role).where(Role.name == body.name.strip())
    ).scalar_one_or_none()
    if dup:
        raise HTTPException(status.HTTP_409_CONFLICT, "Role name already in use")

    perms = _validate_permissions(body.permissions)
    role = Role(
        name=body.name.strip(),
        description=(body.description or "").strip() or None,
        permissions_json=perms,
        is_admin=body.is_admin,
        is_default=body.is_default,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    return _serialize(role, 0)


@router.patch("/{role_id}", response_model=RoleRead)
def update_role(
    role_id: int,
    body: RoleUpdate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("roles:write")),
):
    role = session.get(Role, role_id)
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found")

    data = body.model_dump(exclude_unset=True)

    if "name" in data and data["name"] is not None:
        new_name = data["name"].strip()
        dup = session.execute(
            select(Role).where(Role.name == new_name, Role.id != role.id)
        ).scalar_one_or_none()
        if dup:
            raise HTTPException(status.HTTP_409_CONFLICT, "Role name already in use")
        role.name = new_name

    if "description" in data:
        role.description = (data["description"] or "").strip() or None

    if "permissions" in data and data["permissions"] is not None:
        role.permissions_json = _validate_permissions(data["permissions"])

    if "is_admin" in data and data["is_admin"] is not None:
        role.is_admin = data["is_admin"]
    if "is_default" in data and data["is_default"] is not None:
        role.is_default = data["is_default"]

    session.commit()
    session.refresh(role)
    return _serialize(role, len(role.users))


@router.delete("/{role_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_role(
    role_id: int,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_permission("roles:write")),
):
    role = session.get(Role, role_id)
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found")
    if role.is_default:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot delete default role")
    for u in list(role.users):
        u.roles.remove(role)
    session.delete(role)
    session.commit()


@router.get("/permissions/catalog")
def permission_catalog(_: User = Depends(require_permission("roles:read"))) -> dict:
    """Everything the panel can gate on. Grouped for the UI."""
    groups: dict[str, list[str]] = {}
    for code in sorted(VALID_PERMISSIONS):
        group = code.split(":", 1)[0]
        groups.setdefault(group, []).append(code)
    return {"groups": groups, "all": sorted(VALID_PERMISSIONS)}
