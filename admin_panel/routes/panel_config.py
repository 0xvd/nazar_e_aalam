"""
Panel bootstrap endpoint — public, no auth.

Served before login. Returns API base URL, environment, feature flags,
and endpoint paths. The admin panel calls this first, then uses the
returned `api_base` for every subsequent call.
"""
from __future__ import annotations

from datetime import datetime, timezone
from zoneinfo import ZoneInfo

from fastapi import APIRouter, Request, Response

from config import ENV
from schemas.panel_config import MaintenanceConfig, PanelConfigResponse

router = APIRouter(prefix="/panel_config", tags=["panel"])


def _api_base(request: Request) -> str:
    """
    Canonical API base URL.

    Dev  (uvicorn serves /panel at :8000, routes at root)   → "" (relative)
    Prod (nginx serves /panel/, proxies /api/* → uvicorn)  → "/api"

    Returning "" in dev makes CONFIG.api_base + "/wallpapers" resolve to
    "/wallpapers" — FastAPI routes it directly. Returning "/api" in prod
    makes CONFIG.api_base + "/wallpapers" resolve to "/api/wallpapers" —
    nginx strips /api and proxies to FastAPI's /wallpapers. Same endpoint
    in both environments, from the panel's point of view.
    """
    if ENV.is_production():
        # Behind nginx (or any proxy that routes /api/* to this app).
        # A bare path is strictly better than an absolute URL here:
        #  - no host, so no 127.0.0.1 vs localhost vs admin.yourdomain.com drift
        #  - no CORS (same-origin by construction)
        #  - no mixed-content on HTTPS
        return "/api"

    # Dev: relative to the panel's own origin. uvicorn serves /panel/ and
    # the API routes on the same port, so root paths just work.
    return ""


@router.get("", response_model=PanelConfigResponse)
def get_panel_config(request: Request, response: Response) -> PanelConfigResponse:
    now = datetime.now(timezone.utc)
    tz_name = "Asia/Kolkata"
    local_now = now.astimezone(ZoneInfo(tz_name))

    # Safe to cache briefly — config only changes on restart
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