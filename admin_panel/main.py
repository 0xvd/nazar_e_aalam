
"""FastAPI entrypoint."""
from __future__ import annotations

import threading
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, APIRouter,Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy import inspect
from starlette.middleware.base import BaseHTTPMiddleware

from config import ENV
from database import init_db
from logging_config import setup_logging
from routes import (
    administrator_router,
    admin_backup_router,
    auth_router,
    chapter_router,
    panel_config_router,
    chapter_verses_full_router,
    chapter_verses_router,
    dhikr_router,
    dua_router,
    haram_code_router,
    hijri_router,
    prayer_time_router,
    reciter_router,
    setting_router,
    sifat_name_router,
    translator_router,
    verse_translation_router,
    wallpaper_router,
    me_router,
    role_router,
    search_router,
)
from seed import seed_initial_admin, seed_default_roles
from tools.seed_chapters import run as seed_chapters

logger = setup_logging()
log = logger


# ---- Startup ---------------------------------------------------------------

@asynccontextmanager
async def lifespan(app: FastAPI):
    from tools.migrate import (
        assert_up_to_date,
        current_revision,
        head_revision,
        is_up_to_date,
    )

    if ENV.is_production():
        # Production: schema must be migrated (systemd ExecStartPre).
        # Fail loudly if migrations are missing.
        assert_up_to_date()
        log.info(f"[db] {current_revision()}")

    else:
        # Development/testing: bootstrap a fresh DB, warn if behind.
        inspector = inspect(__import__("database").db.engine)

        if not inspector.has_table("users"):
            log.info("[db] fresh database — creating schema via create_all")
            init_db()

            # Stamp Alembic to head so future revisions start from a known point.
            from alembic import command
            from tools.migrate import _config

            command.stamp(_config(), "head")
            log.info("[db] fresh schema stamped to alembic head")

        if not is_up_to_date():
            log.warning(
                f"[db] ⚠ schema behind migrations — "
                f"current={current_revision()} head={head_revision()} "
                f"→ run `alembic upgrade head`"
            )

    # Seed initial data.
    seed_initial_admin()
    seed_default_roles()

    try:
        from tools.seed_reciters import run as seed_reciters
        seed_reciters()
    except SystemExit as e:
        log.warning(f"[seed] reciters skipped: {e}")
    except Exception as e:  # noqa: BLE001
        log.warning(f"[seed] reciters failed: {e}")

    seed_chapters()

    # Background schedulers.
    if ENV.CHAND_SCHEDULER_ENABLED:
        from tools import chand
        chand.start()
        log.info("[chand] scheduler started")

    if ENV.BACKUP_AUTO_ENABLED:
        from tools import backup_scheduler
        backup_scheduler.start()
        log.info(
            f"[backup-scheduler] daily at "
            f"{ENV.BACKUP_AUTO_HOUR:02d}:{ENV.BACKUP_AUTO_MINUTE:02d} IST"
        )

    if ENV.SYNC_QURAN_ON_STARTUP:
        from tools.sync_quran import run_all as quran_sync

        threading.Thread(
            target=quran_sync,
            name="quran-sync",
            daemon=True,
        ).start()

    if ENV.is_debug():
        log.info(
            f"STARTUP: env={ENV.APP_ENV} debug={ENV.APP_DEBUG}"
        )
        log.info(
            f"  docs={ENV.show_docs()} sql_echo={ENV.SQL_ECHO}"
        )

    yield


# ---- FastAPI construction --------------------------------------------------

_fastapi_kwargs: dict = {
    "title": ENV.APP_NAME,
    "version": ENV.APP_VERSION,
    "lifespan": lifespan,
    "debug": ENV.is_debug(),
}

if ENV.show_docs():
    _fastapi_kwargs.update({
        "docs_url": "/docs",
        "redoc_url": "/redoc",
        "openapi_url": "/openapi.json",
        "swagger_ui_oauth2_redirect_url": "/docs/oauth2-redirect",
    })
else:
    _fastapi_kwargs.update({
        "docs_url": None,
        "redoc_url": None,
        "openapi_url": None,
    })

app = FastAPI(**_fastapi_kwargs)


# ---- Middleware ------------------------------------------------------------

app.add_middleware(
    CORSMiddleware,
    allow_origins=ENV.CORS_ORIGINS,
    allow_credentials=ENV.CORS_ALLOW_CREDENTIALS,
    allow_methods=["*"],
    allow_headers=["*"],
)


class _DocsGuard(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if ENV.is_production() and request.url.path in {
            "/docs",
            "/redoc",
            "/openapi.json",
            "/docs/oauth2-redirect",
        }:
            return JSONResponse(
                {"detail": "Not Found"},
                status_code=404,
            )

        return await call_next(request)


app.add_middleware(_DocsGuard)


class _SecurityHeaders(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)

        if ENV.is_production():
            response.headers.setdefault(
                "Strict-Transport-Security",
                "max-age=31536000; includeSubDomains",
            )
            response.headers.setdefault(
                "X-Content-Type-Options",
                "nosniff",
            )
            response.headers.setdefault(
                "X-Frame-Options",
                "DENY",
            )
            response.headers.setdefault(
                "Referrer-Policy",
                "strict-origin-when-cross-origin",
            )
            response.headers.setdefault(
                "Permissions-Policy",
                "geolocation=(), microphone=(), camera=()",
            )
        else:
            response.headers["X-Env"] = ENV.APP_ENV

        return response


app.add_middleware(_SecurityHeaders)


class _ErrorShield(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        try:
            return await call_next(request)
        except Exception:
            if ENV.is_debug():
                raise

            log.exception(
                "unhandled exception: %s %s",
                request.method,
                request.url.path,
            )

            return JSONResponse(
                {"detail": "Internal server error"},
                status_code=500,
            )


app.add_middleware(_ErrorShield)


# ---- API Routers -----------------------------------------------------------

# ---- API Routers -----------------------------------------------------------

# All API endpoints are served under /api.
app.include_router(panel_config_router)

api_router = APIRouter(prefix="/api")

api_router.include_router(auth_router)
api_router.include_router(me_router)
api_router.include_router(dua_router)
api_router.include_router(dhikr_router)
api_router.include_router(wallpaper_router)
api_router.include_router(sifat_name_router)
api_router.include_router(haram_code_router)
api_router.include_router(translator_router)
api_router.include_router(chapter_router)
api_router.include_router(reciter_router)
api_router.include_router(chapter_verses_router)
api_router.include_router(chapter_verses_full_router)
api_router.include_router(verse_translation_router)
api_router.include_router(administrator_router)
api_router.include_router(setting_router)
api_router.include_router(prayer_time_router)
api_router.include_router(hijri_router)
api_router.include_router(admin_backup_router)
api_router.include_router(role_router)
api_router.include_router(search_router)

# Register all API routes.
app.include_router(api_router)



# ---- Dev-only /debug router ------------------------------------------------

if ENV.is_debug():
    from routes.debug import router as debug_router

    app.include_router(debug_router)
    log.info("[/debug] dev-only introspection routes enabled")


# ---- Frontend (development AND production) --------------------------------

_FRONTEND = Path(__file__).resolve().parent / "panel"

if _FRONTEND.is_dir():
    app.mount(
        "/panel",
        StaticFiles(directory=str(_FRONTEND), html=True),
        name="panel",
    )

    @app.get("/", include_in_schema=False)
    def _root():
        return RedirectResponse("/panel/index.html")


# ---- Health check ----------------------------------------------------------

@app.get("/health")
def health() -> dict:
    from tools.migrate import current_revision, head_revision

    return {
        "status": "ok",
        "env": ENV.APP_ENV,
        "version": ENV.APP_VERSION,
        "docs": ENV.show_docs(),
        "debug": ENV.is_debug(),
        "alembic": {
            "current": current_revision(),
            "head": head_revision(),
        },
    }
