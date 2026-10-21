"""
Setting endpoints — key-value config store keyed by (name, context).

Not standard CRUD: keys are strings, not numeric IDs. All writes are
idempotent upserts (PUT), matching Laravel's settings behaviour.

Design:
  - `context` defaults to "app" (the admin panel's only context today).
  - `value` is always `str | None`. The frontend serialises structured
    data to JSON strings if needed.
  - Route order matters: `/bulk` and `/map` are declared before `/{name}`
    so they don't get captured as setting names.
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import db
from database.models import Setting
from dependencies.auth import require_admin
from schemas.setting import (
    SettingBulkResult,
    SettingBulkUpsert,
    SettingListResponse,
    SettingMapResponse,
    SettingRead,
    SettingUpsert,
)

router = APIRouter(prefix="/settings", tags=["settings"])

_CONTEXT_DEFAULT = "app"
_CONTEXT_MAX = 50
_NAME_MAX = 255


def _ctx(context: str | None) -> str:
    return (context or "").strip().lower() or _CONTEXT_DEFAULT


def _validate_name(name: str) -> str:
    n = (name or "").strip()
    if not n:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Setting name cannot be empty")
    if len(n) > _NAME_MAX:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST, f"Setting name too long (max {_NAME_MAX})"
        )
    return n


def _find(session: Session, name: str, context: str) -> Setting | None:
    return session.execute(
        select(Setting)
        .where(Setting.name == name, Setting.context == context)
        .with_for_update()
    ).scalar_one_or_none()


# --------------------------------------------------------------------------- #
#  GET /settings — list all settings for a context
# --------------------------------------------------------------------------- #

@router.get("", response_model=SettingListResponse)
def list_settings(
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
):
    ctx = _ctx(context)
    rows = list(
        session.execute(
            select(Setting).where(Setting.context == ctx).order_by(Setting.name)
        ).scalars().all()
    )
    return SettingListResponse(
        context=ctx,
        count=len(rows),
        items=[SettingRead.model_validate(r) for r in rows],
    )


# --------------------------------------------------------------------------- #
#  GET /settings/map — flat name→value map for the frontend
# --------------------------------------------------------------------------- #

@router.get("/map", response_model=SettingMapResponse)
def get_settings_map(
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
):
    ctx = _ctx(context)
    rows = list(
        session.execute(
            select(Setting).where(Setting.context == ctx)
        ).scalars().all()
    )
    return SettingMapResponse(
        context=ctx,
        count=len(rows),
        values={r.name: r.value for r in rows},
    )


# --------------------------------------------------------------------------- #
#  PUT /settings/bulk — upsert many settings at once (admin)
# --------------------------------------------------------------------------- #

@router.put("/bulk", response_model=SettingBulkResult)
def bulk_upsert_settings(
    body: SettingBulkUpsert,
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
):
    ctx = _ctx(context)
    created = updated = 0
    items: list[Setting] = []

    for raw_name, value in body.values.items():
        name = _validate_name(raw_name)
        existing = _find(session, name, ctx)
        if existing is not None:
            existing.value = value
            items.append(existing)
            updated += 1
        else:
            row = Setting(name=name, value=value, context=ctx)
            session.add(row)
            items.append(row)
            created += 1

    session.commit()
    for r in items:
        session.refresh(r)

    return SettingBulkResult(
        context=ctx,
        created=created,
        updated=updated,
        items=[SettingRead.model_validate(r) for r in items],
    )


# --------------------------------------------------------------------------- #
#  GET /settings/{name} — fetch one setting
# --------------------------------------------------------------------------- #

@router.get("/{name}", response_model=SettingRead)
def get_setting(
    name: str,
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
):
    ctx = _ctx(context)
    row = session.execute(
        select(Setting).where(Setting.name == name.strip(), Setting.context == ctx)
    ).scalar_one_or_none()
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Setting not found")
    return row


# --------------------------------------------------------------------------- #
#  PUT /settings/{name} — upsert one (200 if updated, 201 if created)
# --------------------------------------------------------------------------- #

@router.put("/{name}", response_model=SettingRead)
def upsert_setting(
    name: str,
    body: SettingUpsert,
    response: Response,
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
):
    clean_name = _validate_name(name)
    ctx = _ctx(context)
    existing = _find(session, clean_name, ctx)

    if existing is not None:
        existing.value = body.value
        session.commit()
        session.refresh(existing)
        response.status_code = status.HTTP_200_OK
        return existing

    row = Setting(name=clean_name, value=body.value, context=ctx)
    session.add(row)
    session.commit()
    session.refresh(row)
    response.status_code = status.HTTP_201_CREATED
    return row


# --------------------------------------------------------------------------- #
#  DELETE /settings/{name}
# --------------------------------------------------------------------------- #

@router.delete("/{name}", status_code=status.HTTP_204_NO_CONTENT)
def delete_setting(
    name: str,
    context: str = Query(_CONTEXT_DEFAULT, max_length=_CONTEXT_MAX),
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
) -> None:
    ctx = _ctx(context)
    row = _find(session, name.strip(), ctx)
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Setting not found")
    session.delete(row)
    session.commit()