from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision = "e1cf7e6f4e74"
down_revision = "e1cf7e6f4e73"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "device_profiles",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column(
            "user_id",
            sa.BigInteger(),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("device_uuid", sa.String(64), nullable=False),
        sa.Column("platform", sa.String(10), nullable=True),
        sa.Column("device_model", sa.String(100), nullable=True),
        sa.Column("os_version", sa.String(50), nullable=True),
        sa.Column("app_version", sa.String(50), nullable=True),
        sa.Column("revoked", sa.Boolean(), nullable=False, server_default="0"),
        sa.Column("revoked_at", sa.DateTime(), nullable=True),
        sa.Column("last_seen_at", sa.DateTime(), nullable=True),
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
        "ix_device_profiles_device_uuid",
        "device_profiles",
        ["device_uuid"],
        unique=True,
    )
    op.create_index("ix_device_profiles_user_id", "device_profiles", ["user_id"])
    op.create_index(
        "device_profiles_user_idx", "device_profiles", ["user_id", "revoked"]
    )


def downgrade() -> None:
    op.drop_index("device_profiles_user_idx", table_name="device_profiles")
    op.drop_index("ix_device_profiles_user_id", table_name="device_profiles")
    op.drop_index("ix_device_profiles_device_uuid", table_name="device_profiles")
    op.drop_table("device_profiles")
