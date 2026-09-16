#!/usr/bin/env bash
#
# restore.sh — undo an apply.sh run that stopped before it finished. Puts the
# Claude Code state back from the backup beside the manifest, points ~/.claude
# symlinks back at the old paths, and deletes each new copy that still matches
# its source. Run it from Terminal.app with every Claude Code session closed.
#
# The old project folders were never changed, so they need no restoring. VS Code
# state that sk-project-cleaner already cleared stays cleared; its own backup
# is in cleaner/backup/ beside the manifest.
#
# Usage: restore.sh <manifest.json>
#
# Exit: 0 when everything was restored, 1 otherwise.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

manifest="${1:-}"
[ -n "$manifest" ] || die "usage: restore.sh <manifest.json>"
[ -f "$manifest" ] || die "manifest not found: $manifest"
require_env
jq -e '.tool == "sk-project-migrator" and .version == 1' "$manifest" >/dev/null || die "not an sk-project-migrator manifest: $manifest"
[ "$(jq -c '.env' "$manifest")" = "$(env_json)" ] || die "the manifest was planned for different locations"
dir="$(cd "$(dirname "$manifest")" && pwd -P)"
B="$dir/backup"
[ -f "$dir/copy-started" ] || die "apply.sh never started copying for this manifest; nothing to restore"
[ ! -e "$dir/restored" ] || die "already restored: $dir"
if grep -q "^migration finished" "$dir/apply-output.log" 2>/dev/null; then
  die "this migration finished and verified; restore.sh only undoes a run that stopped"
fi
live="$(live_session_cwds)"
[ -z "$live" ] || die "close every Claude Code session first, still open in: $(printf '%s' "$live" | tr '\n' ' ' | tilde)"

echo "== sk-project-migrator restore"
problems=0
problem() { echo "  ! $*" | tilde; problems=$((problems + 1)); }

while IFS=$'\t' read -r fk tk; do
  if [ ! -d "$B/projects/$fk" ]; then echo "  not backed up, so never moved: $fk"; continue; fi
  if [ -e "$PROJECTS_DIR/$tk" ]; then rm -rf -- "${PROJECTS_DIR:?}/$tk"; fi
  if [ -e "$PROJECTS_DIR/$fk" ]; then rm -rf -- "${PROJECTS_DIR:?}/$fk"; fi
  ditto "$B/projects/$fk" "$PROJECTS_DIR/$fk"
  echo "  restored session folder: $fk"
done < <(jq -r '.claude.key_dirs[] | [.from_key, .to_key] | @tsv' "$manifest")

if [ -f "$B/claude.json" ]; then cat "$B/claude.json" > "$CLAUDE_JSON"; echo "  restored ~/.claude.json"; fi
if [ -f "$B/history.jsonl" ]; then cat "$B/history.jsonl" > "$HISTORY"; echo "  restored history.jsonl"; fi

while IFS=$'\t' read -r l f t; do
  if [ "$(readlink "$l" 2>/dev/null || true)" = "$t" ]; then
    ln -sfn "$f" "$l"
    echo "  relinked: $l -> $f" | tilde
  fi
done < <(jq -r '.claude.symlinks[] | [.link, .from, .to] | @tsv' "$manifest")

while IFS=$'\t' read -r o n; do
  [ -e "$n" ] || continue
  if diff -rq "$o" "$n" >/dev/null 2>&1; then
    rm -rf -- "$n"
    echo "  deleted the copy: $n" | tilde
  else
    problem "the copy differs from its source, so it was kept for a manual check: $n"
  fi
done < <(jq -r '.pairs[] | [.old, .new] | @tsv' "$manifest")

if [ -d "$dir/cleaner/backup" ]; then
  echo "  VS Code state of the old paths stays cleared; its backup: $(printf '%s' "$dir/cleaner/backup" | tilde)"
fi

[ "$problems" -eq 0 ] || die "$problems problem(s) need a manual check"
touch "$dir/restored"
echo "restored. Plan again for a new manifest; delete $(printf '%s' "$dir" | tilde) once the result is checked."
