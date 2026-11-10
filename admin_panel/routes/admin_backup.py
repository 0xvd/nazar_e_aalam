from __future__ import annotations

import subprocess
from datetime import datetime
from pathlib import Path

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from config import ENV
from database.models import User
from dependencies.auth import require_permission
from fastapi import APIRouter, Depends, HTTPException, status
from schemas.backup import (
    BackupInfo,
    BackupListResponse,
    BackupStatusResponse,
    BackupTriggerResponse,
    RestoreRequest,
    RestoreResponse,
    VerifyResponse,
)
from tools import backup_scheduler

router = APIRouter(prefix="/admin/backup", tags=["admin-backup"])

_ROOT = Path(__file__).resolve().parent.parent
_SCRIPTS = _ROOT / "scripts"
_BACKUP_DIR = _ROOT / "backups"
_BACKUP_SCRIPT = _SCRIPTS / "backup.sh"
_VERIFY_SCRIPT = _SCRIPTS / "verify_restore.py"


def _r2_client():
    return boto3.client(
        "s3",
        endpoint_url=f"https://{ENV.R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
        aws_access_key_id=ENV.R2_BACKUP_ACCESS_KEY_ID,
        aws_secret_access_key=ENV.R2_BACKUP_ACCESS_KEY,
        region_name="auto",
    )


def _list_local() -> dict[str, BackupInfo]:
    if not _BACKUP_DIR.exists():
        return {}
    out: dict[str, BackupInfo] = {}
    for f in _BACKUP_DIR.glob("nazar_e_alam_*.sql.gz"):
        st = f.stat()
        out[f.name] = BackupInfo(
            filename=f.name,
            size_bytes=st.st_size,
            size_mb=round(st.st_size / 1024**2, 2),
            created_at=datetime.fromtimestamp(st.st_mtime).isoformat(),
            source="local",
        )
    return out


def _list_r2() -> dict[str, BackupInfo]:
    if not (ENV.R2_ACCOUNT_ID and ENV.R2_BACKUP_BUCKET):
        return {}
    try:
        client = _r2_client()
        resp = client.list_objects_v2(Bucket=ENV.R2_BACKUP_BUCKET, Prefix="backups/")
    except (ClientError, BotoCoreError):
        return {}
    out: dict[str, BackupInfo] = {}
    for obj in resp.get("Contents", []):
        filename = obj["Key"].split("/")[-1]
        out[filename] = BackupInfo(
            filename=filename,
            size_bytes=obj["Size"],
            size_mb=round(obj["Size"] / 1024**2, 2),
            created_at=obj["LastModified"].isoformat(),
            source="r2",
        )
    return out


def _merge(local: dict, r2: dict) -> list[BackupInfo]:
    """Combine local + R2 lists. Same filename on both sides → source='both'."""
    merged: dict[str, BackupInfo] = {}
    for name, info in local.items():
        merged[name] = info
    for name, info in r2.items():
        if name in merged:
            info = info.model_copy(update={"source": "both"})
        merged[name] = info
    return sorted(merged.values(), key=lambda b: b.created_at, reverse=True)


@router.post("", response_model=BackupTriggerResponse)
def trigger_backup_now(
    _: User = Depends(require_permission("backup:write")),
) -> BackupTriggerResponse:
    if not _BACKUP_SCRIPT.exists():
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"backup.sh not found at {_BACKUP_SCRIPT}",
        )

    ok, output = backup_scheduler.run_backup_now(label="admin_manual")
    if not ok:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"Backup failed: {output[-500:]}",
        )

    local_files = sorted(
        _BACKUP_DIR.glob("nazar_e_alam_*.sql.gz"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    if not local_files:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            "Backup script reported success but no file was created",
        )
    latest = local_files[0]

    return BackupTriggerResponse(
        status="ok",
        filename=latest.name,
        size_bytes=latest.stat().st_size,
        uploaded_to_r2="Uploaded → s3://" in output,
    )


@router.get("", response_model=BackupListResponse)
def list_backups(
    _: User = Depends(require_permission("backup:read")),
) -> BackupListResponse:
    merged = _merge(_list_local(), _list_r2())
    return BackupListResponse(count=len(merged), backups=merged[:50])


@router.post("/restore", response_model=RestoreResponse)
def restore_backup(
    body: RestoreRequest,
    _: User = Depends(require_permission("backup:write")),
) -> RestoreResponse:
    if body.confirm != "RESTORE":
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "confirm must be exactly 'RESTORE'",
        )
    if "/" in body.filename or ".." in body.filename:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Invalid filename")

    local_file = _BACKUP_DIR / body.filename
    source = body.source

    if source == "auto":
        source = "local" if local_file.exists() else "r2"
    if source == "local" and not local_file.exists():
        raise HTTPException(
            status.HTTP_404_NOT_FOUND,
            f"{body.filename} not found locally",
        )

    if source == "r2":
        try:
            client = _r2_client()
            local_file.parent.mkdir(parents=True, exist_ok=True)
            client.download_file(
                ENV.R2_BACKUP_BUCKET, f"backups/{body.filename}", str(local_file)
            )
        except (ClientError, BotoCoreError) as e:
            raise HTTPException(
                status.HTTP_502_BAD_GATEWAY,
                f"Failed to fetch from R2: {e}",
            ) from e

    restore_script = _SCRIPTS / "restore.sh"
    if not restore_script.exists():
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"restore.sh not found at {restore_script}",
        )

    result = subprocess.run(
        [str(restore_script), str(local_file)],
        input="RESTORE\n",
        capture_output=True,
        text=True,
        timeout=600,
        cwd=str(_ROOT),
    )
    output = (result.stdout or "") + (result.stderr or "")
    if result.returncode != 0:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"Restore failed: {output[-500:]}",
        )

    return RestoreResponse(
        status="ok",
        filename=body.filename,
        source=source,
        output=output[-1000:],
    )


@router.post("/verify", response_model=VerifyResponse)
def verify_backup(
    _: User = Depends(require_permission("backup:write")),
) -> VerifyResponse:
    if not _VERIFY_SCRIPT.exists():
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"verify_restore.py not found at {_VERIFY_SCRIPT}",
        )
    result = subprocess.run(
        [str(_ROOT / ".venv" / "bin" / "python"), str(_VERIFY_SCRIPT)],
        capture_output=True,
        text=True,
        timeout=600,
        cwd=str(_ROOT),
    )
    output = (result.stdout or "") + (result.stderr or "")
    return VerifyResponse(
        status="ok" if result.returncode == 0 else "failed",
        output=output[-2000:],
    )


@router.get("/status", response_model=BackupStatusResponse)
def backup_status(
    _: User = Depends(require_permission("backup:read")),
) -> BackupStatusResponse:
    state = backup_scheduler.get_state()
    local = _list_local()
    r2 = _list_r2()

    local_names = sorted(local.keys())
    oldest = local_names[0] if local_names else None
    newest = local_names[-1] if local_names else None

    return BackupStatusResponse(
        **state,
        total_local_backups=len(local),
        total_r2_backups=len(r2),
        oldest_local_backup=oldest,
        newest_local_backup=newest,
    )
