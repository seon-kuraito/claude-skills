#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway project plus the state this skill carries
# along, so a behavior case can run plan.sh for real without touching the
# machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines to prefix scripts/plan.sh with, then the move
# pair to plan.
#
# Not covered: apply.sh's refuse-to-start guards (a live session, an open VS
# Code) read files this sandbox does not create — test those by hand.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

old="$sb/dev/demo-app"
new="$sb/dev/acme/demo-app"
key="$(printf '%s' "$old" | sed 's/[^A-Za-z0-9]/-/g')"

mkdir -p "$old/src" "$sb/claude/projects/$key" "$sb/vscode-user/workspaceStorage/eeee2222" "$sb/backups"
printf '# demo-app\n' > "$old/README.md"
printf 'export const answer = 42\n' > "$old/src/index.js"
printf '%s\n' "the project keeps its own copy of $old" > "$old/src/notes.txt"
git -C "$old" init -q
git -C "$old" add -A
git -C "$old" -c user.email=test@example.com -c user.name=test commit -qm "chore: initialize repository"

printf '%s\n' "{\"cwd\":\"$old\",\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":\"hi\"}}" \
  > "$sb/claude/projects/$key/1b1b1b.jsonl"
printf '%s\n' "{\"project\":\"$old\",\"display\":\"an old prompt\"}" > "$sb/claude/history.jsonl"

# "the memory must survive" is half of what this skill promises, so the fixture
# carries a memory card for the plan to count and the move to carry.
mkdir -p "$sb/claude/projects/$key/memory"
printf -- '---\nname: a-project-lesson\n---\n\nSomething this project taught.\n' \
  > "$sb/claude/projects/$key/memory/a-project-lesson.md"
cat > "$sb/claude.json" <<JSON
{
  "projects": { "$old": { "allowedTools": [], "history": [] } },
  "githubRepoPaths": { "owner/demo-app": ["$old"] }
}
JSON
cat > "$sb/vscode-user/workspaceStorage/eeee2222/workspace.json" <<JSON
{ "folder": "file://$old" }
JSON

# The sibling cleaner is looked up under CLAUDE_DIR, which now points at the
# sandbox; CLEANER_DIR is the override that keeps the hand-off testable.
cleaner="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../ultra-project-cleaner" && pwd -P)"

cat <<ENV
CLEANER_DIR=$cleaner
CLAUDE_DIR=$sb/claude
CLAUDE_JSON=$sb/claude.json
VSCODE_USER_DIR=$sb/vscode-user
BACKUP_ROOT=$sb/backups
OLD=$old
NEW=$new
ENV
