# Writing Guide

The static rules for authoring a Claude Code hook. Read this when drafting a hook script, choosing an event, deciding the output mode, or running a self-review. The exhaustive JSON shapes live in `references/schemas.md`; this file is the how-to.

## Anatomy of a hook

```
hooks/<name>/
├── hook.sh          (entry point — reads JSON on stdin, acts, sets exit code)
├── README.md        (house-style — see references/readme-guide.md)
├── install.sh       (optional — post-link setup; run by scripts/link-hook.sh)
├── LICENSE          (+ NOTICE if derived)
└── tests/fixtures/  (optional — sample event payloads, see references/testing.md)
```

A hook is two halves of one thing: the **script** and its **registration** in `settings.json` under an event. Authoring isn't done until both exist — see `references/registration.md`.

Some hooks also carry an optional **`install.sh`** — post-link setup that `scripts/link-hook.sh` runs automatically right after it symlinks the hook. Use it for one-time, idempotent setup a hook needs beyond the symlink: building a compiled artifact, generating an asset, or **checking** registration. It must *not* rewrite `settings.json` — registration stays declare-and-compare, so `install.sh` reports whether the hook is wired but leaves applying `settings.hooks.json` to the live file to the user. Document both install paths (manual copy vs. the script) and the manual registration steps in the README's `## 安裝` section (see `references/readme-guide.md`).

## 1. Choose the event

Pick the lifecycle point where the thing must happen. The most common:

| Goal | Event |
| --- | --- |
| Notify when Claude's turn ends | `Stop` |
| Notify when Claude needs you (idle / permission) | `Notification` |
| Block or rewrite a tool call before it runs | `PreToolUse` |
| React after a tool succeeds (format, lint, log) | `PostToolUse` |
| Validate / block a prompt, or inject context | `UserPromptSubmit` |
| Inject context at session start / after compaction | `SessionStart` (matcher `compact`) |
| Clean up when a session ends | `SessionEnd` |

The full event table (30+ events, when each fires) is in `references/schemas.md`. Two traps:

- **Stop ≠ Notification.** `Stop` fires when Claude *finishes responding*; `Notification` fires when Claude is *waiting for you* (idle, or a permission prompt). "Tell me when the turn is done" → `Stop`. "Tell me when Claude needs me" → `Notification`.
- **`Stop` fires on every turn, not only at task completion**, and not on user interrupts. API errors fire `StopFailure` instead.

## 2. Pick the hook type

Five types; `command` is the default.

- **`command`** — runs a shell command / script. Deterministic. Use for anything rule-based: notify, format, log, block by pattern.
- **`prompt`** — single-turn LLM (Haiku by default) returning `{"ok": true|false, "reason": "..."}`. Use when the decision needs judgment but only the hook's input data.
- **`agent`** — multi-turn subagent with tool access (experimental). Use when judgment requires inspecting files / running commands (e.g. "do the tests pass before Stop?").
- **`http`** — POST the event JSON to a URL; the response body uses the same output format. Use for a shared / remote service.
- **`mcp_tool`** — call a tool on an already-connected MCP server.

Prefer `command` for determinism. Reach for `prompt` / `agent` only when a rule can't express the decision.

## 3. Read the input

Every event delivers JSON on stdin. Read it once, parse with `jq`:

```bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
```

Common fields on every event: `session_id`, `transcript_path`, `cwd`, `hook_event_name`. Event-specific fields (`tool_name` / `tool_input` on tool events, `prompt` on `UserPromptSubmit`, `source` on `SessionStart`, …) are in `references/schemas.md`. Never assume a field exists — default with `// empty` and validate.

## 4. Produce the output

Two modes — don't mix them.

### Simple mode (exit codes)

- **`exit 0`** — no objection; the action proceeds. For `UserPromptSubmit`, `SessionStart`, and a few others, stdout is added to Claude's context. For a pure side-effect hook (notify / log), `exit 0` silently is all you need.
- **`exit 2`** — blocking error. stderr is fed back to Claude (or shown to the user on non-blockable events). Blocks the action *on events that can block* — `PreToolUse`, `UserPromptSubmit`, `Stop`, `PreCompact`, and others (full table in `references/schemas.md`).
- **any other code** — non-blocking error; the action proceeds and the first line of stderr shows as a `<hook> hook error` notice.

### Structured mode (exit 0 + JSON on stdout)

For finer control, `exit 0` and print a JSON object. Universal fields: `continue`, `stopReason`, `suppressOutput`, `systemMessage`. Per-event control goes under `hookSpecificOutput` with a `hookEventName` matching the firing event — e.g. `PreToolUse` uses `permissionDecision: "allow"|"deny"|"ask"`; `Stop` / `PostToolUse` use a top-level `decision: "block"`. Exact shapes: `references/schemas.md`.

Don't mix the modes: Claude Code ignores stdout JSON when you `exit 2`.

## 5. Narrow with matchers and `if`

- **`matcher`** — group-level filter on the event's key field (tool name for tool events, `source` for `SessionStart`, notification type for `Notification`, …). `"Edit|Write"` is a pipe-list; anything with regex characters is a regex; `""` / omitted matches all. Many events ignore the matcher (e.g. `Stop`, `UserPromptSubmit`) — see the matcher table in `references/schemas.md`.
- **`if`** — handler-level filter using permission-rule syntax (`"Bash(git *)"`), so the process only spawns when the call matches. Tool events only. Best-effort and fail-open — not a security boundary; use the permission system for hard allow / deny.

## 6. async, timeout, once

- **`async: true`** — runs in the background without blocking the session; `asyncRewake: true` wakes Claude when done (implies async). Use for slow side-effects.
- **`timeout`** — seconds. Defaults: 600 for `command` / `http` / `mcp_tool` (30 on `UserPromptSubmit`, 10 on `MessageDisplay`), 30 for `prompt`, 60 for `agent`.
- **`once: true`** — run once per session, then drop.

## 7. Gate the side-effect — the event fires unconditionally

A hook fires on **every** occurrence of its event: `Stop` every turn, `PostToolUse` after every matching call, `Notification` every time Claude waits. The event has no notion of *when you'd actually want the action* — so if the hook should act only sometimes, it must check the condition itself and `exit 0` early to skip.

- **Environment gate** — can the side-effect even happen here? A desktop-notification hook is useless (or errors) on a remote / headless / non-macOS host. Guard and bail quietly:
  ```bash
  if [ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || [ "$(uname)" != "Darwin" ] || ! command -v osascript >/dev/null 2>&1; then
    exit 0
  fi
  ```
- **Context gate** — the event fires more often than you want. "Only notify when I've stepped away" is *not* what `Stop` means: it fires every turn, whether or not you are looking. The hook must detect the condition itself — e.g. compare the frontmost app to your terminal and `exit 0` when it matches (macOS: via System Events, which may need Accessibility permission). Likewise "only on `main`" → check `git branch` and skip otherwise.

Settle the gate at interview time (Step 1) — an ungated `Stop` notifier alerts on *every single turn*, which is rarely what the user pictured.

## Conventions

- **Read stdin once.** `INPUT=$(cat)` at the top; parse fields from `$INPUT`. Reading stdin twice hangs.
- **`exit 0` for side-effects.** A notify / log hook must never block or loop Claude. Don't emit JSON unless you intend a decision.
- **Idempotent.** A hook may fire repeatedly (every turn, every edit). Re-running must be safe.
- **Fast.** Hooks sit on the critical path. Keep the work minimal, or mark it `async`.
- **Verify a dependency precisely, then degrade.** A directory existing isn't the tool working — test the actual executable (`[ -x "$app/Contents/MacOS/Bin" ]`, `command -v tool`). A half-built or broken dependency should fall through to a fallback (or a quiet `exit 0`), not be assumed good and silently swallow the action.
- **Quiet stdout unless it's the contract.** On most events, stray stdout is noise and can break JSON parsing. Send diagnostics to stderr.
- **Script in English; localize what the user reads.** The hook script, its comments, and structure stay English (the repo convention). A string the *user* sees — a notification body, a blocked-action reason — may be in the user's language if they prefer: it is display output, not config.

## Security

Hooks run **arbitrary shell with your full user permissions**, automatically, on every matching event. Treat hook input as untrusted — it reflects what the model is doing:

- **Quote every expansion** — `"$FILE_PATH"`, never bare `$FILE_PATH`.
- **Absolute paths** — reference scripts via `"$CLAUDE_PROJECT_DIR"/…` or an absolute path; otherwise `command not found`.
- **Validate before acting** — parse with `jq`, default missing fields, and never `eval` tool input or splice it into a shell string.
- **Guard your shell profile** — wrap any `echo` in `~/.zshrc` / `~/.bashrc` in `if [[ $- == *i* ]]`, or its output prepends to the hook's stdout and breaks JSON parsing.
- **A hook is not a hard boundary** — `if` and matchers fail open. A `PreToolUse` `deny` is enforced, but for guarantees pair policy with permission rules.

## Determinism vs judgment

If the decision is a rule (block `rm -rf`, format `.ts` files), use a `command` hook — deterministic, fast, free. If it needs judgment ("did the user's request actually complete?"), use a `prompt` (input only) or `agent` (can inspect the repo) hook. Don't push a `command` hook into fuzzy judgment, and don't pay for an LLM call when a rule suffices.

## Review checklist

After drafting, verify:

- [ ] The event is the right lifecycle point (re-check Stop vs Notification, PreToolUse vs PostToolUse).
- [ ] Input is read once (`INPUT=$(cat)`) and parsed with `jq`, with defaults for missing fields.
- [ ] Output mode is single and correct — `exit 0` (silent or stdout-context), `exit 2` + stderr (block), or `exit 0` + JSON (structured) — not mixed.
- [ ] For a side-effect hook, it `exit 0`s and emits no stray stdout.
- [ ] The matcher / `if` actually narrows to the intended calls, and the event supports the matcher used.
- [ ] Every variable is quoted; scripts use absolute paths; no untrusted input reaches a shell unguarded.
- [ ] The script is idempotent and fast (or marked `async`).
- [ ] A blocking hook can't infinite-loop — a `Stop` hook that blocks checks `stop_hook_active` and exits 0 when it is `true`.
- [ ] If the action should only happen sometimes (the right OS, you've stepped away, a specific branch), the hook gates on that condition and `exit 0`s to skip — the event itself fires on every occurrence.
