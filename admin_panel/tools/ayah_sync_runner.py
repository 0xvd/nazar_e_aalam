from __future__ import annotations

import io
import sys
import threading
import traceback
from contextlib import redirect_stderr, redirect_stdout
from datetime import datetime
from pathlib import Path

from database import db
from database.models import SyncJob
from sqlalchemy import select

from tools import sync_quran as _sq

_ROOT = Path(__file__).resolve().parent.parent
_LOG_DIR = _ROOT / "logs" / "sync"

_TOTAL_AYAHS = sum(_sq.AYAH_COUNTS)


class _Tee(io.TextIOBase):
    """File-only tee. Checkpoints are handled by the flush thread."""

    def __init__(self, fh):
        self._fh = fh
        self._closed = False

    def write(self, s: str) -> int:
        if self._closed or self._fh.closed:
            return len(s)
        try:
            self._fh.write(s)
            self._fh.flush()
        except ValueError:
            self._closed = True
        return len(s)

    def flush(self) -> None:
        if self._closed or self._fh.closed:
            return
        try:
            self._fh.flush()
        except ValueError:
            self._closed = True


def run(job_id: int) -> None:
    _LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_path = _LOG_DIR / f"ayah_{job_id}.log"

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

    n_reciters = len(targets) if targets else len(_sq.RECITERS)
    grand_total = _TOTAL_AYAHS * n_reciters

    _announce(log_path, job_id, targets)

    counters = {
        "processed": 0,
        "total": grand_total,
        "uploaded": 0,
        "skipped": 0,
        "failed": 0,
        "bytes_done": 0,
        "current_file": None,
    }
    counters_lock = threading.Lock()
    stop_flush = threading.Event()
    stop_flag = threading.Event()
    log_lock = threading.Lock()
    current_reciter = {"name": targets[0] if targets else ""}

    def _append_log(line: str) -> None:
        try:
            with log_lock, log_path.open("a", encoding="utf-8") as fh:
                fh.write(line + "\n")
        except Exception:
            pass

    def _flush_and_check() -> bool:
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
        except Exception as exc:
            print(f"[runner] flush error: {type(exc).__name__}: {exc}", flush=True)
            return False

    def _flush_loop() -> None:
        print(f"[runner] flush thread started for job {job_id}", flush=True)
        while not stop_flush.is_set():
            stop_flush.wait(2.0)
            if _flush_and_check():
                stop_flag.set()

    def _heartbeat_loop() -> None:
        while not stop_flush.is_set():
            stop_flush.wait(10.0)
            if stop_flush.is_set():
                break
            with counters_lock:
                snap = dict(counters)
            pct = (snap["processed"] / snap["total"] * 100) if snap["total"] else 0.0
            cur = snap["current_file"] or "—"
            rec = current_reciter["name"] or "—"
            _append_log(
                f"[heartbeat] {rec}: {snap['processed']}/{snap['total']} "
                f"({pct:.1f}%)  ↑{snap['uploaded']}  ↷{snap['skipped']}  "
                f"✗{snap['failed']}  {snap['bytes_done']} bytes  cur={cur}"
            )

    threading.Thread(target=_flush_loop, name=f"flush-{job_id}", daemon=True).start()
    threading.Thread(target=_heartbeat_loop, name=f"hb-{job_id}", daemon=True).start()

    orig_download = _sq.download
    base_processed = {"n": 0}

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
            else:
                try:
                    counters["uploaded"] += 1
                    counters["bytes_done"] += Path(dest).stat().st_size
                except OSError:
                    pass
        return ok

    orig_sync_reciter = _sq.sync_reciter

    def _sync_reciter_checked(client, key, info, *, verbose, dry_run):
        current_reciter["name"] = info.get("name", key)

        result = orig_sync_reciter(client, key, info, verbose=verbose, dry_run=dry_run)

        with counters_lock:
            counters["uploaded"] = counters.get("uploaded", 0)

        return result

    _sq.download = _download_checked
    _sq.sync_reciter = _sync_reciter_checked

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
                except Exception:
                    traceback.print_exc()
                    raise
    except _StopRequested:
        pass
    except Exception as exc:
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
        _sq.sync_reciter = orig_sync_reciter
        sys.argv = _original_argv
        stop_flush.set()
        _flush_and_check()

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


def recover_orphans() -> int:
    with db.session() as s:
        stuck = (
            s.execute(
                select(SyncJob).where(SyncJob.status.in_(("running", "stopping")))
            )
            .scalars()
            .all()
        )
        for j in stuck:
            j.status = "interrupted"
            j.finished_at = datetime.utcnow()
            j.message = "Process restarted before the job finished."
        return len(stuck)
