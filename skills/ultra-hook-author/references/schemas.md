# Hook JSON Schemas

The JSON contract between Claude Code and a hook: what arrives on stdin per event, how to register in `settings.json`, and what exit codes / stdout mean. Consult this whenever parsing hook input or shaping hook output. Source: the official [Hooks reference](https://code.claude.com/docs/en/hooks). Field names are reproduced exactly — the runtime reads them literally. But the field *set* drifts across Claude Code versions (fields appear, vanish, or get renamed) — treat anything beyond the common four (`session_id` / `transcript_path` / `cwd` / `hook_event_name`) as a map, not a contract, and capture a real payload (`references/testing.md`) to confirm before relying on it.

## Contents

1. Common input fields
2. Event list (when each fires)
3. Per-event input fields (common events)
4. settings.json registration
5. Matcher semantics
6. Output — exit codes
7. Output — structured JSON
8. Environment variables
9. Verified captures (first-hand)

## 1. Common input fields

On stdin as JSON on (almost) every event:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/conversation.jsonl",
  "cwd": "/Users/you/project",
  "hook_event_name": "PreToolUse",
  "permission_mode": "default|plan|acceptEdits|auto|dontAsk|bypassPermissions"
}
```

`permission_mode` appears on tool / permission events. Subagent context adds `agent_id` / `agent_type`. `SessionStart` may add `model`. Treat anything beyond `session_id` / `cwd` / `hook_event_name` as possibly-absent.

## 2. Event list

| Event | Fires when |
| --- | --- |
| `SessionStart` | A session begins (startup / resume / clear / compact) |
| `Setup` | `--init-only`, or `--init` / `--maintenance` in `-p` mode |
| `UserPromptSubmit` | You submit a prompt, before Claude processes it |
| `UserPromptExpansion` | A typed command expands into a prompt; can block expansion |
| `PreToolUse` | Before a tool call runs; can block it |
| `PermissionRequest` | A permission dialog is about to appear |
| `PermissionDenied` | A tool call is denied by the auto-mode classifier |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a batch of parallel tool calls resolves |
| `Notification` | Claude Code sends a notification (idle / permission / auth / elicitation) |
| `MessageDisplay` | While assistant message text is displayed |
| `SubagentStart` / `SubagentStop` | A subagent spawns / finishes |
| `Stop` | Claude finishes responding |
| `StopFailure` | The turn ends due to an API error (output + exit code ignored) |
| `TeammateIdle` | An agent-team teammate is about to go idle |
| `TaskCreated` / `TaskCompleted` | A task is created / marked complete via `TaskCreate` |
| `InstructionsLoaded` | A CLAUDE.md / `.claude/rules/*.md` loads into context |
| `ConfigChange` | A configuration file changes during a session |
| `CwdChanged` | The working directory changes (e.g. a `cd`) |
| `FileChanged` | A watched file changes on disk |
| `WorktreeCreate` / `WorktreeRemove` | A worktree is created / removed |
| `PreCompact` / `PostCompact` | Before / after context compaction |
| `Elicitation` / `ElicitationResult` | An MCP server requests input / the user responds |
| `SessionEnd` | A session terminates |

## 3. Per-event input fields (common events)

Each adds these to the common fields:

```jsonc
// Stop, SubagentStop  (field set is version-dependent — capture to confirm)
{ "stop_hook_active": false, "last_assistant_message": "..." }
// recent builds also carry: "effort": {"level": "…"}, "background_tasks": [], "session_crons": []. Older refs list "reasoning" — not present in recent captures.

// Notification
{ "notification_type": "permission_prompt|idle_prompt|auth_success|elicitation_dialog|elicitation_complete|elicitation_response", "message": "..." }

// PreToolUse, PermissionRequest, PermissionDenied
{ "tool_name": "Bash", "tool_input": { /* tool-specific args */ } }

// PostToolUse (success)
{ "tool_name": "Edit", "tool_input": { }, "tool_output": "string|object" }

// PostToolUseFailure
{ "tool_name": "Bash", "tool_input": { }, "error": "message" }

// UserPromptSubmit
{ "prompt": "user-submitted text" }

// SessionStart
{ "source": "startup|resume|clear|compact", "model": "optional", "session_title": "optional" }

// SessionEnd            → matcher value is the reason (clear|resume|logout|prompt_input_exit|...)
// PreCompact, PostCompact
{ "trigger": "manual|auto" }

// ConfigChange
{ "config_source": "user_settings|project_settings|local_settings|policy_settings|skills" }

// FileChanged
{ "file_path": "/abs/path/to/changed/file" }

// CwdChanged
{ "new_cwd": "/abs/new/dir" }

// StopFailure
{ "error_type": "rate_limit|overloaded|authentication_failed|...", "error_message": "..." }
```

For the remaining events' fields, see the [reference](https://code.claude.com/docs/en/hooks#hook-input).

## 4. settings.json registration

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "/abs/path/hook.sh", "timeout": 10 }
        ]
      }
    ]
  },
  "disableAllHooks": false
}
```

- `<EventName>` is a key inside the single `hooks` object — add a new event as a sibling, don't replace the object.
- The group's `matcher` filters the event (§5). Each entry in the inner `hooks` array is one handler.
- Handler fields: `type` (`command` | `http` | `mcp_tool` | `prompt` | `agent`), plus per-type fields. Command: `command`, optional `args` (exec form — no shell), `async`, `asyncRewake`, `shell`, `timeout`, `once`, `if`, `statusMessage`.
- Path placeholders in `command` / `args`: `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`.

Scopes (low → high precedence): `~/.claude/settings.json` (user) < `.claude/settings.json` (project) < `.claude/settings.local.json` (local) < managed. See `references/registration.md`.

## 5. Matcher semantics

- `"*"`, `""`, or omitted → match all.
- Only `[a-zA-Z0-9_|]` → exact string, or `|`-separated list of exact strings (`"Edit|Write"`).
- Any other character → JavaScript regex (`"mcp__.*"`, `"^Notebook"`).
- MCP tools are named `mcp__<server>__<tool>`; `"mcp__memory__.*"` matches one server.

What each event matches on:

| Event(s) | Matcher filters on |
| --- | --- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name |
| `SessionStart` | `startup\|resume\|clear\|compact` |
| `SessionEnd` | end reason |
| `Notification` | notification type |
| `SubagentStart`, `SubagentStop` | agent type |
| `PreCompact`, `PostCompact` | `manual\|auto` |
| `ConfigChange` | config source |
| `FileChanged` | literal filenames (`.envrc\|.env`) |
| `Stop`, `UserPromptSubmit`, `PostToolBatch`, `CwdChanged`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`, `MessageDisplay`, `WorktreeCreate`, `WorktreeRemove` | no matcher — always fires |

## 6. Output — exit codes

- **`0`** — success. stdout is parsed as JSON if valid (§7), else treated as text; on `UserPromptSubmit` / `SessionStart` / `Setup`, stdout is injected into Claude's context.
- **`2`** — blocking error. stdout ignored; stderr fed to Claude (or shown to the user on non-blockable events).
- **other** — non-blocking error; action proceeds, first stderr line shown as `<hook> hook error`, full stderr in the debug log.

Which events `exit 2` can block:

| Can block (exit 2 stops the action) | Cannot block (exit 2 just shows stderr) |
| --- | --- |
| `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `SubagentStop`, `PostToolBatch`, `PreCompact`, `ConfigChange`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `Elicitation`, `ElicitationResult`, `WorktreeCreate` | `PostToolUse`, `PostToolUseFailure`, `Notification`, `SessionStart`, `SessionEnd`, `SubagentStart`, `Setup`, `CwdChanged`, `FileChanged`, `PostCompact`, `PermissionDenied`, `MessageDisplay`, `StopFailure`, `InstructionsLoaded` |

## 7. Output — structured JSON (exit 0)

Universal fields (any event):

```json
{
  "continue": true,
  "stopReason": "shown when continue is false",
  "suppressOutput": false,
  "systemMessage": "warning shown to the user"
}
```

Top-level `decision` (UserPromptSubmit, PostToolUse, PostToolUseFailure, PostToolBatch, Stop, SubagentStop, ConfigChange, PreCompact):

```json
{ "decision": "block", "reason": "why" }
```

`hookSpecificOutput` — per-event control; `hookEventName` must match the firing event:

```jsonc
// PreToolUse
{ "hookSpecificOutput": { "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "...",
    "updatedInput": { },           // optional — rewrite tool args
    "additionalContext": "..." } }

// PermissionRequest
{ "hookSpecificOutput": { "hookEventName": "PermissionRequest",
    "decision": { "behavior": "allow|deny", "updatedInput": { } } } }

// PostToolUse
{ "hookSpecificOutput": { "hookEventName": "PostToolUse",
    "updatedToolOutput": "string|object", "additionalContext": "..." } }

// Stop / SubagentStop  (block continues the turn; additionalContext is non-error feedback)
{ "hookSpecificOutput": { "hookEventName": "Stop", "additionalContext": "..." } }

// SessionStart
{ "hookSpecificOutput": { "hookEventName": "SessionStart",
    "additionalContext": "...", "sessionTitle": "...", "watchPaths": ["/abs"], "reloadSkills": false } }

// UserPromptSubmit  → use additionalContext to inject text into context
```

`prompt` / `agent` hooks instead return `{ "ok": true|false, "reason": "..." }`.

## 8. Environment variables

Set in the hook process:

- `CLAUDE_PROJECT_DIR` — project root (also `${...}` placeholder in `command` / `args`).
- `CLAUDE_PLUGIN_ROOT`, `CLAUDE_PLUGIN_DATA` — plugin root / data dir (plugin hooks).
- `CLAUDE_EFFORT` — current effort level (`low|medium|high|xhigh|max`).
- `CLAUDE_CODE_REMOTE` — `"true"` in remote / web environments.
- `CLAUDE_ENV_FILE` — (`SessionStart`, `Setup`, `CwdChanged`, `FileChanged` only) write `export` lines here to persist vars for later Bash commands.
- `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` — raises the default 8-block cap for a `Stop` hook that legitimately needs more iterations.

## 9. Verified captures (first-hand)

Real payloads captured from a live session (2026-06-18; stamp `claude --version` when you re-capture — fields vary by build). **When these conflict with the transcribed shapes in §3, trust these.** Capture method: `references/testing.md`.

`Stop` — turn ended:

```jsonc
{
  "session_id": "…",
  "transcript_path": "…/<id>.jsonl",
  "cwd": "/abs/project",
  "permission_mode": "auto",
  "effort": { "level": "xhigh" },          // present on stdin, not just CLAUDE_EFFORT
  "hook_event_name": "Stop",
  "stop_hook_active": false,
  "last_assistant_message": "…full text of Claude's last message…",
  "background_tasks": [],
  "session_crons": []
}
```

This build sends `last_assistant_message` / `effort` / `background_tasks` / `session_crons` (none in the published reference) and does **not** send the docs' `reasoning`.

`Notification` — a permission prompt is about to show:

```jsonc
{
  "session_id": "…",
  "transcript_path": "…",
  "cwd": "/abs/project",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission",
  "notification_type": "permission_prompt"
}
```

`notification_type` **is** a real stdin field (here `permission_prompt`), alongside `message` — confirms §3 (don't assume it's matcher-only). Other values (`idle_prompt` / `auth_success` / `elicitation_*`) not yet captured here.

`SubagentStop` — a subagent (Task) finished:

```jsonc
{
  "session_id": "…",                  // the MAIN session
  "transcript_path": "…/<id>.jsonl",
  "cwd": "/abs/project",
  "permission_mode": "default",
  "agent_id": "a2217bed…",
  "agent_type": "general-purpose",
  "agent_transcript_path": "…/subagents/agent-<id>.jsonl",   // the subagent's own
  "effort": { "level": "…" },
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "last_assistant_message": "done",
  "background_tasks": [ /* the subagent's entry */ ],
  "session_crons": []
}
```

`SubagentStop` carries `agent_id` / `agent_type` / `agent_transcript_path` that a main `Stop` does **not** — so a hook can distinguish a subagent stop from a main-agent stop by these. (Confirms §1's "subagent context adds agent_id / agent_type.") A subagent finishing fires `SubagentStop`, never the main `Stop`.

**No controlling tty** (confirmed): a hook opening `/dev/tty` fails — it has no controlling terminal. So a hook can't write directly to the terminal; emit terminal sequences via the `terminalSequence` output field instead (docs-described, not yet first-hand confirmed).
