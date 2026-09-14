# Procedure

`plan.sh` writes the manifest, `apply.sh` executes it from Terminal.app, `finalize.sh` deletes the old folders once the user has checked the new ones, and `restore.sh` undoes a run that stopped. Every script is safe to read; only `apply.sh`, `finalize.sh`, and `restore.sh` change anything.

## Manifest

```json
{
  "tool": "ultra-project-migrator",
  "version": 1,
  "created": "<UTC timestamp>",
  "env": { "claude_dir": "…", "claude_json": "…", "vscode_user_dir": "…" },
  "pairs": [ { "old": "<abs path>", "new": "<abs path>", "size_kb": 5120, "git": { "head": "<sha>", "dirty": 2 } } ],
  "claude": {
    "key_dirs": [ { "from_key": "<folder>", "to_key": "<folder>", "from": "<path>", "to": "<path>", "cwd_fields": 40, "sessions": 3, "memory": 5 } ],
    "projects": [ { "from": "<path>", "to": "<path>" } ],
    "github": [ { "repo": "<owner>/<repo>", "from": "<path>", "to": "<path>" } ],
    "history_entries": 12,
    "symlinks": [ { "link": "<path under ~/.claude>", "from": "<old target>", "to": "<new target>" } ]
  },
  "repo_mentions": [ { "old": "<path>", "file": "<relative>", "line": 3, "match": "<pattern>", "text": "<line, cut at 160>" } ],
  "cleaner": { "installed": true, "dir": "<path>", "manifest": "<path>", "items": 4 },
  "warnings": [ "<text>" ],
  "blockers": [ "<text>" ]
}
```

`git` is `null` for a folder without `.git`. `repo_mentions` holds at most 200 lines per pattern. Nothing in the manifest is edited by hand: to change a move, plan again.

## What plan.sh checks

**Blockers** — `apply.sh` refuses a manifest that has any:

- the old path is `/`, the home folder, `~/Developer`, or inside `~/.claude`; or it is not a folder, or it is a symlink
- old and new are the same, or one contains the other
- the new path exists and is not an empty folder
- two moves overlap, two targets overlap, or a target lies inside another moved folder
- the target volume has less free space than the folder needs
- `~/.claude.json` already has a `projects` entry for a new path
- a session folder for a new path already exists, its name would pass 200 characters, or two session folders would get the same name

**Warnings** — a Claude Code session or another process works inside an old path (it must close before `apply.sh`); `ultra-project-cleaner` is not installed or could not plan.

**Session folders** — a folder under `~/.claude/projects/` moves when its path is at or under an old path. Its path is the `projects` entry whose encoded form equals the folder name, else a session `cwd` that encodes exactly to the name, else the folder name itself when it equals an encoded old path (a folder that only holds memory). Folder names are never decoded: see *Store notes*.

## What apply.sh does, phase by phase

| Phase | Changes | Stops when |
|---|---|---|
| preflight | nothing | the manifest has blockers, another environment, or a `backup/`; a Claude Code session is open; VS Code holds `state.vscdb`; an old folder is gone; a target is no longer empty; a process works inside an old folder; a session folder is gone or one for a new path appeared |
| copy | creates each new folder with `ditto`; touches `copy-started` first | a copy differs from its source (`diff -rq`), or git `HEAD` differs |
| backup | `backup/projects/<from_key>/`, `backup/claude.json`, `backup/history.jsonl` | a copy fails |
| symlinks | `ln -sfn <new target> <link>` | a new target is missing (a link changed since planning is skipped, not stopped on) |
| session folders | renames each folder, rewrites `cwd` in every `*.jsonl` under it (subagent transcripts too), restores each file's time from the backup | a folder vanished, or its new name exists |
| ~/.claude.json | renames `projects` keys and rewrites `githubRepoPaths` values in one write | the file changed while the script ran, or a renamed key would replace another entry |
| history.jsonl | rewrites `project` fields | the file changed while the script ran |
| VS Code state | runs the cleaner's `apply.sh` on its manifest | never: a cleaner failure prints a warning and the run goes on |
| verify | nothing | any check fails: copies match, old session folders gone and new ones in place, no old `cwd` left, each session file equals its backup after reversing the rewrite and keeps its time, `~/.claude.json` and history hold no old path, relinked symlinks resolve |

Beside the manifest, a run leaves `apply-output.log` (everything printed), `copy-started`, `backup/`, and, when the cleaner ran, `cleaner/` (its manifest, `backup/`, and `apply-log.jsonl`) plus `cleaner-plan.txt`.

## When apply.sh stops

The last lines of `apply-output.log` name the phase, the phases already in effect, and the `restore.sh` command.

| Stopped in | State | What to do |
|---|---|---|
| preflight | nothing changed | fix the cause, then run `apply.sh` again with the same manifest |
| copy | a new folder may be partial; no backup yet | `restore.sh` deletes copies that match their source and lists a partial one for a manual check; after the partial copy is deleted, run `apply.sh` again with the same manifest |
| backup or later | Claude Code state partly moved; `apply.sh` refuses to run again because `backup/` exists | run `restore.sh`, then plan again for a new manifest |
| verify | every change made, a check failed | read the `FAIL` lines first; `restore.sh` undoes the run when the cause is not obvious |

`restore.sh` refuses while a Claude Code session is open, when copying never started, when the run already finished (`migration finished` in the log), and when it already restored. It does not bring back VS Code state the cleaner cleared: that state is editor-only (window restore, workspace storage, a cache), VS Code rebuilds it, and its backup stays in `cleaner/backup/`. Delete the old manifest folder once the restored result is checked.

## finalize.sh

`finalize.sh [--dry-run] <manifest>` needs `migration finished` in `apply-output.log` and the `copy-started` marker. For each move it checks that the new copy exists and is not empty, that every file in the old folder newer than `copy-started` has the same content in the new copy, and that no Claude Code session or process works inside it. Any problem stops it before deleting anything. Otherwise it deletes the old folders, then the manifest folder with every backup. `--dry-run` runs the same checks and deletes nothing.

The content check skips `.DS_Store`, `.git/index`, and `.git/FETCH_HEAD`: git rewrites the last two even on read-only commands, such as the background status and fetch an editor runs when the old folder is opened by mistake. Any other difference, including new git objects from a real commit or fetch, stops finalize; delete by hand only after checking what changed.

## Store notes

- **Session folder names** — Claude Code names the folder by replacing every character that is not a letter or digit with `-`. Different paths can share a name (`a.b` and `a-b`), so a name never proves a path; the plan uses registrations and session `cwd` values instead.
- **Field rewrite** — a value changes only when it is an old path or continues with `/` after it, so a look-alike prefix (`proj-ab` for `proj-a`) stays. Only the `cwd` key in session files and `project` in history change.
- **File times** — `/resume` lists sessions by modification time, and Claude Code deletes transcripts older than `cleanupPeriodDays` (default 30) by the same time. Rewriting without restoring the time would reorder the list and postpone that cleanup.
- **`githubRepoPaths`** — maps `<owner>/<repo>` to the local clones Claude Code knows; each value moves with its folder, and repos keep their order.
- **Which sessions write what** — a session started with `claude` in a terminal (transcript `entrypoint` `cli`) writes the project entry once the trust dialog is accepted, a `githubRepoPaths` value when the repo has a GitHub remote, and a history line per typed prompt. A session started from the VS Code extension (`claude-vscode`) writes only its session folder, so a plan with no config or history entries is normal for a project used only through VS Code. This can change between Claude Code versions; the plan reads what is on disk.
- **Safe writes** — `~/.claude.json` and `history.jsonl` are copied to a snapshot, the new content is computed from it, and the live file is overwritten in place (`cat new > file`, keeping inode and mode) only when it still equals the snapshot.
- **Why Terminal.app** — Claude Code rewrites `~/.claude.json` and `history.jsonl` while any session runs, and VS Code keeps `state.vscdb` open; a change made from inside a session can be overwritten or corrupt the database.
