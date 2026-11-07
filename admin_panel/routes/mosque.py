from urllib.parse import quote

import requests
from fastapi import APIRouter, Query

from config import ENV

router = APIRouter(prefix="/mosques", tags=["mosques"])

GOOGLE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
TIMENOW_URL = "https://time.now/mosques/api/mosques"


def _format_google(place: dict) -> dict:
    name = place.get("name", "Unknown")
    addr = place.get("vicinity", "")
    query = f"{name} {addr}"
    return {
        "name": name,
        "address": addr,
        "lat": place["geometry"]["location"]["lat"],
        "lon": place["geometry"]["location"]["lng"],
        "distance_km": None,
        "source": "google",
        "google_maps_url": f"https://www.google.com/maps/search/?api=1&query={quote(query)}",
    }


def _format_timenow(m: dict) -> dict:
    name = m.get("name", "Unknown")
    addr = m.get("address", "")
    query = f"{name} {addr}"
    return {
        "name": name,
        "address": addr,
        "lat": None,
        "lon": None,
        "distance_km": m.get("distance_km"),
        "source": "time.now",
        "google_maps_url": f"https://www.google.com/maps/search/?api=1&query={quote(query)}",
    }


def _empty_response(reason: str, attempts: list[dict]) -> dict:
    """Never break the UI — return a friendly empty result."""
    return {
        "source": "none",
        "count": 0,
        "mosques": [],
        "message": reason,
        "attempts": attempts,
    }


@router.get("/nearby")
def nearby(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    radius_m: int = Query(2000, ge=100, le=50000),
):
    """
    Find nearby mosques.

    Never raises for upstream failures — always returns 200 with either:
      - mosques: [...]                    (source = google | time.now)
      - mosques: [], message: "..."       (source = none)

    Frontend can show a friendly "No mosques found" state on empty results.
    """
    attempts: list[dict] = []

    if ENV.GOOGLE_MAPS_API_KEY:
        try:
            resp = requests.get(
                GOOGLE_URL,
                params={
                    "location": f"{lat},{lon}",
                    "radius": radius_m,
                    "type": "mosque",
                    "key": ENV.GOOGLE_MAPS_API_KEY,
                },
                timeout=10,
            )
            data = resp.json()
            status = data.get("status")

            if status in ("OK", "ZERO_RESULTS"):
                results = [_format_google(p) for p in data.get("results", [])]
                return {"source": "google", "count": len(results), "mosques": results}

            attempts.append(
                {
                    "source": "google",
                    "status": status,
                    "error": data.get("error_message", status or "unknown"),
                }
            )
            print(
                f"[mosque-api] google: {status} — {data.get('error_message', '')}",
                flush=True,
            )

        except requests.RequestException as e:
            attempts.append(
                {"source": "google", "status": "network", "error": str(e)[:200]}
            )
            print(f"[mosque-api] google network error: {e}", flush=True)
    else:
        attempts.append(
            {"source": "google", "status": "skipped", "error": "no API key configured"}
        )

    try:
        radius_km = max(1, radius_m // 1000)
        resp = requests.get(
            TIMENOW_URL,
            params={"lat": lat, "lon": lon, "radius": radius_km},
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()

        if not isinstance(data, list):
            attempts.append(
                {
                    "source": "time.now",
                    "status": "invalid_response",
                    "error": f"expected list, got {type(data).__name__}",
                }
            )
        else:
            results = [_format_timenow(m) for m in data]
            return {"source": "time.now", "count": len(results), "mosques": results}

    except requests.RequestException as e:
        attempts.append(
            {"source": "time.now", "status": "network", "error": str(e)[:200]}
        )
        print(f"[mosque-api] time.now network error: {e}", flush=True)

    print(f"[mosque-api] all sources failed, returning empty: {attempts}", flush=True)

    google_attempt = next((a for a in attempts if a["source"] == "google"), None)
    timenow_attempt = next((a for a in attempts if a["source"] == "time.now"), None)

    if google_attempt and google_attempt["status"] == "OVER_QUERY_LIMIT":
        msg = "Daily mosque search limit reached. Please try again tomorrow."
    elif google_attempt and google_attempt["status"] == "REQUEST_DENIED":
        msg = "Mosque search is temporarily unavailable. Please try again later."
    elif timenow_attempt and timenow_attempt["status"] == "network":
        msg = "Network is slow right now — no mosques loaded. Pull down to retry."
    else:
        msg = "No mosques found nearby. Try a wider search area or move to a different location."

    return _empty_response(msg, attempts)
