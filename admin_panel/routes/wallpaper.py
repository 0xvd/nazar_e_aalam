"""Wallpaper endpoints — CRUD + file upload."""
from __future__ import annotations

import io
import uuid

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from config import ENV
from database import db
from database.models import User, Wallpaper
from dependencies.auth import require_admin
from routes.base_router import make_crud_router
from schemas.wallpaper import WallpaperCreate, WallpaperRead, WallpaperUpdate

router = make_crud_router(
    model=Wallpaper,
    prefix="/wallpapers",
    tag="wallpapers",
    create_schema=WallpaperCreate,
    update_schema=WallpaperUpdate,
    read_schema=WallpaperRead,
    order_by="name",
    search_fields=("name",),
)

_ALLOWED = {"image/jpeg", "image/png", "image/webp"}
_MAX_BYTES = 10 * 1024 * 1024   # 10 MB
_EXT = {"image/jpeg": "jpg", "image/png": "png", "image/webp": "webp"}


def _r2():
    return boto3.client(
        "s3",
        endpoint_url=f"https://{ENV.R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
        aws_access_key_id=ENV.R2_ACCESS_KEY_ID,
        aws_secret_access_key=ENV.R2_SECRET_ACCESS_KEY,
        region_name="auto",
    )


@router.post("/upload", response_model=WallpaperRead, status_code=status.HTTP_201_CREATED)
async def upload_wallpaper(
    file: UploadFile = File(...),
    name: str = Form(...),
    session: Session = Depends(db.get_db),
    _: User = Depends(require_admin),
) -> Wallpaper:
    if file.content_type not in _ALLOWED:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Only JPEG, PNG, or WebP allowed (got {file.content_type})",
        )

    data = await file.read()
    if len(data) > _MAX_BYTES:
        raise HTTPException(
            status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            f"Max file size is 10 MB (got {len(data) / 1024**2:.1f} MB)",
        )

    clean_name = (name or file.filename or "wallpaper").strip()[:255]
    key = f"wallpapers/{uuid.uuid4().hex}.{_EXT[file.content_type]}"

    try:
        _r2().upload_fileobj(
            io.BytesIO(data),
            ENV.R2_BUCKET,
            key,
            ExtraArgs={
                "ContentType": file.content_type,
                "CacheControl": "public, max-age=31536000, immutable",
            },
        )
    except (BotoCoreError, ClientError) as e:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            f"R2 upload failed: {e}",
        ) from e

    base = (ENV.R2_PUBLIC_BASE_URL or "").rstrip("/")
    if not base:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            "R2_PUBLIC_BASE_URL not configured",
        )

    w = Wallpaper(name=clean_name, image=f"{base}/{key}")
    session.add(w)
    session.commit()
    session.refresh(w)
    return w

@router.post("/upload-image", status_code=status.HTTP_200_OK)
async def upload_wallpaper_image(
    file: UploadFile = File(...),
    _: User = Depends(require_admin),
) -> dict:
    """Upload an image to R2 and return its URL. Does NOT create a DB row.

    Used by the frontend edit flow: upload → get URL → PATCH /wallpapers/{id}.
    """
    if file.content_type not in _ALLOWED:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            f"Only JPEG, PNG, or WebP allowed (got {file.content_type})",
        )

    data = await file.read()
    if len(data) > _MAX_BYTES:
        raise HTTPException(
            status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            f"Max file size is 10 MB (got {len(data) / 1024**2:.1f} MB)",
        )

    key = f"wallpapers/{uuid.uuid4().hex}.{_EXT[file.content_type]}"

    try:
        _r2().upload_fileobj(
            io.BytesIO(data),
            ENV.R2_BUCKET,
            key,
            ExtraArgs={
                "ContentType": file.content_type,
                "CacheControl": "public, max-age=31536000, immutable",
            },
        )
    except (BotoCoreError, ClientError) as e:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY,
            f"R2 upload failed: {e}",
        ) from e

    base = (ENV.R2_PUBLIC_BASE_URL or "").rstrip("/")
    if not base:
        raise HTTPException(500, "R2_PUBLIC_BASE_URL not configured")

    return {"url": f"{base}/{key}"}