#!/usr/bin/env python3
"""skill-package — repo-specific: the package holds SKILL.md and README.md, and the frontmatter keys are known."""
import sys
from _lib import items, frontmatter, report

ALLOWED = {
    "name", "description", "license", "allowed-tools", "metadata", "compatibility",
    # command-only skills, invoked by the user rather than routed to by the model
    "argument-hint", "disable-model-invocation", "disallowed-tools",
}

findings = []
for name, path in items(sys.argv):
    for required in ("SKILL.md", "README.md"):
        if not (path / required).exists():
            findings.append((name, f"has no {required}"))
    fields = frontmatter(path / "SKILL.md")
    if fields is None:
        findings.append((name, "SKILL.md has no readable frontmatter"))
        continue
    unknown = sorted(set(fields) - ALLOWED)
    if unknown:
        findings.append((name, f"frontmatter has unknown key(s): {', '.join(unknown)}"))
report(findings)
