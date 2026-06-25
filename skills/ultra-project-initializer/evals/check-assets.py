#!/usr/bin/env python3
"""Deterministic checks for ultra-project-initializer's shipped assets.

Run: python3 skills/ultra-project-initializer/evals/check-assets.py  (exit 0 = pass)

Not an LLM eval — a static regression guard for the asset files the skill
applies verbatim. Catches a silent edit that breaks the label set, a label
color/description, or the branch-protection invariants (e.g. a non-zero review
count, which deadlocks every PR in a solo repo).
"""
import json
import re
import sys
from pathlib import Path

ASSETS = Path(__file__).resolve().parent.parent / "assets"
fails = []


def check(cond, msg):
    if not cond:
        fails.append(msg)


# --- type-labels.json -------------------------------------------------------
EXPECTED = ["feat", "fix", "improve", "perf", "refactor",
            "style", "test", "docs", "build", "ci", "chore"]
labels = json.loads((ASSETS / "type-labels.json").read_text())
check(isinstance(labels, list), "type-labels.json must be a JSON array")
names = [l.get("name") for l in labels]
check(names == EXPECTED,
      f"label names must equal the importance order {EXPECTED}, got {names}")
for l in labels:
    check(bool(re.fullmatch(r"[0-9a-f]{6}", str(l.get("color", "")))),
          f"{l.get('name')}: color must be 6-digit lowercase hex, got {l.get('color')!r}")
    check(bool(str(l.get("description", "")).strip()),
          f"{l.get('name')}: description must be non-empty")

# --- main-protection-ruleset.json ------------------------------------------
rs = json.loads((ASSETS / "main-protection-ruleset.json").read_text())
check(rs.get("name") == "main-protection", "ruleset name must be 'main-protection'")
check(rs.get("target") == "branch", "ruleset target must be 'branch'")
types = {r.get("type") for r in rs.get("rules", [])}
check({"deletion", "non_fast_forward", "pull_request"} <= types,
      f"ruleset must include deletion, non_fast_forward, pull_request; got {sorted(types)}")
pr = next((r for r in rs.get("rules", []) if r.get("type") == "pull_request"), {})
check(pr.get("parameters", {}).get("required_approving_review_count") == 0,
      "pull_request required_approving_review_count must be 0 "
      "(a higher count deadlocks every PR in a solo repo)")

# --- report -----------------------------------------------------------------
if fails:
    print("FAIL:")
    for m in fails:
        print("  -", m)
    sys.exit(1)
print(f"PASS: type-labels.json ({len(labels)} labels) + main-protection-ruleset.json")
