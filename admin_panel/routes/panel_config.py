from __future__ import annotations

from datetime import UTC, datetime
from zoneinfo import ZoneInfo

from config import ENV
from fastapi import APIRouter, Request, Response
from schemas.panel_config import MaintenanceConfig, PanelConfigResponse

router = APIRouter(prefix="/panel_config", tags=["panel"])


def _api_base(request: Request) -> str:
    if ENV.is_production():
        return ""
    return ""


@router.get("", response_model=PanelConfigResponse)
def get_panel_config(request: Request, response: Response) -> PanelConfigResponse:
    now = datetime.now(UTC)
    tz_name = "Asia/Kolkata"
    local_now = now.astimezone(ZoneInfo(tz_name))

    response.headers["Cache-Control"] = "public, max-age=300"

    return PanelConfigResponse(
        schema_version=1,
        app_name=ENV.APP_NAME,
        app_version=ENV.APP_VERSION,
        env=ENV.APP_ENV,
        is_production=ENV.is_production(),
        is_debug=ENV.is_debug(),
        api_base=_api_base(request),
        cdn_base=(ENV.R2_PUBLIC_BASE_URL or "").rstrip("/") or None,
        docs_enabled=ENV.show_docs(),
        features={
            "backup": ENV.BACKUP_AUTO_ENABLED,
            "chand": ENV.CHAND_SCHEDULER_ENABLED,
            "quran_sync": ENV.SYNC_QURAN_ON_STARTUP,
            "rate_limit": ENV.RATE_LIMIT_ENABLED,
        },
        auth={
            "login": "/auth/login",
            "refresh": "/auth/refresh",
            "logout": "/auth/logout",
            "me": "/auth/me",
        },
        pagination={
            "default_limit": 50,
            "max_limit": 500,
        },
        defaults={
            "token_key": "nea_access_token",
            "refresh_key": "nea_refresh_token",
            "user_key": "nea_user",
            "timezone": tz_name,
            "locale": "en",
            "date_format": "YYYY-MM-DD",
        },
        maintenance=MaintenanceConfig(
            enabled=ENV.MAINTENANCE_MODE,
            message=ENV.MAINTENANCE_MESSAGE or None,
        ),
        server_time=local_now.isoformat(),
        server_timezone=tz_name,
    )
