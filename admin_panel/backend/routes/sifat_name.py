"""Sifat name (names of Allah) endpoints."""
from database.models import SifatName
from routes.base_router import make_crud_router
from schemas.sifat_name import SifatNameCreate, SifatNameRead, SifatNameUpdate

router = make_crud_router(
    model=SifatName,
    prefix="/sifat-names",
    tag="sifat-names",
    create_schema=SifatNameCreate,
    update_schema=SifatNameUpdate,
    read_schema=SifatNameRead,
    order_by="position",
    search_fields=("name", "ar_name", "translated_name", "meaning"),
)