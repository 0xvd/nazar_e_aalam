from __future__ import annotations

import argparse
import fnmatch
import subprocess
import sys
from pathlib import Path

_DEFAULT_SKIP_DIRS = (
    ".venv",
    "venv",
    "site-packages",
    "node_modules",
    "__pycache__",
    ".git",
)

IGNORE_FILE_DEFAULT = ".formatignore"


def _run(cmd: list[str], cwd: Path | None = None) -> int:
    return subprocess.run(cmd, cwd=cwd, capture_output=True).returncode


def _load_ignore_patterns(ignore_file: Path) -> list[str]:
    if not ignore_file.is_file():
        return []
    patterns: list[str] = []
    for raw in ignore_file.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(line)
    return patterns


def _matches_ignore(path: Path, patterns: list[str]) -> str | None:
    """Return the matching pattern (for reporting), or None."""
    s = str(path)
    for pat in patterns:
        if fnmatch.fnmatch(s, pat) or fnmatch.fnmatch(path.name, pat):
            return pat

        if pat.rstrip("/") in s:
            return pat

        if path.is_dir() and path.name == pat.rstrip("/"):
            return pat
    return None


def _process(path: Path, write: bool) -> str:
    if not path.is_file():
        return f"{path} : error (not a file)"

    check_cmd = [sys.executable, "-m", "ruff", "check", str(path)]
    check_cmd.append("--fix" if write else "--diff")
    check_code = _run(check_cmd)

    fmt_cmd = [sys.executable, "-m", "ruff", "format", str(path)]
    if not write:
        fmt_cmd.append("--diff")
    fmt_code = _run(fmt_cmd)

    if check_code != 0 or fmt_code != 0:
        return f"{path} : formatted" if write else f"{path} : would format"
    return f"{path} : unchanged"


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("paths", nargs="+", type=Path)
    p.add_argument("-r", "--recursive", action="store_true")
    p.add_argument("-w", "--write", action="store_true", help="Write changes")
    p.add_argument(
        "--ignore-file",
        type=Path,
        default=Path(IGNORE_FILE_DEFAULT),
        help=f"Ignore patterns file (default: {IGNORE_FILE_DEFAULT})",
    )
    p.add_argument(
        "--verbose",
        action="store_true",
        help="Print the ignore pattern list and the built-in skips",
    )
    args = p.parse_args(argv)

    user_patterns = _load_ignore_patterns(args.ignore_file)

    print("Ignoring (built-in): " + ", ".join(_DEFAULT_SKIP_DIRS))
    if user_patterns:
        print("Ignoring (from %s): %s" % (args.ignore_file, ", ".join(user_patterns)))
    else:
        print(f"Ignoring (from {args.ignore_file}): <file not found or empty>")
    print()

    files: list[Path] = []
    for pin in args.paths:
        if pin.is_dir():
            if not args.recursive:
                print(f"skip dir {pin} (use -r)", file=sys.stderr)
                continue
            files.extend(sorted(pin.rglob("*.py")))
        else:
            files.append(pin)

    kept: list[Path] = []
    skipped: list[tuple[Path, str]] = []
    for f in files:
        if any(part in _DEFAULT_SKIP_DIRS for part in f.parts):
            skipped.append((f, "<built-in dir>"))
            continue

        hit = _matches_ignore(f, user_patterns)
        if hit:
            skipped.append((f, hit))
            continue
        kept.append(f)

    if args.verbose and skipped:
        print("--- Skipped files ---")
        for path, why in skipped:
            print(f"  {path}  (pattern: {why})")
        print()

    if not kept:
        print("No files to process.")
        return 0

    for f in kept:
        print(_process(f, write=args.write))

    verb = "formatted" if args.write else "would format"
    print(
        f"\nSummary: {len(kept)} processed ({verb} as needed), "
        f"{len(skipped)} skipped, {len(files)} candidates"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
