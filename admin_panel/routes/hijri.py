from __future__ import annotations

from database import db
from dependencies.auth import require_admin
from fastapi import APIRouter, Depends, HTTPException, Query, status
from schemas.hijri import HijriResponse
from sqlalchemy.orm import Session
from tools.chand import force_refresh_now, get_effective_hijri

router = APIRouter(prefix="/hijri", tags=["hijri"])


@router.get("/now", response_model=HijriResponse)
def get_hijri_now(
    city: str = Query(..., min_length=1, max_length=80),
    session: Session = Depends(db.get_db),
):
    """
    Current Islamic date for ANY city/area string.

    - If a curated override exists for this city+month → use it ("confirmed")
    - If we're within the Maghrib-window on day 28-30 → mark "tentative"
    - Otherwise → computed from the Umm al-Qura baseline ("baseline")

    No allowlist — any string works, e.g. "nadiad", "sao paulo", "tokyo".
    """
    key = city.strip().lower()
    if not key:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "City must be a non-empty string.",
        )
    data = get_effective_hijri(session, key)
    return HijriResponse(city=key, **data)


@router.post("/refresh", status_code=status.HTTP_202_ACCEPTED)
def trigger_refresh(_=Depends(require_admin)):
    """Force an immediate scrape (bypasses the schedule window). Admin-only."""
    import threading

    threading.Thread(target=force_refresh_now, daemon=True).start()
    return {"status": "scheduled"}
