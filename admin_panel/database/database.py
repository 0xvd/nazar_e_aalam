from __future__ import annotations

from collections.abc import Generator
from contextlib import contextmanager
from typing import Any, Generic, TypeVar

from sqlalchemy import asc, create_engine, desc, func, or_, select
from sqlalchemy.engine import Engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker
from sqlalchemy.sql import Executable

from config import ENV


class Base(DeclarativeBase):
    """Single declarative base shared by every ORM model."""


M = TypeVar("M", bound=Base)


class Database:
    """
    Owns the engine and the session factory. One instance per process.

    All data helpers accept an existing `Session` — the manager never opens
    implicit sessions, so callers always control transaction boundaries.
    """

    def __init__(
        self,
        url: str | None = None,
        *,
        echo: bool | None = None,
        pool_size: int = 10,
        max_overflow: int = 20,
        pool_recycle: int = 3600,
    ) -> None:
        self.url = url or ENV.DATABASE_URL
        self.echo = echo if echo is not None else ENV.SQL_ECHO

        self.engine: Engine = create_engine(
            self.url,
            pool_pre_ping=True,
            pool_recycle=pool_recycle,
            pool_size=pool_size,
            max_overflow=max_overflow,
            echo=self.echo,
            future=True,
        )
        self.SessionLocal: sessionmaker[Session] = sessionmaker(
            bind=self.engine,
            autocommit=False,
            autoflush=False,
            expire_on_commit=False,
            class_=Session,
        )

    def get_session(self) -> Session:
        """Create a new session — the caller owns closing it."""
        return self.SessionLocal()

    @contextmanager
    def session(self) -> Generator[Session, None, None]:
        """Transaction-managed session: commit on success, rollback on error."""
        s = self.SessionLocal()
        try:
            yield s
            s.commit()
        except Exception:
            s.rollback()
            raise
        finally:
            s.close()

    def get_db(self) -> Generator[Session, None, None]:
        """FastAPI dependency — yields a session, always closes it."""
        s = self.SessionLocal()
        try:
            yield s
        except Exception:
            s.rollback()
            raise
        finally:
            s.close()

    def create_all(self) -> None:

        from database import models  # noqa: F401

        Base.metadata.create_all(bind=self.engine)

    def drop_all(self) -> None:
        from database import models  # noqa: F401

        Base.metadata.drop_all(bind=self.engine)

    @staticmethod
    def execute(session: Session, stmt: Executable) -> Any:
        return session.execute(stmt)

    @staticmethod
    def fetch_one(session: Session, stmt: Executable) -> Any:
        return session.execute(stmt).scalar_one_or_none()

    @staticmethod
    def fetch_all(session: Session, stmt: Executable) -> list[Any]:
        return list(session.execute(stmt).scalars().all())

    @staticmethod
    def scalar(session: Session, stmt: Executable) -> Any:
        return session.execute(stmt).scalar()

    @staticmethod
    def commit(session: Session) -> None:
        session.commit()

    @staticmethod
    def rollback(session: Session) -> None:
        session.rollback()


db = Database()


class BaseRepository(Generic[M]):
    """
    Generic CRUD over a single model.

    Usage:
        class UserRepository(BaseRepository[User]):
            model = User

        repo = UserRepository(session)
        user = repo.create(email="a@b.com", password="...")
        repo.save()        # single commit
    """

    model: type[M]

    def __init__(self, session: Session) -> None:
        self.session = session

    def get(self, id_: int) -> M | None:
        return self.session.get(self.model, id_)

    def list(self, *, skip: int = 0, limit: int = 100) -> list[M]:
        stmt = select(self.model).offset(skip).limit(limit)
        return list(self.session.execute(stmt).scalars().all())

    def filter(self, **kwargs: Any) -> list[M]:
        stmt = select(self.model).filter_by(**kwargs)
        return list(self.session.execute(stmt).scalars().all())

    def first(self, **kwargs: Any) -> M | None:
        stmt = select(self.model).filter_by(**kwargs).limit(1)
        return self.session.execute(stmt).scalar_one_or_none()

    def exists(self, **kwargs: Any) -> bool:
        return self.first(**kwargs) is not None

    def count(self) -> int:
        stmt = select(func.count()).select_from(self.model)
        return self.session.execute(stmt).scalar_one()

    def create(self, **kwargs: Any) -> M:
        obj = self.model(**kwargs)
        self.session.add(obj)
        self.session.flush()
        return obj

    def update(self, id_: int, **kwargs: Any) -> M | None:
        obj = self.get(id_)
        if obj is None:
            return None
        for key, value in kwargs.items():
            setattr(obj, key, value)
        self.session.flush()
        return obj

    def delete(self, id_: int) -> bool:
        obj = self.get(id_)
        if obj is None:
            return False
        self.session.delete(obj)
        self.session.flush()
        return True

    def save(self) -> None:
        self.session.commit()

    def rollback(self) -> None:
        self.session.rollback()

    def paginate(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        search: str | None = None,
        search_fields: tuple[str, ...] = (),
        order_by: str | None = None,
        order_dir: str = "asc",
        extra_filters: dict[str, object] | None = None,
    ) -> tuple[list[M], int]:
        """
        Return (items, total). `extra_filters` maps DB column names to values
        — used for parent-scoped nested routes (e.g. {"chapter_id": 1}).
        """
        base = select(self.model)

        if extra_filters:
            for col, val in extra_filters.items():
                if hasattr(self.model, col):
                    base = base.where(getattr(self.model, col) == val)

        if search and search_fields:
            like = f"%{search.strip()}%"
            conditions = [
                getattr(self.model, f).ilike(like)
                for f in search_fields
                if hasattr(self.model, f)
            ]
            if conditions:
                base = base.where(or_(*conditions))

        total = self.session.execute(
            select(func.count()).select_from(base.subquery())
        ).scalar_one()

        if order_by and hasattr(self.model, order_by):
            col = getattr(self.model, order_by)
            base = base.order_by(desc(col) if order_dir.lower() == "desc" else asc(col))
        base = base.order_by(asc(self.model.id))

        items = list(
            self.session.execute(base.offset(skip).limit(limit)).scalars().all()
        )
        return items, total


def get_db() -> Generator[Session, None, None]:
    """FastAPI dependency alias — `Depends(get_db)` or `Depends(db.get_db)`."""
    yield from db.get_db()


def init_db() -> None:
    """Dev bootstrap — prefer Alembic in production."""
    db.create_all()
