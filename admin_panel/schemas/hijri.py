from __future__ import annotations

from pydantic import BaseModel


class HijriResponse(BaseModel):
    city: str
    gregorian_date: str
    hijri_year: int
    hijri_month: int
    hijri_day: int
    hijri_month_name: str
    source: str
    is_tentative: bool
    message: str | None = None
