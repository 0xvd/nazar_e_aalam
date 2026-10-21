"""bcrypt password hashing — thin wrapper around the `bcrypt` package."""
from __future__ import annotations

import bcrypt

from config import ENV


def hash_password(password: str) -> str:
    """Hash a plaintext password with bcrypt at ENV.BCRYPT_ROUNDS cost."""
    salt = bcrypt.gensalt(rounds=ENV.BCRYPT_ROUNDS)
    return bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")


def verify_password(password: str, hashed: str) -> bool:
    """Constant-time check of a plaintext password against a bcrypt hash."""
    if not hashed:
        return False
    try:
        return bcrypt.checkpw(password.encode("utf-8"), hashed.encode("utf-8"))
    except (ValueError, TypeError):
        return False