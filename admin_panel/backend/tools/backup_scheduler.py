"""
In-app backup scheduler.

Runs `scripts/backup.sh` once per day at BACKUP_AUTO_HOUR:BACKUP_AUTO_MINUTE.
Tracks last/next run in memory. Exposes state for the /admin/backup/status
endpoint.

Does NOT replace cron — if both are configured, a nightly cron + an in-app
scheduler will each run a backup. Use one or the other.
"""
from __future__ import annotations

import subprocess
import threading
import time
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

from config import ENV


_ROOT = Path(__file__).resolve().parent.parent
_SCRIPT = _ROOT / "scripts" / "backup.sh"
_TZ = ZoneInfo("Asia/Kolkata")

_state: dict = {
    "running": False,
    "last_run_at": None,       # ISO string
    "last_run_status": None,   # "success" | "failed"
    "last_run_output": None,
}
_lock = threading.Lock()


# --------------------------------------------------------------------------- #
#  Run one backup
# --------------------------------------------------------------------------- #

def run_backup_now(label: str = "auto") -> tuple[bool, str]:
    """Run backup.sh synchronously. Returns (success, combined output)."""
    if not _SCRIPT.exists():
        return False, f"backup.sh not found at {_SCRIPT}"

    result = subprocess.run(
        [str(_SCRIPT), "--label", label],
        capture_output=True,
        text=True,
        timeout=600,
        cwd=str(_ROOT),
    )
    output = (result.stdout or "") + (result.stderr or "")
    success = result.returncode == 0

    with _lock:
        _state["last_run_at"] = datetime.now(_TZ).isoformat()
        _state["last_run_status"] = "success" if success else "failed"
        _state["last_run_output"] = output[-2000:]  # truncate

    return success, output


# --------------------------------------------------------------------------- #
#  Next-run computation
# --------------------------------------------------------------------------- #

def next_run_time() -> datetime:
    now = datetime.now(_TZ)
    target = now.replace(
        hour=ENV.BACKUP_AUTO_HOUR,
        minute=ENV.BACKUP_AUTO_MINUTE,
        second=0,
        microsecond=0,
    )
    if target <= now:
        target += timedelta(days=1)
    return target


def get_state() -> dict:
    with _lock:
        return {
            "scheduler_enabled": ENV.BACKUP_AUTO_ENABLED,
            "scheduler_running": _state["running"],
            "last_run_at": _state["last_run_at"],
            "last_run_status": _state["last_run_status"],
            "next_run_at": (
                next_run_time().isoformat() if ENV.BACKUP_AUTO_ENABLED else None
            ),
            "scheduled_time": f"{ENV.BACKUP_AUTO_HOUR:02d}:{ENV.BACKUP_AUTO_MINUTE:02d}",
        }


# --------------------------------------------------------------------------- #
#  Scheduler loop
# --------------------------------------------------------------------------- #

def _loop() -> None:
    with _lock:
        _state["running"] = True
    print(
        f"[backup-scheduler] started — daily at "
        f"{ENV.BACKUP_AUTO_HOUR:02d}:{ENV.BACKUP_AUTO_MINUTE:02d} IST",
        flush=True,
    )

    while True:
        try:
            next_at = next_run_time()
            sleep_s = (next_at - datetime.now(_TZ)).total_seconds()
            if sleep_s > 0:
                # Sleep in chunks so a config change could be picked up
                # (only between runs — once we're sleeping we commit to this time)
                time.sleep(min(sleep_s, 60))
                if sleep_s > 60:
                    continue

            print(f"[backup-scheduler] running backup at {datetime.now(_TZ)}", flush=True)
            ok, out = run_backup_now(label="auto")
            print(
                f"[backup-scheduler] {'✓' if ok else '✗'} "
                f"{out.splitlines()[-1] if out else ''}",
                flush=True,
            )
            # Small buffer to avoid firing twice in the same minute
            time.sleep(90)
        except Exception as e:  # noqa: BLE001
            print(f"[backup-scheduler] cycle error: {e}", flush=True)
            time.sleep(60)


def start() -> None:
    """Start the scheduler in a daemon thread."""
    if not ENV.BACKUP_AUTO_ENABLED:
        print("[backup-scheduler] disabled (BACKUP_AUTO_ENABLED=false)", flush=True)
        return
    threading.Thread(target=_loop, name="backup-scheduler", daemon=True).start()