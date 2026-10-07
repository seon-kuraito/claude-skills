#!/usr/bin/env python3
"""readme-catalog — the repo README lists every skill, sorted alphabetically."""
import re
import sys
from pathlib import Path
from _lib import report

repo = Path(sys.argv[1])
names = sys.argv[2:]
readme = (repo / "README.md").read_text()
table = re.search(r"^## Skills 一覽\n(.*?)(?=^## )", readme, re.S | re.M)
listed = re.findall(r"\]\(skills/([a-z0-9-]+)\)", table.group(1) if table else readme)

findings = [(name, "missing from the Skills 一覽 table in README.md") for name in names if name not in listed]
if listed != sorted(listed):
    findings.append(("README.md", "the Skills 一覽 table is not sorted alphabetically"))
report(findings)
