#!/usr/bin/env bash
#
# validate-registration.sh — sanity-check a hooks registration block before it
# is applied to ~/.claude/settings.json. Checks: valid JSON, a top-level "hooks"
# object, known event names, and that every command handler names a command.
# See references/registration.md.
#
# Usage: validate-registration.sh <settings-or-hooks-json>
#
# Exit: 0 if the block looks well-formed, 1 on any problem. Requires jq.
set -uo pipefail

file="${1:-}"
if [ -z "$file" ]; then echo "usage: validate-registration.sh <json-file>" >&2; exit 1; fi
if [ ! -f "$file" ]; then echo "error: file not found: $file" >&2; exit 1; fi
if ! command -v jq >/dev/null 2>&1; then echo "error: jq is required" >&2; exit 1; fi

if ! jq empty "$file" 2>/dev/null; then
  echo "FAIL: not valid JSON" >&2; exit 1
fi
if ! jq -e '.hooks | type == "object"' "$file" >/dev/null 2>&1; then
  echo "FAIL: no top-level \"hooks\" object" >&2; exit 1
fi

known=(SessionStart Setup UserPromptSubmit UserPromptExpansion PreToolUse PermissionRequest PermissionDenied PostToolUse PostToolUseFailure PostToolBatch Notification MessageDisplay SubagentStart SubagentStop Stop StopFailure TeammateIdle TaskCreated TaskCompleted InstructionsLoaded ConfigChange CwdChanged FileChanged WorktreeCreate WorktreeRemove PreCompact PostCompact Elicitation ElicitationResult SessionEnd)

problems=0

# Every event key must be a known event name.
while IFS= read -r event; do
  [ -z "$event" ] && continue
  if ! printf '%s\n' "${known[@]}" | grep -qx "$event"; then
    echo "WARN: unknown event name: $event" >&2
    problems=$((problems + 1))
  fi
done < <(jq -r '.hooks | keys[]' "$file")

# Every event value must be an array of handler groups; otherwise the handler
# scan below can't iterate it and would emit a misleading count (and a raw jq error).
if ! jq -e '.hooks | map(type == "array") | all' "$file" >/dev/null 2>&1; then
  echo "FAIL: every event value must be an array of handler groups" >&2
  problems=$((problems + 1))
else
  # Every command handler must name a command.
  missing=$(jq '[.hooks[][] | .hooks[]? | select(.type == "command") | select((.command // "") == "")] | length' "$file")
  if [ "$missing" != "0" ]; then
    echo "FAIL: $missing command handler(s) with no \"command\"" >&2
    problems=$((problems + 1))
  fi
fi

if [ "$problems" -eq 0 ]; then
  echo "ok: registration block is well-formed"
  exit 0
fi
echo "$problems problem(s) found" >&2
exit 1
