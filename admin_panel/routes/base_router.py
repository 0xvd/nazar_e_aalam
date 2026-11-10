from database import Base, BaseRepository, db
from dependencies.auth import require_admin, require_permission
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from pydantic import BaseModel
from schemas.common import Page
from sqlalchemy.orm import Session


def make_crud_router(
    *,
    model: type[Base],
    prefix: str,
    tag: str,
    create_schema: type[BaseModel],
    update_schema: type[BaseModel],
    read_schema: type[BaseModel],
    order_by: str = "id",
    search_fields: tuple[str, ...] = (),
    read_perm: str | None = None,
    write_perm: str | None = None,
    extra_filters: dict[str, str] | None = None,
    public_read: bool = True,
) -> APIRouter:
    """
    CRUD router factory.

    Auth model:
      - `public_read=True` (default): GET / and GET /{id} are UNAUTHENTICATED.
        This is what the mobile app needs.
      - `public_read=False`: GETs require `read_perm` (or admin if unset).
        Use only for internal admin-only resources.
      - All writes (POST, PATCH, DELETE) require `write_perm` (or admin if unset).
    """
    write_dep = require_permission(write_perm) if write_perm else require_admin

    if public_read:
        read_dep = None
    else:
        read_dep = require_permission(read_perm) if read_perm else require_admin

    router = APIRouter(prefix=prefix, tags=[tag])
    repo_cls = type(f"{model.__name__}Repository", (BaseRepository,), {"model": model})
    PageOut = Page[read_schema]  # type: ignore[misc]

    def get_repo(session: Session = Depends(db.get_db)) -> BaseRepository:
        return repo_cls(session)  # type: ignore[return-value]

    def _parent(request: Request) -> dict[str, int]:
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

    if read_dep is None:

        @router.get("", response_model=PageOut)
        def list_items(
            request: Request,
            skip: int = Query(0, ge=0),
            limit: int = Query(50, ge=1, le=500),
            search: str | None = Query(None, max_length=200),
            order_dir: str = Query("asc", pattern="^(asc|desc)$"),
            repo: BaseRepository = Depends(get_repo),
        ):
            return _list_impl(repo, request, skip, limit, search, order_dir)
    else:

        @router.get("", response_model=PageOut)
        def list_items(
            request: Request,
            skip: int = Query(0, ge=0),
            limit: int = Query(50, ge=1, le=500),
            search: str | None = Query(None, max_length=200),
            order_dir: str = Query("asc", pattern="^(asc|desc)$"),
            repo: BaseRepository = Depends(get_repo),
            _=Depends(read_dep),
        ):
            return _list_impl(repo, request, skip, limit, search, order_dir)

    def _list_impl(repo, request, skip, limit, search, order_dir):
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

    if read_dep is None:

        @router.get("/{item_id}", response_model=read_schema)
        def get_item(
            item_id: int,
            request: Request,
            repo: BaseRepository = Depends(get_repo),
        ):
            return _get_impl(item_id, request, repo)
    else:

        @router.get("/{item_id}", response_model=read_schema)
        def get_item(
            item_id: int,
            request: Request,
            repo: BaseRepository = Depends(get_repo),
            _=Depends(read_dep),
        ):
            return _get_impl(item_id, request, repo)

    def _get_impl(item_id, request, repo):
        obj = repo.get(item_id)
        if obj is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
        _ensure_parent(obj, _parent(request))
        return obj

    @router.post("", response_model=read_schema, status_code=status.HTTP_201_CREATED)
    def create_item(
        body: create_schema,  # type: ignore[valid-type]
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(write_dep),
    ):
        data = body.model_dump()
        data.update(_parent(request))
        obj = repo.create(**data)
        repo.save()
        repo.session.refresh(obj)
        return obj

    @router.patch("/{item_id}", response_model=read_schema)
    def update_item(
        item_id: int,
        body: update_schema,  # type: ignore[valid-type]
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(write_dep),
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

    @router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
    def delete_item(
        item_id: int,
        request: Request,
        repo: BaseRepository = Depends(get_repo),
        _=Depends(write_dep),
    ) -> None:
        obj = repo.get(item_id)
        if obj is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Not found")
        _ensure_parent(obj, _parent(request))
        repo.delete(item_id)
        repo.save()

    return router
