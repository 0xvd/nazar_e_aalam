"""
Generic CRUD router factory — supports nested resources.

    router = make_crud_router(
        model=ChapterDetail,
        prefix="/chapters/{chapter_id}/verses",
        tag="chapter-verses",
        create_schema=ChapterDetailCreate,
        update_schema=ChapterDetailUpdate,
        read_schema=ChapterDetailRead,
        order_by="verse_number",
        extra_filters={"chapter_id": "chapter_id"},
    )

`extra_filters` maps URL path parameter names → DB column names. On list,
create, get, update, delete, the parent FK is enforced automatically.
"""
# NOTE: DO NOT add `from __future__ import annotations` here.
from typing import Type

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database import Base, BaseRepository, db
from dependencies.auth import require_admin
from schemas.common import Page


def make_crud_router(
    *,
    model: Type[Base],
    prefix: str,
    tag: str,
    create_schema: Type[BaseModel],
    update_schema: Type[BaseModel],
    read_schema: Type[BaseModel],
    order_by: str = "id",
    search_fields: tuple[str, ...] = (),
    extra_filters: dict[str, str] | None = None,
) -> APIRouter:
    router = APIRouter(prefix=prefix, tags=[tag])
    repo_cls = type(f"{model.__name__}Repository", (BaseRepository,), {"model": model})
    PageOut = Page[read_schema]  # type: ignore[misc]

    def get_repo(session: Session = Depends(db.get_db)) -> BaseRepository:
        return repo_cls(session)  # type: ignore[return-value]

    def _parent(request: Request) -> dict[str, int]:
        """Extract parent FK values from path params → {db_col: int_value}."""
        if not extra_filters:
            return {}
        out: dict[str, int] = {}
        for url_param, db_col in extra_filters.items():
            raw = request.path_params.get(url_param)
            if raw is None:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    f"Missing path parameter '{url_param}'",
                )
            try:
                out[db_col] = int(raw)
            except (TypeError, ValueError) as exc:
                raise HTTPException(
                    status.HTTP_400_BAD_REQUEST,
                    f"Path parameter '{url_param}' must be an integer",
                ) from exc
        return out

    def _ensure_parent(obj, parent: dict[str, int]) -> None:
        for db_col, val in parent.items():
            if getattr(obj, db_col) != val:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")

    # ---- list ----------------------------------------------------------

    @router.get("", response_model=PageOut)
    def list_items(
        request: Request,
        skip: int = Query(0, ge=0),
        limit: int = Query(50, ge=1, le=500),
        search: str | None = Query(None, max_length=200),
        order_dir: str = Query("asc", pattern="^(asc|desc)$"),
        repo: BaseRepository = Depends(get_repo),
    ):
        parent = _parent(request)
        items, total = repo.paginate(
            skip=skip,
            limit=limit,
            search=search,
            search_fields=search_fields,
            order_by=order_by,
            order_dir=order_dir,
            extra_filters=parent or None,
        )
        return PageOut.build(
            [read_schema.model_validate(i) for i in items],
            total=total,
            skip=skip,
            limit=limit,
        )

    # ---- get one -------------------------------------------------------

    @router.get("/{item_id}", response_model=read_schema)
    def get_item(
        item_id: int,
        request: Request,
        repo: BaseRepository = Depends(get_repo),
    ):
        obj = repo.get(item_id)
        if obj is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
        _ensure_parent(obj, _parent(request))
        return obj

    # ---- create --------------------------------------------------------

    @router.post("", response_model=read_schema, status_code=status.HTTP_201_CREATED)
    def create_item(
        body: create_schema,  # type: ignore[valid-type]
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(require_admin),
    ):
        data = body.model_dump()
        data.update(_parent(request))
        obj = repo.create(**data)
        repo.save()
        repo.session.refresh(obj)
        return obj

    # ---- update --------------------------------------------------------

    @router.patch("/{item_id}", response_model=read_schema)
    def update_item(
        item_id: int,
        body: update_schema,  # type: ignore[valid-type]
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(require_admin),
    ):
        obj = repo.get(item_id)
        if obj is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
        _ensure_parent(obj, _parent(request))

        data = body.model_dump(exclude_unset=True)
        if not data:
            raise HTTPException(status.HTTP_400_BAD_REQUEST, "No fields to update")
        obj = repo.update(item_id, **data)
        repo.save()
        repo.session.refresh(obj)
        return obj

    # ---- delete --------------------------------------------------------

    @router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
    def delete_item(
        item_id: int,
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(require_admin),
    ) -> None:
        obj = repo.get(item_id)
        if obj is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
        _ensure_parent(obj, _parent(request))
        repo.delete(item_id)
        repo.save()

    return router