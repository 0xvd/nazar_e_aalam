from database.models import Dhikr
from routes.base_router import make_crud_router
from schemas.dhikr import DhikrCreate, DhikrRead, DhikrUpdate

router = make_crud_router(
    model=Dhikr,
    prefix="/dhikrs",
    tag="dhikrs",
    create_schema=DhikrCreate,
    update_schema=DhikrUpdate,
    read_schema=DhikrRead,
    order_by="position",
    search_fields=("en_short_name", "en_full_name", "ar_short_name", "ar_full_name"),
)
