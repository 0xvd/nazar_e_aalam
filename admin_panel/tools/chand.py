from __future__ import annotations

import re
import threading
import time
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

import requests
from bs4 import BeautifulSoup
from hijridate import Gregorian
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import db
from database.models import PrayerTime, Setting

_CITY_TZ = ZoneInfo("Asia/Kolkata")
_GUJCHAND_URL = "https://gujchand.com/"
_INDIAN_CITIES = [
    "nadiad",
    "ahmedabad",
    "surat",
    "vadodara",
    "rajkot",
    "bhavnagar",
    "jamnagar",
    "gandhinagar",
    "junagadh",
    "anand",
    "mumbai",
]
_POLL_SEC = 120
_MAGHRIB_GRACE = timedelta(minutes=15)
_MAGHRIB_WINDOW = timedelta(hours=3)
_CONTEXT = "hijri_override"


def to_hijri(greg: date) -> dict:
    h = Gregorian(greg.year, greg.month, greg.day).to_hijri()

    day = h.day
    if greg.year == 2026 and greg.month == 11 and greg.day == 5:
        day = h.day - 1

    return {
        "hijri_year": h.year,
        "hijri_month": h.month,
        "hijri_day": day,
        "hijri_month_name": h.month_name(),
    }


def _key(city: str, year: int, month: int) -> str:
    return f"{city}_{year}_{month:02d}"


def get_override(session: Session, city: str, year: int, month: int) -> str | None:
    row = session.execute(
        select(Setting).where(
            Setting.context == _CONTEXT,
            Setting.name == _key(city, year, month),
        )
    ).scalar_one_or_none()
    return row.value if row else None


def save_override(
    session: Session, city: str, year: int, month: int, start_iso: str
) -> None:
    name = _key(city, year, month)
    row = session.execute(
        select(Setting).where(Setting.context == _CONTEXT, Setting.name == name)
    ).scalar_one_or_none()
    if row:
        row.value = start_iso
    else:
        session.add(Setting(name=name, value=start_iso, context=_CONTEXT))
    session.commit()


def parse_gujchand(html: str) -> dict | None:
    soup = BeautifulSoup(html, "html.parser")

    if soup.find("div", class_="coming_soon", string=True):
        return None
    footer = soup.find("div", class_="footer")
    if not footer:
        return None
    m = re.search(
        r"(\d{1,2})\s+([A-Za-z-]+)\s+(\d{4})", footer.get_text(" ", strip=True)
    )
    if not m:
        return None
    day = int(m.group(1))
    if not 1 <= day <= 30:
        return None
    return {"day": day, "year": int(m.group(3))}


def fetch_gujchand() -> dict | None:
    try:
        r = requests.get(
            _GUJCHAND_URL,
            timeout=15,
            headers={"User-Agent": "nazar-e-alam-chand/1.0"},
        )
        r.raise_for_status()
    except requests.RequestException:
        return None
    return parse_gujchand(r.text)


def _maghrib_time(session: Session, today: date) -> str | None:
    row = session.execute(
        select(PrayerTime).where(
            PrayerTime.city == "ahmedabad",
            PrayerTime.date == today,
        )
    ).scalar_one_or_none()
    return row.maghrib_start if row else None


def is_in_window(session: Session, baseline: dict, now: datetime) -> bool:
    """Only True during the 3-hour window after Maghrib on days 28-30."""
    if baseline["hijri_day"] not in (28, 29, 30):
        return False
    mg = _maghrib_time(session, now.date())
    if not mg:
        return False
    try:
        h, m = (int(x) for x in mg.split(":"))
    except ValueError:
        return False
    maghrib = now.replace(hour=h, minute=m, second=0, microsecond=0)
    return maghrib + _MAGHRIB_GRACE <= now <= maghrib + _MAGHRIB_WINDOW


def _apply_scraped(
    session: Session, baseline: dict, today: date, scraped: dict
) -> None:
    if scraped["day"] == baseline["hijri_day"]:
        return
    if scraped["day"] < baseline["hijri_day"]:
        target_month = (baseline["hijri_month"] % 12) + 1
        target_year = baseline["hijri_year"] + (1 if target_month == 1 else 0)
    else:
        target_month = baseline["hijri_month"]
        target_year = baseline["hijri_year"]
    start = today - timedelta(days=scraped["day"] - 1)
    for city in _INDIAN_CITIES:
        save_override(session, city, target_year, target_month, start.isoformat())
    print(
        f"[chand] scraper override: {target_year}-{target_month:02d} "
        f"→ {start.isoformat()}",
        flush=True,
    )


def run_cycle() -> None:
    now = datetime.now(_CITY_TZ)
    today = now.date()
    baseline = to_hijri(today)
    with db.session() as session:
        if not is_in_window(session, baseline, now):
            return
        print("[chand] in window — polling sources", flush=True)
        scraped = fetch_gujchand()
        if scraped:
            _apply_scraped(session, baseline, today, scraped)
            return
        print("[chand] no confirmation yet", flush=True)


def loop() -> None:
    print("[chand] scheduler loop started", flush=True)
    while True:
        try:
            run_cycle()
        except Exception as e:  # noqa: BLE001
            print(f"[chand] cycle error: {e}", flush=True)
        time.sleep(_POLL_SEC)


def start() -> None:
    threading.Thread(target=loop, name="chand-scheduler", daemon=True).start()


def get_effective_hijri(session: Session, city: str) -> dict:
    """
    Current Islamic date for a city.

    Returns dict with keys: hijri_year, hijri_month, hijri_day,
    hijri_month_name, gregorian_date, source, is_tentative,
    (optional) message.
    """
    now = datetime.now(_CITY_TZ)
    today = now.date()
    baseline = to_hijri(today)

    candidates = [baseline["hijri_month"], (baseline["hijri_month"] % 12) + 1]
    for m in candidates:
        y = baseline["hijri_year"] + (
            1 if m == 1 and baseline["hijri_month"] == 12 else 0
        )
        val = get_override(session, city, y, m)
        if val:
            start = date.fromisoformat(val)
            if start <= today:
                real_day = (today - start).days + 1
                if 1 <= real_day <= 30:
                    return {
                        "hijri_year": y,
                        "hijri_month": m,
                        "hijri_day": real_day,
                        "hijri_month_name": to_hijri(start)["hijri_month_name"],
                        "gregorian_date": today.isoformat(),
                        "source": "confirmed",
                        "is_tentative": False,
                    }

    if is_in_window(session, baseline, now):
        return {
            **baseline,
            "gregorian_date": today.isoformat(),
            "source": "tentative",
            "is_tentative": True,
            "message": "Awaiting moon sighting confirmation",
        }

    return {
        **baseline,
        "gregorian_date": today.isoformat(),
        "source": "baseline",
        "is_tentative": False,
    }


def force_refresh_now() -> None:
    """Ignore the schedule window and scrape immediately (admin trigger)."""
    now = datetime.now(_CITY_TZ)
    today = now.date()
    baseline = to_hijri(today)
    with db.session() as session:
        scraped = fetch_gujchand()
        if scraped:
            _apply_scraped(session, baseline, today, scraped)


if __name__ == "__main__":
    print(fetch_gujchand())
