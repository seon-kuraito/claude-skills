#!/usr/bin/env python3
"""no-cjk-passages — agent-facing text is English direction: a run of 12 or more CJK characters sits only where copy lives — inside corner-bracket quotes, in backticks, in fenced code, in menus.md, README.md, assets/, or tests/."""
import re
import sys
from _lib import items, report

# Kana, the CJK unified blocks, and the compatibility ideographs; punctuation is not counted.
CJK_RUN = re.compile(r"[぀-ヿ㐀-䶿一-鿿豈-﫿]{12,}")
COPY = re.compile("「[^」]*」|`[^`]*`")
SKIPPED_TOP = ("README.md", "LICENSE", "NOTICE", "assets", "tests")
SKIPPED_NAME = ("menus.md",)

findings = []
for name, path in items(sys.argv):
    for file in sorted(path.rglob("*")):
        if not file.is_file() or file.suffix in (".png", ".jpg", ".ico"):
            continue
        rel = file.relative_to(path)
        if rel.parts[0] in SKIPPED_TOP or rel.name in SKIPPED_NAME:
            continue
        try:
            text = file.read_text()
        except UnicodeDecodeError:
            continue
        fenced = False
        for line_no, line in enumerate(text.split("\n"), 1):
            if line.lstrip().startswith("```"):
                fenced = not fenced
                continue
            if fenced:
                continue
            if CJK_RUN.search(COPY.sub("", line)):
                findings.append((name, f"{rel}:{line_no} carries a CJK passage outside quoted copy — write the direction in English"))

report(findings)
