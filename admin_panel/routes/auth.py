from __future__ import annotations

from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from cache import rate_limiter
from config import ENV
from database import db
from database.models import DeviceProfile, User
from dependencies.auth import get_current_user
from repositories.refresh_token_repository import RefreshTokenRepository
from repositories.user_repository import UserRepository
from schemas.auth import (
    DeviceRegisterRequest,
    DeviceRegisterResponse,
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
_bearer_optional = HTTPBearer(auto_error=False)


def _utcnow_naive() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


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
    if (
        user is None
        or not user.password
        or not verify_password(body.password, user.password)
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


@router.get("/me", response_model=UserOut)
def me(user: User = Depends(get_current_user)) -> UserOut:
    return UserOut.model_validate(user)


@router.post("/device/register", response_model=DeviceRegisterResponse)
def register_device(
    body: DeviceRegisterRequest,
    request: Request,
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_optional),
    session: Session = Depends(db.get_db),
) -> DeviceRegisterResponse:
    """
    Register (or resume) an anonymous device.

    Rules:
    - No token   + brand-new UUID      → create user, issue long-lived token
    - No token   + UUID already exists → 401 (can't claim someone else's device)
    - Valid token + UUID matches claim → resume, update last_seen, refresh token
    - Valid token + UUID differs       → 403 (can't hijack another device)
    - Any token that's revoked/expired → 401 (client must clear and try again with no token,
                                           but that path is also blocked if UUID exists)
    """

    if ENV.RATE_LIMIT_ENABLED:
        allowed, _ = rate_limiter.hit(
            f"device-register:{_client_ip(request)}",
            limit=ENV.DEVICE_REGISTER_RATE_LIMIT,
            window=60,
        )
        if not allowed:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many device registrations. Try again in a minute.",
            )

    uuid = body.device_uuid.strip()

    claims = None
    if credentials is not None:
        try:
            claims = decode_token(
                credentials.credentials, expected_type=TokenType.ACCESS
            )
        except TokenError:
            claims = None

    profile = session.query(DeviceProfile).filter_by(device_uuid=uuid).one_or_none()

    if profile is None and claims is not None:
        try:
            _ = int(claims["sub"])
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    "Token is present but this device is not registered to it. "
                    "Clear your local token to start fresh."
                ),
            )
        except (KeyError, ValueError):
            claims = None

    if profile is not None and profile.revoked:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This device has been deactivated. Contact support.",
        )

    if profile is not None:
        if claims is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Device is already registered. Log in or reinstall to continue.",
                headers={"WWW-Authenticate": "Bearer"},
            )
        try:
            token_user_id = int(claims["sub"])
        except (KeyError, ValueError):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Malformed token.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if token_user_id != profile.user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Token does not belong to this device.",
            )

        if claims.get("dev") and claims["dev"] != uuid[:12]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Token was issued for a different device.",
            )

    is_new_user = False
    guest_email = f"guest+{uuid}@device.local"

    if profile is None:
        user = User(
            is_admin=False,
            email=guest_email,
            email_verified_at=_utcnow_naive(),
        )
        session.add(user)
        session.flush()
        is_new_user = True

        profile = DeviceProfile(
            user_id=user.id,
            device_uuid=uuid,
            platform=body.platform,
            device_model=body.device_model,
            os_version=body.os_version,
            app_version=body.app_version,
            last_seen_at=_utcnow_naive(),
        )
        session.add(profile)
    else:
        user = session.get(User, profile.user_id)
        if user is None:
            user = User(
                is_admin=False,
                email=guest_email,
                email_verified_at=_utcnow_naive(),
            )
            session.add(user)
            session.flush()
            profile.user_id = user.id
            is_new_user = True

        profile.last_seen_at = _utcnow_naive()
        if body.platform:
            profile.platform = body.platform
        if body.device_model:
            profile.device_model = body.device_model
        if body.os_version:
            profile.os_version = body.os_version
        if body.app_version:
            profile.app_version = body.app_version

    ttl = timedelta(days=ENV.DEVICE_TOKEN_TTL_DAYS)
    access = create_access_token(
        subject=user.id,
        extra={"dev": uuid[:12], "admin": user.is_admin},
        ttl=ttl,
    )
    session.commit()

    return DeviceRegisterResponse(
        access_token=access,
        expires_in=int(ttl.total_seconds()),
        user_id=user.id,
        is_new_user=is_new_user,
    )
