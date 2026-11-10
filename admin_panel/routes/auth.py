from __future__ import annotations

import hashlib
import secrets
from datetime import UTC, datetime, timedelta

from cache import rate_limiter
from config import ENV
from database import db
from database.models import DeviceProfile, Invitation, OtpChallenge, Role, User
from dependencies.auth import get_current_user
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from repositories.refresh_token_repository import RefreshTokenRepository
from repositories.user_repository import UserRepository
from schemas.auth import (
    DeviceRegisterRequest,
    DeviceRegisterResponse,
    LoginRequest,
    LoginResponse,
    OtpChallengeResponse,
    RefreshRequest,
    ResendOtpRequest,
    TokenPair,
    UserOut,
    VerifyOtpRequest,
)
from schemas.invitation import InvitationAccept, InvitationPublic
from security._jwt import (
    TokenError,
    TokenType,
    create_access_token,
    create_otp_challenge_token,
    create_refresh_token,
    decode_otp_challenge_token,
    decode_token,
)
from security.passwords import hash_password, verify_password
from services.email_service import render_template, send_email
from sqlalchemy import select
from sqlalchemy.orm import Session

router = APIRouter(prefix="/auth", tags=["auth"])
_bearer_optional = HTTPBearer(auto_error=False)
_LAST_OTP: dict[str, str] = {}


def _utcnow_naive() -> datetime:
    return datetime.now(UTC).replace(tzinfo=None)


def _client_ip(request: Request) -> str:
    xff = request.headers.get("x-forwarded-for")
    if xff:
        return xff.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def _read_setting(session: Session, name: str, default: str = "") -> str:
    from database.models import Setting

    row = session.execute(
        select(Setting).where(Setting.name == name, Setting.context == "app")
    ).scalar_one_or_none()
    return row.value if row and row.value is not None else default


def _two_factor_enabled(session: Session) -> bool:
    """Read the 2fa_enabled setting. Production hard-locks to True."""
    if ENV.is_production():
        return True
    raw = _read_setting(session, "2fa_enabled", "true").strip().lower()
    return raw in ("1", "true", "yes", "on")


def _mask_email(email: str) -> str:
    """Mask for display only — 'user@example.com' → 'u***@e***.com'."""
    try:
        local, domain = email.split("@", 1)
        name, _, tld = domain.rpartition(".")
        if not local or not name:
            return "***"
        return (
            f"{local[0]}***@{name[0]}***.{tld}"
            if tld
            else f"{local[0]}***@{name[0]}***"
        )
    except Exception:
        return "***"


def _hash_otp(otp: str) -> str:
    return hashlib.sha256(otp.encode("utf-8")).hexdigest()


def _issue_otp(session: Session, user: User) -> OtpChallenge:

    old = session.execute(
        select(OtpChallenge).where(
            OtpChallenge.user_id == user.id,
            OtpChallenge.used_at.is_(None),
            OtpChallenge.expires_at > _utcnow_naive(),
        )
    ).scalar_one_or_none()
    if old is not None:
        old.used_at = _utcnow_naive()

    otp = f"{secrets.randbelow(1_000_000):06d}"
    challenge = OtpChallenge(
        user_id=user.id,
        otp_hash=_hash_otp(otp),
        expires_at=_utcnow_naive() + timedelta(minutes=5),
        max_attempts=3,
    )
    session.add(challenge)
    session.flush()

    if ENV.is_debug():
        _LAST_OTP[user.email.lower()] = otp

    html = render_template(
        "otp.html",
        first_name=user.first_name or "there",
        otp=otp,
        expires_minutes=5,
    )
    try:
        send_email(
            to=user.email,
            subject="Your Nazar-e-Aalam verification code",
            html_body=html,
        )
    except Exception:
        pass
    return challenge


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


@router.post("/login", response_model=None)
def login(
    body: LoginRequest,
    request: Request,
    session: Session = Depends(db.get_db),
):
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

    if _two_factor_enabled(session):
        challenge = _issue_otp(session, user)
        session.commit()
        token = create_otp_challenge_token(user.id, ttl_minutes=5)
        return OtpChallengeResponse(
            challenge_token=token,
            email_hint=_mask_email(user.email),
            expires_in=300,
            attempts_left=challenge.max_attempts,
        )

    pair = _issue_tokens(session, user, request)
    session.commit()
    return LoginResponse(**pair.model_dump(), user=UserOut.model_validate(user))


@router.post("/verify-otp", response_model=LoginResponse)
def verify_otp(
    body: VerifyOtpRequest,
    request: Request,
    session: Session = Depends(db.get_db),
):

    try:
        claims = decode_otp_challenge_token(body.challenge_token)
    except TokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Verification expired. Please sign in again.",
        ) from exc

    user_id = int(claims["sub"])
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    challenge = (
        session.execute(
            select(OtpChallenge)
            .where(
                OtpChallenge.user_id == user.id,
                OtpChallenge.used_at.is_(None),
            )
            .order_by(OtpChallenge.id.desc())
        )
        .scalars()
        .first()
    )

    if challenge is None or challenge.expires_at <= _utcnow_naive():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Verification expired. Please sign in again.",
        )
    if challenge.attempts >= challenge.max_attempts:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Too many incorrect attempts. Please sign in again.",
        )

    if _hash_otp(body.otp.strip()) != challenge.otp_hash:
        challenge.attempts += 1
        session.commit()
        remaining = max(0, challenge.max_attempts - challenge.attempts)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Incorrect code. {remaining} attempt(s) left.",
        )

    challenge.used_at = _utcnow_naive()
    pair = _issue_tokens(session, user, request)
    session.commit()
    return LoginResponse(**pair.model_dump(), user=UserOut.model_validate(user))


@router.post("/resend-otp", response_model=OtpChallengeResponse)
def resend_otp(
    body: ResendOtpRequest,
    session: Session = Depends(db.get_db),
):
    try:
        claims = decode_otp_challenge_token(body.challenge_token)
    except TokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Verification expired. Please sign in again.",
        ) from exc

    user_id = int(claims["sub"])
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    challenge = (
        session.execute(
            select(OtpChallenge)
            .where(OtpChallenge.user_id == user.id, OtpChallenge.used_at.is_(None))
            .order_by(OtpChallenge.id.desc())
        )
        .scalars()
        .first()
    )

    if challenge is None or challenge.expires_at <= _utcnow_naive():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Verification expired. Please sign in again.",
        )

    if challenge.last_resend_at:
        delta = _utcnow_naive() - challenge.last_resend_at
        if delta.total_seconds() < 30:
            wait = int(30 - delta.total_seconds())
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Please wait {wait}s before requesting a new code.",
            )

    if challenge.resend_count >= 5:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Resend limit reached. Please sign in again.",
        )

    new_otp = f"{secrets.randbelow(1_000_000):06d}"
    challenge.otp_hash = _hash_otp(new_otp)
    challenge.expires_at = _utcnow_naive() + timedelta(minutes=5)
    challenge.attempts = 0
    challenge.resend_count += 1
    challenge.last_resend_at = _utcnow_naive()

    if ENV.is_debug():
        _LAST_OTP[user.email.lower()] = new_otp

    html = render_template(
        "otp.html",
        first_name=user.first_name or "there",
        otp=new_otp,
        expires_minutes=5,
    )
    try:
        send_email(
            to=user.email,
            subject="Your Nazar-e-Aalam verification code",
            html_body=html,
        )
    except Exception:
        pass

    session.commit()
    token = create_otp_challenge_token(user.id, ttl_minutes=5)
    return OtpChallengeResponse(
        challenge_token=token,
        email_hint=_mask_email(user.email),
        expires_in=300,
        attempts_left=challenge.max_attempts,
    )


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


def _hash_invite_token(raw: str) -> str:
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


@router.get("/accept-invite/{token}", response_model=InvitationPublic)
def get_invitation(
    token: str,
    session: Session = Depends(db.get_db),
) -> InvitationPublic:
    inv = session.execute(
        select(Invitation).where(Invitation.token_hash == _hash_invite_token(token))
    ).scalar_one_or_none()
    if inv is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Invalid invitation link")
    if not inv.is_valid:
        raise HTTPException(
            status.HTTP_410_GONE,
            f"This invitation is {inv.status}. Ask an admin to send a new one.",
        )
    return InvitationPublic(
        email=inv.email,
        role_name=inv.role.name if inv.role else None,
        inviter_name=(
            f"{(inv.invited_by.first_name or '')} {(inv.invited_by.last_name or '')}".strip()
            or (inv.invited_by.email if inv.invited_by else None)
        ),
        expires_at=inv.expires_at,
    )


@router.post(
    "/accept-invite",
    response_model=LoginResponse,
    status_code=status.HTTP_201_CREATED,
)
def accept_invitation(
    body: InvitationAccept,
    request: Request,
    session: Session = Depends(db.get_db),
) -> LoginResponse:
    inv = session.execute(
        select(Invitation).where(
            Invitation.token_hash == _hash_invite_token(body.token)
        )
    ).scalar_one_or_none()
    if inv is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Invalid invitation link")
    if not inv.is_valid:
        raise HTTPException(
            status.HTTP_410_GONE,
            f"This invitation is {inv.status}. Ask an admin to send a new one.",
        )

    existing = session.execute(
        select(User).where(User.email == inv.email)
    ).scalar_one_or_none()
    if existing is not None:
        raise HTTPException(
            status.HTTP_409_CONFLICT,
            "An account with this email already exists.",
        )

    user = User(
        email=inv.email,
        password=hash_password(body.password),
        first_name=body.first_name,
        last_name=body.last_name,
        is_admin=True,
        email_verified_at=_utcnow_naive(),
    )
    if inv.role_id is not None:
        role = session.get(Role, inv.role_id)
        if role is not None:
            user.roles = [role]

    session.add(user)
    session.flush()

    inv.used_at = _utcnow_naive()
    inv.accepted_by_id = user.id

    try:
        html = render_template(
            "welcome.html",
            first_name=body.first_name or "there",
            role_name=(user.roles[0].name if user.roles else "Administrator"),
            login_url=f"{ENV.APP_URL.rstrip('/')}/panel/pages/login.html",
        )
        send_email(
            to=user.email,
            subject="Welcome to the Nazar-e-Aalam admin panel",
            html_body=html,
        )
    except Exception:
        pass

    pair = _issue_tokens(session, user, request)
    session.commit()
    session.refresh(user)
    return LoginResponse(
        **pair.model_dump(),
        user=UserOut.model_validate(user),
    )
