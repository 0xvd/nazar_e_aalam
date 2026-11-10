from __future__ import annotations

import shutil
import sys
from collections import deque
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

import json
import time

import boto3
import requests
from botocore.exceptions import (
    BotoCoreError,
    ClientError,
)
from config import ENV

RECITERS: dict[str, dict] = {
    "mishary-rashid-alafasy": {
        "name": "Mishary Rashid Alafasy",
        "everyayah_slug": "Alafasy_64kbps",
        "bitrate": "64",
        "est_mb": 500,
    },
    "yasser-al-dosari": {
        "name": "Yasser Al-Dosari",
        "everyayah_slug": "Yasser_Ad-Dussary_128kbps",
        "bitrate": "128",
        "est_mb": 850,
    },
    "abdul-rahman-al-sudais": {
        "name": "Abdul Rahman Al-Sudais",
        "everyayah_slug": "Abdurrahmaan_As-Sudais_64kbps",
        "bitrate": "64",
        "est_mb": 500,
    },
    "maher-al-muaiqly": {
        "name": "Maher Al-Muaiqly",
        "everyayah_slug": "Maher_AlMuaiqly_64kbps",
        "bitrate": "64",
        "est_mb": 500,
    },
    "abdul-basit-abdul-samad": {
        "name": "Abdul Basit Abdul Samad",
        "everyayah_slug": "AbdulSamad_64kbps_QuranExplorer.Com",
        "bitrate": "64",
        "est_mb": 500,
    },
    "saad-al-ghamdi": {
        "name": "Saad Al-Ghamdi",
        "everyayah_slug": "Ghamadi_40kbps",
        "bitrate": "40",
        "est_mb": 300,
    },
}

AYAH_COUNTS = [
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
]
assert sum(AYAH_COUNTS) == 6236

EVERYAYAH_BASE = "https://everyayah.com/data/{slug}/{surah:03d}{ayah:03d}.mp3"

DOWNLOAD_ROOT = _ROOT / "downloads"
STATE_FILE = _ROOT / "sync_state.json"

_global_cap = int(ENV.QURAN_MAX_GB * 1024**3)
_per_reciter_cap = int(ENV.QURAN_MAX_PER_RECITER_GB * 1024**3)


def _fmt_bytes(n: float) -> str:
    if n < 1024:
        return f"{n:.0f} B"
    if n < 1024**2:
        return f"{n / 1024:.0f} KB"
    if n < 1024**3:
        return f"{n / 1024**2:.1f} MB"
    return f"{n / 1024**3:.2f} GB"


def _fmt_duration(sec: float) -> str:
    sec = int(sec)
    if sec < 60:
        return f"{sec}s"
    if sec < 3600:
        return f"{sec // 60}m{sec % 60:02d}s"
    return f"{sec // 3600}h{(sec % 3600) // 60:02d}m"


def _banner(title: str) -> None:
    bar = "═" * 71
    print(f"\n{bar}\n {title}\n{bar}")


def _r2():
    missing = [
        k
        for k in (
            "R2_ACCOUNT_ID",
            "R2_ACCESS_KEY_ID",
            "R2_SECRET_ACCESS_KEY",
            "R2_BUCKET",
        )
        if not getattr(ENV, k)
    ]
    if missing:
        raise SystemExit(
            f"✗ Missing R2 env vars: {', '.join(missing)}.\n"
            "  Add them to .env — see .env.example."
        )
    return boto3.client(
        "s3",
        endpoint_url=f"https://{ENV.R2_ACCOUNT_ID}.r2.cloudflarestorage.com",
        aws_access_key_id=ENV.R2_ACCESS_KEY_ID,
        aws_secret_access_key=ENV.R2_SECRET_ACCESS_KEY,
        region_name="auto",
    )


def r2_list(client, prefix: str) -> dict[str, int]:
    """Return {key: size_bytes} for every object under `prefix` (paginated)."""
    result: dict[str, int] = {}
    paginator = client.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=ENV.R2_BUCKET, Prefix=prefix):
        for obj in page.get("Contents", []):
            result[obj["Key"]] = obj["Size"]
    return result


def r2_upload(client, key: str, path: Path, reciter_bytes: int) -> None:
    size = path.stat().st_size
    if reciter_bytes + size > _per_reciter_cap:
        raise _CapReached(f"Per-reciter cap ({_fmt_bytes(_per_reciter_cap)}) reached")
    global _uploaded_bytes
    if _uploaded_bytes + size > _global_cap:
        raise _CapReached(f"Global cap ({_fmt_bytes(_global_cap)}) reached")

    for attempt in range(3):
        try:
            client.upload_file(
                str(path),
                ENV.R2_BUCKET,
                key,
                ExtraArgs={
                    "ContentType": "audio/mpeg",
                    "CacheControl": "public, max-age=31536000, immutable",
                },
            )
            _uploaded_bytes += size
            return
        except ClientError as e:
            code = e.response["Error"]["Code"]
            if code == "AccessDenied":
                raise SystemExit(
                    f"\n✗ AccessDenied uploading {key}\n"
                    f"  → Run: python -m tools.sync_quran --test\n"
                    f"  → Verify API token has 'Object Read & Write' on '{ENV.R2_BUCKET}'"
                ) from e
            if code == "NoSuchBucket":
                raise SystemExit(
                    f"\n✗ Bucket '{ENV.R2_BUCKET}' does not exist.\n"
                    f"  → Check Cloudflare dashboard, or fix R2_BUCKET in .env"
                ) from e
            if attempt == 2:
                raise
            time.sleep(2**attempt)


class _CapReached(Exception):
    """Raised when the storage cap is hit — handled per-reciter."""


SESSION = requests.Session()
SESSION.headers["User-Agent"] = "nazar-e-alam-sync/1.0"


def download(url: str, dest: Path) -> bool:
    if dest.exists() and dest.stat().st_size > 0:
        return True
    dest.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        try:
            with SESSION.get(url, stream=True, timeout=30) as r:
                if r.status_code != 200:
                    print(f"    ✗ {url} → HTTP {r.status_code}")
                    return False
                tmp = dest.with_suffix(dest.suffix + ".part")
                with tmp.open("wb") as f:
                    for chunk in r.iter_content(8192):
                        f.write(chunk)
                tmp.replace(dest)
                return True
        except (requests.RequestException, OSError) as e:
            if attempt == 2:
                print(f"    ✗ {url} → {e}")
                return False
            time.sleep(2**attempt)
    return False


def _load_state() -> dict:
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {"reciters": {}, "last_run": None}


def _save_state(state: dict) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=2, ensure_ascii=False))


_uploaded_bytes = 0


_IS_TTY = sys.stdout.isatty()
_TERM_W = shutil.get_terminal_size((120, 24)).columns


def _make_progress_bar(pct: float, width: int = 22) -> str:
    filled = int(width * pct / 100)
    return "█" * filled + "░" * (width - filled)


def _speed_str(bps: float) -> str:
    if bps >= 1024**2:
        return f"{bps / 1024**2:5.2f} MB/s"
    if bps > 0:
        return f"{bps / 1024:5.1f} KB/s"
    return "     —    "


def _render_progress(
    *,
    processed: int,
    total: int,
    uploaded: int,
    skipped: int,
    failed: int,
    bytes_done: int,
    rate_fps: float,
    rate_bps: float,
    current_file: str,
    final: bool = False,
) -> None:
    pct = (processed / total * 100) if total else 0
    bar = _make_progress_bar(pct)
    remaining = max(0, total - processed)
    eta_str = _fmt_duration(remaining / rate_fps) if rate_fps > 0 else "    —  "
    speed = _speed_str(rate_bps)

    line = (
        f"  {bar} {pct:5.1f}%  "
        f"{processed:>5}/{total}  "
        f"↑{uploaded:<5}  ↷{skipped:<5}  ✗{failed:<2}  "
        f"{_fmt_bytes(bytes_done):>9}  "
        f"{speed}  "
        f"ETA {eta_str:>7}  "
        f"{current_file}"
    )
    if _IS_TTY:
        padded = line.ljust(_TERM_W - 1)[: _TERM_W - 1]
        print(f"\r{padded}", end="\n" if final else "", flush=True)
    else:
        if final or processed % 100 == 0:
            print(line, flush=True)


def sync_reciter(client, key: str, info: dict, *, verbose: bool, dry_run: bool) -> dict:
    slug = info["everyayah_slug"]
    staging = DOWNLOAD_ROOT / "everyayah" / key
    prefix = f"reciters/{key}/ayahs/"
    total = sum(AYAH_COUNTS)

    print(f"\n→ {info['name']}  ({slug})  est. {info['est_mb']} MB")
    print("  Scanning R2 for existing files…", end=" ", flush=True)
    try:
        existing = r2_list(client, prefix)
    except (ClientError, BotoCoreError) as e:
        print(f"failed: {e}")
        raise SystemExit(1)
    already_bytes = sum(existing.values())
    to_do = total - len(existing)
    print(
        f"found {len(existing):,} existing  "
        f"({_fmt_bytes(already_bytes)})  "
        f"→  {to_do:,} to upload"
    )

    if dry_run:
        return {
            "name": info["name"],
            "everyayah_slug": slug,
            "bitrate": info["bitrate"],
            "bytes": 0,
            "uploaded": 0,
            "skipped": len(existing),
            "failed": 0,
            "dry_run": True,
            "completed_at": None,
        }

    print("  Starting…")

    started = time.time()
    uploaded = skipped = failed = 0
    reciter_bytes = 0
    failures: list[tuple[int, int, str]] = []
    current_file = ""
    recent: deque[tuple[float, int]] = deque(maxlen=30)
    last_render = 0.0
    last_render_processed = -1
    upload_started: float | None = None

    def _current_rates() -> tuple[float, float]:
        if len(recent) < 2:
            return 0.0, 0.0
        span = recent[-1][0] - recent[0][0]
        if span <= 0:
            return 0.0, 0.0
        n = len(recent) - 1
        b = sum(sz for _, sz in list(recent)[1:])
        return n / span, b / span

    def _maybe_render(force_final: bool = False) -> None:
        nonlocal last_render, last_render_processed
        processed = uploaded + skipped
        now = time.time()
        if not force_final:
            if _IS_TTY:
                if now - last_render < 0.1:
                    return
            else:
                if processed - last_render_processed < 100:
                    return
        fps, bps = _current_rates()
        _render_progress(
            processed=processed,
            total=total,
            uploaded=uploaded,
            skipped=skipped,
            failed=failed,
            bytes_done=reciter_bytes,
            rate_fps=fps,
            rate_bps=bps,
            current_file=current_file,
            final=force_final,
        )
        last_render = now
        last_render_processed = processed

    try:
        for surah, count in enumerate(AYAH_COUNTS, start=1):
            for ayah in range(1, count + 1):
                filename = f"{surah:03d}{ayah:03d}.mp3"
                current_file = filename
                r2_key = prefix + filename
                local = staging / filename

                if r2_key in existing:
                    skipped += 1
                    local.unlink(missing_ok=True)
                    continue

                if upload_started is None:
                    upload_started = time.time()

                if not download(
                    EVERYAYAH_BASE.format(slug=slug, surah=surah, ayah=ayah),
                    local,
                ):
                    failed += 1
                    failures.append((surah, ayah, "download failed"))
                    _maybe_render()
                    continue

                try:
                    r2_upload(client, r2_key, local, reciter_bytes)
                except _CapReached:
                    _maybe_render(force_final=True)
                    raise

                size = local.stat().st_size
                reciter_bytes += size
                uploaded += 1
                recent.append((time.time(), size))
                local.unlink(missing_ok=True)
                _maybe_render()

        _maybe_render(force_final=True)
    except _CapReached as cap:
        elapsed = time.time() - started
        _print_reciter_summary(info, uploaded, skipped, failed, reciter_bytes, elapsed)
        print(f"  ⚠ {cap}. Stopping this reciter. Rerun to resume.")
        return {
            "name": info["name"],
            "everyayah_slug": slug,
            "bitrate": info["bitrate"],
            "bytes": reciter_bytes,
            "uploaded": uploaded,
            "skipped": skipped,
            "failed": failed,
            "failures": failures,
            "interrupted": True,
            "completed_at": None,
        }
    except KeyboardInterrupt:
        _maybe_render(force_final=True)
        elapsed = time.time() - started
        _print_reciter_summary(info, uploaded, skipped, failed, reciter_bytes, elapsed)
        print("  ⚠ Ctrl-C — progress saved. Rerun to resume.")
        raise

    elapsed = time.time() - started
    _print_reciter_summary(info, uploaded, skipped, failed, reciter_bytes, elapsed)
    if failures:
        print(f"  Failed files ({len(failures)}):")
        for s, a, reason in failures[:10]:
            print(f"    - {s:03d}{a:03d}.mp3  ({reason})")
        if len(failures) > 10:
            print(f"    … and {len(failures) - 10} more")

    return {
        "name": info["name"],
        "everyayah_slug": slug,
        "bitrate": info["bitrate"],
        "bytes": reciter_bytes,
        "uploaded": uploaded,
        "skipped": skipped,
        "failed": failed,
        "failures": failures,
        "completed_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    }


def _print_progress(
    uploaded,
    skipped,
    failed,
    reciter_bytes,
    processed,
    total,
    started,
    now,
    current_file,
) -> None:
    elapsed = now - started
    rate = processed / elapsed if elapsed else 0
    remaining = max(0, total - processed)
    eta = remaining / rate if rate else 0
    pct = (processed / total * 100) if total else 0
    print(
        f"    [{processed:>4}/{total}]  {pct:>5.1f}%  "
        f"↑{uploaded:<4}  ↷{skipped:<4}  ✗{failed:<3}  "
        f"{_fmt_bytes(reciter_bytes):>8}  "
        f"{rate:>5.1f}f/s  "
        f"cur={current_file}  "
        f"ETA {_fmt_duration(eta):>7}",
        flush=True,
    )


def _print_reciter_summary(info, uploaded, skipped, failed, bytes_, elapsed) -> None:
    speed = bytes_ / elapsed / 1024**2 if elapsed else 0
    print(
        f"  {'✓' if not failed else '⚠'} {info['name']}: "
        f"{uploaded} uploaded · {skipped} skipped · {failed} failed  "
        f"({_fmt_bytes(bytes_)} in {_fmt_duration(elapsed)}, {speed:.2f} MB/s)"
    )


def cmd_status() -> None:
    state = _load_state()
    _banner("Sync status")
    for key, info in RECITERS.items():
        row = state["reciters"].get(key)
        if row and not row.get("interrupted") and not row.get("dry_run"):
            print(
                f"  ✓ {key:<28} {info['name']:<24}  "
                f"{_fmt_bytes(row.get('bytes', 0)):>9}"
            )
        elif row and row.get("interrupted"):
            print(
                f"  ⚠ {key:<28} {info['name']:<24}  "
                f"partial ({_fmt_bytes(row.get('bytes', 0))})"
            )
        else:
            print(f"  ✗ {key:<28} {info['name']:<24}  (not synced)")
    if state.get("last_run"):
        print(f"\n  Last run: {state['last_run']}")


def cmd_check() -> None:
    _banner("Config check")
    missing = [
        k
        for k in (
            "R2_ACCOUNT_ID",
            "R2_ACCESS_KEY_ID",
            "R2_SECRET_ACCESS_KEY",
            "R2_BUCKET",
            "R2_PUBLIC_BASE_URL",
        )
        if not getattr(ENV, k)
    ]
    if missing:
        print(f"✗ Missing env: {', '.join(missing)}")
    else:
        print("✓ All R2 env vars present")
        print(f"  bucket:            {ENV.R2_BUCKET}")
        print(f"  public base url:   {ENV.R2_PUBLIC_BASE_URL}")
        print(
            f"  s3 endpoint:       https://{ENV.R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
        )

    if ENV.R2_PUBLIC_BASE_URL and "r2.cloudflarestorage.com" in ENV.R2_PUBLIC_BASE_URL:
        print(
            "\n⚠ R2_PUBLIC_BASE_URL points at the S3 API endpoint — audio streaming will fail.\n"
            "  Fix in .env — use your bucket's public URL instead:\n"
            "    • r2.dev:  R2 → bucket → Settings → Public Access → copy https://pub-xxx.r2.dev\n"
            "    • custom:  R2 → bucket → Settings → Connect Domain"
        )

    total_mb = sum(r["est_mb"] for r in RECITERS.values())
    print("\nBudget:")
    print(f"  global cap:        {ENV.QURAN_MAX_GB:.1f} GB")
    print(f"  per-reciter cap:   {ENV.QURAN_MAX_PER_RECITER_GB:.1f} GB")
    print(f"  estimated total:   {total_mb / 1024:.2f} GB")
    print(f"  reciters:          {len(RECITERS)}")
    for info in RECITERS.values():
        print(
            f"    {info['name']:<28} {info['everyayah_slug']:<40} ~{info['est_mb']} MB"
        )


def cmd_test() -> None:
    """End-to-end R2 diagnostic — pinpoints AccessDenied in seconds."""
    _banner("R2 connectivity test")
    try:
        client = _r2()
    except SystemExit:
        return

    try:
        client.list_objects_v2(Bucket=ENV.R2_BUCKET, MaxKeys=1)
        print("✓ ListBucket")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        print(f"✗ ListBucket: {code} — {e.response['Error'].get('Message', '')}")
        print("  → Check token has 'Object Read & Write' on this bucket")
        return

    test_key = "_sync_test.txt"
    test_body = b"hello r2"
    try:
        client.put_object(
            Bucket=ENV.R2_BUCKET,
            Key=test_key,
            Body=test_body,
            ContentType="text/plain",
        )
        print("✓ PutObject")
    except ClientError as e:
        code = e.response["Error"]["Code"]
        print(f"✗ PutObject: {code} — {e.response['Error'].get('Message', '')}")
        print("  → R2 API token needs 'Object Read & Write' permission")
        return

    try:
        resp = client.get_object(Bucket=ENV.R2_BUCKET, Key=test_key)
        body = resp["Body"].read()
        assert body == test_body
        print("✓ GetObject")
    except (ClientError, AssertionError) as e:
        print(f"✗ GetObject: {e}")

    if ENV.R2_PUBLIC_BASE_URL:
        url = f"{ENV.R2_PUBLIC_BASE_URL.rstrip('/')}/{test_key}"
        try:
            r = requests.get(url, timeout=10)
            if r.status_code == 200 and r.content == test_body:
                print(f"✓ Public URL reachable: {url}")
            else:
                print(f"✗ Public URL: HTTP {r.status_code} for {url}")
                print("  → Enable Public Access or fix R2_PUBLIC_BASE_URL")
        except requests.RequestException as e:
            print(f"✗ Public URL unreachable: {e}")

    try:
        client.delete_object(Bucket=ENV.R2_BUCKET, Key=test_key)
        print("✓ DeleteObject")
    except ClientError as e:
        print(f"✗ DeleteObject: {e}")

    print("\nDone. If all 5 checks pass, sync will work.")


def cmd_sync(only: list[str], *, verbose: bool, dry_run: bool) -> None:
    try:
        client = _r2()
    except SystemExit as e:
        print(e)
        return

    _banner("Nazar-e-Alam · Quran audio sync")
    print(f"  Bucket:           {ENV.R2_BUCKET}")
    print(f"  Public URL:       {ENV.R2_PUBLIC_BASE_URL or '(not set)'}")
    print(f"  Global cap:       {ENV.QURAN_MAX_GB:.1f} GB")
    print(f"  Per-reciter cap:  {ENV.QURAN_MAX_PER_RECITER_GB:.1f} GB")
    print(f"  Reciters:         {len(only) if only else len(RECITERS)}")
    if dry_run:
        print("  Mode:             DRY RUN (no network)")
    elif verbose:
        print("  Mode:             VERBOSE")

    state = _load_state()
    targets = only or list(RECITERS)
    grand_uploaded = grand_skipped = grand_failed = 0
    grand_bytes = 0
    overall_start = time.time()
    interrupted = False

    try:
        for key in targets:
            if key not in RECITERS:
                print(f"\n✗ Unknown reciter: {key}")
                continue
            if key in state["reciters"] and not only:
                prev = state["reciters"][key]
                if not prev.get("interrupted") and not prev.get("dry_run"):
                    print(f"\n↷ {RECITERS[key]['name']} — already complete, skipping")
                    continue
            info = RECITERS[key]
            result = sync_reciter(client, key, info, verbose=verbose, dry_run=dry_run)
            state["reciters"][key] = result
            _save_state(state)

            grand_uploaded += result.get("uploaded", 0)
            grand_skipped += result.get("skipped", 0)
            grand_failed += result.get("failed", 0)
            grand_bytes += result.get("bytes", 0)
    except KeyboardInterrupt:
        interrupted = True
    finally:
        elapsed = time.time() - overall_start
        _banner("Sync summary" + (" (INTERRUPTED)" if interrupted else ""))
        print(f"  Uploaded:  {grand_uploaded:>7,} files   ({_fmt_bytes(grand_bytes)})")
        print(f"  Skipped:   {grand_skipped:>7,} files   (already in R2)")
        print(f"  Failed:    {grand_failed:>7,} files")
        print(f"  Time:      {_fmt_duration(elapsed)}")
        if grand_bytes and elapsed:
            print(f"  Avg speed: {grand_bytes / elapsed / 1024**2:.2f} MB/s")
        state["last_run"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        _save_state(state)
        if interrupted:
            print("\n  ⚠ Interrupted — rerun to resume.")


def main() -> None:
    args = sys.argv[1:]
    if "--check" in args:
        cmd_check()
        return
    if "--status" in args:
        cmd_status()
        return
    if "--test" in args:
        cmd_test()
        return
    verbose = "-v" in args or "--verbose" in args
    dry_run = "--dry-run" in args
    only = [a for a in args if not a.startswith("-")]
    cmd_sync(only, verbose=verbose, dry_run=dry_run)


def run_all() -> None:
    """
    Entry point for main.py's lifespan thread.
    No sys.argv parsing — always syncs every reciter at default settings.
    Silently returns if R2 isn't configured.
    """
    if not (ENV.R2_ACCOUNT_ID and ENV.R2_ACCESS_KEY_ID and ENV.R2_BUCKET):
        print("[quran-sync] R2 not configured — skipping", flush=True)
        return
    try:
        cmd_sync([], verbose=False, dry_run=False)
    except SystemExit:
        pass
    except Exception as e:  # noqa: BLE001
        print(f"[quran-sync] failed: {e}", flush=True)


if __name__ == "__main__":
    main()
