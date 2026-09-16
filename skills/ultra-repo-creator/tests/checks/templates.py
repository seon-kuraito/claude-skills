#!/usr/bin/env python3
"""templates — the files the skill copies verbatim exist and stay documented.

A missing template only surfaces mid-run, after the repo already exists.
"""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
assets = root / "assets"
failures = []

required = [
    "execution-gate.md",
    "blank/gitignore.txt",
    "meta-repo/CLAUDE.md.tmpl",
    "meta-repo/README.md.tmpl",
    "meta-repo/code-workspace.tmpl",
    "meta-repo/gitignore.txt",
    "meta-repo/members.md.tmpl",
]
for rel in required:
    path = assets / rel
    if not path.exists() or not path.read_text().strip():
        failures.append(f"assets/{rel} is missing or empty")

gate = assets / "execution-gate.md"
if gate.exists() and "🚧" not in gate.read_text():
    failures.append("execution-gate.md carries no 🚧 gate marker")

# Every placeholder in a meta-repo template must be explained where the skill fills it.
reference = (root / "references" / "meta-repo.md").read_text()
for path in sorted((assets / "meta-repo").glob("*")):
    for name in sorted(set(re.findall(r"\{\{([A-Z_]+)\}\}", path.read_text()))):
        if f"{{{{{name}}}}}" not in reference:
            failures.append(f"{{{{{name}}}}} in {path.name} is never explained in references/meta-repo.md")

gitignore = assets / "blank" / "gitignore.txt"
if gitignore.exists() and ".DS_Store" not in gitignore.read_text():
    failures.append("blank/gitignore.txt does not ignore .DS_Store")

for message in failures:
    print(f"FAIL  {message}")
print("---")
print(f"templates: {'pass' if not failures else str(len(failures)) + ' failed'}")
sys.exit(1 if failures else 0)
