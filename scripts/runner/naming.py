#!/usr/bin/env python3
"""naming — sk-<single-token>-<verber>, with `author` reserved for extension-authoring skills."""
import re
import sys
from _lib import items, frontmatter, report

PATTERN = re.compile(r"^sk-[a-z0-9]+-[a-z]+$")
AUTHORS = {"sk-skill-author", "sk-hook-author", "sk-agent-author"}

findings = []
for name, path in items(sys.argv):
    if not PATTERN.match(name):
        findings.append((name, "directory name is not sk-<single-token>-<verber>"))
    elif name.endswith("-author") and name not in AUTHORS:
        findings.append((name, "`author` is reserved for skills that author Claude Code extensions"))
    fields = frontmatter(path / "SKILL.md")
    if fields is None:
        findings.append((name, "SKILL.md has no frontmatter to read the name from"))
    elif fields.get("name") != name:
        findings.append((name, f"frontmatter name is {fields.get('name')!r}, expected {name!r}"))
report(findings)
