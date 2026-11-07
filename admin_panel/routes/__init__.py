from routes.admin_backup import router as admin_backup_router
from routes.admin_devices import router as admin_devices_router
from routes.admin_dhikr import router as admin_dhikr_router
from routes.administrator import router as administrator_router
from routes.auth import router as auth_router
from routes.campaign_dhikr import router as c_dhikr_router
from routes.chapter import router as chapter_router
from routes.chapter_detail import (
    composite_router as chapter_verses_full_router,
)
from routes.chapter_detail import (
    crud_router as chapter_verses_router,
)
from routes.prayer_time import router as prayer_time_router
from routes.dua import router as dua_router
from routes.haram_code import router as haram_code_router
from routes.hijri import router as hijri_router
from routes.me import router as me_router
from routes.mosque import router as mosque_router
from routes.panel_config import router as panel_config_router
from routes.prayer_time import router as prayer_time_router
from routes.reciter import router as reciter_router
from routes.role import router as role_router
from routes.search import router as search_router
from routes.setting import router as setting_router
from routes.sifat_name import router as sifat_name_router
from routes.sync import router as sync_router
from routes.translator import router as translator_router
from routes.verse_translation import router as verse_translation_router
from routes.wallpaper import router as wallpaper_router

__all__ = [
    "admin_backup_router",
    "admin_devices_router",
    "admin_dhikr_router",
    "administrator_router",
    "auth_router",
    "c_dhikr_router",
    "chapter_router",
    "chapter_verses_full_router",
    "chapter_verses_router",
    "dhikr_router",
    "c_dhikr_router",
    "admin_devices_router",
    "dua_router",
    "haram_code_router",
    "hijri_router",
    "me_router",
    "mosque_router",
    "panel_config_router",
    "prayer_time_router",
    "reciter_router",
    "role_router",
    "search_router",
    "setting_router",
    "sifat_name_router",
    "sync_router",
    "translator_router",
    "verse_translation_router",
    "wallpaper_router",
]
