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

## Pairing a blocking hook with permission rules

A blocking hook fails open: a missing `jq`, a timeout, or a script error lets the call through. Where a guarantee is needed, add `permissions.deny` rules in the same `settings.json` — the harness enforces them without running anything. Read the pattern rules in the [permissions reference](https://code.claude.com/docs/en/permissions#read-and-edit) before writing one: a rule that looks right and matches nothing fails in silence. Five facts; the first two are documented there, and all but the second were also observed first-hand (2026-09):

- **Anchor the pattern.** `Read(**/<name>)` is relative to the session's working directory: it did not block a file that sat outside it. `Read(//**/<name>)` starts at the filesystem root and blocked the file wherever it was; `Read(~/<path>)` starts at the home directory. A single leading `/` anchors at the settings source — `~/.claude/` for user settings — not at the root. A rule in user settings that is meant for every project takes the `//` or the `~/` form.
- **A `Read` deny rule covers more than Read.** It also blocks Edit and Write on the same path, creating the file included, and the file commands Claude Code recognizes in Bash (`cat`, `head`, `tail`, `sed`, `tee`) plus redirection targets. So a family rule such as `Read(//**/<name>.*)` also stops a template file from being written, even where the hook lets template writes through. It does not cover a command that names no file (`grep -r pattern .`) or a script that opens files itself; for those the reference points to the sandbox.
- **A deny rule has no exception.** When the hook allowlists part of a family — the public certificates inside a key-file extension, say — leave the whole family out of the deny list, or the allowlisted names go too.
- **The hook hides the rule.** Both layers block the same names and the hook answers first, so a normal read cannot show whether the deny rule works. Test with a name only the deny layer knows: add a throwaway rule such as `Read(//**/*.zzprobe)`, read a probe file with that extension from a scratch folder, and expect `File is in a directory that is denied by your permission settings`. Then remove the rule and the file.
- **Rules apply at once.** A change to `permissions.deny` took effect in the running session, with no restart.

## Renaming a hook

The registered `command` names the hook's directory, so a rename breaks the live path the moment the directory moves. Do it in this order, and keep the old path alive until nothing calls it:

1. Rename the directory in the repo and update what names it: `settings.hooks.json`, the catalog row in the repo README (which also moves, to stay alphabetical), the hook's own README, the header comment of `hook.sh`.
2. Run `scripts/link-hook.sh <new-name>`.
3. Change the `command` path in the live `settings.json`. The running session picked the new path up at once (observed 2026-09).
4. Point the OLD symlink at the new directory instead of deleting it: `ln -sfn <repo>/hooks/<new-name> ~/.claude/hooks/<old-name>`. A session that started before the rename may still call the old path; this keeps its guard on.
5. When no such session is left, remove the old symlink.

A hook that derives its own name from its directory (`HOOK_NAME="${HOOK_DIR##*/}"`) reports whichever name it was called through, so during step 4 its messages and its log file can carry the old name. When the working tree the symlink points at is the live hook, do the rename on a separate `git worktree` first and run the fixtures there.

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
