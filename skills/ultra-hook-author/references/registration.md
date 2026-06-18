# Registration

A hook script does nothing until it is registered in `settings.json`. This file covers the settings scopes, how the `claude-hooks` repo manages registration without committing the live settings file, and how to confirm a hook actually fires. It is the hook analog of "will it trigger?" — but where a skill tunes a description, a hook's firing is purely structural.

## Settings scopes & precedence

A hook can live in any of these (low → high precedence):

| File | Scope |
| --- | --- |
| `~/.claude/settings.json` | all your projects (user) |
| `.claude/settings.json` | one project, shareable / committed |
| `.claude/settings.local.json` | one project, gitignored |
| managed settings | org-wide, can't be overridden |

A personal, cross-project hook (a notifier, a global guard) goes in the **user** file. A project-specific hook (format this repo's files) goes in the **project** file so collaborators get it. The `claude-hooks` repo's hooks are personal → user settings.

## Declare-and-compare (the claude-hooks repo)

`settings.json` is live runtime state — Claude Code rewrites it when you change model, theme, or permissions — so the repo does **not** symlink or version it. Instead:

- The hook **script** lives in the repo at `hooks/<name>/hook.sh` and is symlinked into `~/.claude/hooks/<name>` by `scripts/link-hook.sh`, so `settings.json` can point at a stable `~/.claude/hooks/<name>/hook.sh` path.
- The **registration** is declared in the repo's `settings.hooks.json` (the source of truth for *how* each hook should be registered) and applied by hand to the live `~/.claude/settings.json`.

So registering a repo hook is two steps: declare the block in `settings.hooks.json`, then merge that block into `~/.claude/settings.json` — add the event as a sibling key, don't replace the `hooks` object. `scripts/validate-registration.sh` checks a block is well-formed before it is applied.

That second step writes the user's **live** settings — runtime state Claude Code itself also edits. Treat it like any change to live config: show the exact merge and confirm before writing, never clobber the existing `hooks` object, and consider delegating the edit to the `update-config` skill (the harness's own settings.json editor) rather than hand-patching it.

## Will it fire? — the correctness checklist

A hook has no trigger description; firing correctness is structural:

- [ ] **Event** — the right lifecycle point (Stop vs Notification; PreToolUse vs PostToolUse).
- [ ] **Matcher** — present only on events that support it (§5 of `references/schemas.md`), and actually matching the intended calls. Matchers are case-sensitive.
- [ ] **`if`** — only on tool events; narrows by command / args but fails open.
- [ ] **Command path** — absolute or `${CLAUDE_PROJECT_DIR}`-rooted, and the script is executable (`chmod +x`).
- [ ] **Scope** — in a settings file that is actually loaded for this session.

## OS notes

The script body is shell, so the platform matters for side-effect commands:

- **macOS** — notify with `osascript -e 'display notification "…" with title "…"'`; play a sound with `afplay /System/Library/Sounds/Glass.aiff`. `osascript` routes through Script Editor, which needs notification permission in System Settings the first time.
- **Linux** — `notify-send 'title' 'body'`.
- **Windows** — PowerShell `MessageBox`, or set the handler's `"shell": "powershell"`.

For portability, branch on `$(uname)` inside the script; on a single-OS machine, keep the platform command inline.

## Verify & debug

- **`/hooks`** — a read-only browser of all registered hooks grouped by event; confirm yours appears under the right event with the right matcher / command. It can't edit — change `settings.json` directly.
- **Pipe a fixture** — `cat fixture.json | ./hook.sh ; echo $?` reproduces what Claude Code does (see `references/testing.md`).
- **Debug log** — `claude --debug-file /tmp/claude.log`, then `tail -f /tmp/claude.log`, shows which hooks matched, their exit codes, stdout, and stderr. `/debug` enables it mid-session.
- **Not firing?** — check the matcher case, the event type, and that the script is executable. For `PermissionRequest` in `-p` mode, switch to `PreToolUse`.
- **Live vs restart** — the hook *script* is re-read per invocation, so script edits apply immediately. A *registration* change (adding/editing an event in settings.json) was observed to take effect within a session without a restart (a settings reload — e.g. a permission-mode toggle — may be what applies it); if a new registration still isn't firing, restarting Claude Code is the sure fix.
