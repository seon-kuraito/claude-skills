---
　
## 🚧 Execution gate

- **Triggers on** — handing `apply.sh` to the user (it copies projects, moves session folders, and rewrites `~/.claude.json`, history, symlinks, and the old paths' VS Code state), and running `finalize.sh`, which deletes the old folders for good.
- **Stop & show** — for `apply.sh`: each move with its size and uncommitted changes, the Claude Code state it moves, the VS Code items it clears, the hard-coded old paths left for the user, the manifest path, and the exact Terminal command; for `finalize.sh`: its `--dry-run` output.
- **Confirm** — wait for explicit confirmation; only then give the quit-and-run instructions or delete the old folders.
- **Never chain** — `apply.sh` and `finalize.sh` are separate confirmations with a check at the new path between them.
　
---
