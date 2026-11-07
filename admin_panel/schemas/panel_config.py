from __future__ import annotations

from pydantic import BaseModel


class MaintenanceConfig(BaseModel):
    enabled: bool
    message: str | None = None
    until: str | None = None


class PanelConfigResponse(BaseModel):
    schema_version: int = 1

    app_name: str
    app_version: str
    env: str
    is_production: bool
    is_debug: bool

    api_base: str
    cdn_base: str | None

    docs_enabled: bool
    features: dict[str, bool]

    auth: dict[str, str]

    pagination: dict[str, int]
    defaults: dict[str, str]

    maintenance: MaintenanceConfig
    server_time: str
    server_timezone: str
