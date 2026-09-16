#!/usr/bin/env python3
"""pr-templates — the canned PR bodies keep the family's PR shape.

This skill posts these verbatim without going through sk-pr-creator, so the
format conventions have to hold here on their own.
"""
import sys
from pathlib import Path

assets = Path(__file__).resolve().parents[2] / "assets"
failures = []
SECTIONS = ["## 📝 Summary", "## 🎯 Scope", "## ✅ Test plan"]

for name in ("pr-into-main.md", "pr-into-preparing.md"):
    path = assets / name
    if not path.exists():
        failures.append(f"{name} is missing")
        continue
    lines = path.read_text().split("\n")
    headings = [line for line in lines if line.startswith("## ")]
    if headings != SECTIONS:
        failures.append(f"{name} headings are {headings}, expected {SECTIONS}")
    if "　" not in path.read_text():
        failures.append(f"{name} has no full-width spacer between sections")
    if not any(line.startswith("- ") for line in lines):
        failures.append(f"{name} has no bullet content")
    if any(line.startswith("  - ") or line.startswith("    - ") for line in lines):
        failures.append(f"{name} nests bullets, which the PR format forbids")

for name in ("consent-gate.md", "pr-vite-config.md"):
    path = assets / name
    if not path.exists() or not path.read_text().strip():
        failures.append(f"{name} is missing or empty")

gate = assets / "consent-gate.md"
if gate.exists() and not any(mark in gate.read_text() for mark in ("🛑", "🚧")):
    failures.append("consent-gate.md carries no gate marker")

for message in failures:
    print(f"FAIL  {message}")
print("---")
print(f"pr-templates: {'pass' if not failures else str(len(failures)) + ' failed'}")
sys.exit(1 if failures else 0)
