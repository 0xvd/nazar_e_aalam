import sqlalchemy as sa
from alembic import op

revision = "e1cf7e6f4e76"
down_revision = "e1cf7e6f4e75"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "location_cache",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("lat_grid", sa.Float(), nullable=False),
        sa.Column("lon_grid", sa.Float(), nullable=False),
        sa.Column("city", sa.String(255), nullable=True),
        sa.Column("state", sa.String(255), nullable=True),
        sa.Column("country", sa.String(255), nullable=True),
        sa.Column("country_code", sa.String(10), nullable=True),
        sa.Column("postcode", sa.String(20), nullable=True),
        sa.Column("timezone", sa.String(100), nullable=True),
        sa.Column("formatted_address", sa.Text(), nullable=True),
        sa.Column("source", sa.String(50), nullable=True),
        sa.Column("ip_address", sa.String(45), nullable=True),
        sa.Column("last_fetched_at", sa.DateTime(), nullable=True),
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
        "location_cache_grid_idx", "location_cache", ["lat_grid", "lon_grid"]
    )


def downgrade() -> None:
    op.drop_index("location_cache_grid_idx", table_name="location_cache")
    op.drop_table("location_cache")
