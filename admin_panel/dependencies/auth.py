"""Auth dependencies for FastAPI routes."""
from __future__ import annotations

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from database import db
from database.models import User
from repositories.user_repository import UserRepository
from security._jwt import TokenError, TokenType, decode_token

_bearer = HTTPBearer(auto_error=False)

_CREDENTIALS_EXC = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Could not validate credentials",
    headers={"WWW-Authenticate": "Bearer"},
)


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: Session = Depends(db.get_db),
) -> User:
    """Resolve the authenticated user from the `Authorization: Bearer …` header."""
    if credentials is None:
        raise _CREDENTIALS_EXC
    try:
        payload = decode_token(
            credentials.credentials, expected_type=TokenType.ACCESS
        )
    except TokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(exc),
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc

    try:
        user_id = int(payload["sub"])
    except (KeyError, ValueError) as exc:
        raise _CREDENTIALS_EXC from exc

    user = UserRepository(session).get(user_id)
    if user is None:
        raise _CREDENTIALS_EXC
    return user


def require_admin(user: User = Depends(get_current_user)) -> User:
    """Like get_current_user, but 403s if the user is not an admin."""
    if not user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )
    return user