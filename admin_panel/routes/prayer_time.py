from __future__ import annotations

from datetime import date as date_cls

from database import db
from database.models import PrayerTime, PrayerTimeCache
from dependencies.auth import require_admin
from fastapi import APIRouter, Depends, HTTPException, Query, status
from schemas.common import Page
from schemas.prayer_time import (
    AutoSeedRequest,
    AutoSeedResponse,
    CityInfo,
    PrayerTimeRead,
    PrayerTimeUpdate,
    SeedRequest,
    SeedResult,
)
from sqlalchemy import func, select
from sqlalchemy.orm import Session
from tools import cities
from tools.prayer_calc import calculate as calculate_prayer_times
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


@router.get("/for-location")
def prayer_times_for_location(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    date_str: str | None = Query(None, alias="date", pattern=r"^\d{4}-\d{2}-\d{2}$"),
    session: Session = Depends(db.get_db),
):
    """
    Prayer times for arbitrary coordinates, computed locally.
    """
    target = date_cls.fromisoformat(date_str) if date_str else date_cls.today()

    nearest = cities.nearest(lat, lon)
    if nearest and nearest[1] <= 25.0:
        city_key, _dist_km = nearest
        row = session.execute(
            select(PrayerTime).where(
                PrayerTime.city == city_key,
                PrayerTime.date == target,
            )
        ).scalar_one_or_none()
        if row is not None:
            return {
                "lat": lat,
                "lon": lon,
                "date": row.date.isoformat(),
                "city": row.city,
                "city_name": cities.get(row.city)["name"]
                if cities.get(row.city)
                else row.city,
                "source": "curated",
                "cached": False,
                "is_friday": row.is_friday,
                "timings": {
                    "imsak": row.imsak,
                    "fajr": row.fajr_start,
                    "sunrise": row.sunrise,
                    "dhuhr": row.zuhr_start,
                    "asr": row.asr_start,
                    "sunset": row.sunset,
                    "maghrib": row.maghrib_start,
                    "isha": row.isha_start,
                },
            }

    grid_lat, grid_lon = round(lat, 3), round(lon, 3)

    cached = session.execute(
        select(PrayerTimeCache).where(
            PrayerTimeCache.lat_grid == grid_lat,
            PrayerTimeCache.lon_grid == grid_lon,
            PrayerTimeCache.date == target,
        )
    ).scalar_one_or_none()

    if cached is not None:
        return {
            "lat": lat,
            "lon": lon,
            "date": cached.date.isoformat(),
            "city": cached.nearest_city,
            "city_name": (
                cities.get(cached.nearest_city)["name"]
                if cached.nearest_city and cities.get(cached.nearest_city)
                else cached.nearest_city
            ),
            "source": "computed",
            "cached": True,
            "is_friday": cached.is_friday,
            "timings": {
                "imsak": cached.imsak,
                "fajr": cached.fajr_start,
                "sunrise": cached.sunrise,
                "dhuhr": cached.zuhr_start,
                "asr": cached.asr_start,
                "sunset": cached.sunset,
                "maghrib": cached.maghrib_start,
                "isha": cached.isha_start,
            },
        }

    if nearest and nearest[1] <= 100.0:
        tz_str = (cities.get(nearest[0]) or {}).get("tz", "UTC")
        city_hint = nearest[0]
    else:
        tz_str = "UTC"
        city_hint = None

    t = calculate_prayer_times(lat, lon, target, timezone_str=tz_str)

    row = PrayerTimeCache(
        lat_grid=grid_lat,
        lon_grid=grid_lon,
        date=target,
        nearest_city=city_hint,
        timezone=tz_str,
        imsak=t["imsak"],
        fajr_start=t["fajr"],
        sunrise=t["sunrise"],
        zuhr_start=t["dhuhr"],
        asr_start=t["asr"],
        sunset=t["sunset"],
        maghrib_start=t["maghrib"],
        isha_start=t["isha"],
        is_friday=t["is_friday"],
    )
    session.add(row)
    session.commit()
    session.refresh(row)

    return {
        "lat": lat,
        "lon": lon,
        "date": row.date.isoformat(),
        "city": city_hint,
        "city_name": cities.get(city_hint)["name"]
        if city_hint and cities.get(city_hint)
        else city_hint,
        "source": "computed",
        "cached": False,
        "is_friday": row.is_friday,
        "timings": {
            "imsak": row.imsak,
            "fajr": row.fajr_start,
            "sunrise": row.sunrise,
            "dhuhr": row.zuhr_start,
            "asr": row.asr_start,
            "sunset": row.sunset,
            "maghrib": row.maghrib_start,
            "isha": row.isha_start,
        },
    }


@router.get("", response_model=Page[PrayerTimeRead])
def list_prayer_times(
    city: str | None = Query(None, max_length=50),
    from_: date_cls | None = Query(None, alias="from"),
    to: date_cls | None = Query(None),
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


@router.post("/auto-seed", response_model=AutoSeedResponse)
def auto_seed_city(
    body: AutoSeedRequest,
    session: Session = Depends(db.get_db),
    _=Depends(require_admin),
):
    """
    Create (or refresh) a PrayerTime row for an arbitrary city.
    Called from the admin panel when a non-curated city is detected.
    """
    from datetime import timedelta

    city_key = body.name.lower().strip()
    today = date_cls.today()
    inserted = 0
    skipped = 0

    for i in range(365):
        d = today + timedelta(days=i)
        existing = session.query(PrayerTime).filter_by(city=city_key, date=d).first()
        if existing:
            skipped += 1
            continue

        t = calculate_prayer_times(body.lat, body.lon, d, timezone_str=body.tz)
        session.add(
            PrayerTime(
                date=d,
                city=city_key,
                imsak=t["imsak"],
                fajr_start=t["fajr"],
                sunrise=t["sunrise"],
                zuhr_start=t["dhuhr"],
                asr_start=t["asr"],
                sunset=t["sunset"],
                maghrib_start=t["maghrib"],
                isha_start=t["isha"],
                is_friday=t["is_friday"],
            )
        )
        inserted += 1

    session.commit()
    return AutoSeedResponse(city=city_key, inserted=inserted)


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
