#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# ///
"""check — the read-only architecture check for Claude Code memory.

    uv run check.py [--claude-dir DIR] [--inventory]

Fails on broken architecture and warns on content that may be stale; changes
nothing. A user's preferences are out of scope: they are checked by reading
them, not by this script.

Exit 0 when nothing fails, exit 1 otherwise.
"""
import argparse
import re
import sys
from pathlib import Path

PARENT_WORDS = {"claude", "global", "memory"}
CASE_REF = re.compile(r"global-memory/([a-z0-9][a-z0-9-]*)/")
WRITE_ENTRY = "global-memory/<case>"
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---", re.DOTALL)
NAME_FIELD = re.compile(r"^name:\s*(.*?)\s*$", re.MULTILINE)
LINK = re.compile(r"\[\[([^\[\]]+)\]\]")
TILDE_PATH = re.compile(r"`(~/[^`\s]+)`")
GLOBAL_FILE = re.compile(r"~/\.claude/global-memory/([a-z0-9][a-z0-9-]*)/([^/`\s]+)\.md$")
INDEX_LINK = re.compile(r"\]\(([^)\s]+\.md)\)")
PLACEHOLDER = set("<>{}*…")


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Check the memory architecture under a Claude Code folder.")
    parser.add_argument("--claude-dir", default="~/.claude", help="the Claude Code folder (default: ~/.claude)")
    parser.add_argument("--inventory", action="store_true", help="also list every memory folder and case with its file count")
    args = parser.parse_args()

    claude = Path(args.claude_dir).expanduser()
    home = claude.parent
    global_memory = claude / "global-memory"
    claude_md = claude / "CLAUDE.md"
    fails, warns, infos = [], [], []

    def where(path: Path) -> str:
        return str(path.relative_to(claude))

    # Global memory: the lookup lines, the write entry, and the case layout.
    cases = []
    if global_memory.is_dir():
        text = read(claude_md) if claude_md.is_file() else None
        if text is None:
            fails.append(("CLAUDE.md", "does not exist, so no lookup line can reach global memory"))
        referenced = set(CASE_REF.findall(text)) if text else set()
        if text is not None and WRITE_ENTRY not in text:
            fails.append(("CLAUDE.md", "has no write entry — the line that names `global-memory/<case>`"))

        for entry in sorted(global_memory.iterdir()):
            if entry.name.startswith("."):
                continue
            if entry.is_file():
                fails.append((where(entry), "sits directly in global-memory/ — move it into a case"))
                continue
            cases.append(entry)
            if text is not None and entry.name not in referenced:
                fails.append((where(entry), "has no lookup line in CLAUDE.md"))
            repeated = sorted(set(entry.name.split("-")) & PARENT_WORDS)
            if repeated:
                fails.append((where(entry), f"repeats a word of its parent path: {', '.join(repeated)}"))
            for child in sorted(entry.iterdir()):
                if child.name.startswith("."):
                    continue
                if child.is_dir():
                    fails.append((where(child), "is a folder inside a case — a case holds files only"))
                elif child.suffix == ".md" and child.stem.startswith(entry.name + "-"):
                    fails.append((where(child), "repeats its case in the file name"))

        for name in sorted(referenced):
            if not (global_memory / name).is_dir():
                fails.append(("CLAUDE.md", f"names global-memory/{name}/, which does not exist"))
    else:
        infos.append(("global-memory", "does not exist — global memory is not initialized"))

    # Project memory: every folder's index against its files.
    folders = []
    projects = claude / "projects"
    if projects.is_dir():
        for folder in sorted(projects.glob("*/memory")):
            if not folder.is_dir():
                continue
            files = sorted(f for f in folder.glob("*.md") if f.name != "MEMORY.md")
            index = folder / "MEMORY.md"
            folders.append((folder, files))
            if not files and not index.exists():
                continue
            if not index.is_file():
                fails.append((where(folder), "holds memory files but no MEMORY.md"))
                continue
            listed = set()
            for target in INDEX_LINK.findall(read(index)):
                listed.add((folder / target).resolve())
                if not (folder / target).is_file():
                    fails.append((where(index), f"links to {target}, which does not exist"))
            for file in files:
                if file.resolve() not in listed:
                    fails.append((where(file), "is not listed in MEMORY.md"))

    # The same memory, byte for byte, in more than one project: a rule that travels.
    copies = {}
    for folder, files in folders:
        for file in files:
            copies.setdefault(read(file), []).append(file)
    for same in copies.values():
        if len(same) > 1:
            others = ", ".join(where(f) for f in same[1:])
            warns.append((where(same[0]), f"is the same memory as {others} — a rule that travels belongs in a case"))

    # Every memory file: its name, its links, and its paths.
    memory_files = [f for case in cases for f in sorted(case.glob("*.md"))]
    memory_files += [f for _, files in folders for f in files]
    for file in memory_files:
        text = read(file)
        header = FRONTMATTER.match(text)
        name = NAME_FIELD.search(header.group(1)) if header else None
        if name is None:
            fails.append((where(file), "has no frontmatter `name`"))
        elif name.group(1).strip("\"'") != file.stem:
            fails.append((where(file), f"`name` is {name.group(1)!r}, but the file name is {file.stem!r}"))

        for target in LINK.findall(text):
            if PLACEHOLDER & set(target):
                continue
            if "/" in target:
                case, _, stem = target.partition("/")
                if not (global_memory / case / f"{stem}.md").is_file():
                    fails.append((where(file), f"[[{target}]] points at no global memory file"))
            elif not (file.parent / f"{target}.md").is_file():
                warns.append((where(file), f"[[{target}]] points at no memory in this folder"))

        for raw in TILDE_PATH.findall(text):
            if PLACEHOLDER & set(raw) or "..." in raw:
                continue
            if not (home / raw[2:]).exists():
                warns.append((where(file), f"`{raw}` does not exist"))
            elif GLOBAL_FILE.match(raw):
                case, stem = GLOBAL_FILE.match(raw).groups()
                warns.append((where(file), f"`{raw}` is a path to a global memory file — link it as [[{case}/{stem}]]"))

    if args.inventory:
        for folder, files in folders:
            infos.append((where(folder), f"{len(files)} memory file(s)"))
        for case in cases:
            infos.append((where(case), f"{len(list(case.glob('*.md')))} file(s)"))

    for label, findings in (("FAIL", fails), ("WARN", warns), ("INFO", infos)):
        for place, message in findings:
            print(f"{label}  {place} — {message}")
    print("---")
    print(f"check: {len(fails)} fail, {len(warns)} warn")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
