---
name: sk-memory-composer
description: Authors, routes, audits, and restructures Claude Code memory — per-project memory files with their MEMORY.md index, and the user-level global memory under ~/.claude/global-memory/. Use before writing any memory file — including when the user, while asking for something else, sets a rule or preference meant to hold for future work — and for ANY other task touching a memory: updating one; deciding whether a rule belongs in global or project memory; deleting, splitting, merging, or migrating memories; adding or renaming a case directory; setting global memory up from scratch; handing memories to another session; or auditing memory for duplicates and drift — matched on intent rather than exact wording or language. Distinct from sk-claudemd-composer (CLAUDE.md content outside the memory sections) and sk-project-cleaner / sk-project-migrator (the memory folders of a deleted or moved project).
---

# Memory Composer

Keep Claude Code's memory in one architecture across two layers: project memory, which the harness loads for one project, and global memory, which follows the user into every project through lookup lines in the user-level CLAUDE.md. This skill owns that architecture — where a memory goes, how cases and files are named and linked, what CLAUDE.md carries, and how it is checked. How the user wants memories written is theirs: read it from their global memory, never from here.

The scripts live in this skill's `scripts/`: resolve the base directory Claude Code reports with `realpath` and call them from there (`<base>` below). They use only the Python standard library: run them with `uv run` when uv is installed, otherwise with `python3`. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

## Read the user's preferences first

Before any flow, find the lookup line in the user-level CLAUDE.md that covers memory work, list that case, and read the files that match the task. Apply them on top of this skill. When no such line exists, follow the harness's own memory instructions for the file itself. A preference file that restates a rule from `references/architecture.md` is a duplicate: report it.

## The architecture

- **Project memory** — `~/.claude/projects/<encoded-path>/memory/`, one file per memory plus a `MEMORY.md` index. The harness loads the index into sessions started in that project, and nowhere else.
- **Global memory** — `~/.claude/global-memory/<case>/<name>.md`. Nothing loads these files on its own.
- **Lookup lines** — every case has a CLAUDE.md section that ends with the line in `assets/lookup-line.tmpl`. It is the only thing that sends a session into a case, and only at the moment it names.
- **Write entry** — the `## Memory` section carries the routing line in `assets/claude-md-memory-section.txt`. Lookup lines only bring a session in to read; this line makes a session that never loaded this skill consider global memory when it writes.
- **Preferences stay out** — body language, extra frontmatter, body shapes, granularity, and when to delete or hand off belong to the user's cases.

The full rules and their reasons: `references/architecture.md`.

## Pick a flow

| The task | Flow |
| --- | --- |
| No `~/.claude/global-memory/` yet | Init |
| Save or update a memory, including one Claude decides on mid-task or a standing rule the user states in passing | Write |
| A rule fits no case, or a case name no longer says when to look it up | Case |
| Is the memory in order — duplicates, drift, misplaced rules | Audit |
| Split, merge, migrate, or delete memories | Restructure |
| Hand memories to another session, or clear memories once their work lands | The user's preferences; no flow here |

The steps are in `references/flows.md`. In outline:

- **Init** — make sure the user-level CLAUDE.md exists: when it does not, load `sk-claudemd-composer` for a blank one and come back; without that skill, create the blank file yourself. Then create `~/.claude/global-memory/`, add the `## Memory` section, and run the check.
- **Write** — route to global or project, pick the case by reading the CLAUDE.md sections, write or update the file, update the index, decide whether the rule needs its own CLAUDE.md line, run the check.
- **Case** — add a case only when nothing fits, name it by the rules, give it a section and a lookup line; to rename one, move it and rewrite every lookup line, link, and path that names it.
- **Audit** — run the check, build the inventory from disk, compare every memory with the user's preferences, and report every finding before changing anything.
- **Restructure** — list the changes, pass the gate, back up, apply, run the check.

## Check

`uv run <base>/scripts/check.py` reads `~/.claude` (or `--claude-dir <dir>`) and changes nothing; `--inventory` also lists every memory folder and case with its file count. It fails on broken architecture — a case without a lookup line, a lookup line without a case, no write entry, a `name` that differs from its file name, a broken `[[<case>/<name>]]` link, an index out of step with its folder. It warns on a bare `[[name]]` link to nothing, on a backtick `~/` path that does not exist, on a backtick path to a global memory file where a `[[<case>/<name>]]` link belongs, and on one memory that sits byte for byte in two project folders. Run it at the end of every flow that writes and at the start of an audit. It checks architecture only; preferences are checked by reading them.

## Safety rules

- **Back up before a change that touches more than one file** — `uv run <base>/scripts/backup.py --dest <dir> <path>...` copies them, paths kept, into a new timestamped folder and prints it. Use the session scratchpad when the host provides one, otherwise the system temp directory. The backup does not outlive the session or a reboot: say so, and run the check before the session ends.
- **Show the diff before any CLAUDE.md edit** — the file loads into every session.
- **Write only the memory parts of CLAUDE.md** — sections that end with a lookup line, and the write entry. The rest of the file belongs to `sk-claudemd-composer`.
- **Never list the cases inside a memory** — say how to find them (`ls ~/.claude/global-memory/`). A list goes stale the day a case is added.
- **Never invent a fact to fill a field** — a date, a source, a reason: ask, or leave it out.

## Execution gate

Before a Restructure, a case rename, deleting any memory, or applying an Audit's changes, stop at an execution gate and wait for an explicit go. List every file to be created, changed, moved, or deleted, the backup folder, and the CLAUDE.md diff. The backup lasts only until the session ends or the machine reboots, so finish the change and the check in one session.

## References

- `references/architecture.md` — the two layers, path encoding, lookup lines, rule lines, the write entry, cases, files, links, indexes, and where architecture ends and preferences begin
- `references/flows.md` — every flow step by step, and the evidence rules an audit follows
- `references/menus.md` — every menu and plain-text question

## Related

- [sk-claudemd-composer](../sk-claudemd-composer/SKILL.md) — CLAUDE.md as a whole. This skill writes only the memory sections inside it, and asks it for a blank user-level CLAUDE.md when none exists.
- [sk-project-cleaner](../sk-project-cleaner/SKILL.md) / [sk-project-migrator](../sk-project-migrator/SKILL.md) — a project's memory folder once the project is deleted or moved.
