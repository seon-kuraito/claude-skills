---
name: ultra-project-cleaner
description: Diagnoses and clears what Claude Code and VS Code remember about local project paths on macOS — session and memory folders, ~/.claude.json project and GitHub-repo entries, prompt history, VS Code workspace storage, window-restore registrations, and the GitHub extension's cache. Use when a project was deleted, archived, or already moved away and its leftovers at the old path should go, when the user asks whether anything can be cleaned up, or when stale projects keep appearing in Claude Code or VS Code — regardless of exact wording or language. Not for moving or renaming a project or keeping its sessions working at a new path, nor for deleting a project's own files, build output, or dependencies.
---

# Ultra Project Cleaner

Clear the state Claude Code and VS Code keep per project path once that project is gone or retired. Plan read-only in the session, confirm at a gate, and let the user run the change from Terminal.app — the session running this skill lives inside those apps and cannot close them, and both rewrite their state files while they run.

Supports macOS with VS Code (stable) only; anywhere else, say so and stop. The scripts live in this skill's `scripts/`: resolve the base directory Claude Code reports with `realpath` and call them from there (`<base>` below).

## Pick a mode

- **Targeted** — the user names project paths, gone or still on disk. Every record at or under them is a candidate and starts selected. Turn a vague project name into exact paths with the user before planning.
- **Diagnose** — no path named ("anything I can clean up?"). Only records whose path no longer exists become candidates, none selected; the user picks all or some. Orphan session folders and paths under `/Volumes/` are reported as info and cannot be selected: an orphan's path cannot be proven gone, and a missing path on a volume may be an unplugged drive.

## Flow

1. **Plan** — run `bash <base>/scripts/plan.sh --paths <path>...` or `bash <base>/scripts/plan.sh --diagnose`. It changes nothing and writes a manifest (default `~/Backups/<timestamp>-project-cleaner/manifest.json`).
2. **Report** — per project path: which records exist, how many sessions and memory cards a session-folder deletion loses, what is not selectable and why, the info section, and the `scanned` counts, so "no candidates" reads as checked rather than skipped. In diagnose mode, ask which candidates to clear.
3. **Record the selection** — set `selected` on the chosen items; only `selectable` items count (`references/manifest.md`).
4. **Gate** — render `assets/execution-gate.md` (see *🚧 Execution gate*).
5. **Hand off** — once confirmed, tell the user to quit VS Code with Cmd+Q, close every Claude Code session including this one, run `bash <base>/scripts/apply.sh <manifest>` in Terminal.app, then reopen VS Code and `/resume` this session.
6. **Verify** — after the resume, read `apply-log.jsonl` beside the manifest and rerun the same `plan.sh` command: applied items must be gone, and every skipped item needs its reason explained.
7. **Finish** — when the user confirms the result, delete the manifest folder, which holds the backup. Remind them that File › Open Recent entries are removed by hand.

## Safety rules

- **Change state only through the scripts** — never delete a session folder or edit `~/.claude.json`, `history.jsonl`, or VS Code's files from inside the session, however small the change looks: both apps rewrite those files while they run, and only `apply.sh` backs up, re-checks, and refuses while they are open.
- **Back up before deleting** — `apply.sh` copies every file, folder, and database it changes into `backup/` beside the manifest first. Keep it until the user has checked the result.
- **Act on the manifest only** — `apply.sh` re-checks each selected item and skips any whose state changed since planning; it never widens the selection.
- **Protect live work** — records of a project a Claude Code session runs in cannot be selected, and `apply.sh` refuses to start while any session or VS Code is still open.
- **Say what is lost** — deleting a session folder removes its sessions and memory cards for good once the backup is gone; state the counts at the gate.
- **Leave the rest of `~/.claude.json` alone** — only `projects` and `githubRepoPaths` entries change; every other field is Claude Code's own.
- **Know why** — `references/state-map.md` explains each store, how a record maps to a path, and why it is changed the way it is.

## Called from another skill

`ultra-project-migrator` hands its old paths to this skill: `plan.sh --paths <old>... --only vscode --no-live-guard --out <file>` during its preview, and `apply.sh <file>` inside its own Terminal run, so the user quits VS Code once. The contract is in `references/manifest.md`.

## 🚧 Execution gate

Before step 5, render `assets/execution-gate.md`: `apply.sh` deletes session folders, config entries, and editor state that cannot come back once the backup is gone.

## References

- `references/state-map.md` — every store, how a record maps to a path, safe editing, and which stores need VS Code closed
- `references/manifest.md` — manifest fields, selection, per-item re-checks, apply output, and the calling contract
