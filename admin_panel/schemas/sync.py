"""Schemas for the admin sync API."""
from __future__ import annotations

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


Status = Literal[
    "queued", "running", "stopping", "stopped", "done", "failed", "interrupted"
]


class SyncStartRequest(BaseModel):
    reciters: list[str] | None = Field(
        default=None,
        description="Reciter slugs to sync. Omit to sync all configured reciters.",
    )


class SyncStartResponse(BaseModel):
    job_id: int
    status: Status
    attached: bool = Field(
        description="True when an already-active job was returned instead of a new one."
    )


class SyncJobStatus(BaseModel):
    id: int
    kind: str
    status: Status
    reciters: list[str] | None = None

    total: int = 0
    processed: int = 0
    uploaded: int = 0
    skipped: int = 0
    failed: int = 0
    bytes_done: int = 0

    current_file: str | None = None
    message: str | None = None
    error: str | None = None

    started_at: datetime | None = None
    finished_at: datetime | None = None
    stop_requested: bool = False

    model_config = {"from_attributes": True}


class SyncStatusResponse(BaseModel):
    active: SyncJobStatus | None = None
    last: SyncJobStatus | None = None


class SyncLogChunk(BaseModel):
    job_id: int
    chunk: str
    offset: int
    next_offset: int
    size: int
    eof: bool
    exists: bool = True