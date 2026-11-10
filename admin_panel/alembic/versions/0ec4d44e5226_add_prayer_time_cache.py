from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0ec4d44e5226"
down_revision: str | None = "fe75ad8c00a7"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "prayer_time_cache",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("lat_grid", sa.Float(precision=53), nullable=False),
        sa.Column("lon_grid", sa.Float(precision=53), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("nearest_city", sa.String(50), nullable=True),
        sa.Column("timezone", sa.String(100), nullable=True),
        sa.Column("imsak", sa.String(10), nullable=True),
        sa.Column("fajr_start", sa.String(10), nullable=True),
        sa.Column("sunrise", sa.String(10), nullable=True),
        sa.Column("zuhr_start", sa.String(10), nullable=True),
        sa.Column("asr_start", sa.String(10), nullable=True),
        sa.Column("sunset", sa.String(10), nullable=True),
        sa.Column("maghrib_start", sa.String(10), nullable=True),
        sa.Column("isha_start", sa.String(10), nullable=True),
        sa.Column("is_friday", sa.Boolean(), nullable=False, server_default="0"),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(),
            nullable=False,
            server_default=sa.func.now(),
            onupdate=sa.func.now(),
        ),
    )
    op.create_index(
        "prayer_time_cache_grid_idx",
        "prayer_time_cache",
        ["lat_grid", "lon_grid", "date"],
    )


def downgrade() -> None:
    op.drop_index("prayer_time_cache_grid_idx", table_name="prayer_time_cache")
    op.drop_table("prayer_time_cache")
