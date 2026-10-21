"""User-specific data access."""
from __future__ import annotations

from datetime import datetime, timezone

from database.database import BaseRepository
from database.models import User


class UserRepository(BaseRepository[User]):
    model = User

    def get_by_email(self, email: str) -> User | None:
        return self.first(email=email.lower().strip())

    def create_user(
        self,
        *,
        email: str,
        password_hash: str,
        first_name: str | None = None,
        last_name: str | None = None,
        is_admin: bool = False,
        email_verified: bool = True,
    ) -> User:
        return self.create(
            email=email.lower().strip(),
            password=password_hash,
            first_name=first_name,
            last_name=last_name,
            is_admin=is_admin,
            email_verified_at=(
                datetime.now(timezone.utc).replace(tzinfo=None)
                if email_verified
                else None
            ),
        )