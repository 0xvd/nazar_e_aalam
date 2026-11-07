from database.models import Translator
from routes.base_router import make_crud_router
from schemas.translator import (
    TranslatorCreate,
    TranslatorRead,
    TranslatorUpdate,
)

router = make_crud_router(
    model=Translator,
    prefix="/translators",
    tag="translators",
    create_schema=TranslatorCreate,
    update_schema=TranslatorUpdate,
    read_schema=TranslatorRead,
    order_by="full_name",
    search_fields=("full_name", "short_name", "language", "language_code"),
)
