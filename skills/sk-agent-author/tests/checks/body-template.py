#!/usr/bin/env python3
"""body-template — the agent skeleton and the interview stay in step.

Every placeholder the template carries must be explained where the author
fills it — the interview mapping or SKILL.md — and every placeholder those
documents name must exist in the template.
"""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
template = (root / "assets" / "agent-body.md.tmpl").read_text()
interview = (root / "references" / "interview.md").read_text() + (root / "SKILL.md").read_text()

in_template = set(re.findall(r"\{\{([A-Z_]+)\}\}", template))
in_interview = set(re.findall(r"\{\{([A-Z_]+)\}\}", interview))
failures = []

for name in sorted(in_template - in_interview):
    failures.append(f"{{{{{name}}}}} is in the template but nothing documents what fills it")
for name in sorted(in_interview - in_template):
    failures.append(f"{{{{{name}}}}} is documented but absent from the template")
if not in_template:
    failures.append("the template carries no placeholders at all")

for message in failures:
    print(f"FAIL  {message}")
print("---")
print(f"body-template: {len(in_template)} placeholders, {'pass' if not failures else str(len(failures)) + ' failed'}")
sys.exit(1 if failures else 0)
