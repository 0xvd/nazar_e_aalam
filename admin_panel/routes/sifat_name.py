from database.models import SifatName
from schemas.sifat_name import SifatNameCreate, SifatNameRead, SifatNameUpdate

from routes.base_router import make_crud_router

router = make_crud_router(
    model=SifatName,
    prefix="/sifat-names",
    tag="sifat-names",
    create_schema=SifatNameCreate,
    update_schema=SifatNameUpdate,
    read_schema=SifatNameRead,
    order_by="position",
    search_fields=("name", "ar_name", "translated_name", "meaning"),
    read_perm="sifat:read",
    write_perm="sifat:write",
)
