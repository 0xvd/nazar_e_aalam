"""
Application configuration.

Values are read from the environment (populated from `.env` at import time).
Use `ENV.<name>` anywhere in the codebase.

Helpers:
    get_env / get_env_bool / get_env_int / get_env_float / get_env_list
    set_env
    ENV.reload()
"""
from __future__ import annotations

import os
from typing import Any

from dotenv import load_dotenv

# --------------------------------------------------------------------------- #
#  .env loading
# --------------------------------------------------------------------------- #

# override=False → real environment variables win over .env entries.
load_dotenv(override=False)


# --------------------------------------------------------------------------- #
#  Typed getters
# --------------------------------------------------------------------------- #


def get_env(key: str, default: Any = None) -> Any:
    """Return the raw string value of `key`, or `default` if empty/missing."""
    val = os.getenv(key)
    if val is None or val == "":
        return default
    return val


def get_env_bool(key: str, default: bool = False) -> bool:
    val = os.getenv(key)
    if val is None or val == "":
        return default
    return val.strip().lower() in {"1", "true", "yes", "on", "y", "t"}


def get_env_int(key: str, default: int = 0) -> int:
    val = os.getenv(key)
    if val is None or val == "":
        return default
    try:
        return int(val)
    except (ValueError, TypeError):
        return default


def get_env_float(key: str, default: float = 0.0) -> float:
    val = os.getenv(key)
    if val is None or val == "":
        return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


def get_env_list(
    key: str,
    default: list[str] | None = None,
    sep: str = ",",
) -> list[str]:
    val = os.getenv(key)
    if not val:
        return list(default) if default is not None else []
    return [item.strip() for item in val.split(sep) if item.strip()]


def set_env(key: str, value: Any, *, reload_env: bool = True) -> None:
    """
    Set an environment variable. By default, refreshes the ENV class so
    subsequent reads see the new value. Mostly useful in tests.
    """
    os.environ[key] = str(value)
    if reload_env and "ENV" in globals():
        ENV.reload()  # type: ignore[name-defined]


# --------------------------------------------------------------------------- #
#  Config container
# --------------------------------------------------------------------------- #


class ENV:
    """
    Typed configuration container.

    Values are class attributes — read them directly:
        ENV.DATABASE_URL
        ENV.JWT_SIGNING_KEY
        ENV.CORS_ORIGINS

    `reload()` re-reads every value from the environment. Called once at
    module import, and again automatically by `set_env()`.
    """

    # ---- App ------------------------------------------------------------
    APP_NAME: str
    APP_ENV: str
    APP_DEBUG: bool
    APP_VERSION: str
    APP_URL: str
    APP_PORT: int

    # ---- Database -------------------------------------------------------
    DATABASE_URL: str
    SQL_ECHO: bool

    # ---- JWT / auth -----------------------------------------------------
    JWT_SIGNING_KEY: str
    JWT_ALGORITHM: str
    JWT_ACCESS_TTL_MINUTES: int
    JWT_REFRESH_TTL_DAYS: int
    JWT_ISSUER: str

    # ---- Initial admin seed --------------------------------------------
    INITIAL_ADMIN_EMAIL: str
    INITIAL_ADMIN_PASSWORD: str
    INITIAL_ADMIN_FIRST_NAME: str
    INITIAL_ADMIN_LAST_NAME: str

    # ---- Password hashing ----------------------------------------------
    BCRYPT_ROUNDS: int

    # ---- CORS -----------------------------------------------------------
    CORS_ORIGINS: list[str]
    CORS_ALLOW_CREDENTIALS: bool

    # ---- Cookies --------------------------------------------------------
    COOKIE_SECURE: bool
    COOKIE_DOMAIN: str
    COOKIE_SAMESITE: str

    # ---- Cache ----------------------------------------------------------
    CACHE_BACKEND: str
    CACHE_DEFAULT_TTL: int
    REDIS_URL: str

    # ---- Rate limiting --------------------------------------------------
    RATE_LIMIT_ENABLED: bool
    RATE_LIMIT_PER_MINUTE: int

    # ---- Uploads / media -----------------------------------------------
    UPLOAD_DIR: str
    MEDIA_URL: str
    MAX_UPLOAD_SIZE_MB: int

    # ---- Email ----------------------------------------------------------
    SMTP_HOST: str
    SMTP_PORT: int
    SMTP_USER: str
    SMTP_PASSWORD: str
    SMTP_FROM: str
    SMTP_TLS: bool

    # ---- Logging --------------------------------------------------------
    LOG_LEVEL: str

    R2_ACCOUNT_ID: str
    R2_ACCESS_KEY_ID: str
    R2_SECRET_ACCESS_KEY: str
    R2_BUCKET: str
    R2_PUBLIC_BASE_URL: str
    QURAN_MAX_GB: float
    QURAN_MAX_PER_RECITER_GB: float
    SYNC_QURAN_ON_STARTUP: bool
    CHAND_SCHEDULER_ENABLED: bool

    R2_BACKUP_BUCKET: str
    R2_BACKUP_ACCESS_KEY_ID: str
    R2_BACKUP_ACCESS_KEY: str

    BACKUP_AUTO_ENABLED: bool
    BACKUP_AUTO_HOUR: int
    BACKUP_AUTO_MINUTE: int

    LOG_LEVEL: str
    LOG_RETENTION_DAYS: int

    MAINTENANCE_MODE: bool
    MAINTENANCE_MESSAGE: str

    @classmethod
    def reload(cls) -> None:
        """Re-read every value from the environment."""
        values: dict[str, Any] = {
            # App
            "APP_NAME": get_env("APP_NAME", "Nazar-e-Aalam Admin"),
            "APP_ENV": get_env("APP_ENV", "development"),
            "APP_DEBUG": get_env_bool("APP_DEBUG", True),
            "APP_VERSION": get_env("APP_VERSION", "0.1.0"),
            "APP_URL": get_env("APP_URL", "http://localhost:8000"),
            "APP_PORT": get_env_int("APP_PORT", 8000),

            # Database
            "DATABASE_URL": get_env(
                "DATABASE_URL",
                "mysql+pymysql://root@localhost:3306/nazar_e_alam",
            ),
            "SQL_ECHO": get_env_bool("SQL_ECHO", False),

            # JWT / auth
            "JWT_SIGNING_KEY": get_env("JWT_SIGNING_KEY", "change-me-in-production"),
            "JWT_ALGORITHM": get_env("JWT_ALGORITHM", "HS256"),
            "JWT_ACCESS_TTL_MINUTES": get_env_int("JWT_ACCESS_TTL_MINUTES", 15),
            "JWT_REFRESH_TTL_DAYS": get_env_int("JWT_REFRESH_TTL_DAYS", 30),
            "JWT_ISSUER": get_env("JWT_ISSUER", "nazar-e-aalam"),

            # Initial admin seed
            "INITIAL_ADMIN_EMAIL": get_env("INITIAL_ADMIN_EMAIL", "admin@example.com"),
            "INITIAL_ADMIN_PASSWORD": get_env("INITIAL_ADMIN_PASSWORD", "admin123"),
            "INITIAL_ADMIN_FIRST_NAME": get_env("INITIAL_ADMIN_FIRST_NAME", "Admin"),
            "INITIAL_ADMIN_LAST_NAME": get_env("INITIAL_ADMIN_LAST_NAME", ""),

            # Password hashing
            "BCRYPT_ROUNDS": get_env_int("BCRYPT_ROUNDS", 12),

            # CORS
            "CORS_ORIGINS": get_env_list(
                "CORS_ORIGINS",
                ["http://localhost:8000", "http://localhost:5173"],
            ),
            "CORS_ALLOW_CREDENTIALS": get_env_bool("CORS_ALLOW_CREDENTIALS", True),

            # Cookies
            "COOKIE_SECURE": get_env_bool("COOKIE_SECURE", False),
            "COOKIE_DOMAIN": get_env("COOKIE_DOMAIN", ""),
            "COOKIE_SAMESITE": get_env("COOKIE_SAMESITE", "lax"),

            # Cache
            "CACHE_BACKEND": get_env("CACHE_BACKEND", "memory"),
            "CACHE_DEFAULT_TTL": get_env_int("CACHE_DEFAULT_TTL", 300),
            "REDIS_URL": get_env("REDIS_URL", "redis://localhost:6379/0"),

            # Rate limiting
            "RATE_LIMIT_ENABLED": get_env_bool("RATE_LIMIT_ENABLED", True),
            "RATE_LIMIT_PER_MINUTE": get_env_int("RATE_LIMIT_PER_MINUTE", 60),

            # Uploads / media
            "UPLOAD_DIR": get_env("UPLOAD_DIR", "./uploads"),
            "MEDIA_URL": get_env("MEDIA_URL", "/media"),
            "MAX_UPLOAD_SIZE_MB": get_env_int("MAX_UPLOAD_SIZE_MB", 10),

            # Email
            "SMTP_HOST": get_env("SMTP_HOST", ""),
            "SMTP_PORT": get_env_int("SMTP_PORT", 587),
            "SMTP_USER": get_env("SMTP_USER", ""),
            "SMTP_PASSWORD": get_env("SMTP_PASSWORD", ""),
            "SMTP_FROM": get_env("SMTP_FROM", "noreply@example.com"),
            "SMTP_TLS": get_env_bool("SMTP_TLS", True),

            # Logging
            "LOG_LEVEL": get_env("LOG_LEVEL", "INFO"),
                        # Quran audio (Cloudflare R2)
            "R2_ACCOUNT_ID": get_env("R2_ACCOUNT_ID", ""),
            "R2_ACCESS_KEY_ID": get_env("R2_ACCESS_KEY_ID", ""),
            "R2_SECRET_ACCESS_KEY": get_env("R2_SECRET_ACCESS_KEY", ""),
            "R2_BUCKET": get_env("R2_BUCKET", ""),
            "R2_PUBLIC_BASE_URL": get_env("R2_PUBLIC_BASE_URL", "").rstrip("/"),
            "QURAN_MAX_GB": get_env_float("QURAN_MAX_GB", 9.0),
            "QURAN_MAX_PER_RECITER_GB": get_env_float("QURAN_MAX_PER_RECITER_GB", 2.0),
            "SYNC_QURAN_ON_STARTUP": get_env_bool("SYNC_QURAN_ON_STARTUP", False),
            "CHAND_SCHEDULER_ENABLED": get_env_bool("CHAND_SCHEDULER_ENABLED", False),

            "R2_BACKUP_BUCKET": get_env("R2_BACKUP_BUCKET", ""),
            "R2_BACKUP_ACCESS_KEY_ID": get_env("R2_BACKUP_ACCESS_KEY_ID", ""),
            "R2_BACKUP_ACCESS_KEY": get_env("R2_BACKUP_ACCESS_KEY", ""),

            "BACKUP_AUTO_ENABLED": get_env_bool("BACKUP_AUTO_ENABLED", True),
            "BACKUP_AUTO_HOUR": get_env_int("BACKUP_AUTO_HOUR", 3),
            "BACKUP_AUTO_MINUTE": get_env_int("BACKUP_AUTO_MINUTE", 0),
            "LOG_LEVEL": get_env("LOG_LEVEL", "INFO"),
            "LOG_RETENTION_DAYS": get_env_int("LOG_RETENTION_DAYS", 30),

            "MAINTENANCE_MODE": get_env_bool("MAINTENANCE_MODE", False),
            "MAINTENANCE_MESSAGE": get_env("MAINTENANCE_MESSAGE", ""),

        }
        for name, value in values.items():
            setattr(cls, name, value)

    # ---- helpers ---------------------------------------------------------

    @classmethod
    def is_production(cls) -> bool:
        return cls.APP_ENV.lower() == "production"

    @classmethod
    def is_development(cls) -> bool:
        return cls.APP_ENV.lower() == "development"

    @classmethod
    def is_staging(cls) -> bool:
        return cls.APP_ENV.lower() == "staging"

    @classmethod
    def is_testing(cls) -> bool:
        return cls.APP_ENV.lower() == "testing"

    @classmethod
    def is_debug(cls) -> bool:
        """True when verbose/debug behavior should be enabled."""
        return cls.APP_DEBUG and not cls.is_production()

    @classmethod
    def show_docs(cls) -> bool:
        """Docs are shown everywhere except production."""
        return not cls.is_production()

    @classmethod
    def dump(cls, *, safe: bool = True) -> dict[str, Any]:
        """
        Return all values as a dict. When `safe=True`, secrets are masked —
        use this for logging / health endpoints, not for actual work.
        """
        secret_keys = {
            "DATABASE_URL",
            "JWT_SIGNING_KEY",
            "INITIAL_ADMIN_PASSWORD",
            "SMTP_PASSWORD",
        }
        out: dict[str, Any] = {}
        for name in cls.__annotations__:
            value = getattr(cls, name, None)
            if safe and name in secret_keys and value:
                out[name] = "***"
            else:
                out[name] = value
        return out


ENV.reload()


__all__ = [
    "ENV",
    "get_env",
    "get_env_bool",
    "get_env_int",
    "get_env_float",
    "get_env_list",
    "set_env",
]