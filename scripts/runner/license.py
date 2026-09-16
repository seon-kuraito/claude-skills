#!/usr/bin/env python3
"""license — every skill carries its own LICENSE, and a NOTICE whenever it is derived."""
import sys
from _lib import items, report

findings = []
for name, path in items(sys.argv):
    license_file = path / "LICENSE"
    if not license_file.exists() or not license_file.read_text().strip():
        findings.append((name, "has no LICENSE"))
    notice = path / "NOTICE"
    if notice.exists() and not notice.read_text().strip():
        findings.append((name, "has an empty NOTICE"))
report(findings)
