from __future__ import annotations

import threading
from datetime import datetime
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from database import db
from database.models import SyncJob, User
from dependencies.auth import require_admin
from schemas.sync import (
    SyncJobStatus,
    SyncLogChunk,
    SyncStartRequest,
    SyncStartResponse,
    SyncStatusResponse,
)
from tools import ayah_sync_runner

router = APIRouter(prefix="/admin/sync", tags=["admin-sync"])

_ACTIVE = ("queued", "running", "stopping")
_ROOT = Path(__file__).resolve().parent.parent


def _active(session: Session) -> SyncJob | None:
    return session.execute(
        select(SyncJob)
        .where(SyncJob.status.in_(_ACTIVE))
        .order_by(SyncJob.id.desc())
        .limit(1)
    ).scalar_one_or_none()


def _last(session: Session) -> SyncJob | None:
    return session.execute(
        select(SyncJob)
        .where(SyncJob.status.notin_(_ACTIVE))
        .order_by(SyncJob.id.desc())
        .limit(1)
    ).scalar_one_or_none()


@router.post("/ayah/start", response_model=SyncStartResponse)
def start_ayah_sync(
    body: SyncStartRequest,
    user: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> SyncStartResponse:
    existing = _active(session)
    if existing is not None:
        return SyncStartResponse(
            job_id=existing.id, status=existing.status, attached=True
        )

    job = SyncJob(
        kind="ayah",
        status="queued",
        reciters=body.reciters or None,
        started_by_id=user.id,
        started_at=datetime.utcnow(),
    )
    session.add(job)
    session.commit()
    session.refresh(job)

    t = threading.Thread(
        target=ayah_sync_runner.run,
        args=(job.id,),
        name=f"ayah-sync-{job.id}",
        daemon=True,
    )
    t.start()

    return SyncStartResponse(job_id=job.id, status="queued", attached=False)


@router.get("/ayah/status", response_model=SyncStatusResponse)
def ayah_sync_status(
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> SyncStatusResponse:
    a = _active(session)
    l = _last(session)
    return SyncStatusResponse(
        active=SyncJobStatus.model_validate(a) if a else None,
        last=SyncJobStatus.model_validate(l) if l else None,
    )


@router.get("/ayah/logs", response_model=SyncLogChunk)
def ayah_sync_logs(
    job_id: int = Query(..., ge=1),
    offset: int = Query(0, ge=0),
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> SyncLogChunk:
    job = session.get(SyncJob, job_id)
    if job is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Job not found")

    if not job.log_path:
        return SyncLogChunk(
            job_id=job_id,
            chunk="",
            offset=offset,
            next_offset=offset,
            size=0,
            eof=True,
            exists=False,
        )

    path = Path(job.log_path)
    if not path.exists():
        return SyncLogChunk(
            job_id=job_id,
            chunk="",
            offset=offset,
            next_offset=offset,
            size=0,
            eof=True,
            exists=False,
        )

    size = path.stat().st_size
    if offset > size:
        offset = 0

    with path.open("r", encoding="utf-8", errors="replace", newline="") as fh:
        fh.seek(offset)
        data = fh.read()
        next_off = fh.tell()

    eof = next_off >= size and job.status not in _ACTIVE

    return SyncLogChunk(
        job_id=job_id,
        chunk=data,
        offset=offset,
        next_offset=next_off,
        size=size,
        eof=eof,
        exists=True,
    )


@router.post("/ayah/stop", response_model=SyncJobStatus)
def stop_ayah_sync(
    _: User = Depends(require_admin),
    session: Session = Depends(db.get_db),
) -> SyncJobStatus:
    job = _active(session)
    if job is None:
        raise HTTPException(status.HTTP_409_CONFLICT, "No active sync job")
    if job.status == "stopping":
        return SyncJobStatus.model_validate(job)

    job.stop_requested = True
    job.status = "stopping"
    session.commit()
    session.refresh(job)
    return SyncJobStatus.model_validate(job)
