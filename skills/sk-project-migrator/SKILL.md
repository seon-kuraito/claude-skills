---
name: sk-project-migrator
description: Moves or renames local project folders on macOS and carries along what Claude Code and VS Code remember about them, so sessions, memory, and project settings survive the new path. Use when the user wants to move, rename, relocate, or reorganize project folders (for example into per-owner directories), or asks how to keep Claude Code sessions and memory after changing a project's path — regardless of exact wording or language. Not for moving files inside a project, cloning a repo elsewhere, or deleting a retired project's leftovers.
---

# Project Migrator

Move project folders to new paths and carry the state Claude Code and VS Code keep per path. Plan read-only in the session, confirm at a gate, and let the user run the change from Terminal.app — the session running this skill usually sits inside the folder being moved, and both apps rewrite their state files while they run.

Supports macOS with VS Code (stable) only; anywhere else, say so and stop. The scripts live in this skill's `scripts/`: resolve the base directory Claude Code reports with `realpath` and call them from there (`<base>` below).

## What moves, what is cleared, what stays

- **Moves with the project** — the folder, copied with `ditto` and checked against its source and git `HEAD`; its session folders, including those of subfolders, with each session's `cwd` rewritten and file times kept; `~/.claude.json` `projects` keys and `githubRepoPaths` values; `history.jsonl` `project` fields; `~/.claude` symlinks that point into the old path.
- **Cleared** — the old paths' VS Code state, through `sk-project-cleaner` in the same Terminal run; VS Code builds fresh state when it opens the new path. When the cleaner is not installed, that state stays behind: say so in the report.
- **Reported only** — hard-coded old paths inside the projects (absolute, `~/…`, `${workspaceFolder:<old name>}`). They are project content, so the user decides what to edit after the move.
- **Deleted last** — the old folders stay until the user has resumed at the new path and confirmed the result.

## Flow

1. **Pin down the moves** — exact old and new absolute paths, several pairs per run if needed. A new path must not exist yet, or be an empty folder. Confirm the pairs with the user before planning.
2. **Plan** — run `bash <base>/scripts/plan.sh --move <old> <new> [--move <old> <new>]...`. It changes nothing and writes a manifest (default `~/Backups/<timestamp>-project-migrator/manifest.json`).
3. **Report** — relay the printed report: each move with its size and uncommitted changes, session folders with their session and memory counts, config, history, and symlink counts, the VS Code items to clear, hard-coded old paths, warnings, and blockers. Resolve blockers with the user and plan again; `apply.sh` refuses a plan that has any.
4. **Gate** — render `assets/execution-gate.md` for `apply.sh`.
5. **Hand off** — tell the user to quit VS Code with Cmd+Q, close every Claude Code session including this one, and run `bash <base>/scripts/apply.sh <manifest>` in Terminal.app. When it prints `migration finished`, open the new path with File › Open Folder or `code -n <new path>` and `/resume` this session there. Warn against File › Open Recent: it still lists the old path, the old folder stays on disk until step 7, and a resume there finds no sessions.
6. **Check at the new path** — read `apply-output.log` beside the manifest and make sure every verify line reads `ok`. Check that `git status` matches the plan, then go through the hard-coded old paths with the user.
7. **Finalize** — run `bash <base>/scripts/finalize.sh --dry-run <manifest>` and render the gate again with its output. After confirmation, run it without `--dry-run`: it deletes the old folders and the manifest folder, backups included.

## When apply.sh stops

`apply.sh` prints the phase it stopped in, what already took effect, and the `restore.sh` command. The old folders are never changed. Tell the user to run that command in Terminal.app before reopening any session: `restore.sh` puts the Claude Code state back from the backup, points symlinks back, and deletes each new copy that still matches its source. Then `/resume` at the old path and plan again. Per-phase details and the exceptions are in `references/procedure.md`.

## Safety rules

- **Change state only through the scripts** — never move session folders or edit `~/.claude.json`, `history.jsonl`, symlinks, or VS Code's files from inside the session, however small the change looks: both apps rewrite those files while they run, and only `apply.sh` backs up, re-checks, and verifies.
- **Copy, delete last** — the old folder is the fallback until the user confirms; `finalize.sh` refuses while a process works inside an old folder, or when a file there changed after the copy started and the new copy lacks that content (git's refreshed `.git/index` and `.git/FETCH_HEAD` aside).
- **Back up before changing** — `apply.sh` copies the session folders, `~/.claude.json`, and `history.jsonl` into `backup/` beside the manifest before it touches them.
- **Act on the manifest only** — `apply.sh` re-checks the plan before copying (sessions and VS Code closed, targets still empty, session folders unchanged) and rewrites only paths at or under the old paths.
- **Rewrite fields, not text** — only `cwd` in session files and `project` in history change; a path quoted inside a message stays as written, so transcripts keep what was said.
- **Leave the rest of `~/.claude.json` alone** — only `projects` keys and `githubRepoPaths` values change; every other field is Claude Code's own.
- **Verify after writing** — `apply.sh` fails loudly unless each copy matches, no old `cwd` is left, each session equals its backup apart from `cwd` with times kept, and config, history, and symlinks hold no old path.

## Working with sk-project-cleaner

The migrator finds the cleaner at `~/.claude/skills/sk-project-cleaner`, plans the old paths with its `plan.sh --paths <old>... --only vscode --no-live-guard` during the preview, and runs its `apply.sh` inside the same Terminal run, so the user quits VS Code once. A user who wants a project's state deleted rather than moved needs the cleaner itself, not this skill.

## 🚧 Execution gate

Before step 5 and again before step 7, render `assets/execution-gate.md`: `apply.sh` changes state outside the project that the user cannot see, and `finalize.sh` deletes the old folders for good.

## References

- `references/procedure.md` — manifest fields, plan checks, what each `apply.sh` phase changes and checks, restore per phase, finalize, and notes on each store
