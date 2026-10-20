"""
VerseTranslation endpoints — nested under /chapters/{chapter_id}/verses/{verse_id}.

Create auto-sets both `chapter_id` and `chapter_detail_id` from the URL path.
"""
from database.models import VerseTranslation
from routes.base_router import make_crud_router
from schemas.verse_translation import (
    VerseTranslationCreate,
    VerseTranslationRead,
    VerseTranslationUpdate,
)

router = make_crud_router(
    model=VerseTranslation,
    prefix="/chapters/{chapter_id}/verses/{verse_id}/translations",
    tag="verse-translations",
    create_schema=VerseTranslationCreate,
    update_schema=VerseTranslationUpdate,
    read_schema=VerseTranslationRead,
    order_by="verse_number",
    search_fields=("translate_name",),
    extra_filters={
        "chapter_id": "chapter_id",
        "verse_id": "chapter_detail_id",
    },
)