from database.models import HaramCode
from routes.base_router import make_crud_router
from schemas.haram_code import HaramCodeCreate, HaramCodeRead, HaramCodeUpdate

router = make_crud_router(
    model=HaramCode,
    prefix="/haram-codes",
    tag="haram-codes",
    create_schema=HaramCodeCreate,
    update_schema=HaramCodeUpdate,
    read_schema=HaramCodeRead,
    order_by="code",
    search_fields=("code", "name", "description"),
)
