#!/usr/bin/env python3
"""description — present, one line, at most 1024 characters. A command-only skill is exempt: nothing routes to it."""
import sys
from _lib import items, frontmatter, report

LIMIT = 1024

findings = []
for name, path in items(sys.argv):
    fields = frontmatter(path / "SKILL.md")
    if fields is None:
        findings.append((name, "SKILL.md has no frontmatter"))
        continue
    if fields.get("disable-model-invocation") == "true":
        continue
    description = fields.get("description", "")
    if not description:
        findings.append((name, "frontmatter has no description"))
    elif len(description) > LIMIT:
        findings.append((name, f"description is {len(description)} characters, limit is {LIMIT}"))
report(findings)
