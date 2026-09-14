# State map

Where Claude Code and VS Code keep per-project state on macOS, how each record is tied to a project path, and how `apply.sh` changes it. Locations are the defaults; `scripts/lib.sh` lists the environment overrides.

## Claude Code

| Store | Location | Record → path | Change |
|---|---|---|---|
| Session folder | `~/.claude/projects/<key>/` — session `*.jsonl`, `memory/`, subagent logs, tool results | the registration whose path encodes to `<key>`; otherwise a session `cwd` that encodes exactly to `<key>` | delete the folder |
| Project entry | `~/.claude.json` → `projects["<path>"]` | the key is the path | delete the entry |
| GitHub repo path | `~/.claude.json` → `githubRepoPaths["<owner>/<repo>"][]` | each array value is a path | remove the value; drop the repo key when that empties it |
| Prompt history | `~/.claude/history.jsonl`, one JSON object per line | the `project` field | drop matching lines; keep every other line byte for byte |

None of these needs VS Code closed, but no Claude Code session may be running while they change.

Not every session writes all four. A session started with `claude` in a terminal (transcript `entrypoint` `cli`) writes its session folder, the project entry once the trust dialog is accepted, a `githubRepoPaths` value when the repo has a GitHub remote, and a history line per typed prompt. A session started from the VS Code extension (`entrypoint` `claude-vscode`) writes only its session folder. A project used only through VS Code therefore shows no project entry, repo path, or history line, and that is not a missed record. This behavior can change between Claude Code versions, so plan from what is on disk rather than from this note.

Leave alone: `~/.claude/sessions/*.json` and `~/.claude/ide/*.lock` (runtime files that disappear with their process), `file-history/` and `session-env/` (keyed by session id, not path), `backups/` (Claude Code rotates its own copies of `~/.claude.json`), and every other `~/.claude.json` field (caches, flags, account data).

### Mapping a session folder to its path

The key is the path with every non-alphanumeric character replaced by `-`. The mapping cannot be reversed: `/a/b-c` and `/a/b/c` share a key, and `.` becomes `-` too. Never decode a key. Take the path from the `projects` registration whose path encodes to the folder name, or from a session `cwd` that encodes exactly to it. Later `cwd` values follow `cd` and can point at a deleted subfolder of a project that still exists.

A folder without sessions is not residue: Claude Code deletes transcripts older than `cleanupPeriodDays` (30 by default), while memory cards stay. A folder without a registration and without a provable path is an orphan — report it, never delete it.

### Writing `~/.claude.json` and `history.jsonl`

Every running Claude Code process rewrites `~/.claude.json`, which is why `apply.sh` refuses to start while a session is open. It still copies the file to a snapshot, computes the new content from that snapshot, compares the live file with the snapshot right before writing, and writes with `cat new > file` — that keeps the inode and permissions a rename would reset.

## VS Code (stable)

Under `~/Library/Application Support/Code/User/`:

| Store | Location | Record → path | Change | VS Code closed? |
|---|---|---|---|---|
| Workspace storage | `workspaceStorage/<id>/`, whose `workspace.json` holds a `folder`, `workspace`, or `configuration` URI | the `file://` URI, percent-decoded | delete the folder | yes — the running app holds the entries listed for window restore |
| Window restore | `globalStorage/storage.json` → `backupWorkspaces.workspaces[].configURIPath`, `backupWorkspaces.folders[].folderUri` | the URI | remove the entry | yes — VS Code rewrites the file on quit |
| Profile association | `globalStorage/storage.json` → `profileAssociations.workspaces["<uri>"]` | the URI key | remove the key | yes |
| GitHub extension cache | `globalStorage/state.vscdb` (SQLite, table `ItemTable`, key `vscode.github`, a TEXT JSON value) → `branchProtection:<uri>` keys | the URI inside the key | remove the key, write the value back as TEXT, then check `pragma integrity_check` | yes — the app keeps the database open |

Leave alone: `backupWorkspaces.emptyWindows` and `~/Library/Application Support/Code/Backups/` (unsaved untitled editors live there), and every other `storage.json` field. Open Recent entries are removed by hand from File › Open Recent.

### Paths that mislead

- **Unplugged drives** — a path under `/Volumes/` looks missing while its drive is detached, so diagnose mode never offers it.
- **Reused paths** — a new folder at an old project's path makes the old records look alive. Diagnose mode cannot see that; targeted mode covers it.

## Why the change runs from Terminal.app

The session running this skill lives inside VS Code or a Claude Code process. Quitting VS Code ends that session, and any running Claude Code process can overwrite `~/.claude.json` after an edit. Planning stays in the session because it only reads; the change runs where both apps are closed, and the session resumes afterwards to verify.
