#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# ///
"""backup-script — scripts/backup.py copies files and folders with their paths, and copies nothing when a path is missing."""
import subprocess
import sys
import tempfile
from pathlib import Path

here = Path(__file__).resolve().parent
script = here.parent.parent / "scripts" / "backup.py"

passed, failed = 0, 0


def check(label, condition, detail=""):
    global passed, failed
    if condition:
        passed += 1
    else:
        failed += 1
        print(f"FAIL  {label}{' — ' + detail if detail else ''}")


with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp)
    home = root / "home"
    dest = root / "scratchpad"
    (home / ".claude/global-memory/gate").mkdir(parents=True)
    (home / ".claude/global-memory/gate/outward-git-actions.md").write_text("gate rule\n", encoding="utf-8")
    (home / ".claude/CLAUDE.md").write_text("# Global Instructions\n", encoding="utf-8")
    outside = root / "elsewhere/notes.md"
    outside.parent.mkdir(parents=True)
    outside.write_text("outside home\n", encoding="utf-8")

    run = subprocess.run([sys.executable, str(script), "--dest", str(dest), "--home", str(home),
                          str(home / ".claude/CLAUDE.md"), str(home / ".claude/global-memory/gate"), str(outside)],
                         capture_output=True, text=True)
    check("copies files and folders", run.returncode == 0, run.stderr)
    folder = Path(run.stdout.strip())
    check("prints a new folder inside --dest", folder.parent == dest and folder.name.startswith("memory-backup-"), run.stdout)
    check("keeps a file's path relative to home",
          (folder / ".claude/CLAUDE.md").read_text(encoding="utf-8") == "# Global Instructions\n")
    check("copies a folder with its files",
          (folder / ".claude/global-memory/gate/outward-git-actions.md").read_text(encoding="utf-8") == "gate rule\n")
    check("keeps the absolute path of a file outside home",
          (folder / outside.relative_to(outside.anchor)).is_file())

    second = subprocess.run([sys.executable, str(script), "--dest", str(dest), "--home", str(home), str(home / ".claude/CLAUDE.md")],
                            capture_output=True, text=True)
    check("never reuses an existing folder", Path(second.stdout.strip()) != folder, second.stdout)

    empty = root / "empty-dest"
    missing = subprocess.run([sys.executable, str(script), "--dest", str(empty), "--home", str(home),
                              str(home / ".claude/CLAUDE.md"), str(home / ".claude/nope.md")],
                             capture_output=True, text=True)
    check("a missing path exits 1", missing.returncode == 1, missing.stdout)
    check("a missing path is named", "nope.md" in missing.stderr, missing.stderr)
    check("a missing path copies nothing", not empty.exists())

print("---")
print(f"backup-script: pass {passed}, fail {failed}")
sys.exit(1 if failed else 0)
