"""
Authentication endpoints.

  POST /auth/login     → email + password → access + refresh tokens
  POST /auth/refresh   → refresh token    → new access + refresh (rotation)
  POST /auth/logout    → refresh token    → revoke
  GET  /auth/me        → access token     → current user
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from cache import rate_limiter
from config import ENV
from database import db
from database.models import User
from dependencies.auth import get_current_user
from repositories.refresh_token_repository import RefreshTokenRepository
from repositories.user_repository import UserRepository
from schemas.auth import (
    LoginRequest,
    LoginResponse,
    RefreshRequest,
    TokenPair,
    UserOut,
)
from security._jwt import (
    TokenError,
    TokenType,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from security.passwords import verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


# ---- helpers ---------------------------------------------------------------

def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _client_ip(request: Request) -> str:
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def _issue_tokens(
    session: Session,
    user: User,
    request: Request,
) -> TokenPair:
    access = create_access_token(subject=user.id, extra={"admin": user.is_admin})
    raw_refresh = create_refresh_token(subject=user.id)
    expires_at = _utcnow_naive() + timedelta(days=ENV.JWT_REFRESH_TTL_DAYS)

    RefreshTokenRepository(session).issue(
        user_id=user.id,
        raw_token=raw_refresh,
        expires_at=expires_at,
        user_agent=(request.headers.get("user-agent") or "")[:255],
        ip_address=_client_ip(request)[:45],
    )
    return TokenPair(
        access_token=access,
        refresh_token=raw_refresh,
        expires_in=ENV.JWT_ACCESS_TTL_MINUTES * 60,
    )


# ---- endpoints -------------------------------------------------------------

@router.post("/login", response_model=LoginResponse)
def login(
    body: LoginRequest,
    request: Request,
    session: Session = Depends(db.get_db),
) -> LoginResponse:
    if ENV.RATE_LIMIT_ENABLED:
        allowed, _ = rate_limiter.hit(
            f"login:{_client_ip(request)}",
            limit=10,
            window=60,
        )
        if not allowed:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many login attempts. Try again in a minute.",
            )

    user = UserRepository(session).get_by_email(body.email)
    if user is None or not user.password or not verify_password(
        body.password, user.password
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    pair = _issue_tokens(session, user, request)
    session.commit()
    return LoginResponse(**pair.model_dump(), user=UserOut.model_validate(user))


@router.post("/refresh", response_model=TokenPair)
def refresh(
    body: RefreshRequest,
    request: Request,
    session: Session = Depends(db.get_db),
) -> TokenPair:
    try:
        decode_token(body.refresh_token, expected_type=TokenType.REFRESH)
    except TokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)
        ) from exc

    rt_repo = RefreshTokenRepository(session)
    row = rt_repo.find_active(body.refresh_token)
    if row is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token revoked or expired",
        )

    user = UserRepository(session).get(row.user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found"
        )

    # Rotation: revoke the old token, issue a new pair
    rt_repo.revoke(row)
    pair = _issue_tokens(session, user, request)
    session.commit()
    return pair


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(
    body: RefreshRequest,
    session: Session = Depends(db.get_db),
) -> None:
    rt_repo = RefreshTokenRepository(session)
    row = rt_repo.find_active(body.refresh_token)
    if row is not None:
        rt_repo.revoke(row)
        session.commit()
    # If the token is already gone, return 204 anyway (idempotent logout).


@router.get("/me", response_model=UserOut)
def me(user: User = Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(user)