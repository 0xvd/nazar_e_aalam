"""
Background runner for `tools.sync_quran`.

Spawned as a daemon thread by routes/sync.py. Owns its own DB sessions so it
never shares a request-scoped Session (important for multi-worker Gunicorn).

Progress reporting is driven by a dedicated 2-second flush thread, NOT by
parsing `sync_quran`'s output. That avoids the whole class of bugs where
progress only updates every 100 files (non-TTY) or never updates at all
(TTY with \r line endings). The flush thread reads an in-memory counters dict
and writes to the DB every 2 seconds, so the admin panel sees fresh progress
even during the "skip existing files" phase, before any download occurs.
"""
from __future__ import annotations

import io
import re
import sys
import threading
import time
import traceback
from contextlib import redirect_stderr, redirect_stdout
from datetime import datetime
from pathlib import Path

from sqlalchemy import select

from database import db
from database.models import SyncJob
from tools import sync_quran as _sq


_ROOT = Path(__file__).resolve().parent.parent
_LOG_DIR = _ROOT / "logs" / "sync"

# Matches progress lines emitted by sync_quran._render_progress (kept for
# optional parsing if we ever want to extract upload/skip/bytes from output).
_PROGRESS_RE = re.compile(
    r"(?P<processed>\d+)/(?P<total>\d+)\s+"
    r"↑(?P<uploaded>\d+)\s+"
    r"↷(?P<skipped>\d+)\s+"
    r"✗(?P<failed>\d+)\s+"
    r"(?P<bytes>[0-9.]+)\s*(?P<unit>[KMG]?B)"
)


def _parse_bytes(num: str, unit: str) -> int:
    n = float(num)
    return int(n * {"B": 1, "KB": 1024, "MB": 1024**2, "GB": 1024**3}[unit])


class _Tee(io.TextIOBase):
    """File-writer only. Progress reporting is handled by the flush thread,
    not by parsing output here, so this class stays focused on logging."""

    def __init__(self, fh):
        self._fh = fh
        self._closed = False

    def write(self, s: str) -> int:  # type: ignore[override]
        if self._closed or self._fh.closed:
            return len(s)
        try:
            self._fh.write(s)
            self._fh.flush()
        except ValueError:
            self._closed = True
        return len(s)

    def flush(self) -> None:  # type: ignore[override]
        if self._closed or self._fh.closed:
            return
        try:
            self._fh.flush()
        except ValueError:
            self._closed = True


# --------------------------------------------------------------------------- #
#  Public entrypoint (called from a thread by routes/sync.py)
# --------------------------------------------------------------------------- #
def run(job_id: int) -> None:
    _LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_path = _LOG_DIR / f"ayah_{job_id}.log"

    # ---- Claim the job atomically ----
    with db.session() as s:
        job = s.get(SyncJob, job_id)
        if job is None:
            return
        if job.status not in ("queued", "running"):
            return
        job.status = "running"
        job.started_at = datetime.utcnow()
        job.log_path = str(log_path)
        targets = list(job.reciters) if job.reciters else []

    _announce(log_path, job_id, targets)

    # ---- Shared state (runner thread writes, flush thread reads) ----
    counters = {
        "processed": 0,
        "total": 0,
        "uploaded": 0,
        "skipped": 0,
        "failed": 0,
        "bytes_done": 0,
        "current_file": None,
    }
    counters_lock = threading.Lock()
    stop_flush = threading.Event()
    stop_flag = threading.Event()  # local mirror of DB's stop_requested

    def _flush_and_check() -> bool:
        """
        Single DB round-trip: writes current counters AND reads stop_requested.
        Returns True if the job should stop.
        Called only from the flush thread (and once at the end).
        """
        try:
            with counters_lock:
                snap = dict(counters)
            with db.session() as s:
                job = s.get(SyncJob, job_id)
                if job is None:
                    return True
                for k, v in snap.items():
                    if v is not None and hasattr(job, k):
                        setattr(job, k, v)
                return bool(job.stop_requested)
        except Exception as exc:  # noqa: BLE001
            print(f"[runner] flush error: {type(exc).__name__}: {exc}", flush=True)
            return False

    def _flush_loop() -> None:
        print(f"[runner] flush thread started for job {job_id}", flush=True)
        while not stop_flush.is_set():
            stop_flush.wait(2.0)
            if _flush_and_check():
                stop_flag.set()

    flush_thread = threading.Thread(
        target=_flush_loop, name=f"flush-{job_id}", daemon=True
    )
    flush_thread.start()

    # ---- Download wrapper: pure in-memory, never touches DB ----
    orig_download = _sq.download

    def _download_checked(url, dest):
        if stop_flag.is_set():
            raise _StopRequested()

        with counters_lock:
            counters["processed"] += 1
            counters["current_file"] = Path(dest).name

        ok = orig_download(url, dest)

        with counters_lock:
            if not ok:
                counters["failed"] += 1
        return ok

    # ---- Optional hook: if sync_quran exposes _progress_hook, use it ----
    if hasattr(_sq, "_progress_hook"):
        def _hook(**kw):
            with counters_lock:
                for k, v in kw.items():
                    if v is not None and k in counters:
                        counters[k] = v
        _sq._progress_hook = _hook

    # ---- Run sync_quran ----
    _sq.download = _download_checked
    _original_argv = sys.argv
    try:
        sys.argv = ["sync_quran"] + targets
        with log_path.open("w", encoding="utf-8", buffering=1) as fh:
            tee = _Tee(fh)
            with redirect_stdout(tee), redirect_stderr(tee):
                try:
                    _sq._IS_TTY = False
                    _sq.cmd_sync(targets, verbose=False, dry_run=False)
                except _StopRequested:
                    print("\n[runner] stopped on request.", flush=True)
                except SystemExit as e:
                    print(f"\n[runner] sync_quran exited: {e}", flush=True)
                except Exception:  # noqa: BLE001
                    traceback.print_exc()
                    raise
    except _StopRequested:
        pass
    except Exception as exc:  # noqa: BLE001
        with db.session() as s:
            job = s.get(SyncJob, job_id)
            if job:
                job.status = "failed"
                job.error = f"{type(exc).__name__}: {exc}"[:2000]
                job.finished_at = datetime.utcnow()
        stop_flush.set()
        return
    finally:
        _sq.download = orig_download
        sys.argv = _original_argv
        stop_flush.set()
        _flush_and_check()  # final flush so last values are persisted

    # ---- Finalise ----
    with db.session() as s:
        job = s.get(SyncJob, job_id)
        if job is None:
            return
        if job.stop_requested:
            job.status = "stopped"
        elif job.failed:
            job.status = "done"
            job.message = f"{job.failed} file(s) failed — rerun to retry."
        else:
            job.status = "done"
        job.finished_at = datetime.utcnow()
        job.current_file = None


def _announce(log_path: Path, job_id: int, targets: list[str]) -> None:
    with log_path.open("a", encoding="utf-8") as fh:
        fh.write(
            f"[runner] job={job_id} started at "
            f"{datetime.utcnow().isoformat(timespec='seconds')}Z\n"
            f"[runner] targets: {targets or '(all)'}\n\n"
        )


class _StopRequested(Exception):
    pass


# --------------------------------------------------------------------------- #
#  Startup recovery (called from main.py lifespan)
# --------------------------------------------------------------------------- #


def recover_orphans() -> int:
    """
    Any job still marked running/stopping at boot means the previous process
    died. Mark them interrupted so the UI doesn't show a ghost job.
    """
    with db.session() as s:
        stuck = s.execute(
            select(SyncJob).where(SyncJob.status.in_(("running", "stopping")))
        ).scalars().all()
        for j in stuck:
            j.status = "interrupted"
            j.finished_at = datetime.utcnow()
            j.message = "Process restarted before the job finished."
        return len(stuck)