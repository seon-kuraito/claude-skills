# Manifest

`plan.sh` writes the manifest and `apply.sh` executes it. Between the two, the skill changes only the `selected` flags.

## Shape

```json
{
  "tool": "sk-project-cleaner",
  "version": 1,
  "created": "<UTC timestamp>",
  "mode": "diagnose | paths",
  "only": "all | claude | vscode",
  "exact": false,
  "targets": ["<absolute path>"],
  "env": { "claude_dir": "…", "claude_json": "…", "vscode_user_dir": "…" },
  "scanned": { "<kind>": 12 },
  "items": [
    {
      "id": "i1", "kind": "claude-key-dir", "path": "<project path>",
      "reason": "missing | targeted", "selectable": true, "selected": false,
      "key": "<folder name>", "sessions": 2, "memory": 3, "size": "38M", "registered": true
    }
  ],
  "info": [ { "kind": "orphan-key-dir | unknown-path-key-dir | skipped-volume", "path": "<path, or empty>" } ]
}
```

For a record of a project a Claude Code session runs in, `reason` gains ` (live Claude Code session)` and `selectable` is `false`.

`exact` is `true` when the plan ran with `--exact`, so the verify step can rerun the same command. `apply.sh` does not read it: it matches every item by its identifying fields either way.

## Kinds

| `kind` | Identifying fields | `apply.sh` re-checks before acting |
|---|---|---|
| `claude-key-dir` | `key` (plus `sessions`, `memory`, `size`, `registered`) | the folder still exists |
| `claude-json-project` | `path` | `projects` still has the key |
| `claude-json-github-path` | `repo`, `path` | the repo's array still holds the path |
| `claude-history` | `path`, `entries` | a line with that `project` still exists |
| `vscode-workspace-storage` | `storage_id`, `uri`, `in_use_now` | `workspace.json` still names the same URI |
| `vscode-backup-workspace` | `list` (`workspaces` or `folders`), `uri` | the entry is still listed |
| `vscode-profile-association` | `uri` | the key still exists |
| `vscode-github-cache` | `key` | the cache still has the key |
| `vscode-git-repo-cache` | `remote`, `folder`, `workspace_path`, `repository_path` | the remote still holds that folder entry with the same two paths |
| `vscode-eslint-flag` | `uri` | `noESLintMessageShown.workspaces` still has the URI |
| `vscode-gitlens-visibility` | `path` | `gitlens:repoVisibility` still lists the path |
| `vscode-python-state` | `path`, `entries` | a key, registry row, or copy marker still names the path |
| `vscode-terminal-dir-history` | `path` | an entry without a `remoteAuthority` still has the path as its key |

A `vscode-git-repo-cache` item's `path` is whichever of its two paths made it a candidate — the repository path first. `entries` on a `vscode-python-state` item counts the keys, registry rows, and copy markers that name the path.

For `reason: missing`, `apply.sh` also re-checks that the path is still missing. An item that fails a re-check is logged as skipped. Nothing outside the selected items is touched.

## Selecting

Write the flags back into the same file:

```sh
jq '.items |= map(if .selectable and (.id | IN("i1", "i4")) then .selected = true else . end)' \
  manifest.json > manifest.tmp && mv manifest.tmp manifest.json
```

To clear every candidate the report offered, use `if .selectable then .selected = true else . end`. A targeted plan starts with every selectable item selected; set `selected` to `false` on anything the user keeps.

## Apply output

Beside the manifest, `apply.sh` creates:

- `backup/` — `claude.json`, `history.jsonl`, `storage.json`, `state.vscdb`, `projects/<key>/`, `workspaceStorage/<id>/`, each only when that store changes.
- `apply-log.jsonl` — one `{"id", "status": "applied | skipped", "note"}` line per selected item.

It refuses a manifest whose `env` differs from its own locations, and a manifest that already has a `backup/` beside it.

## Calling contract

Another skill can reuse the cleaner for paths it has already handled:

1. Resolve this skill from its install: `realpath` of `~/.claude/skills/sk-project-cleaner`, then `scripts/` inside it.
2. Plan with `plan.sh --paths <path>... --only vscode --no-live-guard --out <file>`. `--only vscode` keeps Claude Code records out of the plan, since the caller moved those rather than deleting them. `--no-live-guard` keeps records selectable even though the caller's own session may still run at an old path: the caller closes every session before its Terminal run, and `apply.sh` refuses to start while one is open.
3. Show the report inside the caller's own gate.
4. Run `apply.sh <file>` inside the caller's Terminal run, after the caller's own changes, while VS Code and Claude Code are still closed.
5. When this skill is not installed, skip the cleanup and tell the user which paths still carry editor state.
