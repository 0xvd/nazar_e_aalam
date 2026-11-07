from __future__ import annotations

import threading
import time
from abc import ABC, abstractmethod
from collections.abc import Callable
from typing import Any

from config import ENV


class CacheBackend(ABC):
    """Abstract cache backend contract."""

    @abstractmethod
    def get(self, key: str) -> Any | None: ...

    @abstractmethod
    def set(self, key: str, value: Any, ttl: int | None) -> None: ...

    @abstractmethod
    def delete(self, key: str) -> bool: ...

    @abstractmethod
    def exists(self, key: str) -> bool: ...

    @abstractmethod
    def clear(self) -> None: ...

    @abstractmethod
    def delete_prefix(self, prefix: str) -> int: ...

    @abstractmethod
    def ttl(self, key: str) -> int: ...


class MemoryCache(CacheBackend):
    """
    Thread-safe in-process cache with TTL.

    Data is stored in memory — not shared between processes. Good enough for
    a single-worker deployment; use Redis when you scale workers.
    """

    def __init__(self) -> None:
        self._store: dict[str, tuple[Any, float | None]] = {}
        self._lock = threading.RLock()

    @staticmethod
    def _is_expired(expires_at: float | None) -> bool:
        return expires_at is not None and expires_at <= time.time()

    def _purge_if_expired(self, key: str) -> None:
        entry = self._store.get(key)
        if entry and self._is_expired(entry[1]):
            del self._store[key]

    def get(self, key: str) -> Any | None:
        with self._lock:
            self._purge_if_expired(key)
            entry = self._store.get(key)
            return entry[0] if entry else None

    def set(self, key: str, value: Any, ttl: int | None = None) -> None:
        with self._lock:
            expires_at = time.time() + ttl if ttl is not None else None
            self._store[key] = (value, expires_at)

    def delete(self, key: str) -> bool:
        with self._lock:
            return self._store.pop(key, None) is not None

    def exists(self, key: str) -> bool:
        with self._lock:
            self._purge_if_expired(key)
            return key in self._store

    def clear(self) -> None:
        with self._lock:
            self._store.clear()

    def delete_prefix(self, prefix: str) -> int:
        with self._lock:
            keys = [k for k in self._store if k.startswith(prefix)]
            for k in keys:
                del self._store[k]
            return len(keys)

    def ttl(self, key: str) -> int:
        with self._lock:
            self._purge_if_expired(key)
            entry = self._store.get(key)
            if not entry:
                return -2
            if entry[1] is None:
                return -1
            return max(0, int(entry[1] - time.time()))


class Cache:
    """High-level cache API on top of a backend."""

    def __init__(self, backend: CacheBackend) -> None:
        self._backend = backend

    def get(self, key: str, default: Any = None) -> Any:
        value = self._backend.get(key)
        return default if value is None else value

    def set(self, key: str, value: Any, ttl: int | None = None) -> None:
        """
        Store a value. `ttl=None` uses ENV.CACHE_DEFAULT_TTL (or no expiry if
        that is 0). Pass `ttl=0` to explicitly disable expiry.
        """
        effective_ttl = ENV.CACHE_DEFAULT_TTL if ttl is None else ttl
        self._backend.set(key, value, effective_ttl if effective_ttl > 0 else None)

    def delete(self, key: str) -> bool:
        return self._backend.delete(key)

    def exists(self, key: str) -> bool:
        return self._backend.exists(key)

    def clear(self) -> None:
        self._backend.clear()

    def delete_prefix(self, prefix: str) -> int:
        return self._backend.delete_prefix(prefix)

    def ttl(self, key: str) -> int:
        return self._backend.ttl(key)

    def incr(self, key: str, amount: int = 1, ttl: int | None = None) -> int:
        """
        Increment an integer counter.

        - Key missing → created with `amount` and `ttl` (if given).
        - Key present → incremented; existing TTL is preserved.
        """
        current = self._backend.get(key)
        if current is None:
            new_value = amount
            self._backend.set(key, new_value, ttl if ttl and ttl > 0 else None)
        else:
            new_value = int(current) + amount
            remaining = self._backend.ttl(key)
            self._backend.set(key, new_value, remaining if remaining > 0 else None)
        return new_value

    def get_or_set(
        self,
        key: str,
        factory: Callable[[], Any],
        ttl: int | None = None,
    ) -> Any:
        existing = self._backend.get(key)
        if existing is not None:
            return existing
        value = factory()
        self.set(key, value, ttl)
        return value


class RateLimiter:
    """
    Fixed-window rate limiter backed by `Cache`.

    Example:
        allowed, remaining = rate_limiter.hit("login:1.2.3.4", limit=5, window=60)
    """

    def __init__(self, cache: Cache) -> None:
        self._cache = cache

    def hit(
        self,
        key: str,
        *,
        limit: int,
        window: int,
    ) -> tuple[bool, int]:
        """
        Register one hit against `key` inside a `window`-second window.

        Returns (allowed, remaining).
        """
        full_key = f"rl:{key}"
        current = self._cache.incr(full_key, ttl=window)
        remaining = max(0, limit - current)
        return current <= limit, remaining

    def reset(self, key: str) -> None:
        self._cache.delete(f"rl:{key}")


def _build_backend() -> CacheBackend:
    return MemoryCache()


cache = Cache(_build_backend())
rate_limiter = RateLimiter(cache)


__all__ = [
    "Cache",
    "CacheBackend",
    "MemoryCache",
    "RateLimiter",
    "cache",
    "rate_limiter",
]
