"""Panel bootstrap config — everything the admin panel needs at startup."""
from __future__ import annotations

from pydantic import BaseModel


class MaintenanceConfig(BaseModel):
    enabled: bool
    message: str | None = None
    until: str | None = None   # ISO datetime, optional ETA


class PanelConfigResponse(BaseModel):
    # Schema version — bump on breaking change; frontend can check
    schema_version: int = 1

    # ---- Identity ----
    app_name: str
    app_version: str
    env: str                      # "development" | "staging" | "production" | "testing"
    is_production: bool
    is_debug: bool

    # ---- Endpoints ----
    api_base: str                 # no trailing slash; e.g. "https://api.example.com"
    cdn_base: str | None          # R2 public base for images; null if unset

    # ---- Feature flags ----
    docs_enabled: bool
    features: dict[str, bool]     # {"backup": true, "chand": true, "quran_sync": false}

    # ---- Sub-endpoint paths (relative to api_base) ----
    auth: dict[str, str]          # {"login": "/auth/login", ...}

    # ---- Defaults the panel should adopt ----
    pagination: dict[str, int]    # {"default_limit": 50, "max_limit": 500}
    defaults: dict[str, str]      # {"token_key": "nea_token", "timezone": "Asia/Kolkata", ...}

    # ---- State ----
    maintenance: MaintenanceConfig
    server_time: str              # ISO timestamp with tz
    server_timezone: str