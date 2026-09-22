#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway copy of the state this skill cleans, so a
# behavior case can run plan.sh for real without touching the machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines to prefix scripts/plan.sh with, then the two
# paths the cases name. TARGET is a project folder that is deliberately absent:
# that case is "the project is gone, its records are not". PAD is a launch pad
# that still exists — sessions start there, and the projects live under it —
# with records of its own: that case is "clear the pad, keep what is under it".
#
# Not covered: apply.sh's two refuse-to-start guards read $CLAUDE_DIR/sessions
# and $VSCODE_USER_DIR/globalStorage/state.vscdb. Neither exists here, so a
# sandbox run never exercises them — test those by hand.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

pad="$sb/home"                                # the launch pad — created below
gone="$pad/dev/old-demo"                      # never created — already deleted
key="$(printf '%s' "$gone" | sed 's/[^A-Za-z0-9]/-/g')"
padkey="$(printf '%s' "$pad" | sed 's/[^A-Za-z0-9]/-/g')"

mkdir -p "$sb/claude/projects/$key" "$sb/claude/projects/$padkey" \
  "$sb/vscode-user/workspaceStorage/ffff1111" "$sb/vscode-user/workspaceStorage/ffff2222" "$sb/backups"
printf '%s\n' "{\"cwd\":\"$gone\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"hi\"}}" \
  > "$sb/claude/projects/$key/0a0a0a.jsonl"
printf '%s\n' "{\"cwd\":\"$pad\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"hi\"}}" \
  > "$sb/claude/projects/$padkey/0b0b0b.jsonl"
printf '%s\n' "{\"project\":\"$gone\",\"display\":\"an old prompt\"}" \
  "{\"project\":\"$pad\",\"display\":\"a quick question\"}" > "$sb/claude/history.jsonl"

# Memory cards live beside the sessions and are the costly half of the loss the
# gate has to report, so both fixtures carry one.
mkdir -p "$sb/claude/projects/$key/memory" "$sb/claude/projects/$padkey/memory"
printf -- '---\nname: an-old-lesson\n---\n\nSomething the old project taught.\n' \
  > "$sb/claude/projects/$key/memory/an-old-lesson.md"
printf -- '---\nname: no-auto-memory-here\n---\n\nSave nothing here unless asked.\n' \
  > "$sb/claude/projects/$padkey/memory/no-auto-memory-here.md"
cat > "$sb/claude.json" <<JSON
{
  "projects": {
    "$pad": { "allowedTools": [], "history": [] },
    "$gone": { "allowedTools": [], "history": [] },
    "$pad/dev/kept": { "allowedTools": [], "history": [] }
  },
  "githubRepoPaths": { "owner/old-demo": ["$gone"] }
}
JSON
cat > "$sb/vscode-user/workspaceStorage/ffff1111/workspace.json" <<JSON
{ "folder": "file://$gone" }
JSON
cat > "$sb/vscode-user/workspaceStorage/ffff2222/workspace.json" <<JSON
{ "folder": "file://$pad" }
JSON
mkdir -p "$pad/dev/kept"

# UV_CACHE_DIR keeps `uv run` inside the sandbox, so a case that forbids every
# outside write can still run the scripts. PROJECTS_DIR is not read by the
# scripts; it is for the brief: a case told to treat it as the user's
# ~/Developer looks for projects in the fixture, not across the user's repos.
# PAD stands for the user's home directory the same way, and substitutes
# <pad> in tests/model.json.
cat <<ENV
CLAUDE_DIR=$sb/claude
CLAUDE_JSON=$sb/claude.json
VSCODE_USER_DIR=$sb/vscode-user
BACKUP_ROOT=$sb/backups
PROJECTS_DIR=$pad/dev
TARGET=$gone
PAD=$pad
UV_CACHE_DIR=$sb/.uv-cache
ENV
