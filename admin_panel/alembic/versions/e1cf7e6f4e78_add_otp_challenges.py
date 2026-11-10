from __future__ import annotations

import sqlalchemy as sa
from alembic import op

revision: str = "e1cf7e6f4e78"
down_revision: str | None = "f655b4fd05e5"


def upgrade() -> None:
    op.create_table(
        "otp_challenges",
        sa.Column("id", sa.BigInteger(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("otp_hash", sa.String(64), nullable=False),
        sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("max_attempts", sa.Integer(), nullable=False, server_default="3"),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("used_at", sa.DateTime(), nullable=True),
        sa.Column("resend_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_resend_at", sa.DateTime(), nullable=True),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()
        ),
        sa.Column(
            "updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "otp_challenges_user_idx", "otp_challenges", ["user_id", "created_at"]
    )
    op.create_index(
        "otp_challenges_active_idx",
        "otp_challenges",
        ["user_id", "used_at", "expires_at"],
    )


def downgrade() -> None:
    op.drop_index("otp_challenges_active_idx", table_name="otp_challenges")
    op.drop_index("otp_challenges_user_idx", table_name="otp_challenges")
    op.drop_table("otp_challenges")
