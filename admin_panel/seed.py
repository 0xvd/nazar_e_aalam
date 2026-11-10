from __future__ import annotations

from config import ENV
from database import db
from database.models import Role, User
from security.passwords import hash_password
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

SUPER_ADMIN_ALIAS = "super-admin"


SUPER_ADMIN_PERMISSIONS = [
    "duas:read",
    "duas:write",
    "dhikrs:read",
    "dhikrs:write",
    "sifat:read",
    "sifat:write",
    "haram-codes:read",
    "haram-codes:write",
    "wallpapers:read",
    "wallpapers:write",
    "reciters:read",
    "reciters:write",
    "chapters:read",
    "chapters:write",
    "administrators:read",
    "administrators:write",
    "invitations:read",
    "invitations:write",
    "roles:read",
    "roles:write",
    "devices:read",
    "devices:write",
    "prayer-times:read",
    "prayer-times:write",
    "hijri:read",
    "hijri:write",
    "dhikr-campaigns:read",
    "dhikr-campaigns:write",
    "settings:read",
    "settings:write",
    "backup:read",
    "backup:write",
    "sync:read",
    "sync:write",
    "uploads:read",
    "uploads:write",
]


def _get_or_create_super_admin_role(session) -> Role:
    role = session.execute(
        select(Role).where(Role.alias == SUPER_ADMIN_ALIAS)
    ).scalar_one_or_none()

    if role is None:
        role = Role(
            name="Super Admin",
            alias=SUPER_ADMIN_ALIAS,
            description="Full access, can do everything",
            is_admin=True,
            is_default=False,
            permissions_json=SUPER_ADMIN_PERMISSIONS,
        )
        session.add(role)
        session.flush()
        return role

    if not role.permissions_json:
        role.permissions_json = SUPER_ADMIN_PERMISSIONS
    return role


def seed_initial_admin() -> None:
    """
    Create the initial super admin from ENV.INITIAL_ADMIN_* if missing,
    and ALWAYS ensure the account has the Super Admin role attached.

    Idempotent and race-safe: if multiple gunicorn workers run this
    simultaneously, exactly one INSERT wins and the rest are no-ops.
    """
    with db.session() as session:
        super_admin_role = _get_or_create_super_admin_role(session)

        email = ENV.INITIAL_ADMIN_EMAIL.lower().strip()
        user = session.execute(
            select(User).where(User.email == email)
        ).scalar_one_or_none()

        if user is None:
            try:
                user = User(
                    email=email,
                    password=hash_password(ENV.INITIAL_ADMIN_PASSWORD),
                    first_name=ENV.INITIAL_ADMIN_FIRST_NAME or None,
                    last_name=ENV.INITIAL_ADMIN_LAST_NAME or None,
                    is_admin=True,
                )
                session.add(user)
                session.flush()
                print(f"[seed] Created initial admin: {email}")
            except IntegrityError:
                session.rollback()
                print(f"[seed] Initial admin already exists (race): {email}")
                return

        role_aliases = {r.alias for r in user.roles}
        if SUPER_ADMIN_ALIAS not in role_aliases:
            user.roles.append(super_admin_role)
            print(f"[seed] Attached Super Admin role to {email}")

        if not user.is_admin:
            user.is_admin = True
            print(f"[seed] Promoted {email} to is_admin=True")


def seed_default_roles() -> None:
    from database.models import Role

    SUPER_ADMIN_PERMS = [
        "duas:read",
        "duas:write",
        "dhikrs:read",
        "dhikrs:write",
        "sifat:read",
        "sifat:write",
        "haram-codes:read",
        "haram-codes:write",
        "wallpapers:read",
        "wallpapers:write",
        "reciters:read",
        "reciters:write",
        "chapters:read",
        "chapters:write",
        "administrators:read",
        "administrators:write",
        "invitations:read",
        "invitations:write",
        "roles:read",
        "roles:write",
        "devices:read",
        "devices:write",
        "prayer-times:read",
        "prayer-times:write",
        "hijri:read",
        "hijri:write",
        "dhikr-campaigns:read",
        "dhikr-campaigns:write",
        "settings:read",
        "settings:write",
        "backup:read",
        "backup:write",
        "sync:read",
        "sync:write",
        "uploads:read",
        "uploads:write",
    ]

    ADMIN_PERMS = [
        "duas:read",
        "duas:write",
        "dhikrs:read",
        "dhikrs:write",
        "sifat:read",
        "sifat:write",
        "haram-codes:read",
        "haram-codes:write",
        "wallpapers:read",
        "wallpapers:write",
        "reciters:read",
        "reciters:write",
        "chapters:read",
        "chapters:write",
        "prayer-times:read",
        "dhikr-campaigns:read",
        "dhikr-campaigns:write",
        "uploads:read",
        "uploads:write",
    ]

    EDITOR_PERMS = [
        "duas:read",
        "dhikrs:read",
        "sifat:read",
        "haram-codes:read",
        "wallpapers:read",
        "reciters:read",
        "chapters:read",
        "prayer-times:read",
        "dhikr-campaigns:read",
        "settings:read",
    ]

    defaults = [
        {
            "name": "Super Admin",
            "alias": "super-admin",
            "description": "Full access, can do everything",
            "permissions_json": SUPER_ADMIN_PERMS,
            "is_admin": True,
            "is_default": False,
        },
        {
            "name": "Admin",
            "alias": "admin",
            "description": "Can read and write content, cannot manage admins",
            "permissions_json": ADMIN_PERMS,
            "is_admin": True,
            "is_default": True,
        },
        {
            "name": "Editor",
            "alias": "editor",
            "description": "Read-only access to content",
            "permissions_json": EDITOR_PERMS,
            "is_admin": True,
            "is_default": False,
        },
    ]

    with db.session() as session:
        for d in defaults:
            existing = session.execute(
                select(Role).where(Role.alias == d["alias"])
            ).scalar_one_or_none()

            if existing is None:
                session.add(Role(**d))
                print(
                    f"[seed] Created role: {d['alias']} with {len(d['permissions_json'])} perms"
                )
            elif not existing.permissions_json:
                existing.permissions_json = d["permissions_json"]
                print(
                    f"[seed] Backfilled {d['alias']} with {len(d['permissions_json'])} perms"
                )
