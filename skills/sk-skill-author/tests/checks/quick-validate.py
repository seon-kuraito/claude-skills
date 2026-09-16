#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""quick-validate — scripts/quick_validate.py against fixture skill packages.

It is the gate package_skill.py runs before packaging, so a hole here ships a
malformed skill.
"""
import importlib.util
import sys
import tempfile
from pathlib import Path

here = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("quick_validate", here.parent.parent / "scripts" / "quick_validate.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
validate_skill = module.validate_skill

passed, failed = 0, 0


def case(label, body, expect_valid):
    global passed, failed
    with tempfile.TemporaryDirectory() as tmp:
        skill = Path(tmp) / "sk-example-verber"
        skill.mkdir()
        if body is not None:
            (skill / "SKILL.md").write_text(body)
        valid, message = validate_skill(str(skill))
        if valid == expect_valid:
            passed += 1
        else:
            failed += 1
            print(f"FAIL  {label} — got valid={valid} ({message})")


def frontmatter(**fields):
    lines = "\n".join(f"{k}: {v}" for k, v in fields.items())
    return f"---\n{lines}\n---\n\n# Body\n"


case("a well-formed skill", frontmatter(name="sk-example-verber", description="Does one thing."), True)
case("no SKILL.md", None, False)
case("no frontmatter", "# Body only\n", False)
case("frontmatter never closed", "---\nname: sk-example-verber\n", False)
case("no name", frontmatter(description="Does one thing."), False)
case("no description", frontmatter(name="sk-example-verber"), False)
case("unknown frontmatter key", frontmatter(name="sk-example-verber", description="x", colour="red"), False)
case("name not kebab-case", frontmatter(name="Sk_Example", description="x"), False)
case("name with a doubled hyphen", frontmatter(name="sk--example", description="x"), False)
case("name over 64 characters", frontmatter(name="sk-" + "x" * 70, description="x"), False)
case("description with angle brackets", frontmatter(name="sk-example-verber", description="Use <this>"), False)
case("description over 1024 characters", frontmatter(name="sk-example-verber", description="x" * 1025), False)
case("allowed optional keys", frontmatter(name="sk-example-verber", description="x", license="MIT", compatibility="Claude Code"), True)

print("---")
print(f"quick-validate: pass {passed}, fail {failed}")
sys.exit(1 if failed else 0)
