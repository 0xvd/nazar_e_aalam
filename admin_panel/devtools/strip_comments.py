from __future__ import annotations

import argparse
import ast
import io
import re
import sys
import tokenize
from pathlib import Path

_KEEP_RE = re.compile(r"#\s*(noqa|type:\s*ignore|pragma|fmt:)", re.IGNORECASE)
_SKIP_DIRS = (".venv", "venv", "site-packages", "node_modules", "__pycache__")


def _count_and_strip_comments(src: str) -> tuple[str, int]:
    try:
        tokens = list(tokenize.generate_tokens(io.StringIO(src).readline))
    except tokenize.TokenError:
        return src, 0

    comments: dict[int, int] = {}
    removed = 0
    for tok in tokens:
        if tok.type == tokenize.COMMENT:
            if _KEEP_RE.search(tok.string):
                continue
            comments[tok.start[0]] = tok.start[1]
            removed += 1

    if not comments:
        return src, 0

    lines = src.splitlines(keepends=True)
    for line_no, col in comments.items():
        idx = line_no - 1
        if 0 <= idx < len(lines):
            body = lines[idx].rstrip("\n")
            newline = lines[idx][len(body) :]
            lines[idx] = body[:col].rstrip() + newline
    return "".join(lines), removed


def _strip_module_docstring(src: str) -> str:
    try:
        tree = ast.parse(src)
    except SyntaxError:
        return src
    if not tree.body:
        return src
    first = tree.body[0]
    if (
        isinstance(first, ast.Expr)
        and isinstance(first.value, ast.Constant)
        and isinstance(first.value.value, str)
    ):
        lines = src.splitlines(keepends=True)
        start = first.lineno - 1
        end = first.end_lineno
        rest = "".join(lines[end:])
        rest = rest.removeprefix("\n")
        return "".join(lines[:start]) + rest
    return src


def _process(path: Path, write: bool) -> str:
    try:
        src = path.read_text(encoding="utf-8")
    except Exception as e:
        return f"{path} : error ({e})"

    cleaned, n = _count_and_strip_comments(src)
    cleaned = _strip_module_docstring(cleaned)

    if cleaned == src:
        return f"{path} : 0"
    if write:
        path.write_text(cleaned, encoding="utf-8")
    return f"{path} : {n}"


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser()
    p.add_argument("paths", nargs="+", type=Path)
    p.add_argument("-r", "--recursive", action="store_true")
    p.add_argument("-w", "--write", action="store_true")
    args = p.parse_args(argv)

    files: list[Path] = []
    for pin in args.paths:
        if pin.is_dir():
            if not args.recursive:
                print(f"skip dir {pin} (use -r)", file=sys.stderr)
                continue
            files.extend(sorted(pin.rglob("*.py")))
        else:
            files.append(pin)

    files = [f for f in files if not any(x in str(f) for x in _SKIP_DIRS)]

    for f in files:
        print(_process(f, write=args.write))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
