from collections.abc import Sequence

revision: str = "f655b4fd05e5"
down_revision: str | None = ("0ec4d44e5226", "e1cf7e6f4e77")
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
