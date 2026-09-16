#!/usr/bin/env python3
"""no-real-paths — instructions carry placeholders, never a real machine path or account name."""
import re
import sys
from pathlib import Path
from _lib import items, report

HANDLES = ("seon-kuraito", "seonkuraito", "seon.kuraito")
REAL_PATH = re.compile(r"/Users/(?!<)")
SCANNED = ("SKILL.md", "README.md", "references", "scripts", "assets", "agents", "tests")

findings = []
for name, path in items(sys.argv):
    for target in SCANNED:
        target_path = path / target
        files = [target_path] if target_path.is_file() else sorted(target_path.rglob("*")) if target_path.is_dir() else []
        for file in files:
            if not file.is_file() or file.suffix in (".png", ".jpg", ".ico"):
                continue
            try:
                text = file.read_text()
            except UnicodeDecodeError:
                continue
            where = file.relative_to(path)
            for line_no, line in enumerate(text.split("\n"), 1):
                if REAL_PATH.search(line):
                    findings.append((name, f"{where}:{line_no} hard-codes a machine path — use ~ or a placeholder"))
                for handle in HANDLES:
                    if handle in line:
                        findings.append((name, f"{where}:{line_no} names the real account {handle!r} — use <owner>"))
# The repo README is the other place a real account name hides.
root_readme = Path(sys.argv[1]) / "README.md"
if root_readme.exists():
    for line_no, line in enumerate(root_readme.read_text().split("\n"), 1):
        if REAL_PATH.search(line):
            findings.append(("README.md", f"line {line_no} hard-codes a machine path — use ~ or a placeholder"))
        for handle in HANDLES:
            if handle in line:
                findings.append(("README.md", f"line {line_no} names the real account {handle!r} — use <owner>"))

report(findings)
