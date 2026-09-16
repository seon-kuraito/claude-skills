"""Shared helpers for the rule scripts. Not a rule itself — the leading underscore keeps it out of the drift comparison."""
import re
import sys
from pathlib import Path

FRONTMATTER = re.compile(r"\A---\n(.*?)\n---", re.DOTALL)


def items(argv):
    """Yield (name, path) for the skills named on the command line."""
    repo = Path(argv[1])
    for name in argv[2:]:
        yield name, repo / "skills" / name


def frontmatter(skill_md: Path):
    """Return the frontmatter as a dict of the scalar keys, or None when it is absent."""
    if not skill_md.exists():
        return None
    match = FRONTMATTER.match(skill_md.read_text())
    if not match:
        return None
    fields, key = {}, None
    for line in match.group(1).split("\n"):
        head = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if head:
            key = head.group(1)
            fields[key] = head.group(2).strip()
        elif key and line.strip():
            fields[key] += " " + line.strip()
    return fields


def report(findings):
    """Print one line per finding and exit 1 when there is any."""
    for name, message in findings:
        print(f"FAIL  {name} — {message}")
    sys.exit(1 if findings else 0)
