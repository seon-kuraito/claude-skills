#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# ///
"""check-script — scripts/check.py against a valid Claude Code folder and one broken copy per rule.

Each case builds the valid folder in a temporary directory, breaks one thing,
and asserts the exit code and the finding the script prints.
"""
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

here = Path(__file__).resolve().parent
script = here.parent.parent / "scripts" / "check.py"

CLAUDE_MD = """# Global Instructions

## Memory

- Before writing any memory, check whether it belongs in `~/.claude/global-memory/<case>` instead.

## Gates

- Stop before any push.
- Before any action above, `ls ~/.claude/global-memory/gate/` and read the file that matches.
"""

passed, failed = 0, 0


def memory(name, body):
    return f"---\nname: {name}\ndescription: A test memory\nmetadata:\n  type: feedback\n---\n\n{body}\n"


def write(path: Path, text: str):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def build(root: Path) -> Path:
    claude = root / ".claude"
    write(claude / "CLAUDE.md", CLAUDE_MD)
    write(claude / "global-memory/gate/outward-git-actions.md",
          memory("outward-git-actions", "Stop before a push. Related: [[gate/diff-before-discarding]], `~/.claude/CLAUDE.md`, `~/.claude/global-memory/<case>/`, [[<case>/<name>]]."))
    write(claude / "global-memory/gate/diff-before-discarding.md", memory("diff-before-discarding", "Read the diff first."))
    project = claude / "projects/-Users-user-work-demo/memory"
    write(project / "MEMORY.md", "- [Build command](build-command.md) — how the demo builds\n")
    write(project / "build-command.md", memory("build-command", "Run the build. Related: [[gate/outward-git-actions]]."))
    return claude


def case(label, mutate, expect_exit, expect_text=None, extra=()):
    global passed, failed
    with tempfile.TemporaryDirectory() as tmp:
        claude = build(Path(tmp))
        mutate(claude)
        run = subprocess.run([sys.executable, str(script), "--claude-dir", str(claude), *extra],
                             capture_output=True, text=True)
        output = run.stdout + run.stderr
        problems = []
        if run.returncode != expect_exit:
            problems.append(f"exit {run.returncode}, expected {expect_exit}")
        if expect_text and expect_text not in output:
            problems.append(f"output lacks {expect_text!r}")
        if expect_text is None and ("FAIL" in output or "WARN" in output):
            problems.append("expected no finding")
        if problems:
            failed += 1
            print(f"FAIL  {label} — {'; '.join(problems)}\n{output}")
        else:
            passed += 1


def nothing(claude):
    pass


def duplicate_memory(claude):
    source = claude / "projects/-Users-user-work-demo/memory/build-command.md"
    other = claude / "projects/-Users-user-work-other/memory"
    write(other / "MEMORY.md", "- [Build command](build-command.md) — how the other project builds\n")
    write(other / "build-command.md", source.read_text(encoding="utf-8"))


def remove(relative):
    def mutate(claude):
        target = claude / relative
        shutil.rmtree(target) if target.is_dir() else target.unlink()
    return mutate


def add(relative, text):
    def mutate(claude):
        write(claude / relative, text)
    return mutate


def replace(relative, old, new):
    def mutate(claude):
        path = claude / relative
        path.write_text(path.read_text(encoding="utf-8").replace(old, new), encoding="utf-8")
    return mutate


def chain(*mutations):
    def mutate(claude):
        for mutation in mutations:
            mutation(claude)
    return mutate


case("a valid folder", nothing, 0)
case("global memory not initialized", chain(
    remove("global-memory"),
    replace("projects/-Users-user-work-demo/memory/build-command.md", " Related: [[gate/outward-git-actions]].", "")), 0)
case("inventory lists folders and cases", nothing, 0, "INFO  global-memory/gate — 2 file(s)", ("--inventory",))
case("no user-level CLAUDE.md", remove("CLAUDE.md"), 1, "does not exist, so no lookup line")
case("no write entry", replace("CLAUDE.md", "global-memory/<case>", "global memory"), 1, "has no write entry")
case("a case without a lookup line", add("global-memory/talk/answer-first.md", memory("answer-first", "Answer first.")), 1,
     "global-memory/talk — has no lookup line")
case("a lookup line without a case", replace("CLAUDE.md", "global-memory/gate/", "global-memory/gate/` and `~/.claude/global-memory/shell/"), 1,
     "names global-memory/shell/, which does not exist")
case("a file directly in global-memory", add("global-memory/stray.md", memory("stray", "Loose.")), 1,
     "sits directly in global-memory/")
case("a case that repeats its parent path", chain(
    add("global-memory/memory-rules/route-first.md", memory("route-first", "Route first.")),
    replace("CLAUDE.md", "## Gates", "- Before you write a memory, `ls ~/.claude/global-memory/memory-rules/` and read the file that matches.\n\n## Gates")),
     1, "repeats a word of its parent path: memory")
case("a folder inside a case", add("global-memory/gate/old/outward-git-actions.md", memory("outward-git-actions", "Old.")), 1,
     "is a folder inside a case")
case("a file name that repeats its case", add("global-memory/gate/gate-force-push.md", memory("gate-force-push", "Never force-push.")), 1,
     "repeats its case in the file name")
case("a name that differs from the file name", replace("global-memory/gate/diff-before-discarding.md", "name: diff-before-discarding", "name: diff-first"), 1,
     "`name` is 'diff-first'")
case("a memory without frontmatter", add("global-memory/gate/bare.md", "Just a body.\n"), 1,
     "has no frontmatter `name`")
case("a broken global link", replace("projects/-Users-user-work-demo/memory/build-command.md", "[[gate/outward-git-actions]]", "[[gate/missing-rule]]"), 1,
     "[[gate/missing-rule]] points at no global memory file")
case("a bare link to nothing warns", replace("projects/-Users-user-work-demo/memory/build-command.md", "Run the build.", "Run the build. See [[release-steps]]."), 0,
     "WARN  projects/-Users-user-work-demo/memory/build-command.md — [[release-steps]] points at no memory in this folder")
case("an elided tilde path is skipped", replace("global-memory/gate/diff-before-discarding.md", "Read the diff first.", "Read `~/.claude/projects/...` and `~/…/notes.md` first."), 0)
case("inventory lists an empty memory folder", add("projects/-Users-user-work-empty/memory/.keep", ""), 0,
     "INFO  projects/-Users-user-work-empty/memory — 0 memory file(s)", ("--inventory",))
case("a backtick path to a global file warns", replace("projects/-Users-user-work-demo/memory/build-command.md", "[[gate/outward-git-actions]]", "`~/.claude/global-memory/gate/outward-git-actions.md`"), 0,
     "is a path to a global memory file — link it as [[gate/outward-git-actions]]")
case("a backtick path to a case folder is fine", replace("projects/-Users-user-work-demo/memory/build-command.md", "[[gate/outward-git-actions]]", "`~/.claude/global-memory/gate/`"), 0)
case("a missing tilde path warns", replace("global-memory/gate/diff-before-discarding.md", "Read the diff first.", "Read `~/work/gone/notes.md` first."), 0,
     "`~/work/gone/notes.md` does not exist")
case("a project file missing from its index", add("projects/-Users-user-work-demo/memory/test-command.md", memory("test-command", "Run the tests.")), 1,
     "test-command.md — is not listed in MEMORY.md")
case("an index line without its file", remove("projects/-Users-user-work-demo/memory/build-command.md"), 1,
     "links to build-command.md, which does not exist")
case("a project folder without an index", remove("projects/-Users-user-work-demo/memory/MEMORY.md"), 1,
     "holds memory files but no MEMORY.md")
case("the same memory in two projects warns", duplicate_memory, 0,
     "is the same memory as projects/-Users-user-work-other/memory/build-command.md")

print("---")
print(f"check-script: pass {passed}, fail {failed}")
sys.exit(1 if failed else 0)
