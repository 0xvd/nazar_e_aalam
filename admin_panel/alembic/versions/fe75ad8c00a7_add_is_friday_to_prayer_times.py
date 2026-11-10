from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "fe75ad8c00a7"
down_revision: str | None = "e1cf7e6f4e76"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column(
        "prayer_times",
        sa.Column("is_friday", sa.Boolean(), nullable=False, server_default="0"),
    )


def downgrade() -> None:
    op.drop_column("prayer_times", "is_friday")
