"""
Refresh-token persistence.

Raw refresh tokens are never stored — only their SHA-256 hash. Each login /
refresh creates a new row; logout or rotation marks the row revoked.
"""
from __future__ import annotations

import hashlib
from datetime import datetime, timezone

from database.database import BaseRepository
from database.models import RefreshToken


def _utcnow_naive() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


class RefreshTokenRepository(BaseRepository[RefreshToken]):
    model = RefreshToken

    @staticmethod
    def hash_token(raw: str) -> str:
        return hashlib.sha256(raw.encode("utf-8")).hexdigest()

    def issue(
        self,
        *,
        user_id: int,
        raw_token: str,
        expires_at: datetime,
        user_agent: str | None = None,
        ip_address: str | None = None,
    ) -> RefreshToken:
        return self.create(
            user_id=user_id,
            token_hash=self.hash_token(raw_token),
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address,
        )

    def find_active(self, raw_token: str) -> RefreshToken | None:
        row = self.first(token_hash=self.hash_token(raw_token), revoked=False)
        if row is None:
            return None
        if row.expires_at <= _utcnow_naive():
            return None
        return row

    def revoke(self, token: RefreshToken) -> None:
        token.revoked = True
        token.revoked_at = _utcnow_naive()
        self.session.flush()

    def revoke_all_for_user(self, user_id: int) -> int:
        rows = self.filter(user_id=user_id, revoked=False)
        now = _utcnow_naive()
        for row in rows:
            row.revoked = True
            row.revoked_at = now
        self.session.flush()
        return len(rows)