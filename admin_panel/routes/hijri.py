"""
Hijri date endpoints.

GET  /hijri/now?city=nadiad   → current Islamic date
POST /hijri/refresh           → force one immediate scrape (admin)
"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from database import db
from dependencies.auth import require_admin
from schemas.hijri import HijriResponse
from tools import cities
from tools.chand import force_refresh_now, get_effective_hijri

router = APIRouter(prefix="/hijri", tags=["hijri"])


@router.get("/now", response_model=HijriResponse)
def get_hijri_now(
    city: str = Query(..., description="City key, e.g. 'nadiad'"),
    session: Session = Depends(db.get_db),
):
    key = city.strip().lower()
    if cities.get(key) is None:
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            f"Unknown city '{city}'. See GET /prayer-times/cities.",
        )
    data = get_effective_hijri(session, key)
    return HijriResponse(city=key, **data)


@router.post("/refresh", status_code=status.HTTP_202_ACCEPTED)
def trigger_refresh(_=Depends(require_admin)):
    """Force an immediate scrape (bypasses the schedule window). Admin-only."""
    import threading
    threading.Thread(target=force_refresh_now, daemon=True).start()
    return {"status": "scheduled"}