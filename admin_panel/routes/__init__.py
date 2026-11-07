"""HTTP routers."""
from routes.administrator import router as administrator_router   # ← new
from routes.auth import router as auth_router
from routes.chapter import router as chapter_router
from routes.chapter_detail import (
    composite_router as chapter_verses_full_router,
    crud_router as chapter_verses_router,
)
from routes.prayer_time import router as prayer_time_router   # ← new
from routes.dhikr import router as dhikr_router
from routes.dua import router as dua_router
from routes.haram_code import router as haram_code_router
from routes.reciter import router as reciter_router
from routes.sifat_name import router as sifat_name_router
from routes.translator import router as translator_router
from routes.verse_translation import router as verse_translation_router
from routes.wallpaper import router as wallpaper_router
from routes.setting import router as setting_router   # ← new
from routes.hijri import router as hijri_router   # ← new
from routes.admin_backup import router as admin_backup_router   # add
from routes.panel_config import router as panel_config_router
from routes.me import router as me_router
from routes.role import router as role_router
from routes.search import router as search_router
from routes.sync import router as sync_router
from routes.mosque import router as mosque_router
from routes.admin_devices import router as admin_devices_router
from routes.dhikr import router as dhikr_router
from routes.admin_dhikr import router as admin_dhikr_router

__all__ = [
    "administrator_router",       # ← new
    "auth_router",
    "chapter_router",
    "mosque_router",
    "chapter_verses_full_router",
    "sync_router",
    "chapter_verses_router",
    "dhikr_router",
    "admin_devices_router",
    "dua_router",
    "haram_code_router",
    "reciter_router",
    "sifat_name_router",
    "translator_router",
    "me_router",
    "verse_translation_router",
    "wallpaper_router",
    "setting_router",
    "prayer_time_router",      # ← new
    "hijri_router",
    "admin_backup_router",
    "panel_config_router",
    "role_router",
    "search_router",
    "dhikr_router",
    "admin_dhikr_router",
]