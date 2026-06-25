#!/usr/bin/env python3
"""Deterministic format check for ultra-pr-creator's body template.

Run: python3 skills/ultra-pr-creator/evals/check-template.py  (exit 0 = pass)

Not an LLM eval — a static regression guard for the byte-exact template
conventions that humans miss and a SKILL.md/template edit can silently break:
the three emoji-prefixed H2s in order, the U+3000 (　) section spacer, open
`- [ ]` checkboxes, and the attribution footer set off by a plain blank line.
"""
import sys
from pathlib import Path

tpl = (Path(__file__).resolve().parent.parent / "assets" / "pr-body-template.md").read_text()
lines = tpl.split("\n")
fails = []


def check(cond, msg):
    if not cond:
        fails.append(msg)


h2 = [l for l in lines if l.startswith("## ")]
check(h2 == ["## 📝 Summary", "## 🎯 Scope", "## ✅ Test plan"],
      f"H2 headings must be exactly the three emoji-prefixed sections in order, got {h2}")
check(any(l == "　" for l in lines),
      "must contain a U+3000 (　) spacer line between sections")
check("- [ ]" in tpl, "Test plan must use open `- [ ]` checkboxes")
check("- [x]" not in tpl and "- [X]" not in tpl,
      "template must NOT ship ticked `- [x]` checkboxes")

FOOTER = "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
nonempty = [l for l in lines if l.strip()]
check(bool(nonempty) and nonempty[-1] == FOOTER,
      "last non-empty line must be the attribution footer")
if FOOTER in lines:
    i = lines.index(FOOTER)
    check(i > 0 and lines[i - 1] == "",
          "footer must be preceded by a plain blank line (not a 　 spacer)")

if fails:
    print("FAIL:")
    for m in fails:
        print("  -", m)
    sys.exit(1)
print("PASS: pr-body-template.md format conforms")
