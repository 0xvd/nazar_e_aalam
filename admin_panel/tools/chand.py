from __future__ import annotations

import re
import threading
import time
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

import requests
from bs4 import BeautifulSoup
from database import db
from database.models import PrayerTime, Setting
from hijridate import Gregorian
from sqlalchemy import select
from sqlalchemy.orm import Session

_CITY_TZ = ZoneInfo("Asia/Kolkata")
_GUJCHAND_URL = "https://gujchand.com/"
_INDIAN_CITIES = [
    "nadiad", "ahmedabad", "surat", "vadodara", "rajkot", "bhavnagar",
    "jamnagar", "gandhinagar", "junagadh", "anand", "mumbai",
]
_POLL_SEC = 120
_MAGHRIB_GRACE = timedelta(minutes=15)
_MAGHRIB_WINDOW = timedelta(hours=6)   # was 3h — too short, missed late announcements
_FALLBACK_MAGHRIB_HOUR = 18
_FALLBACK_MAGHRIB_MIN = 30
_CONTEXT = "hijri_override"


# ─────────────────────────────── helpers ────────────────────────────────

def to_hijri(greg: date) -> dict:
    h = Gregorian(greg.year, greg.month, greg.day).to_hijri()
    return {
        "hijri_year": h.year,
        "hijri_month": h.month,
        "hijri_day": h.day,
        "hijri_month_name": h.month_name(),
    }


def _next_hijri_month(year: int, month: int) -> tuple[int, int]:
    return (year + 1, 1) if month == 12 else (year, month + 1)


def _prev_hijri_month(year: int, month: int) -> tuple[int, int]:
    return (year - 1, 12) if month == 1 else (year, month - 1)


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


def save_override(session: Session, city: str, year: int, month: int, start_iso: str) -> None:
    name = _key(city, year, month)
    row = session.execute(
        select(Setting).where(Setting.context == _CONTEXT, Setting.name == name)
    ).scalar_one_or_none()
    if row:
        row.value = start_iso
    else:
        session.add(Setting(name=name, value=start_iso, context=_CONTEXT))
    session.commit()


# ─────────────────────────── Maghrib detection ─────────────────────────

def _maghrib_dt(session: Session, now: datetime) -> datetime:
    """When is Maghrib today? Never returns None — falls back to 18:30."""
    row = session.execute(
        select(PrayerTime).where(
            PrayerTime.city == "ahmedabad",
            PrayerTime.date == now.date(),
        )
    ).scalar_one_or_none()
    h, m = _FALLBACK_MAGHRIB_HOUR, _FALLBACK_MAGHRIB_MIN
    if row and row.maghrib_start:
        try:
            h, m = (int(x) for x in row.maghrib_start.split(":"))
        except ValueError:
            pass
    return now.replace(hour=h, minute=m, second=0, microsecond=0)


def is_after_maghrib(session: Session, now: datetime) -> bool:
    return now >= _maghrib_dt(session, now)


def is_in_window(session: Session, baseline: dict, now: datetime) -> bool:
    """Scraper window: post-Maghrib on days 28-30, extended to 6h."""
    if baseline["hijri_day"] not in (28, 29, 30):
        return False
    mg = _maghrib_dt(session, now)
    return mg + _MAGHRIB_GRACE <= now <= mg + _MAGHRIB_WINDOW


# ───────────────────────────── scraper ──────────────────────────────────

def parse_gujchand(html: str) -> dict | None:
    soup = BeautifulSoup(html, "html.parser")
    if soup.find("div", class_="coming_soon", string=True):
        return None
    footer = soup.find("div", class_="footer")
    if not footer:
        return None
    m = re.search(r"(\d{1,2})\s+([A-Za-z-]+)\s+(\d{4})", footer.get_text(" ", strip=True))
    if not m:
        return None
    day = int(m.group(1))
    if not 1 <= day <= 30:
        return None
    return {"day": day, "year": int(m.group(3))}


def fetch_gujchand() -> dict | None:
    try:
        r = requests.get(
            _GUJCHAND_URL, timeout=15,
            headers={"User-Agent": "nazar-e-alam-chand/1.0"},
        )
        r.raise_for_status()
    except requests.RequestException:
        return None
    return parse_gujchand(r.text)


# ─────────────── the ONE rule: pick the effective hijri day ─────────────

def _effective_date(session: Session, now: datetime) -> tuple[date, bool]:
    return now.date(), False


def resolve_hijri(session: Session, city: str, effective: date) -> dict:
    """
    THE single source of truth. Given an *effective* Gregorian date,
    return the best hijri answer, preferring confirmed overrides.
    """
    raw = to_hijri(effective)

    # Look at every month whose start could make `effective` land in 1..30.
    # Walk from current month backward and forward; a month is "valid" if
    # effective - start is in [0, 29].
    candidates: list[tuple[int, int]] = []
    y, m = raw["hijri_year"], raw["hijri_month"]
    for delta in (0, 1, -1, 2, -2):  # small neighborhood, ±2 months
        yy, mm = y, m + delta
        while mm > 12:
            mm -= 12; yy += 1
        while mm < 1:
            mm += 12; yy -= 1
        candidates.append((yy, mm))

    for y, m in candidates:
        val = get_override(session, city, y, m)
        if not val:
            continue
        start = date.fromisoformat(val)
        delta = (effective - start).days
        if 0 <= delta <= 29:
            return {
                "hijri_year": y,
                "hijri_month": m,
                "hijri_day": delta + 1,
                "hijri_month_name": to_hijri(start)["hijri_month_name"],
                "gregorian_date": effective.isoformat(),
                "source": "confirmed",
                "is_tentative": False,
            }

    # No confirmed override → Umm al-Qura on the effective date.
    return {
        **raw,
        "gregorian_date": effective.isoformat(),
        "source": "baseline",
        "is_tentative": False,
    }


# ─────────────────── tentative flag (read path decoration) ──────────────

def _maybe_mark_tentative(session: Session, city: str, result: dict, now: datetime) -> dict:
    """
    If we're in the scraping window AND there's no override for the
    *upcoming* month yet, flag the result as tentative. This is what
    drives the 'Awaiting moon sighting confirmation' UI.
    """
    today = now.date()
    today_baseline = to_hijri(today)
    if today_baseline["hijri_day"] not in (28, 29, 30):
        return result
    if not is_in_window(session, today_baseline, now):
        return result

    ny, nm = _next_hijri_month(today_baseline["hijri_year"], today_baseline["hijri_month"])
    if get_override(session, city, ny, nm) is None:
        result["is_tentative"] = True
        result["source"] = "tentative"
        result["message"] = "Awaiting moon sighting confirmation"
    return result


# ─────────────────────────── scraper side ───────────────────────────────

def _apply_scraped(session, now, scraped):
    today = now.date()
    # Trust hijridate's month numbering.
    raw = to_hijri(today)
    if scraped["day"] == raw["hijri_day"]:
        return
    if scraped["day"] == 1:
        target_year, target_month = _next_hijri_month(
            raw["hijri_year"], raw["hijri_month"]
        )
    else:
        target_year, target_month = raw["hijri_year"], raw["hijri_month"]
    start = today - timedelta(days=scraped["day"] - 1)
    for city in _INDIAN_CITIES:
        save_override(session, city, target_year, target_month, start.isoformat())
    print(
        f"[chand] scraper override: {target_year}-{target_month:02d} "
        f"→ {start.isoformat()} (scraped day={scraped['day']})", flush=True,
    )

def _ensure_roll_forward(session: Session, now: datetime) -> None:
    """
    After Maghrib on day 30 with no next-month override yet, pre-write it
    assuming a 30-day month. This guarantees the read path flips to day 1
    the moment Maghrib passes, even before gujchand confirms.
    Day 29 is intentionally NOT pre-rolled (29-day months exist).
    """
    today = now.date()
    baseline = to_hijri(today)
    if baseline["hijri_day"] != 30:
        return
    if not is_after_maghrib(session, now):
        return

    ny, nm = _next_hijri_month(baseline["hijri_year"], baseline["hijri_month"])
    start = today + timedelta(days=1)

    wrote = False
    for city in _INDIAN_CITIES:
        if get_override(session, city, ny, nm) is None:
            save_override(session, city, ny, nm, start.isoformat())
            wrote = True
    if wrote:
        print(f"[chand] pre-roll {ny}-{nm:02d} → {start}", flush=True)


# ───────────────────────────── scheduler ────────────────────────────────

def run_cycle() -> None:
    now = datetime.now(_CITY_TZ)
    with db.session() as session:
        # Always run the pre-roll (cheap, idempotent).
        _ensure_roll_forward(session, now)

        today_baseline = to_hijri(now.date())
        if not is_in_window(session, today_baseline, now):
            return

        print("[chand] in window — polling sources", flush=True)
        scraped = fetch_gujchand()
        if scraped:
            _apply_scraped(session, now, scraped)
        else:
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


# ───────────────────────────── public API ───────────────────────────────

def get_effective_hijri(session: Session, city: str) -> dict:
    now = datetime.now(_CITY_TZ)
    effective, _after = _effective_date(session, now)
    result = resolve_hijri(session, city, effective)
    result = _maybe_mark_tentative(session, city, result, now)
    return result


def force_refresh_now() -> dict:
    now = datetime.now(_CITY_TZ)
    with db.session() as session:
        scraped = fetch_gujchand()
        if not scraped:
            return {"status": "no_data"}
        _apply_scraped(session, now, scraped)
        return {"status": "applied", "scraped_day": scraped["day"]}


if __name__ == "__main__":
    with db.session() as s:
        print(get_effective_hijri(s, "nadiad"))