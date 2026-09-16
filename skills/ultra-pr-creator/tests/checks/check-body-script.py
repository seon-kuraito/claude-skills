#!/usr/bin/env python3
"""check-body-script — scripts/check-body.py against fixture PR bodies.

It is the last gate before a PR goes out, so a hole here ships a malformed body.
"""
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[2]
script = root / "scripts" / "check-body.py"
fixtures = root / "tests" / "fixtures"

passed, failed = 0, 0


def case(label, fixture, expect_ok, expect_text=None, extra=()):
    global passed, failed
    result = subprocess.run(
        [sys.executable, str(script), str(fixtures / fixture), *extra],
        capture_output=True, text=True,
    )
    ok = result.returncode == 0
    if ok != expect_ok:
        failed += 1
        print(f"FAIL  {label} — exit {result.returncode}, expected {'0' if expect_ok else 'non-zero'}")
        return
    if expect_text and expect_text not in result.stdout:
        failed += 1
        print(f"FAIL  {label} — output never mentions {expect_text!r}")
        return
    passed += 1


case("a well-formed body", "body-good.md", True)
case("a bullet in another language", "body-not-english.md", False, "not English")
case("a missing section", "body-missing-section.md", False, "sections are")
case("a nested bullet", "body-nested-bullet.md", False, "nests a bullet")
case("no attribution footer", "body-no-footer.md", False, "attribution footer")
case("a collapsed section spacer", "body-collapsed-spacer.md", False, "spacer")
case("fewer bullets than commits", "body-good.md", False, "one per commit", extra=("--commits", "5"))
case("bullets matching the commit count", "body-good.md", True, extra=("--commits", "2"))

print("---")
print(f"check-body-script: pass {passed}, fail {failed}")
sys.exit(1 if failed else 0)
