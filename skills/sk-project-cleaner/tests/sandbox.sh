#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway copy of the state this skill cleans, so a
# behavior case can run plan.sh for real without touching the machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines to prefix scripts/plan.sh with, then the target
# path to clean. The project folder itself is deliberately absent: the case is
# "the project is gone, its records are not".
#
# Not covered: apply.sh's two refuse-to-start guards read $CLAUDE_DIR/sessions
# and $VSCODE_USER_DIR/globalStorage/state.vscdb. Neither exists here, so a
# sandbox run never exercises them — test those by hand.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

gone="$sb/dev/old-demo"                       # never created — already deleted
key="$(printf '%s' "$gone" | sed 's/[^A-Za-z0-9]/-/g')"

mkdir -p "$sb/claude/projects/$key" "$sb/vscode-user/workspaceStorage/ffff1111" "$sb/backups"
printf '%s\n' "{\"cwd\":\"$gone\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"hi\"}}" \
  > "$sb/claude/projects/$key/0a0a0a.jsonl"
printf '%s\n' "{\"project\":\"$gone\",\"display\":\"an old prompt\"}" > "$sb/claude/history.jsonl"

# Memory cards live beside the sessions and are the costly half of the loss the
# gate has to report, so the fixture carries one.
mkdir -p "$sb/claude/projects/$key/memory"
printf -- '---\nname: an-old-lesson\n---\n\nSomething the old project taught.\n' \
  > "$sb/claude/projects/$key/memory/an-old-lesson.md"
cat > "$sb/claude.json" <<JSON
{
  "projects": {
    "$gone": { "allowedTools": [], "history": [] },
    "$sb/dev/kept": { "allowedTools": [], "history": [] }
  },
  "githubRepoPaths": { "owner/old-demo": ["$gone"] }
}
JSON
cat > "$sb/vscode-user/workspaceStorage/ffff1111/workspace.json" <<JSON
{ "folder": "file://$gone" }
JSON
mkdir -p "$sb/dev/kept"

# UV_CACHE_DIR keeps `uv run` inside the sandbox, so a case that forbids every
# outside write can still run the scripts. DEVELOPER_DIR is not read by the
# scripts; it is for the brief: a case told to treat it as the user's
# ~/Developer looks for projects in the fixture, not across the user's repos.
cat <<ENV
CLAUDE_DIR=$sb/claude
CLAUDE_JSON=$sb/claude.json
VSCODE_USER_DIR=$sb/vscode-user
BACKUP_ROOT=$sb/backups
DEVELOPER_DIR=$sb/dev
TARGET=$gone
UV_CACHE_DIR=$sb/.uv-cache
ENV
