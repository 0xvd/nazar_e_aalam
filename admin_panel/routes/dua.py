from database.models import Dua
from schemas.dua import DuaCreate, DuaRead, DuaUpdate

from routes.base_router import make_crud_router

router = make_crud_router(
    model=Dua,
    prefix="/duas",
    tag="duas",
    create_schema=DuaCreate,
    update_schema=DuaUpdate,
    read_schema=DuaRead,
    order_by="position",
    search_fields=("en_short_name", "en_full_name", "ar_short_name", "ar_full_name"),
    read_perm="duas:read",
    write_perm="duas:write",
)
