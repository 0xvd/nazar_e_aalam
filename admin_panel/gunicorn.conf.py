import multiprocessing
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent
LOG_DIR = ROOT / "logs"
LOG_DIR.mkdir(exist_ok=True)


bind = os.getenv("GUNICORN_BIND", "127.0.0.1:8000")


_default_workers = max(2, min(4, multiprocessing.cpu_count()))
workers = int(os.getenv("GUNICORN_WORKERS", _default_workers))
worker_class = "uvicorn_worker.UvicornWorker"


timeout = 120
graceful_timeout = 30
keepalive = 5


max_requests = 2000
max_requests_jitter = 200


accesslog = str(LOG_DIR / "gunicorn_access.log")
errorlog = str(LOG_DIR / "gunicorn_error.log")
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
access_log_format = '%({x-forwarded-for}i)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)sµs'
capture_output = True


proc_name = "nazar-e-alam"
pidfile = str(ROOT / "gunicorn.pid")
preload_app = False
