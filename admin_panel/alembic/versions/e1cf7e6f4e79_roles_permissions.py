from __future__ import annotations

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "e1cf7e6f4e79"
down_revision: str | None = "e1cf7e6f4e78"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("roles", sa.Column("description", sa.String(255), nullable=True))
    op.add_column("roles", sa.Column("permissions_json", sa.JSON(), nullable=True))


def downgrade() -> None:
    op.drop_column("roles", "permissions_json")
    op.drop_column("roles", "description")
