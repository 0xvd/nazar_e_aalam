from __future__ import annotations

from sqlalchemy.exc import IntegrityError

from config import ENV
from database import db
from repositories.user_repository import UserRepository
from security.passwords import hash_password


def seed_initial_admin() -> None:
    """Create the initial super admin from ENV.INITIAL_ADMIN_* if missing.

    Idempotent and race-safe: if multiple gunicorn workers run this
    simultaneously, exactly one INSERT wins and the rest are no-ops.
    """
    with db.session() as session:
        repo = UserRepository(session)

        if repo.get_by_email(ENV.INITIAL_ADMIN_EMAIL) is not None:
            return

        try:
            repo.create_user(
                email=ENV.INITIAL_ADMIN_EMAIL,
                password_hash=hash_password(ENV.INITIAL_ADMIN_PASSWORD),
                first_name=ENV.INITIAL_ADMIN_FIRST_NAME,
                last_name=ENV.INITIAL_ADMIN_LAST_NAME,
                is_admin=True,
            )
            print(f"[seed] Created initial admin: {ENV.INITIAL_ADMIN_EMAIL}")
        except IntegrityError:
            session.rollback()
            print("[seed] Initial admin already exists, skipped")


def seed_default_roles() -> None:
    """Create default admin roles if missing."""
    from database import db
    from database.models import Role

    defaults = [
        {
            "name": "Super Admin",
            "alias": "super-admin",
            "is_admin": True,
            "is_default": False,
        },
        {"name": "Admin", "alias": "admin", "is_admin": True, "is_default": True},
        {"name": "Editor", "alias": "editor", "is_admin": True, "is_default": False},
    ]
    with db.session() as session:
        from sqlalchemy import select

        for d in defaults:
            already = session.execute(
                select(Role).where(Role.alias == d["alias"])
            ).scalar_one_or_none()
            if already is None:
                session.add(Role(**d))
