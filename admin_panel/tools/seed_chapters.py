from __future__ import annotations

import json
import sys
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from sqlalchemy import select

from database import db
from database.models import Chapter

DATA_FILE = _ROOT / "data" / "chapters.json"


def run() -> None:
    if not DATA_FILE.exists():
        print(f"[seed_chapters] missing {DATA_FILE} — skipping")
        return

    chapters_data = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    if len(chapters_data) != 114:
        raise SystemExit(
            f"[seed_chapters] expected 114 chapters, got {len(chapters_data)}"
        )

    inserted = updated = 0
    with db.session() as session:
        existing = {c.id: c for c in session.execute(select(Chapter)).scalars().all()}

        for row in chapters_data:
            num = int(row["number"])
            values = {
                "arabic_name": row["arabic_name"],
                "verses_count": int(row["verses_count"]),
                "revelation_place": row["revelation_place"],
                "revelation_order": str(row["revelation_order"]),
                "bismillah_pre": bool(row["bismillah_pre"]),
            }

            current = existing.get(num)
            if current:
                changed = False
                for field, value in values.items():
                    if getattr(current, field) != value:
                        setattr(current, field, value)
                        changed = True
                if changed:
                    updated += 1
            else:
                session.add(Chapter(id=num, **values))
                inserted += 1

    print(f"[seed_chapters] inserted {inserted}, updated {updated}")


if __name__ == "__main__":
    run()
