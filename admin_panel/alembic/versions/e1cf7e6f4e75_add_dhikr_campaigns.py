"""add dhikr_campaigns + dhikr_submissions

Revision ID: e1cf7e6f4e75
Revises: e1cf7e6f4e74
"""
from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "e1cf7e6f4e75"
down_revision = "e1cf7e6f4e74"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "dhikr_campaigns",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("title", sa.String(255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("slug", sa.String(100), nullable=False),
        sa.Column("starts_on", sa.Date(), nullable=False),
        sa.Column("ends_on", sa.Date(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default="0"),
        sa.Column("created_by_id", sa.BigInteger(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now(), onupdate=sa.func.now()),
    )
    op.create_index("ix_dhikr_campaigns_slug", "dhikr_campaigns", ["slug"], unique=True)
    op.create_index("dhikr_campaigns_dates_idx", "dhikr_campaigns", ["starts_on", "ends_on"])
    op.create_index("dhikr_campaigns_open_idx", "dhikr_campaigns", ["is_active"])

    op.create_table(
        "dhikr_submissions",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("campaign_id", sa.BigInteger(), sa.ForeignKey("dhikr_campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", sa.BigInteger(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("device_uuid", sa.String(64), nullable=True),
        sa.Column("full_name", sa.String(255), nullable=True),
        sa.Column("phone", sa.String(20), nullable=True),
        sa.Column("count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("admin_note", sa.Text(), nullable=True),
        sa.Column("handled_by_id", sa.BigInteger(), sa.ForeignKey("users.id", ondelete="SET NULL"), nullable=True),
        sa.Column("handled_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now(), onupdate=sa.func.now()),
    )
    op.create_index("ix_dhikr_submissions_campaign_id", "dhikr_submissions", ["campaign_id"])
    op.create_index("ix_dhikr_submissions_user_id", "dhikr_submissions", ["user_id"])
    op.create_index("dhikr_submissions_campaign_idx", "dhikr_submissions", ["campaign_id", "status"])
    op.create_index("dhikr_submissions_user_idx", "dhikr_submissions", ["user_id"])


def downgrade() -> None:
    op.drop_table("dhikr_submissions")
    op.drop_table("dhikr_campaigns")