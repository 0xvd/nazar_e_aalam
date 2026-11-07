"""
SQLAlchemy 2.x ORM models — ported from the Laravel migrations.

Dropped from the original schema (intentional):
  - donations, transactions, payment_methods, categories   (donation feature)
  - jobs, job_batches, failed_jobs                         (Laravel queue)
  - personal_access_tokens                                 (Laravel Sanctum → JWT)
  - reset_passwords                                        (empty table)
  - wallpaper_categories                                   (flat wallpapers now)
  - blog_posts                                             (not needed)

Changed from the original schema:
  - users:    dropped `invitation_token`, `remember_token`
  - users:    added `refresh_tokens` relationship
  - new table `refresh_tokens` — hashed, revocable, multi-device
  - wall_papers: dropped `category_id` and the category relationship
"""
from __future__ import annotations

import enum
from datetime import date, datetime
from typing import Any

from sqlalchemy import (
    JSON,
    BigInteger,
    Boolean,
    Column,
    Date,
    DateTime,
    Enum as SAEnum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Table,
    Text,
    func,
)
from sqlalchemy.dialects.mysql import LONGTEXT
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.database import Base

# --------------------------------------------------------------------------- #
#  Reusable column types / mixins
# --------------------------------------------------------------------------- #

# Laravel `longText` = MySQL LONGTEXT (4 GB). Text() = 64 KB on MySQL, so we
# upgrade it to LONGTEXT on MySQL while staying portable elsewhere.
LongText = Text().with_variant(LONGTEXT(), "mysql")


class TimestampMixin:
    """Laravel's `$table->timestamps()`."""

    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )


# --------------------------------------------------------------------------- #
#  Python enums (mirror Laravel ENUM columns)
# --------------------------------------------------------------------------- #


class Gender(str, enum.Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"


class RevealedPlace(str, enum.Enum):
    MAKKA = "Makka"
    MADINA = "Madina"


class BulkImportStatus(str, enum.Enum):
    """Reference values for bulk_sura_imports.status (column stays String)."""

    QUEUED = "queued"
    EXTRACTING = "extracting"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


# --------------------------------------------------------------------------- #
#  Association (pivot) tables
# --------------------------------------------------------------------------- #

role_user = Table(
    "role_user",
    Base.metadata,
    Column(
        "user_id",
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "role_id",
        BigInteger,
        ForeignKey("roles.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Index("user_role_index", "user_id", "role_id"),
)

permission_role = Table(
    "permission_role",
    Base.metadata,
    Column(
        "role_id",
        BigInteger,
        ForeignKey("roles.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "permission_id",
        BigInteger,
        ForeignKey("permissions.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Index("role_permission_index", "role_id", "permission_id"),
)

# NOTE: swap `mapped_column` → `Column` inside the two Table() defs above if
# your SQLAlchemy version complains — both work in 2.0.x, `Column` is the
# idiomatic choice for standalone association tables.


# --------------------------------------------------------------------------- #
#  Auth / RBAC
# --------------------------------------------------------------------------- #


class User(TimestampMixin, Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    first_name: Mapped[str | None] = mapped_column(String(255))
    last_name: Mapped[str | None] = mapped_column(String(255))
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    email_verified_at: Mapped[datetime | None] = mapped_column(DateTime)
    expired_at: Mapped[datetime | None] = mapped_column(DateTime)
    password: Mapped[str | None] = mapped_column(String(255))
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    devices: Mapped[list["DeviceProfile"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    profile: Mapped[Profile | None] = relationship(
        back_populates="user", uselist=False, cascade="all, delete-orphan"
    )
    roles: Mapped[list[Role]] = relationship(
        secondary=role_user, back_populates="users"
    )
    refresh_tokens: Mapped[list[RefreshToken]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email={self.email!r})>"


class RefreshToken(Base):
    """
    Long-lived refresh token. The raw token is never stored — only its SHA-256
    hash. One row per device / session; revoke individually on logout.
    """

    __tablename__ = "refresh_tokens"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, index=True)
    revoked: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime)
    user_agent: Mapped[str | None] = mapped_column(String(255))
    ip_address: Mapped[str | None] = mapped_column(String(45))
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )

    user: Mapped[User] = relationship(back_populates="refresh_tokens")

    def __repr__(self) -> str:
        return f"<RefreshToken(user_id={self.user_id}, revoked={self.revoked})>"


class DeviceProfile(TimestampMixin, Base):
    """
    A physical device registered against a user (anonymous or admin).

    The `device_uuid` is generated by the client and stored in secure storage.
    On reinstall, the client keeps the same UUID (iOS Keychain / Android
    Keystore) → same account. If the client generates a new UUID (factory
    reset), a new anonymous user is created.
    """

    __tablename__ = "device_profiles"
    __table_args__ = (
        Index("device_profiles_user_idx", "user_id", "revoked"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    device_uuid: Mapped[str] = mapped_column(
        String(64), unique=True, nullable=False, index=True
    )
    platform: Mapped[str | None] = mapped_column(String(10))       # "ios" | "android"
    device_model: Mapped[str | None] = mapped_column(String(100))
    os_version: Mapped[str | None] = mapped_column(String(50))
    app_version: Mapped[str | None] = mapped_column(String(50))

    revoked: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime)

    user: Mapped[User] = relationship(back_populates="devices")

    def __repr__(self) -> str:
        return f"<DeviceProfile(user_id={self.user_id}, uuid={self.device_uuid[:8]}…, revoked={self.revoked})>"



class Profile(TimestampMixin, Base):
    __tablename__ = "profiles"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    gender: Mapped[Gender] = mapped_column(
        SAEnum(Gender, values_callable=lambda x: [e.value for e in x]), nullable=False
    )
    date_of_birth: Mapped[date | None] = mapped_column(Date)
    profile_picture: Mapped[str | None] = mapped_column(String(255))
    phone_number: Mapped[str | None] = mapped_column(String(255))

    user: Mapped[User] = relationship(back_populates="profile")


class Role(TimestampMixin, Base):
    __tablename__ = "roles"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    alias: Mapped[str | None] = mapped_column(String(100))
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    is_default: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")

    users: Mapped[list[User]] = relationship(
        secondary=role_user, back_populates="roles"
    )
    permissions: Mapped[list[Permission]] = relationship(
        secondary=permission_role, back_populates="roles"
    )


class Permission(TimestampMixin, Base):
    __tablename__ = "permissions"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    group_name: Mapped[str] = mapped_column(String(255), nullable=False)

    roles: Mapped[list[Role]] = relationship(
        secondary=permission_role, back_populates="permissions"
    )


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    email: Mapped[str] = mapped_column(String(255), primary_key=True)
    token: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime | None] = mapped_column(DateTime)


# --------------------------------------------------------------------------- #
#  Quran
# --------------------------------------------------------------------------- #


class Translator(TimestampMixin, Base):
    __tablename__ = "translators"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    short_name: Mapped[str] = mapped_column(String(255), nullable=False)
    language: Mapped[str] = mapped_column(String(255), nullable=False)
    language_code: Mapped[str] = mapped_column(String(255), nullable=False)

    chapter_translations: Mapped[list[ChapterTranslation]] = relationship(
        back_populates="translator", cascade="all, delete-orphan"
    )
    verse_translations: Mapped[list[VerseTranslation]] = relationship(
        back_populates="translator", cascade="all, delete-orphan"
    )


class Chapter(TimestampMixin, Base):
    __tablename__ = "chapters"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    arabic_name: Mapped[str] = mapped_column(String(255), nullable=False)
    verses_count: Mapped[int] = mapped_column(Integer, nullable=False)
    revelation_place: Mapped[str] = mapped_column(String(255), nullable=False)
    revelation_order: Mapped[str] = mapped_column(String(255), nullable=False)
    bismillah_pre: Mapped[bool] = mapped_column(Boolean, default=True, server_default="1")

    translations: Mapped[list[ChapterTranslation]] = relationship(
        back_populates="chapter", cascade="all, delete-orphan"
    )
    details: Mapped[list[ChapterDetail]] = relationship(
        back_populates="chapter", cascade="all, delete-orphan"
    )
    verse_translations: Mapped[list[VerseTranslation]] = relationship(
        back_populates="chapter", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Chapter(id={self.id}, arabic_name={self.arabic_name!r})>"


class ChapterTranslation(TimestampMixin, Base):
    __tablename__ = "chapter_translations"
    __table_args__ = (
        Index("chapter_translation_index", "chapter_id", "translator_id", "translate_name"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    chapter_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("chapters.id", ondelete="CASCADE"), nullable=False
    )
    translator_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("translators.id", ondelete="CASCADE"), nullable=False
    )
    translate_name: Mapped[str] = mapped_column(String(255), nullable=False)

    chapter: Mapped[Chapter] = relationship(back_populates="translations")
    translator: Mapped[Translator] = relationship(back_populates="chapter_translations")


class ChapterDetail(TimestampMixin, Base):
    __tablename__ = "chapter_details"
    __table_args__ = (
        Index(
            "chapter_detail_index",
            "chapter_id",
            "verse_number",
            "page_number",
            "juz_number",
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    chapter_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("chapters.id", ondelete="CASCADE"), nullable=False
    )
    arabic_name: Mapped[str] = mapped_column(Text, nullable=False)
    english_transliteration: Mapped[str | None] = mapped_column(Text)
    verse_number: Mapped[int] = mapped_column(Integer, nullable=False)
    verse_key: Mapped[str] = mapped_column(String(10), nullable=False)
    hizb_number: Mapped[int] = mapped_column(Integer, nullable=False)
    rub_el_hizb_number: Mapped[int] = mapped_column(Integer, nullable=False)
    ruku_number: Mapped[int] = mapped_column(Integer, nullable=False)
    manzil_number: Mapped[int] = mapped_column(Integer, nullable=False)
    sajdah_number: Mapped[int] = mapped_column(Integer, nullable=False)
    page_number: Mapped[int] = mapped_column(Integer, nullable=False)
    juz_number: Mapped[int] = mapped_column(Integer, nullable=False)

    chapter: Mapped[Chapter] = relationship(back_populates="details")
    verse_translations: Mapped[list[VerseTranslation]] = relationship(
        back_populates="chapter_detail", cascade="all, delete-orphan"
    )


class VerseTranslation(TimestampMixin, Base):
    __tablename__ = "verse_translations"
    __table_args__ = (
        Index("verse_translation_index", "chapter_id", "translator_id", "verse_number"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    chapter_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("chapters.id", ondelete="CASCADE"), nullable=False
    )
    chapter_detail_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("chapter_details.id", ondelete="CASCADE"), nullable=False
    )
    translator_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("translators.id", ondelete="CASCADE"), nullable=False
    )
    verse_number: Mapped[int] = mapped_column(Integer, nullable=False)
    translate_name: Mapped[str] = mapped_column(Text, nullable=False)

    chapter: Mapped[Chapter] = relationship(back_populates="verse_translations")
    chapter_detail: Mapped[ChapterDetail] = relationship(back_populates="verse_translations")
    translator: Mapped[Translator] = relationship(back_populates="verse_translations")


# --------------------------------------------------------------------------- #
#  Content: duas, dhikrs, sifat_names, haram_codes
# --------------------------------------------------------------------------- #


class Dua(TimestampMixin, Base):
    __tablename__ = "duas"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    position: Mapped[int | None] = mapped_column(Integer)
    en_short_name: Mapped[str | None] = mapped_column(String(255))
    en_full_name: Mapped[str | None] = mapped_column(LongText)
    ar_short_name: Mapped[str | None] = mapped_column(String(255))
    ar_full_name: Mapped[str | None] = mapped_column(LongText)


class Dhikr(TimestampMixin, Base):
    __tablename__ = "dhikrs"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    position: Mapped[int | None] = mapped_column(Integer)
    en_short_name: Mapped[str | None] = mapped_column(String(255))
    en_full_name: Mapped[str | None] = mapped_column(LongText)
    ar_short_name: Mapped[str | None] = mapped_column(String(255))
    ar_full_name: Mapped[str | None] = mapped_column(LongText)


class SifatName(TimestampMixin, Base):
    __tablename__ = "sifat_names"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    position: Mapped[int | None] = mapped_column(Integer)
    name: Mapped[str | None] = mapped_column(String(255))
    ar_name: Mapped[str | None] = mapped_column(String(255))
    translated_name: Mapped[str | None] = mapped_column(Text)
    meaning: Mapped[str | None] = mapped_column(Text)
    name_benefits: Mapped[str | None] = mapped_column(Text)


class HaramCode(TimestampMixin, Base):
    __tablename__ = "haram_codes"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    code: Mapped[str | None] = mapped_column(String(255))
    name: Mapped[str | None] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text)
    status_info: Mapped[str | None] = mapped_column(Text)


# --------------------------------------------------------------------------- #
#  Config / misc
# --------------------------------------------------------------------------- #


class Setting(TimestampMixin, Base):
    __tablename__ = "settings"
    __table_args__ = (
        Index("settingable_index", "settingable_type", "settingable_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    value: Mapped[str | None] = mapped_column(LongText)
    settingable_type: Mapped[str | None] = mapped_column(String(160))
    settingable_id: Mapped[int | None] = mapped_column(BigInteger)
    context: Mapped[str | None] = mapped_column(LongText)


class PrayerTime(TimestampMixin, Base):
    __tablename__ = "prayer_times"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    city: Mapped[str | None] = mapped_column(String(255))
    imsak: Mapped[str | None] = mapped_column(String(255))
    sunrise: Mapped[str | None] = mapped_column(String(255))
    sunset: Mapped[str | None] = mapped_column(String(255))
    fajr_start: Mapped[str | None] = mapped_column(String(255))
    zuhr_start: Mapped[str | None] = mapped_column(String(255))
    asr_start: Mapped[str | None] = mapped_column(String(255))
    maghrib_start: Mapped[str | None] = mapped_column(String(255))
    isha_start: Mapped[str | None] = mapped_column(String(255))
    sehri: Mapped[str | None] = mapped_column(String(255))
    iftar: Mapped[str | None] = mapped_column(String(255))
    iftar_notification: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    sehri_notification: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")
    second: Mapped[str | None] = mapped_column(String(255))
    se_notify: Mapped[str | None] = mapped_column(String(255))


class DeviceInfo(TimestampMixin, Base):
    __tablename__ = "device_infos"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    ip_address: Mapped[str | None] = mapped_column(String(255))
    os: Mapped[str | None] = mapped_column(String(255))
    country: Mapped[str | None] = mapped_column(String(255))
    state: Mapped[str | None] = mapped_column(String(255))
    latitude: Mapped[str | None] = mapped_column(String(255))
    longitude: Mapped[str | None] = mapped_column(String(255))
    count: Mapped[int] = mapped_column(Integer, default=0, server_default="0")


# --------------------------------------------------------------------------- #
#  Reciters / audio
# --------------------------------------------------------------------------- #

class Reciter(TimestampMixin, Base):
    __tablename__ = "reciters"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    position: Mapped[int | None] = mapped_column(Integer)
    profile_picture: Mapped[str | None] = mapped_column(String(255))

    # --- Quran audio metadata (per-ayah, R2-hosted) ---
    bitrate: Mapped[str | None] = mapped_column(String(20))
    total_ayahs: Mapped[int] = mapped_column(
        Integer, default=6236, server_default="6236"
    )
    base_ayah_url: Mapped[str | None] = mapped_column(String(500))

    suras: Mapped[list[ReciterSura]] = relationship(
        back_populates="reciter", cascade="all, delete-orphan"
    )
    bulk_imports: Mapped[list[BulkSuraImport]] = relationship(
        back_populates="reciter", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Reciter(id={self.id}, slug={self.slug!r}, name={self.name!r})>"


class ReciterSura(TimestampMixin, Base):
    __tablename__ = "reciter_suras"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    reciter_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("reciters.id", ondelete="CASCADE"), nullable=False
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    number: Mapped[int] = mapped_column(Integer, nullable=False)
    duration: Mapped[int | None] = mapped_column(Integer)
    revealed_place: Mapped[RevealedPlace] = mapped_column(
        SAEnum(RevealedPlace, values_callable=lambda x: [e.value for e in x]),
        nullable=False,
    )
    path: Mapped[str] = mapped_column(String(255), nullable=False)

    reciter: Mapped[Reciter] = relationship(back_populates="suras")


class BulkSuraImport(TimestampMixin, Base):
    __tablename__ = "bulk_sura_imports"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    reciter_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("reciters.id", ondelete="CASCADE"), nullable=False
    )
    zip_path: Mapped[str | None] = mapped_column(String(255))
    original_name: Mapped[str | None] = mapped_column(String(255))
    replace_existing: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")

    # See BulkImportStatus — kept as String so new states don't need migrations.
    status: Mapped[str] = mapped_column(String(20), nullable=False, default="queued")
    current_file: Mapped[str | None] = mapped_column(String(255))

    total_files: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    processed: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    success_count: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    failed_count: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    skipped_count: Mapped[int] = mapped_column(Integer, default=0, server_default="0")

    message: Mapped[str | None] = mapped_column(Text)
    error_log: Mapped[Any | None] = mapped_column(JSON)

    reciter: Mapped[Reciter] = relationship(back_populates="bulk_imports")


# --------------------------------------------------------------------------- #
#  Wallpapers (flat — no categories)
# --------------------------------------------------------------------------- #


class Wallpaper(TimestampMixin, Base):
    __tablename__ = "wall_papers"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    image: Mapped[str] = mapped_column(String(255), nullable=False)

    def __repr__(self) -> str:
        return f"<Wallpaper(id={self.id}, name={self.name!r})>"

# --------------------------------------------------------------------------- #
#  Sync jobs (long-running background operations)
# --------------------------------------------------------------------------- #


class SyncJob(TimestampMixin, Base):
    """
    A long-running background operation driven from the admin panel.

    Designed to survive worker restarts and page refreshes:
      - `status` + progress counters live in the DB, so any Gunicorn worker
        can answer /status and /logs.
      - `stop_requested` is set by /stop and polled by the runner between
        ayahs — that's the "safe kill" mechanism.
      - `log_path` is a byte-offset-tailable file on disk.
    """

    __tablename__ = "sync_jobs"
    __table_args__ = (
        Index("sync_jobs_status_idx", "status", "started_at"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    kind: Mapped[str] = mapped_column(String(32), nullable=False)  # "ayah"
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="queued", server_default="queued"
    )
    # queued | running | stopping | stopped | done | failed | interrupted

    reciters: Mapped[Any | None] = mapped_column(JSON)  # list[str] | None = all

    total: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    processed: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    uploaded: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    skipped: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    failed: Mapped[int] = mapped_column(Integer, default=0, server_default="0")
    bytes_done: Mapped[int] = mapped_column(BigInteger, default=0, server_default="0")

    current_file: Mapped[str | None] = mapped_column(String(64))
    message: Mapped[str | None] = mapped_column(Text)
    error: Mapped[str | None] = mapped_column(Text)

    log_path: Mapped[str | None] = mapped_column(String(500))
    stop_requested: Mapped[bool] = mapped_column(
        Boolean, default=False, server_default="0"
    )

    started_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL")
    )
    started_at: Mapped[datetime | None] = mapped_column(DateTime)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime)

    def __repr__(self) -> str:
        return f"<SyncJob(id={self.id}, kind={self.kind!r}, status={self.status!r})>"

class MosqueCache(Base):
    __tablename__ = "mosque_cache"
    
    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    # Round lat/lon to 3 decimals (~100m grid) to cache nearby areas
    lat_grid: Mapped[float] = mapped_column(Float, index=True)
    lon_grid: Mapped[float] = mapped_column(Float, index=True)
    radius: Mapped[int] = mapped_column(Integer) # The search radius
    
    # Store the raw JSON response from Google as text
    data: Mapped[str] = mapped_column(Text) 
    
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())

class DhikrCampaign(TimestampMixin, Base):
    """
    A submission window opened by an admin for a specific Islamic occasion
    (e.g. "19th Chand", "Shab-e-Barat"). Multiple campaigns can coexist;
    at most one is typically open at a time, but the schema doesn't enforce
    that — overlapping is allowed and useful for testing.
    """

    __tablename__ = "dhikr_campaigns"
    __table_args__ = (
        Index("dhikr_campaigns_dates_idx", "starts_on", "ends_on"),
        Index("dhikr_campaigns_open_idx", "is_active"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    # Short slug used by the app banner (e.g. "19th-chand-1448-05")
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)

    starts_on: Mapped[date] = mapped_column(Date, nullable=False)
    ends_on: Mapped[date] = mapped_column(Date, nullable=False)

    is_active: Mapped[bool] = mapped_column(Boolean, default=False, server_default="0")

    created_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL")
    )

    submissions: Mapped[list["DhikrSubmission"]] = relationship(
        back_populates="campaign", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<DhikrCampaign(id={self.id}, slug={self.slug!r}, active={self.is_active})>"


class DhikrSubmission(TimestampMixin, Base):
    """A single user's Dhikr submission, tied to a campaign."""

    __tablename__ = "dhikr_submissions"
    __table_args__ = (
        Index("dhikr_submissions_campaign_idx", "campaign_id", "status"),
        Index("dhikr_submissions_user_idx", "user_id"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    campaign_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("dhikr_campaigns.id", ondelete="CASCADE"),
        nullable=False, index=True,
    )
    user_id: Mapped[int] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False, index=True,
    )
    device_uuid: Mapped[str | None] = mapped_column(String(64))  # convenience for admin

    full_name: Mapped[str | None] = mapped_column(String(255))
    phone: Mapped[str | None] = mapped_column(String(20))
    count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    # pending | handled | rejected
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="pending", server_default="pending"
    )
    admin_note: Mapped[str | None] = mapped_column(Text)
    handled_by_id: Mapped[int | None] = mapped_column(
        BigInteger, ForeignKey("users.id", ondelete="SET NULL")
    )
    handled_at: Mapped[datetime | None] = mapped_column(DateTime)

    campaign: Mapped[DhikrCampaign] = relationship(back_populates="submissions")
    user: Mapped["User"] = relationship(foreign_keys=[user_id])

    def __repr__(self) -> str:
        return f"<DhikrSubmission(id={self.id}, campaign_id={self.campaign_id}, count={self.count})>"