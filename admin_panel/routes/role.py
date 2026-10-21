"""Role + permission endpoints for administrator management."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import db
from database.models import Permission, Role, User
from dependencies.auth import require_admin
from schemas.role import PermissionRead, RoleCreate, RoleRead, RoleUpdate

router = APIRouter(prefix="/roles", tags=["roles"])


@router.get("", response_model=list[RoleRead])
def list_roles(
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    rows = session.execute(select(Role).order_by(Role.id)).scalars().all()
    return [RoleRead.model_validate(r) for r in rows]


@router.post("", response_model=RoleRead, status_code=status.HTTP_201_CREATED)
def create_role(
    body: RoleCreate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    if body.alias and session.execute(
        select(Role).where(Role.alias == body.alias)
    ).scalar_one_or_none():
        raise HTTPException(status.HTTP_409_CONFLICT, "Alias already in use")
    role = Role(
        name=body.name.strip(),
        alias=(body.alias or "").strip() or None,
        is_admin=body.is_admin,
        is_default=body.is_default,
    )
    session.add(role)
    session.commit()
    session.refresh(role)
    return role


@router.patch("/{role_id}", response_model=RoleRead)
def update_role(
    role_id: int,
    body: RoleUpdate,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    role = session.get(Role, role_id)
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found")
    data = body.model_dump(exclude_unset=True)
    if not data:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "No fields")
    for k, v in data.items():
        if k in ("name", "alias") and v is not None:
            v = str(v).strip()
        setattr(role, k, v)
    session.commit()
    session.refresh(role)
    return role


@router.delete("/{role_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_role(
    role_id: int,
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    role = session.get(Role, role_id)
    if role is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Role not found")
    if role.is_default:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot delete default role")
    # Detach from users
    for u in role.users:
        u.roles.remove(role)
    session.delete(role)
    session.commit()


@router.get("/permissions", response_model=list[PermissionRead])
def list_permissions(
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
):
    rows = session.execute(select(Permission).order_by(Permission.group_name, Permission.name)).scalars().all()
    return [PermissionRead.model_validate(p) for p in rows]