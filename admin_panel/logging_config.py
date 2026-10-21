"""
Application logging — routes uvicorn, gunicorn, and app logs through
the same handlers (files + console + journald).

Detects whether uvicorn or gunicorn is running and configures accordingly.
Multi-worker safe: uses WatchedFileHandler so logrotate can safely rotate
files under 4 gunicorn workers without losing lines.
"""
from __future__ import annotations

import logging
import logging.handlers
import os
import sys
from pathlib import Path

_ROOT = Path(__file__).resolve().parent
_LOG_DIR = _ROOT / "logs"
_LOG_DIR.mkdir(exist_ok=True)

_FORMAT = "%(asctime)s | %(levelname)-7s | %(name)-22s | %(message)s"
_DATE = "%Y-%m-%d %H:%M:%S"
_RETENTION_DAYS = int(os.getenv("LOG_RETENTION_DAYS", "30"))
_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()


def _running_under_gunicorn() -> bool:
    """True if the current process was started by gunicorn (master or worker)."""
    # gunicorn sets this env var in its workers
    if os.environ.get("SERVER_SOFTWARE", "").lower().startswith("gunicorn"):
        return True
    # Or the entry-point is gunicorn
    argv0 = (sys.argv[0] or "").lower()
    return "gunicorn" in argv0


def setup_logging() -> logging.Logger:
    """
    Configure logging for the app. Idempotent — safe to call from every
    worker import. Uvicorn's startup config does NOT override this because
    our setup runs AFTER uvicorn's dictConfig (main.py import time).
    """
    root = logging.getLogger()

    # Skip if already configured (worker 2..N under gunicorn see master's setup)
    if any(h.get_name() == "nea_app_file" for h in root.handlers):
        return logging.getLogger("nazar")

    # Clear existing handlers — uvicorn's StreamHandler is still there
    for h in root.handlers[:]:
        root.removeHandler(h)

    root.setLevel(_LEVEL)
    formatter = logging.Formatter(_FORMAT, datefmt=_DATE)

    # ---- 1. All-logs file (WatchedFileHandler → safe with logrotate + 4 workers) ----
    app_handler = logging.handlers.WatchedFileHandler(
        _LOG_DIR / "app.log", encoding="utf-8"
    )
    app_handler.setFormatter(formatter)
    app_handler.setLevel(_LEVEL)
    app_handler.set_name("nea_app_file")
    root.addHandler(app_handler)

    # ---- 2. Error-only file ----
    error_handler = logging.handlers.WatchedFileHandler(
        _LOG_DIR / "error.log", encoding="utf-8"
    )
    error_handler.setFormatter(formatter)
    error_handler.setLevel(logging.ERROR)
    error_handler.set_name("nea_error_file")
    root.addHandler(error_handler)

    # ---- 3. Console (also picked up by journald under systemd) ----
    console = logging.StreamHandler()
    console.setFormatter(formatter)
    console.setLevel(_LEVEL)
    console.set_name("nea_console")
    root.addHandler(console)

    # ---- 4. Route uvicorn/gunicorn loggers through our handlers ----
    # Uvicorn sets propagate=False on its loggers; gunicorn does the same.
    # We override to propagate=True so their logs reach our file handlers.
    #
    # If we're under gunicorn, gunicorn's own access/error logs already go
    # to its `accesslog`/`errorlog` files (configured in gunicorn.conf.py).
    # Duplicating them to app.log would be noise — so only route non-access
    # gunicorn loggers, and let access stay in gunicorn_access.log.
    if _running_under_gunicorn():
        logger_names = (
            "gunicorn.error",          # master + worker errors → app.log too
        )
    else:
        logger_names = (
            "uvicorn",                 # startup/shutdown banners
            "uvicorn.error",           # request errors + startup
            "uvicorn.access",          # HTTP access log
        )

    for name in logger_names:
        lg = logging.getLogger(name)
        lg.handlers = []               # remove uvicorn/gunicorn default handlers
        lg.propagate = True            # bubble up to root → our handlers
        lg.setLevel(_LEVEL)

    # ---- 5. Quiet noisy third-party libraries ----
    noisy = {
        "sqlalchemy.engine": logging.INFO if _LEVEL == "DEBUG" else logging.WARNING,
        "sqlalchemy.pool":   logging.WARNING,
        "botocore":          logging.WARNING,
        "boto3":             logging.WARNING,
        "urllib3":           logging.WARNING,
        "httpx":             logging.WARNING,
        "httpcore":          logging.WARNING,
        "alembic":           logging.INFO,
        "watchfiles":        logging.WARNING,
    }
    for name, level in noisy.items():
        logging.getLogger(name).setLevel(level)

    return logging.getLogger("nazar")


def get_logger(name: str | None = None) -> logging.Logger:
    """Get a namespaced logger. Call after setup_logging() at import time."""
    return logging.getLogger(name or "nazar")