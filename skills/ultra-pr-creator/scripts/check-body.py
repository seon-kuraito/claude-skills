#!/usr/bin/env python3
"""check-body — validate an authored PR body against this skill's format.

Usage: check-body.py <body-file> [--commits N]

The conventions this checks are the ones a reader cannot see slipping: a
non-English bullet, a missing section, a collapsed spacer, a nested bullet, or
fewer Summary bullets than the branch has commits. Exit 0 passes, 1 reports.
"""
import re
import sys
import unicodedata
from pathlib import Path

SECTIONS = ["## 📝 Summary", "## 🎯 Scope", "## ✅ Test plan"]
SPACER = "　"  # the ideographic space the template uses as a section break
FOOTER = "🤖 Generated with [Claude Code](https://claude.com/claude-code)"


def cjk(char: str) -> bool:
    """True for a character that makes the body non-English. The spacer is the
    one wide character the template wants, so it is never a finding."""
    if char == SPACER:
        return False
    code = ord(char)
    return (
        0x3000 <= code <= 0x303F      # CJK punctuation
        or 0x3040 <= code <= 0x30FF   # kana
        or 0x3400 <= code <= 0x4DBF   # CJK extension A
        or 0x4E00 <= code <= 0x9FFF   # CJK unified ideographs
        or 0xFF01 <= code <= 0xFF60   # fullwidth forms
    )


def main() -> int:
    args = sys.argv[1:]
    if not args:
        print("usage: check-body.py <body-file> [--commits N]")
        return 1
    path = Path(args[0])
    minimum = 0
    if "--commits" in args:
        minimum = int(args[args.index("--commits") + 1])

    if not path.is_file() or not path.read_text().strip():
        print(f"FAIL  {path} is missing or empty")
        return 1

    text = path.read_text()
    lines = text.split("\n")
    findings = []

    for number, line in enumerate(lines, 1):
        for char in line:
            if cjk(char):
                name = unicodedata.name(char, "unnamed character")
                findings.append(f"line {number} is not English: {char!r} ({name})")
                break

    headings = [line for line in lines if line.startswith("## ")]
    if headings != SECTIONS:
        findings.append(f"sections are {headings}, expected {SECTIONS} in that order")

    for section in SECTIONS[1:]:
        if section in lines:
            index = lines.index(section)
            if lines[index - 3 : index] != ["", SPACER, ""]:
                findings.append(f"{section} has no blank / {SPACER!r} / blank spacer above it")

    if lines and lines[-1] == "":
        lines = lines[:-1]
    if not lines or lines[-1] != FOOTER:
        findings.append("the attribution footer is missing from the last line")
    elif len(lines) > 1 and lines[-2] != "":
        findings.append("the attribution footer needs one blank line above it")

    for number, line in enumerate(lines, 1):
        if re.match(r"^\s+[-*] ", line):
            findings.append(f"line {number} nests a bullet; the format is top-level bullets only")

    if minimum:
        start = lines.index(SECTIONS[0]) if SECTIONS[0] in lines else 0
        end = lines.index(SECTIONS[1]) if SECTIONS[1] in lines else len(lines)
        bullets = [line for line in lines[start:end] if line.startswith("- ")]
        if len(bullets) < minimum:
            findings.append(f"Summary has {len(bullets)} bullets for {minimum} commits; one per commit is the floor")

    for finding in findings:
        print(f"FAIL  {finding}")
    print("---")
    print("check-body: pass" if not findings else f"check-body: {len(findings)} finding(s)")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
