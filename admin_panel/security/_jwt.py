from __future__ import annotations

import secrets
from datetime import UTC, datetime, timedelta
from typing import Any

import jwt
from config import ENV


class TokenType:
    ACCESS = "access"
    REFRESH = "refresh"


class TokenError(Exception):
    """Raised when a JWT is invalid, expired, or of the wrong type."""


def _now() -> datetime:
    return datetime.now(UTC)


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


def create_access_token(
    subject: int, extra: dict[str, Any] | None = None, *, ttl: timedelta | None = None
) -> str:
    payload = {
        "sub": str(subject),
        "jti": secrets.token_urlsafe(16),
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


def create_otp_challenge_token(subject: int, *, ttl_minutes: int = 5) -> str:
    """
    Short-lived token proving the password step succeeded.

    Cannot be used as an access token — two independent guards prevent it:
      1. Its `type` claim is "otp_challenge" (not "access"), so
         decode_token(expected_type=ACCESS) rejects it.
      2. Its `purpose` claim is "otp_challenge", so get_current_user
         rejects it even if the type check were loosened.
    """
    payload = {
        "sub": str(subject),
        "jti": secrets.token_urlsafe(16),
        "purpose": "otp_challenge",
    }
    return _encode(
        payload,
        timedelta(minutes=ttl_minutes),
        "otp_challenge",
    )


def decode_otp_challenge_token(token: str) -> dict:
    """
    Strictly decode an OTP challenge token. Raises TokenError on any issue
    (expired, wrong type, wrong purpose, tampered).
    """
    claims = decode_token(token, expected_type="otp_challenge")
    if claims.get("purpose") != "otp_challenge":
        raise TokenError("Not an OTP challenge token")
    return claims
