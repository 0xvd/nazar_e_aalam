from __future__ import annotations

import math
from datetime import date, datetime
from zoneinfo import ZoneInfo

DEG2RAD = math.pi / 180.0
RAD2DEG = 180.0 / math.pi


def _julian_day(y: int, m: int, d: int) -> float:
    if m <= 2:
        y -= 1
        m += 12
    a = y // 100
    b = 2 - a + a // 4
    return (
        math.floor(365.25 * (y + 4716)) + math.floor(30.6001 * (m + 1)) + d + b - 1524.5
    )


def _sun_position(jd: float) -> tuple[float, float]:
    dd = jd - 2451545.0
    g = (357.529 + 0.98560028 * dd) % 360
    q = (280.459 + 0.98564736 * dd) % 360
    L = (q + 1.915 * math.sin(g * DEG2RAD) + 0.020 * math.sin(2 * g * DEG2RAD)) % 360
    e = 23.439 - 0.00000036 * dd
    RA = (
        math.atan2(math.cos(e * DEG2RAD) * math.sin(L * DEG2RAD), math.cos(L * DEG2RAD))
        * RAD2DEG
        / 15
    ) % 24
    decl = math.asin(math.sin(e * DEG2RAD) * math.sin(L * DEG2RAD)) * RAD2DEG
    eqt_hours = (q / 15 - RA) % 24
    if eqt_hours > 12:
        eqt_hours -= 24
    return decl, eqt_hours


def _hour_angle_offset_hours(
    angle_below_horizon_deg: float, decl_deg: float, lat_deg: float
) -> float | None:
    cos_h = (
        math.sin(-angle_below_horizon_deg * DEG2RAD)
        - math.sin(decl_deg * DEG2RAD) * math.sin(lat_deg * DEG2RAD)
    ) / (math.cos(decl_deg * DEG2RAD) * math.cos(lat_deg * DEG2RAD))
    if cos_h < -1 or cos_h > 1:
        return None
    return math.acos(cos_h) * RAD2DEG / 15


def _asr_altitude_deg(lat_deg: float, decl_deg: float, shadow: float) -> float:
    diff = abs(lat_deg - decl_deg)
    return math.atan(1.0 / (shadow + math.tan(diff * DEG2RAD))) * RAD2DEG


def _fmt(h: float | None) -> str | None:
    if h is None:
        return None
    h = ((h % 24) + 24) % 24
    hh = int(h)
    mm = round((h - hh) * 60)
    if mm == 60:
        hh += 1
        mm = 0
    if hh == 24:
        hh = 0
    return f"{hh:02d}:{mm:02d}"


def calculate(
    latitude: float,
    longitude: float,
    d: date,
    *,
    timezone_str: str = "Asia/Kolkata",
    fajr_angle: float = 18.0,
    isha_angle: float = 18.0,
    asr_shadow: float = 2.0,
    sunrise_angle: float = 0.833,
    imsak_offset_min: int = 10,
) -> dict[str, str | bool | None]:
    jd = _julian_day(d.year, d.month, d.day) + 0.5
    decl, eqt_h = _sun_position(jd)
    tz = ZoneInfo(timezone_str)
    tz_offset_h = (
        datetime(d.year, d.month, d.day, tzinfo=tz).utcoffset().total_seconds() / 3600
    )
    dhuhr = 12 + tz_offset_h - longitude / 15 - eqt_h

    off_sunrise = _hour_angle_offset_hours(sunrise_angle, decl, latitude)
    off_fajr = _hour_angle_offset_hours(fajr_angle, decl, latitude)
    off_isha = _hour_angle_offset_hours(isha_angle, decl, latitude)
    asr_alt = _asr_altitude_deg(latitude, decl, asr_shadow)
    off_asr = _hour_angle_offset_hours(-asr_alt, decl, latitude)

    fajr = dhuhr - off_fajr if off_fajr else None
    imsak = fajr - imsak_offset_min / 60 if fajr else None
    sunrise = dhuhr - off_sunrise if off_sunrise else None
    sunset = dhuhr + off_sunrise if off_sunrise else None
    asr = dhuhr + off_asr if off_asr else None
    isha = dhuhr + off_isha if off_isha else None

    is_friday = d.weekday() == 4
    return {
        "imsak": _fmt(imsak),
        "fajr": _fmt(fajr),
        "sunrise": _fmt(sunrise),
        "dhuhr": _fmt(dhuhr),
        "asr": _fmt(asr),
        "sunset": _fmt(sunset),
        "maghrib": _fmt(sunset),
        "isha": _fmt(isha),
        "is_friday": is_friday,
    }
