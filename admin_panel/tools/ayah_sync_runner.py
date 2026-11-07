"""
Background runner for `tools.sync_quran`.

Spawned as a daemon thread by routes/sync.py. Owns its own DB sessions so it
never shares a request-scoped Session (important for multi-worker Gunicorn).

Checkpoint strategy: `sync_quran.sync_reciter` already deletes each file from
local staging after upload and skips R2 keys it already has — so a job that is
stopped and later restarted simply resumes from whatever isn't in R2 yet.
This module just needs to persist *counters* so the UI can show progress.
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

# Matches the progress lines emitted by sync_quran._render_progress:
#   "  ███░░ ...  1234/6236  ↑10  ↷50  ✗0  1.23 MB  ..."
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
    """File + optional secondary stream, with line buffering and
    a hook that watches for progress lines and writes checkpoints."""

    def __init__(self, fh, job_id: int, checkpoint_cb):
        self._fh = fh
        self._job_id = job_id
        self._cb = checkpoint_cb
        self._buf = ""
        self._last_ckpt = 0.0
        self._closed = False    # ← NEW

    def write(self, s: str) -> int:  # type: ignore[override]
        if self._closed or self._fh.closed:
            return len(s)
        try:
            self._fh.write(s)
            self._fh.flush()
        except ValueError:
            self._closed = True
            return len(s)

        self._buf += s
        # sync_quran emits progress with \r (TTY) or \n (pipe).
        # Split on either so checkpoints fire in both modes.
        while True:
            m = re.search(r"[\r\n]", self._buf)
            if not m:
                break
            pos = m.start()
            line = self._buf[:pos]
            self._buf = self._buf[pos + 1:]
            self._maybe_checkpoint(line)
        return len(s)

    def flush(self) -> None:  # type: ignore[override]
        if self._closed or self._fh.closed:    # ← guard
            return
        try:
            self._fh.flush()
        except ValueError:
            self._closed = True

    def close(self) -> None:    # ← NEW: mark closed explicitly
        self._closed = True
        try:
            self._fh.flush()
        except Exception:
            pass

    def _maybe_checkpoint(self, line: str) -> None:
        m = _PROGRESS_RE.search(line)
        if not m:
            return
        now = time.monotonic()
        if now - self._last_ckpt < 2.0:
            return
        self._last_ckpt = now
        self._cb(
            processed=int(m["processed"]),
            total=int(m["total"]),
            uploaded=int(m["uploaded"]),
            skipped=int(m["skipped"]),
            failed=int(m["failed"]),
            bytes_done=_parse_bytes(m["bytes"], m["unit"]),
        )

# --------------------------------------------------------------------------- #
#  Public entrypoint (called from a thread by routes/sync.py)
# --------------------------------------------------------------------------- #
def run(job_id: int) -> None:
    _LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_path = _LOG_DIR / f"ayah_{job_id}.log"

    # Claim the job atomically.
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

    # ---- counters we track ourselves (no parsing needed) ---- #
    counters = {
        "processed": 0,
        "uploaded": 0,
        "skipped": 0,
        "failed": 0,
        "bytes_done": 0,
        "current_file": None,
    }
    last_checkpoint = {"at": 0.0}
    counters_lock = threading.Lock()

    def _flush_checkpoint(force: bool = False) -> None:
        now = time.monotonic()
        if not force and now - last_checkpoint["at"] < 2.0:
            return
        last_checkpoint["at"] = now
        _save_progress(job_id, **counters)

    def _should_stop() -> bool:
        with db.session() as s:
            j = s.get(SyncJob, job_id)
            return bool(j and j.stop_requested)

    # ---- wrap download so we can count every ayah ---- #
    orig_download = _sq.download
    _stopped = threading.Event()

    def _download_checked(url, dest):
        if _stopped.is_set():
            raise _StopRequested()
        if _should_stop():
            _stopped.set()
            raise _StopRequested()

        # Derive ayah filename from dest for current_file
        with counters_lock:
            counters["current_file"] = Path(dest).name
            counters["processed"] += 1

        ok = orig_download(url, dest)
        with counters_lock:
            if not ok:
                counters["failed"] += 1
            _flush_checkpoint()
        return ok

    _sq.download = _download_checked
    _original_argv = sys.argv
    try:
        sys.argv = ["sync_quran"] + targets
        with log_path.open("w", encoding="utf-8", buffering=1) as fh:
            tee = _Tee(fh, job_id, lambda **kw: None)  # tee no longer checkpoints
            with redirect_stdout(tee), redirect_stderr(tee):
                try:
                    _sq._IS_TTY = False
                    _sq.cmd_sync(targets, verbose=False, dry_run=False)
                except _StopRequested:
                    print("\n[runner] stopped on request.", flush=True)
                except SystemExit as e:
                    print(f"\n[runner] sync_quran exited: {e}", flush=True)
                except Exception:
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
        return
    finally:
        _sq.download = orig_download
        sys.argv = _original_argv

    # ---- finalise ---- #
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

_CHECKPOINT_ERRORS_LOGGED: set[int] = set()

def _save_progress(job_id: int, **kw) -> None:
    try:
        with db.session() as s:
            job = s.get(SyncJob, job_id)
            if job is None:
                return
            for k, v in kw.items():
                if v is not None and hasattr(job, k):
                    setattr(job, k, v)
    except Exception as exc:  # noqa: BLE001
        if job_id not in _CHECKPOINT_ERRORS_LOGGED:
            _CHECKPOINT_ERRORS_LOGGED.add(job_id)
            print(
                f"[runner] checkpoint FAILED for job {job_id}: "
                f"{type(exc).__name__}: {exc}",
                flush=True,
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