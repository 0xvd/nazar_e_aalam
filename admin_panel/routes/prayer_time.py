from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from database import db
from database.models import PrayerTime
from dependencies.auth import require_admin
from schemas.common import Page
from schemas.prayer_time import (
    CityInfo,
    PrayerTimeRead,
    PrayerTimeUpdate,
    SeedRequest,
    SeedResult,
)
from tools import cities
from tools.seed_prayer_times import seed_city

router = APIRouter(prefix="/prayer-times", tags=["prayer-times"])


@router.get("/cities", response_model=list[CityInfo])
def list_cities():
    return [
        CityInfo(
            key=k,
            name=v["name"],
            latitude=v["lat"],
            longitude=v["lon"],
            timezone=v["tz"],
        )
        for k, v in cities.CITIES.items()
    ]


@router.get("", response_model=Page[PrayerTimeRead])
def list_prayer_times(
    city: str | None = Query(None, max_length=50),
    from_: date | None = Query(None, alias="from"),
    to: date | None = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=400),
    session: Session = Depends(db.get_db),
):
    base = select(PrayerTime)
    if city:
        base = base.where(PrayerTime.city == city.strip().lower())
    if from_:
        base = base.where(PrayerTime.date >= from_)
    if to:
        base = base.where(PrayerTime.date <= to)

    total = session.execute(
        select(func.count()).select_from(base.subquery())
    ).scalar_one()
    rows = list(
        session.execute(base.order_by(PrayerTime.date).offset(skip).limit(limit))
        .scalars()
        .all()
    )
    return Page[PrayerTimeRead].build(
        [PrayerTimeRead.model_validate(r) for r in rows],
        total=total,
        skip=skip,
        limit=limit,
    )


@router.get("/{item_id}", response_model=PrayerTimeRead)
def get_prayer_time(item_id: int, session: Session = Depends(db.get_db)):
    row = session.get(PrayerTime, item_id)
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
    return row


@router.patch("/{item_id}", response_model=PrayerTimeRead)
def update_prayer_time(
    item_id: int,
    body: PrayerTimeUpdate,
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
):
    row = session.get(PrayerTime, item_id)
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")

    data = body.model_dump(exclude_unset=True)
    if not data:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "No fields to update")
    for field, value in data.items():
        setattr(row, field, value)
    session.commit()
    session.refresh(row)
    return row


@router.post("/seed", response_model=SeedResult)
def seed_prayer_times(
    body: SeedRequest,
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
):
    if cities.get(body.city) is None:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Unknown city '{body.city}'. See GET /prayer-times/cities for the catalogue.",
        )
    result = seed_city(
        session, body.city.lower().strip(), body.year, replace=body.replace
    )
    return SeedResult(**result)


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_prayer_time(
    item_id: int,
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
) -> None:
    row = session.get(PrayerTime, item_id)
    if row is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
    session.delete(row)
    session.commit()
