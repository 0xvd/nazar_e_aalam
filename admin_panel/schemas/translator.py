"""Translator request / response schemas."""
from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class TranslatorBase(BaseModel):
    full_name: str = Field(..., min_length=1, max_length=255)
    short_name: str = Field(..., min_length=1, max_length=255)
    language: str = Field(..., min_length=1, max_length=255)
    language_code: str = Field(..., min_length=1, max_length=255)


class TranslatorCreate(TranslatorBase):
    pass


class TranslatorUpdate(BaseModel):
    full_name: str | None = Field(None, min_length=1, max_length=255)
    short_name: str | None = Field(None, min_length=1, max_length=255)
    language: str | None = Field(None, min_length=1, max_length=255)
    language_code: str | None = Field(None, min_length=1, max_length=255)


class TranslatorRead(TranslatorBase):
    model_config = ConfigDict(from_attributes=True)

    id: int