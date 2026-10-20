#!/usr/bin/env python3
"""
Verify that the latest R2 backup restores cleanly and matches live row counts.

Usage:  python scripts/verify_restore.py
"""
from __future__ import annotations

import gzip
import tempfile
import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

import boto3
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

TEST_DB = "nazar_e_alam_restore_test"
TABLES = ["users", "chapters", "reciters", "duas"]


def die(msg: str, code: int = 1) -> None:
    print(f"✗ {msg}")
    sys.exit(code)


# ---- Parse DATABASE_URL ---------------------------------------------------
raw = os.environ.get("DATABASE_URL", "")
if not raw:
    die("DATABASE_URL not set in .env")

normalized = raw.replace("mysql+pymysql://", "mysql://").replace(
    "mysql+mysqldb://", "mysql://"
)
p = urlparse(normalized)
db_user = p.username or "root"
db_pass = p.password or ""
db_host = p.hostname or "localhost"
db_port = str(p.port or 3306)
db_name = p.path.lstrip("/").split("?")[0]
if not db_name:
    die(f"Could not parse DB name from DATABASE_URL: {raw}")

env = {**os.environ, "MYSQL_PWD": db_pass}


def mysql(sql: str, db: str | None = None, gz_file=None):
    """Run a mysql command.

    - sql + no file  → text mode, capture stdout/stderr as strings
    - file (binary)  → binary mode, capture stdout/stderr as bytes
    """
    cmd = ["mysql", "-u", db_user, "-h", db_host, "-P", db_port]
    if db:
        cmd.append(db)

    if gz_file is None:
        cmd.extend(["-e", sql])
        return subprocess.run(cmd, env=env, capture_output=True, text=True)

    if db is None:
        die("Binary restore requires a db argument")

    return subprocess.run(
        cmd,
        env=env,
        stdin=gz_file,     # pass the binary file handle directly
        capture_output=True,
        text=False,        # binary stdout/stderr
    )

# ---- Download latest backup from R2 ---------------------------------------
print("→ Fetching latest backup from R2…")
for key in (
    "R2_ACCOUNT_ID",
    "R2_BACKUP_BUCKET",
    "R2_BACKUP_ACCESS_KEY_ID",
    "R2_BACKUP_ACCESS_KEY",
):
    if not os.environ.get(key):
        die(f"Missing env var: {key}")

client = boto3.client(
    "s3",
    endpoint_url=f"https://{os.environ['R2_ACCOUNT_ID']}.r2.cloudflarestorage.com",
    aws_access_key_id=os.environ["R2_BACKUP_ACCESS_KEY_ID"],
    aws_secret_access_key=os.environ["R2_BACKUP_ACCESS_KEY"],
    region_name="auto",
)
resp = client.list_objects_v2(
    Bucket=os.environ["R2_BACKUP_BUCKET"], Prefix="backups/"
)
objs = [
    o for o in resp.get("Contents", [])
    if o["Key"].endswith(".sql.gz")     # ← only DB dumps, skip log tarballs
]
if not objs:
    die("No .sql.gz backups found in R2 — run ./scripts/backup.sh first")

latest = max(objs, key=lambda o: o["LastModified"])
local = Path("/tmp") / latest["Key"].split("/")[-1]
client.download_file(os.environ["R2_BACKUP_BUCKET"], latest["Key"], str(local))
size_mb = local.stat().st_size / 1024**2
print(f"✓ Downloaded {local.name} ({size_mb:.2f} MB)")

# ---- Create throwaway DB and restore --------------------------------------
print(f"\n→ Creating {TEST_DB}…")
r = mysql(f"DROP DATABASE IF EXISTS {TEST_DB}; CREATE DATABASE {TEST_DB};")
if r.returncode != 0:
    die(f"Create DB failed: {r.stderr.strip()}")

print("→ Restoring backup…")
with tempfile.NamedTemporaryFile(suffix=".sql", delete=False) as tmp:
    with gzip.open(local, "rb") as src:
        tmp.write(src.read())
    tmp_path = Path(tmp.name)

try:
    with open(tmp_path, "rb") as f:
        r = mysql("", db=TEST_DB, gz_file=f)
    if r.returncode != 0:
        err = r.stderr.decode("utf-8", errors="replace").strip()[-500:]
        die(f"Restore failed: {err}")
finally:
    tmp_path.unlink(missing_ok=True)

print("✓ Restore succeeded")

# ---- Compare row counts ---------------------------------------------------
def count_rows(db: str, table: str) -> str:
    r = mysql(f"SELECT COUNT(*) FROM {table};", db=db)
    if r.returncode != 0:
        return "ERR"
    lines = [ln for ln in r.stdout.strip().splitlines() if ln and not ln.isdigit() or ln.isdigit()]
    for ln in reversed(lines):
        if ln.strip().isdigit():
            return ln.strip()
    return r.stdout.strip() or "?"


print(f"\n{'Table':<15} {'Live':>10} {'Restored':>10}  {'Match':>6}")
print("-" * 48)
all_match = True
for t in TABLES:
    live = count_rows(db_name, t)
    test = count_rows(TEST_DB, t)
    match = live == test and live != "ERR"
    all_match = all_match and match
    print(f"{t:<15} {live:>10} {test:>10}  {'✓' if match else '✗':>6}")

# ---- Cleanup --------------------------------------------------------------
print(f"\n→ Dropping {TEST_DB}…")
mysql(f"DROP DATABASE {TEST_DB};")
local.unlink(missing_ok=True)

print()
if all_match:
    print("✅ Restore verified — every row count matches the live DB")
    sys.exit(0)
else:
    print("❌ Row counts differ — the backup may be stale or corrupted")
    sys.exit(1)