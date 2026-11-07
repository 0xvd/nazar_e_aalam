from __future__ import annotations

from datetime import date

from pydantic import BaseModel, ConfigDict, computed_field


class PrayerTimeRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    date: date
    city: str | None = None

    imsak: str | None = None
    fajr_start: str | None = None
    sunrise: str | None = None
    zuhr_start: str | None = None
    asr_start: str | None = None
    sunset: str | None = None
    maghrib_start: str | None = None
    isha_start: str | None = None
    sehri: str | None = None
    iftar: str | None = None

    @computed_field  # type: ignore[prop-decorator]
    @property
    def is_friday(self) -> bool:
        return self.date.weekday() == 4


class PrayerTimeUpdate(BaseModel):
    """Partial update. On Friday, editing `zuhr_start` changes jummah time."""

    imsak: str | None = None
    fajr_start: str | None = None
    sunrise: str | None = None
    zuhr_start: str | None = None
    asr_start: str | None = None
    sunset: str | None = None
    maghrib_start: str | None = None
    isha_start: str | None = None
    sehri: str | None = None
    iftar: str | None = None


class SeedRequest(BaseModel):
    city: str
    year: int
    replace: bool = False


class SeedResult(BaseModel):
    city: str
    year: int
    inserted: int
    skipped: int


class CityInfo(BaseModel):
    key: str
    name: str
    latitude: float
    longitude: float
    timezone: str
