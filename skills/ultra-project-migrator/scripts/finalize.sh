#!/usr/bin/env bash
#
# finalize.sh — after the user has resumed at the new paths and confirmed the
# result, delete the old project folders and the manifest folder (manifest,
# logs, and backups). Refuses when an old folder holds a change the new copy lacks, when
# something still works inside it, or when a new copy is missing.
#
# Usage: finalize.sh [--dry-run] <manifest.json>
#
#   --dry-run  run every check and list what would be deleted; delete nothing
#
# Exit: 0 when everything was deleted (or would be, with --dry-run), 1 otherwise.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

dry=0
if [ "${1:-}" = --dry-run ]; then dry=1; shift; fi
manifest="${1:-}"
[ -n "$manifest" ] || die "usage: finalize.sh [--dry-run] <manifest.json>"
[ -f "$manifest" ] || die "manifest not found: $manifest"
require_env
jq -e '.tool == "ultra-project-migrator" and .version == 1' "$manifest" >/dev/null || die "not an ultra-project-migrator manifest: $manifest"
dir="$(cd "$(dirname "$manifest")" && pwd -P)"
grep -q "^migration finished" "$dir/apply-output.log" 2>/dev/null || die "apply.sh has not finished for this manifest"
[ -f "$dir/copy-started" ] || die "copy marker missing: $dir/copy-started"

echo "== ultra-project-migrator finalize$([ "$dry" = 1 ] && echo " (dry run)")"
problems=0
problem() { echo "  ! $*" | tilde; problems=$((problems + 1)); }
live="$(live_session_cwds)"; cwds="$(process_cwds)"
olds=()

while IFS=$'\t' read -r o n; do
  case "$o" in "/"|"$HOME"|"$HOME/Developer"|"$CLAUDE_DIR"|"$CLAUDE_DIR"/*) problem "refusing to delete $o"; continue ;; esac
  if [ ! -e "$o" ]; then echo "  already gone: $o" | tilde; continue; fi
  if [ ! -d "$n" ] || [ -z "$(ls -A "$n")" ]; then problem "new copy is missing or empty: $n"; continue; fi
  # A file touched after the copy only matters when the new copy lacks its
  # content. git rewrites .git/index and .git/FETCH_HEAD even on read-only
  # commands (an editor's background status or fetch), so those do not count.
  changed=""
  while IFS= read -r -d '' f; do
    rel="${f#"$o"/}"
    case "$rel" in .git/index|.git/FETCH_HEAD) continue ;; esac
    if [ -L "$f" ]; then
      [ "$(readlink "$f")" = "$(readlink "$n/$rel" 2>/dev/null || true)" ] && continue
    elif [ -f "$n/$rel" ] && cmp -s "$f" "$n/$rel"; then
      continue
    fi
    changed="$rel"; break
  done < <(find "$o" -newer "$dir/copy-started" ! -type d ! -name .DS_Store -print0 2>/dev/null)
  if [ -n "$changed" ]; then problem "$o changed after the copy and differs from the new copy, e.g. $changed"; continue; fi
  busy=""
  while IFS= read -r c; do
    if [ -n "$c" ] && under "$c" "$o"; then busy="$c"; fi
  done <<< "$(printf '%s\n%s\n' "$live" "$cwds")"
  if [ -n "$busy" ]; then problem "something still works inside $busy"; continue; fi
  echo "  will delete: $o" | tilde
  olds+=("$o")
done < <(jq -r '.pairs[] | [.old, .new] | @tsv' "$manifest")
echo "  will delete: $dir (manifest, logs, backups)" | tilde

[ "$problems" -eq 0 ] || die "$problems problem(s); nothing deleted"
if [ "$dry" = 1 ]; then echo "dry run: nothing deleted"; exit 0; fi

for o in ${olds[@]+"${olds[@]}"}; do
  rm -rf -- "$o"
  echo "  deleted: $o" | tilde
done
rm -rf -- "$dir"
echo "  deleted: $dir" | tilde
echo "finalized."
