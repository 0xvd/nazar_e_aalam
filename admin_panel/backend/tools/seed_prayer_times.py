#!/usr/bin/env python3
"""
Seed prayer_times for a full year, per city.

Usage:
    python -m tools.seed_prayer_times                     # all cities, current year
    python -m tools.seed_prayer_times nadiad              # one city
    python -m tools.seed_prayer_times --year 2027         # all, specific year
    python -m tools.seed_prayer_times nadiad --year 2027 --replace

Idempotent: existing (city, date) rows are skipped unless --replace is passed.
"""
from __future__ import annotations

import sys
from datetime import date, timedelta
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from sqlalchemy import delete, select

from database import db
from database.models import PrayerTime
from tools import cities
from tools.prayer_calc import calculate


def _days_in_year(year: int) -> list[date]:
    d = date(year, 1, 1)
    out = []
    while d.year == year:
        out.append(d)
        d += timedelta(days=1)
    return out


def seed_city(session, city_key: str, year: int, replace: bool = False) -> dict:
    info = cities.get(city_key)
    if info is None:
        raise SystemExit(f"Unknown city: {city_key}. Known: {', '.join(cities.all_keys())}")

    days = _days_in_year(year)
    start, end = days[0], days[-1]

    existing = set(
        session.execute(
            select(PrayerTime.date).where(
                PrayerTime.city == city_key,
                PrayerTime.date >= start,
                PrayerTime.date <= end,
            )
        ).scalars().all()
    )

    inserted = skipped = 0
    for d in days:
        if d in existing and not replace:
            skipped += 1
            continue
        t = calculate(info["lat"], info["lon"], d, timezone_str=info["tz"])

        if d in existing and replace:
            session.execute(
                delete(PrayerTime).where(
                    PrayerTime.city == city_key, PrayerTime.date == d
                )
            )
            session.flush()

        row = PrayerTime(
            date=d,
            city=city_key,
            imsak=t["imsak"],
            fajr_start=t["fajr"],
            sunrise=t["sunrise"],
            zuhr_start=t["dhuhr"],       # Friday jummah override is applied later via PATCH
            asr_start=t["asr"],
            sunset=t["sunset"],
            maghrib_start=t["maghrib"],
            isha_start=t["isha"],
            sehri=t["imsak"],
            iftar=t["maghrib"],
        )
        session.add(row)
        inserted += 1

    session.commit()
    return {"city": city_key, "year": year, "inserted": inserted, "skipped": skipped}


def run(city_keys: list[str], year: int, replace: bool = False) -> None:
    keys = city_keys or cities.all_keys()
    print(f"Seeding prayer times for {len(keys)} cities, year {year}…")
    grand_i = grand_s = 0
    with db.session() as session:
        for i, key in enumerate(keys, 1):
            r = seed_city(session, key, year, replace=replace)
            grand_i += r["inserted"]
            grand_s += r["skipped"]
            print(f"  [{i:>2}/{len(keys)}] {key:<14} inserted {r['inserted']:>3}, skipped {r['skipped']:>3}")
    print(f"\n✓ Done. Total inserted {grand_i}, skipped {grand_s}.")


def main() -> None:
    args = sys.argv[1:]
    replace = "--replace" in args
    year = None
    keys: list[str] = []
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--year":
            year = int(args[i + 1]); i += 2; continue
        if a in ("--replace", "--all"):
            i += 1; continue
        keys.append(a); i += 1
    if year is None:
        year = date.today().year
    run(keys, year, replace=replace)


if __name__ == "__main__":
    main()