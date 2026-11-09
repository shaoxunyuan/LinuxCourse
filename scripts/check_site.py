#!/usr/bin/env python3
"""检查 docs/ 下的站内链接、锚点、重复 id 与演示页码连续性。"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import urldefrag

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"

LINK_RE = re.compile(r'(?:href|src)="([^"]+)"')
ID_RE = re.compile(r'\bid="([^"]+)"')
SECTION_RE = re.compile(r'<section[^>]*data-page="(\d+)"')
PROMPT_RE = re.compile(r'\[njucm@[^\]]*\]\$')


def is_local(target: str) -> bool:
    return not (
        target.startswith(("http://", "https://", "//", "mailto:", "javascript:", "data:"))
        or target.startswith("#")
    )


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []
    html_files = sorted(DOCS.rglob("*.html"))
    ids_by_file = {f: set(ID_RE.findall(f.read_text(encoding="utf-8"))) for f in html_files}

    for f in html_files:
        text = f.read_text(encoding="utf-8")
        rel = f.relative_to(ROOT)
        for target in LINK_RE.findall(text):
            if not is_local(target):
                continue
            path_part, _, frag = target.partition("#")
            dest = (f.parent / path_part).resolve() if path_part else f
            if path_part and not dest.exists():
                errors.append(f"{rel}: 链接目标不存在 -> {target}")
            elif frag and dest.suffix == ".html":
                dest_text = dest.read_text(encoding="utf-8")
                if frag not in set(ID_RE.findall(dest_text)):
                    errors.append(f"{rel}: 锚点不存在 -> {target}")

        local_ids = ID_RE.findall(text)
        dup = {i for i in local_ids if local_ids.count(i) > 1}
        if dup:
            errors.append(f"{rel}: 重复 id -> {', '.join(sorted(dup))}")

        for m in PROMPT_RE.finditer(text):
            snippet = text[max(0, m.start() - 80):m.start() + 80].replace("\n", " ")
            warnings.append(f"{rel}: 代码块疑似包含提示符 -> ...{snippet}...")

    for f in sorted((DOCS / "Presentations").glob("*.html")):
        if f.name == "index.html":
            continue
        pages = [int(n) for n in SECTION_RE.findall(f.read_text(encoding="utf-8"))]
        if not pages:
            errors.append(f"{f.relative_to(ROOT)}: 未找到带 data-page 的 section")
            continue
        if pages != list(range(1, len(pages) + 1)):
            errors.append(f"{f.relative_to(ROOT)}: data-page 不连续 -> {pages[:5]}...")

    print(f"检查文件数：{len(html_files)}")
    if warnings:
        print("\n警告：")
        for w in warnings:
            print("  -", w)
    if errors:
        print("\n错误：")
        for e in errors:
            print("  -", e)
        return 1
    print("站内链接、锚点、id 与演示页码检查通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
