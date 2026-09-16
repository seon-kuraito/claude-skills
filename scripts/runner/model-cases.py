#!/usr/bin/env python3
"""model-cases — tests/model.json exists and carries at least one default trigger case. A command-only skill is exempt."""
import json
import sys
from _lib import items, frontmatter, report

findings = []
for name, path in items(sys.argv):
    fields = frontmatter(path / "SKILL.md") or {}
    if fields.get("disable-model-invocation") == "true":
        continue
    model = path / "tests" / "model.json"
    if not model.exists():
        findings.append((name, "has no tests/model.json"))
        continue
    try:
        cases = json.loads(model.read_text())
    except json.JSONDecodeError as error:
        findings.append((name, f"tests/model.json is not valid JSON — {error}"))
        continue
    triggers = cases.get("trigger", [])
    if not [case for case in triggers if case.get("default")]:
        findings.append((name, "tests/model.json has no default trigger case"))
    for case in triggers:
        missing = [field for field in ("id", "prompt", "expect") if not case.get(field)]
        if missing:
            findings.append((name, f"trigger case {case.get('id', '?')} is missing {', '.join(missing)}"))
    for case in cases.get("behavior", []):
        missing = [field for field in ("id", "prompt", "assert") if not case.get(field)]
        if missing:
            findings.append((name, f"behavior case {case.get('id', '?')} is missing {', '.join(missing)}"))
report(findings)
