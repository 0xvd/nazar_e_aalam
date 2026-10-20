"""
Gunicorn config for production.

- uvicorn-worker: async FastAPI support (install `pip install uvicorn-worker`)
- 4 workers: 4× throughput on the same box; scale up with GUNICORN_WORKERS
- Access/error logs to files that backup.sh archives
- Graceful restart via `systemctl reload`
"""
import multiprocessing
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent
LOG_DIR = ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)

# ---- Binding --------------------------------------------------------------
# Bind only to localhost — put nginx in front for TLS/HTTP2
bind = os.getenv("GUNICORN_BIND", "127.0.0.1:8000")

# ---- Workers --------------------------------------------------------------
# 4 = the recommendation for small VPS. Use `2*CPU+1` for larger boxes.
_default_workers = max(2, min(4, multiprocessing.cpu_count()))
workers = int(os.getenv("GUNICORN_WORKERS", _default_workers))
worker_class = "uvicorn_worker.UvicornWorker"

# ---- Timeouts -------------------------------------------------------------
timeout = 120                # kill workers stuck > 120s
graceful_timeout = 30        # time to finish in-flight requests on reload
keepalive = 5

# ---- Memory management ----------------------------------------------------
max_requests = 2000          # recycle worker after 2000 requests (leak protection)
max_requests_jitter = 200    # avoid all workers recycling at once

# ---- Logging --------------------------------------------------------------
accesslog = str(LOG_DIR / "gunicorn_access.log")
errorlog = str(LOG_DIR / "gunicorn_error.log")
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
access_log_format = '%({x-forwarded-for}i)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)sµs'
capture_output = True        # capture stdout/stderr from app into errorlog

# ---- Process behavior -----------------------------------------------------
proc_name = "nazar-e-alam"
pidfile = str(ROOT / "gunicorn.pid")
preload_app = False          # safer without preload (avoids fork-with-open-db issues)