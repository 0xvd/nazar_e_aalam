from __future__ import annotations

from sqlalchemy import inspect, select

from config import ENV
from database import db
from database.models import Reciter
from tools.sync_quran import AYAH_COUNTS, RECITERS

REQUIRED_COLUMNS = {"slug", "base_ayah_url", "bitrate", "total_ayahs"}


def _verify_schema() -> None:
    """Fail early with a clear message if the `reciters` table is out of date."""
    inspector = inspect(db.engine)
    if not inspector.has_table("reciters"):
        return
    cols = {c["name"] for c in inspector.get_columns("reciters")}
    missing = REQUIRED_COLUMNS - cols
    if missing:
        raise SystemExit(
            f"✗ Table `reciters` is missing columns: {sorted(missing)}.\n"
            "  The dev DB was created before the Reciter model gained these fields.\n"
            "  Recreate it:\n\n"
            "    mysql -u root nazar_e_alam <<'SQL'\n"
            "    DROP TABLE IF EXISTS reciter_suras;\n"
            "    DROP TABLE IF EXISTS bulk_sura_imports;\n"
            "    DROP TABLE IF EXISTS reciters;\n"
            "    SQL\n\n"
            "  Then restart the app (or run `python -c 'from database import init_db; init_db()'`)."
        )


def run() -> None:
    if not ENV.R2_PUBLIC_BASE_URL:
        print("[seed] R2_PUBLIC_BASE_URL not set — skipping reciter seed")
        return

    _verify_schema()

    total_ayahs = sum(AYAH_COUNTS)

    with db.session() as session:
        for position, (slug, info) in enumerate(RECITERS.items(), start=1):
            existing = session.execute(
                select(Reciter).where(Reciter.slug == slug)
            ).scalar_one_or_none()

            base_url = f"{ENV.R2_PUBLIC_BASE_URL.rstrip('/')}/reciters/{slug}/ayahs/"

            if existing:
                existing.base_ayah_url = base_url
                existing.position = position
                print(f"[seed] Updated: {info['name']}")
                continue

            session.add(
                Reciter(
                    slug=slug,
                    name=info["name"],
                    position=position,
                    bitrate=info["bitrate"],
                    total_ayahs=total_ayahs,
                    base_ayah_url=base_url,
                )
            )
            print(f"[seed] Created: {info['name']}  →  {base_url}")

    print("[seed] Reciters registered.")


if __name__ == "__main__":
    run()
