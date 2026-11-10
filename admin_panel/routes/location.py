from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any

import requests
from cache import rate_limiter
from config import ENV
from database import db
from database.models import LocationCache, User
from dependencies.auth import get_current_user
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

router = APIRouter(prefix="/location", tags=["location"])

_CACHE_TTL = timedelta(days=7)


def _round_grid(lat: float, lon: float, decimals: int = 3) -> tuple[float, float]:
    """3 decimals ≈ 100 m grid — good enough for city-level reverse geocoding."""
    return round(lat, decimals), round(lon, decimals)


def _client_ip(request: Request) -> str | None:
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()
    return request.client.host if request.client else None


def _fetch_reverse_geocode(lat: float, lon: float) -> dict[str, Any]:
    """
    Call BigDataCloud's free reverse geocode endpoint.
    Returns a normalised dict, or raises HTTPException on failure.
    """
    url = "https://api.bigdatacloud.net/data/reverse-geocode-client"
    params = {
        "latitude": lat,
        "longitude": lon,
        "localityLanguage": "en",
    }
    try:
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        d = r.json()
    except requests.RequestException as exc:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            f"Reverse-geocoding service unreachable: {exc}",
        ) from exc

    return {
        "city": d.get("city") or d.get("locality"),
        "state": d.get("principalSubdivision"),
        "country": d.get("countryName"),
        "country_code": d.get("countryCode"),
        "postcode": d.get("postcode"),
        "formatted_address": d.get("localityInfo", {})
        .get("administrative", [{}])[-1]
        .get("name"),
        "source": "bigdatacloud",
    }


def _fetch_ip_location(ip: str) -> dict[str, Any]:
    """BigDataCloud also exposes an IP-based lookup — same endpoint, no coords."""
    url = "https://api.bigdatacloud.net/data/reverse-geocode-client"
    params = {"ip": ip, "localityLanguage": "en"}
    try:
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        d = r.json()
    except requests.RequestException as exc:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            f"IP lookup service unreachable: {exc}",
        ) from exc

    return {
        "city": d.get("city") or d.get("locality"),
        "state": d.get("principalSubdivision"),
        "country": d.get("countryName"),
        "country_code": d.get("countryCode"),
        "postcode": d.get("postcode"),
        "formatted_address": None,
        "source": "ip",
    }


@router.get("/get")
def get_location(
    lat: float | None = Query(None, ge=-90, le=90),
    lon: float | None = Query(None, ge=-180, le=180),
    request: Request = None,
    user: User = Depends(get_current_user),
    session: Session = Depends(db.get_db),
):
    """
    Return the resolved location for the given coordinates (or IP fallback).

    Resolution order:
      1. If lat/lon given → check LocationCache (grid-rounded) → return if fresh.
      2. Otherwise → call BigDataCloud reverse-geocode → cache → return.
      3. If neither lat/lon nor IP available → 400.
    """
    if ENV.RATE_LIMIT_ENABLED:
        allowed, _ = rate_limiter.hit(
            f"location:{_client_ip(request) or 'unknown'}",
            limit=30,
            window=60,
        )
        if not allowed:
            raise HTTPException(
                status.HTTP_429_TOO_MANY_REQUESTS, "Too many location lookups."
            )

    if lat is not None and lon is not None:
        grid_lat, grid_lon = _round_grid(lat, lon)
        cutoff = datetime.utcnow() - _CACHE_TTL

        cached = (
            session.query(LocationCache)
            .filter(
                LocationCache.lat_grid == grid_lat,
                LocationCache.lon_grid == grid_lon,
                LocationCache.last_fetched_at >= cutoff,
            )
            .first()
        )
        if cached:
            return {
                "lat": lat,
                "lon": lon,
                "city": cached.city,
                "state": cached.state,
                "country": cached.country,
                "country_code": cached.country_code,
                "postcode": cached.postcode,
                "timezone": cached.timezone,
                "formatted_address": cached.formatted_address,
                "source": cached.source,
                "cached": True,
            }

        data = _fetch_reverse_geocode(lat, lon)
        row = LocationCache(
            lat_grid=grid_lat,
            lon_grid=grid_lon,
            city=data["city"],
            state=data["state"],
            country=data["country"],
            country_code=data["country_code"],
            postcode=data["postcode"],
            timezone=None,
            formatted_address=data["formatted_address"],
            source=data["source"],
            last_fetched_at=datetime.utcnow(),
        )
        session.add(row)
        session.commit()

        return {
            "lat": lat,
            "lon": lon,
            **{
                k: data[k]
                for k in (
                    "city",
                    "state",
                    "country",
                    "country_code",
                    "postcode",
                    "formatted_address",
                    "source",
                )
            },
            "cached": False,
        }

    ip = _client_ip(request)
    if ip:
        data = _fetch_ip_location(ip)
        return {
            "lat": None,
            "lon": None,
            **data,
            "cached": False,
        }

    raise HTTPException(
        status.HTTP_400_BAD_REQUEST,
        "Provide lat/lon, or ensure your IP is visible to the server.",
    )
