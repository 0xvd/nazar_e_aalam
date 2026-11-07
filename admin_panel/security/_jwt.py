"""
JWT helpers — access and refresh tokens.

Both are JWT-signed. The refresh token is also tracked in the DB
(`refresh_tokens` table) so it can be revoked on logout or rotation.

Note: this module is named `_jwt.py` (not `jwt.py`) to avoid shadowing the
top-level `jwt` (PyJWT) package.
"""
from __future__ import annotations

import secrets
from datetime import datetime, timedelta, timezone
from typing import Any

import jwt

from config import ENV


class TokenType:
    ACCESS = "access"
    REFRESH = "refresh"


class TokenError(Exception):
    """Raised when a JWT is invalid, expired, or of the wrong type."""


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _encode(payload: dict[str, Any], ttl: timedelta, token_type: str) -> str:
    now = _now()
    data = {
        **payload,
        "type": token_type,
        "iss": ENV.JWT_ISSUER,
        "iat": now,
        "exp": now + ttl,
    }
    return jwt.encode(data, ENV.JWT_SIGNING_KEY, algorithm=ENV.JWT_ALGORITHM)


def create_access_token(subject: int, extra: dict[str, Any] | None = None, *, ttl: timedelta | None = None) -> str:
    payload = {
        "sub": str(subject),
        "jti": secrets.token_urlsafe(16),   # ← unique per token
        **(extra or {}),
    }
    return _encode(
        payload,
        ttl or timedelta(minutes=ENV.JWT_ACCESS_TTL_MINUTES),
        TokenType.ACCESS,
    )


def create_refresh_token(subject: int) -> str:
    return _encode(
        {"sub": str(subject), "jti": secrets.token_urlsafe(16)},
        timedelta(days=ENV.JWT_REFRESH_TTL_DAYS),
        TokenType.REFRESH,
    )


def decode_token(token: str, expected_type: str | None = None) -> dict[str, Any]:
    """Decode and validate a token. Raises TokenError on any failure."""
    try:
        data = jwt.decode(
            token,
            ENV.JWT_SIGNING_KEY,
            algorithms=[ENV.JWT_ALGORITHM],
            issuer=ENV.JWT_ISSUER,
            options={"require": ["exp", "iat", "iss", "sub"]},
        )
    except jwt.ExpiredSignatureError as exc:
        raise TokenError("Token has expired") from exc
    except jwt.InvalidTokenError as exc:
        raise TokenError(f"Invalid token: {exc}") from exc

    if expected_type and data.get("type") != expected_type:
        raise TokenError(f"Expected {expected_type} token, got {data.get('type')!r}")
    return data