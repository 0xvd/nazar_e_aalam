"""Chapter (surah) endpoints."""
from database.models import Chapter
from routes.base_router import make_crud_router
from schemas.chapter import ChapterCreate, ChapterRead, ChapterUpdate

router = make_crud_router(
    model=Chapter,
    prefix="/chapters",
    tag="chapters",
    create_schema=ChapterCreate,
    update_schema=ChapterUpdate,
    read_schema=ChapterRead,
    order_by="id",
    search_fields=("arabic_name", "revelation_place"),
)