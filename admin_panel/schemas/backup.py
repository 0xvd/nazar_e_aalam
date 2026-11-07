from __future__ import annotations

from pydantic import BaseModel, Field


class BackupInfo(BaseModel):
    filename: str
    size_bytes: int
    size_mb: float
    created_at: str
    source: str


class BackupListResponse(BaseModel):
    count: int
    backups: list[BackupInfo]


class BackupTriggerResponse(BaseModel):
    status: str
    filename: str
    size_bytes: int
    uploaded_to_r2: bool


class RestoreRequest(BaseModel):
    filename: str = Field(..., min_length=1, max_length=255)
    confirm: str = Field(..., description="Must be exactly 'RESTORE'")
    source: str = Field("auto", pattern="^(auto|local|r2)$")


class RestoreResponse(BaseModel):
    status: str
    filename: str
    source: str
    output: str


class VerifyResponse(BaseModel):
    status: str
    output: str


class BackupStatusResponse(BaseModel):
    scheduler_enabled: bool
    scheduler_running: bool
    last_run_at: str | None
    last_run_status: str | None
    next_run_at: str | None
    scheduled_time: str
    total_local_backups: int
    total_r2_backups: int
    oldest_local_backup: str | None
    newest_local_backup: str | None
