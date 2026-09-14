#!/usr/bin/env bash
#
# apply.sh — execute an ultra-project-migrator manifest. Run it from Terminal.app
# with VS Code fully quit (Cmd+Q) and every Claude Code session closed.
#
# Copies each project to its new path and verifies the copy, backs up the Claude
# Code state it changes, relinks ~/.claude symlinks, renames session folders and
# rewrites their "cwd" fields (keeping file times), rewrites ~/.claude.json and
# history.jsonl, then runs ultra-project-cleaner for the old paths' VS Code
# state. The old folders stay until finalize.sh. Output also goes to
# apply-output.log beside the manifest.
#
# Usage: apply.sh <manifest.json>
#
# Exit: 0 when the migration finished and verified, 1 on error.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

manifest="${1:-}"
[ -n "$manifest" ] || die "usage: apply.sh <manifest.json>"
[ -f "$manifest" ] || die "manifest not found: $manifest"
require_env
jq -e '.tool == "ultra-project-migrator" and .version == 1' "$manifest" >/dev/null || die "not an ultra-project-migrator manifest: $manifest"
[ "$(jq -c '.env' "$manifest")" = "$(env_json)" ] || die "the manifest was planned for different locations; plan again in this environment"
[ "$(jq '.blockers | length' "$manifest")" -eq 0 ] || die "the plan has blockers; resolve them and plan again"

dir="$(cd "$(dirname "$manifest")" && pwd -P)"; manifest="$dir/$(basename "$manifest")"
B="$dir/backup"
[ ! -e "$B" ] || die "already applied (backup exists): $B"

# Everything below also goes to apply-output.log. A pipeline, not exec with a
# process substitution: the script then waits for tee, so the log is complete
# when it returns (bash 3.2 cannot wait for a process substitution).
{
PHASE=preflight
# shellcheck disable=SC2329  # run by the EXIT trap below
on_exit() {
  local rc=$? p finished=""
  [ "$rc" -eq 0 ] && return 0
  if [ "$PHASE" != preflight ]; then
    # shellcheck disable=SC2088  # phase labels, not paths
    for p in copy backup symlinks "session folders" "~/.claude.json" history.jsonl "VS Code state" verify; do
      [ "$p" = "$PHASE" ] && break
      finished="$finished, $p"
    done
  fi
  echo
  echo "stopped during: $PHASE (exit $rc)"
  [ -n "$finished" ] || finished=", nothing"
  echo "finished before it, and still in effect: ${finished#, }"
  if [ -d "$B" ]; then echo "Claude Code state as it was before any change: $B"; fi
  echo "the old project folders were not modified"
  if [ "$PHASE" != preflight ]; then echo "to undo it: bash $here/restore.sh $manifest"; fi
}
trap on_exit EXIT

OLDS="$(jq -r '.pairs[].old' "$manifest")"; NEWS="$(jq -r '.pairs[].new' "$manifest")"
export OLDS NEWS
# The reverse mapping, for checking a rewrite against its backup. Kept in their
# own variables: prefix assignments run left to right, so NEWS="$OLDS" after
# OLDS="$NEWS" would read the already-swapped value.
REV_OLDS="$NEWS"; REV_NEWS="$OLDS"

# ---------------------------------------------------------------- preflight
echo "== ultra-project-migrator apply"
live="$(live_session_cwds)"
[ -z "$live" ] || die "close every Claude Code session first, still open in: $(printf '%s' "$live" | tr '\n' ' ' | tilde)"
if [ -f "$STATE_DB" ] && [ -n "$(lsof -t -- "$STATE_DB" 2>/dev/null || true)" ]; then
  die "quit VS Code first (Cmd+Q); it still holds its state database"
fi
cwds="$(process_cwds)"
while IFS=$'\t' read -r o n; do
  [ -d "$o" ] || die "old folder is gone: $o"
  if [ -e "$n" ] && { [ ! -d "$n" ] || [ -n "$(ls -A "$n")" ]; }; then die "target is no longer empty: $n"; fi
  while IFS= read -r c; do
    if [ -n "$c" ] && under "$c" "$o"; then die "a process is still working inside $c"; fi
  done <<< "$cwds"
done < <(jq -r '.pairs[] | [.old, .new] | @tsv' "$manifest")
while IFS=$'\t' read -r fk tk; do
  [ -d "$PROJECTS_DIR/$fk" ] || die "session folder is gone since planning: $fk"
  [ ! -e "$PROJECTS_DIR/$tk" ] || die "a session folder for the new path appeared since planning: $tk"
done < <(jq -r '.claude.key_dirs[] | [.from_key, .to_key] | @tsv' "$manifest")

# ---------------------------------------------------------------- copy
PHASE=copy
touch "$dir/copy-started"
while IFS=$'\t' read -r o n; do
  mkdir -p "$(dirname "$n")"
  ditto "$o" "$n"
  diff -rq "$o" "$n" >/dev/null 2>&1 || die "the copy differs from its source: $n"
  if [ -d "$o/.git" ]; then
    [ "$(git -C "$o" rev-parse HEAD)" = "$(git -C "$n" rev-parse HEAD)" ] || die "git HEAD differs after copying: $n"
  fi
  echo "  copied and identical: $o -> $n" | tilde
done < <(jq -r '.pairs[] | [.old, .new] | @tsv' "$manifest")

# ---------------------------------------------------------------- backup
PHASE=backup
mkdir -p "$B/projects"
while IFS= read -r fk; do
  ditto "$PROJECTS_DIR/$fk" "$B/projects/$fk"
done < <(jq -r '.claude.key_dirs[].from_key' "$manifest")
if [ -f "$CLAUDE_JSON" ]; then cp -p "$CLAUDE_JSON" "$B/claude.json"; fi
if [ -f "$HISTORY" ]; then cp -p "$HISTORY" "$B/history.jsonl"; fi
echo "  backup: $(printf '%s' "$B" | tilde)"

# ---------------------------------------------------------------- symlinks
PHASE=symlinks
while IFS=$'\t' read -r l f t; do
  if [ "$(readlink "$l" 2>/dev/null || true)" != "$f" ]; then echo "  skipped (changed since planning): $l" | tilde; continue; fi
  [ -e "$t" ] || die "new symlink target is missing: $t"
  ln -sfn "$t" "$l"
  echo "  relinked: $l -> $t" | tilde
done < <(jq -r '.claude.symlinks[] | [.link, .from, .to] | @tsv' "$manifest")

# ---------------------------------------------------------------- session folders
PHASE="session folders"
while IFS=$'\t' read -r fk tk; do
  [ -d "$PROJECTS_DIR/$fk" ] || die "session folder vanished: $fk"
  [ ! -e "$PROJECTS_DIR/$tk" ] || die "session folder already exists: $tk"
  mv "$PROJECTS_DIR/$fk" "$PROJECTS_DIR/$tk"
  while IFS= read -r -d '' f; do
    new="$(mktemp)"
    rewrite_field cwd "$f" > "$new"
    cat "$new" > "$f"; rm -f "$new"
    touch -r "$B/projects/$fk/${f#"$PROJECTS_DIR/$tk"/}" "$f"
  done < <(find "$PROJECTS_DIR/$tk" -name '*.jsonl' -print0)
  echo "  moved session folder: $fk -> $tk"
done < <(jq -r '.claude.key_dirs[] | [.from_key, .to_key] | @tsv' "$manifest")

# ---------------------------------------------------------------- ~/.claude.json
# shellcheck disable=SC2088  # a label, not a path
PHASE="~/.claude.json"
if [ -f "$CLAUDE_JSON" ] && [ "$(jq '(.claude.projects | length) + (.claude.github | length)' "$manifest")" -gt 0 ]; then
  pairs="$(jq -c '[.pairs[] | {old, new}]' "$manifest")"
  snap="$(mktemp)"; new="$(mktemp)"
  cp "$CLAUDE_JSON" "$snap"
  jq --argjson pairs "$pairs" '
    def remap: . as $p | ([$pairs[] | select(.old as $o | $p == $o or ($p | startswith($o + "/")))] | first) as $m
      | if $m then $m.new + ($p | ltrimstr($m.old)) else $p end;
    (if .projects then .projects |= with_entries(.key |= remap) else . end)
    | (if .githubRepoPaths then .githubRepoPaths |= map_values(map(remap)) else . end)' "$snap" > "$new"
  [ "$(jq '.projects // {} | length' "$snap")" = "$(jq '.projects // {} | length' "$new")" ] || die "a moved project entry would replace another one; nothing written"
  write_if_unchanged "$CLAUDE_JSON" "$snap" "$new"
  rm -f "$snap" "$new"
  echo "  rewrote $(jq '.claude.projects | length' "$manifest") project entr(ies) and $(jq '.claude.github | length' "$manifest") githubRepoPaths value(s)"
fi

# ---------------------------------------------------------------- history.jsonl
PHASE=history.jsonl
if [ -f "$HISTORY" ] && [ "$(jq '.claude.history_entries' "$manifest")" -gt 0 ]; then
  snap="$(mktemp)"; new="$(mktemp)"
  cp "$HISTORY" "$snap"
  rewrite_field project "$snap" > "$new"
  write_if_unchanged "$HISTORY" "$snap" "$new"
  rm -f "$snap" "$new"
  echo "  rewrote $(jq '.claude.history_entries' "$manifest") history entr(ies)"
fi

# ---------------------------------------------------------------- VS Code state of the old paths
PHASE="VS Code state"
cm="$(jq -r '.cleaner.manifest // empty' "$manifest")"; cdir="$(jq -r '.cleaner.dir // empty' "$manifest")"
if [ -n "$cm" ] && [ -f "$cm" ] && [ -f "$cdir/scripts/apply.sh" ]; then
  echo "  handing the old paths' VS Code state to ultra-project-cleaner"
  if ! bash "$cdir/scripts/apply.sh" "$cm" | sed 's/^/    /'; then
    echo "  warning: ultra-project-cleaner did not finish; the old paths' VS Code state may remain"
  fi
else
  echo "  skipped: no VS Code cleanup was planned"
fi

# ---------------------------------------------------------------- verify
PHASE=verify
echo "== verify"
bad=0
check() { if [ "$2" = 0 ]; then echo "  ok   $1"; else echo "  FAIL $1"; bad=1; fi; }

while IFS=$'\t' read -r o n; do
  diff -rq "$o" "$n" >/dev/null 2>&1; check "$(printf '%s' "$n" | tilde) matches its source" "$?"
done < <(jq -r '.pairs[] | [.old, .new] | @tsv' "$manifest")

while IFS=$'\t' read -r fk tk; do
  r=0; { [ ! -e "$PROJECTS_DIR/$fk" ] && [ -d "$PROJECTS_DIR/$tk" ]; } || r=1
  check "session folder $tk in place" "$r"
  left="$(find "$PROJECTS_DIR/$tk" -name '*.jsonl' -exec cat {} + 2>/dev/null | count_field cwd)"
  check "no old cwd left in $tk" "$([ "$left" = 0 ] && echo 0 || echo 1)"
  r=0
  while IFS= read -r -d '' f; do
    rel="${f#"$PROJECTS_DIR/$tk"/}"; bk="$B/projects/$fk/$rel"
    back="$(mktemp)"
    OLDS="$REV_OLDS" NEWS="$REV_NEWS" rewrite_field cwd "$f" > "$back"
    cmp -s "$back" "$bk" || r=1
    [ "$(stat -f '%m' "$f")" = "$(stat -f '%m' "$bk")" ] || r=1
    rm -f "$back"
  done < <(find "$PROJECTS_DIR/$tk" -name '*.jsonl' -print0)
  check "sessions in $tk equal the backup apart from cwd, times kept" "$r"
done < <(jq -r '.claude.key_dirs[] | [.from_key, .to_key] | @tsv' "$manifest")

if [ -f "$CLAUDE_JSON" ]; then
  pairs="$(jq -c '[.pairs[] | {old, new}]' "$manifest")"
  stale="$(jq --argjson pairs "$pairs" '
    def old: . as $p | any($pairs[]; .old as $o | $p == $o or ($p | startswith($o + "/")));
    ([.projects // {} | keys[] | select(old)] | length) + ([.githubRepoPaths // {} | .[][] | select(old)] | length)' "$CLAUDE_JSON")"
  # shellcheck disable=SC2088  # a label, not a path
  check "~/.claude.json holds no old path" "$([ "$stale" = 0 ] && echo 0 || echo 1)"
fi
if [ -f "$HISTORY" ]; then
  check "history.jsonl holds no old path" "$([ "$(count_field project < "$HISTORY")" = 0 ] && echo 0 || echo 1)"
fi
while IFS=$'\t' read -r l t; do
  r=0; { [ "$(readlink "$l")" = "$t" ] && [ -e "$l" ]; } || r=1
  check "symlink $(printf '%s' "${l#"$CLAUDE_DIR"/}") resolves to the new path" "$r"
done < <(jq -r '.claude.symlinks[] | [.link, .to] | @tsv' "$manifest")

[ "$bad" -eq 0 ] || die "verification failed; see FAIL lines above"

PHASE="done"
echo
echo "migration finished. The old folders are still in place."
echo "next: open the new location in VS Code, run /resume, and let the skill check the result;"
echo "      after you confirm, finalize.sh deletes the old folders and this manifest folder."
if [ "$(jq '.repo_mentions | length' "$manifest")" -gt 0 ]; then
  echo "hard-coded old paths inside the projects still need a look: $(jq '.repo_mentions | length' "$manifest") line(s), listed in the manifest."
fi
} 2>&1 | tee -a "$dir/apply-output.log"
