#!/usr/bin/env bash
#
# apply.sh — execute an ultra-project-cleaner manifest. Run it from Terminal.app
# with VS Code fully quit (Cmd+Q) and every Claude Code session closed.
#
# It backs up everything it changes into backup/ next to the manifest, re-checks
# each selected item right before acting, skips any item whose state changed
# since planning, and never acts on anything outside the manifest. Each outcome
# is logged to apply-log.jsonl next to the manifest.
#
# Usage: apply.sh <manifest.json>
#
# Exit: 0 when every selected item was applied or cleanly skipped, 1 on error.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

manifest="${1:-}"
[ -n "$manifest" ] || die "usage: apply.sh <manifest.json>"
[ -f "$manifest" ] || die "manifest not found: $manifest"
require_env
jq -e '.tool == "ultra-project-cleaner" and .version == 1' "$manifest" >/dev/null || die "not an ultra-project-cleaner manifest: $manifest"
[ "$(jq -c '.env' "$manifest")" = "$(env_json)" ] || die "the manifest was planned for different locations; plan again in this environment"

dir="$(cd "$(dirname "$manifest")" && pwd -P)"
B="$dir/backup"; LOG="$dir/apply-log.jsonl"
[ ! -e "$B" ] || die "already applied (backup exists): $B"

# ---------------------------------------------------------------- preflight
live="$(live_session_cwds)"
[ -z "$live" ] || die "close every Claude Code session first, still open in: $(printf '%s' "$live" | tr '\n' ' ' | tilde)"
if [ -f "$STATE_DB" ] && [ -n "$(lsof -t -- "$STATE_DB" 2>/dev/null || true)" ]; then
  die "quit VS Code first (Cmd+Q); it still holds its state database"
fi

SEL="$(jq -c '[.items[] | select(.selected and .selectable)]' "$manifest")"
if [ "$(jq 'length' <<< "$SEL")" -eq 0 ]; then echo "nothing selected in the manifest"; exit 0; fi
mkdir -p "$B"; : > "$LOG"
applied=0; skipped=0

log() { # log <id> <applied|skipped> <note>
  jq -nc --arg id "$1" --arg status "$2" --arg note "$3" '{id: $id, status: $status, note: $note}' >> "$LOG"
  printf '  %-8s %-5s %s\n' "$2" "$1" "$3" | tilde
  if [ "$2" = applied ]; then applied=$((applied + 1)); else skipped=$((skipped + 1)); fi
}

# Items of one kind as tab-separated fields, one per line.
rows() { jq -r --arg k "$1" ".[] | select(.kind == \$k) | $2 | @tsv" <<< "$SEL"; }

# A "missing" item is only still valid while its path is still missing.
still_missing() { [ "$1" != missing ] || [ ! -e "$2" ]; }

echo "== ultra-project-cleaner apply — $(jq 'length' <<< "$SEL") selected item(s)"
echo "backup: $(printf '%s' "$B" | tilde)"

# ---------------------------------------------------------------- Claude Code: key directories
while IFS=$'\t' read -r id path reason key; do
  kd="$PROJECTS_DIR/$key"
  case "$key" in ""|*/*|.|..) log "$id" skipped "invalid key"; continue ;; esac
  if [ ! -d "$kd" ]; then log "$id" skipped "key directory already gone"; continue; fi
  if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
  mkdir -p "$B/projects"; ditto "$kd" "$B/projects/$key"
  rm -rf -- "$kd"
  log "$id" applied "deleted key directory $key"
done < <(rows claude-key-dir '[.id, .path, .reason, .key]')

# ---------------------------------------------------------------- Claude Code: ~/.claude.json
if [ -f "$CLAUDE_JSON" ]; then
  del_projects="[]"; del_github="[]"
  while IFS=$'\t' read -r id path reason; do
    if ! jq -e --arg p "$path" '.projects // {} | has($p)' "$CLAUDE_JSON" >/dev/null; then log "$id" skipped "project entry already gone"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    del_projects="$(jq -c --arg p "$path" '. + [$p]' <<< "$del_projects")"
    log "$id" applied "removed projects entry"
  done < <(rows claude-json-project '[.id, .path, .reason]')
  while IFS=$'\t' read -r id path reason repo; do
    if ! jq -e --arg r "$repo" --arg p "$path" '(.githubRepoPaths[$r] // []) | any(. == $p)' "$CLAUDE_JSON" >/dev/null; then log "$id" skipped "githubRepoPaths entry already gone"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    del_github="$(jq -c --arg r "$repo" --arg p "$path" '. + [{repo: $r, path: $p}]' <<< "$del_github")"
    log "$id" applied "removed githubRepoPaths entry for $repo"
  done < <(rows claude-json-github-path '[.id, .path, .reason, .repo]')

  if [ "$del_projects" != "[]" ] || [ "$del_github" != "[]" ]; then
    cp -p "$CLAUDE_JSON" "$B/claude.json"
    snap="$(mktemp)"; new="$(mktemp)"
    cp "$CLAUDE_JSON" "$snap"
    jq --argjson dp "$del_projects" --argjson dg "$del_github" '
      (if .projects then .projects |= with_entries(select(.key as $k | any($dp[]; . == $k) | not)) else . end)
      | (if .githubRepoPaths then
          .githubRepoPaths |= (to_entries
            | map(.key as $r | .value |= map(select(. as $p | any($dg[]; .repo == $r and .path == $p) | not)))
            | map(select((.value | length) > 0 or (.key as $r | any($dg[]; .repo == $r) | not)))
            | from_entries)
        else . end)' "$snap" > "$new"
    write_if_unchanged "$CLAUDE_JSON" "$snap" "$new"
    rm -f "$snap" "$new"
  fi
fi

# ---------------------------------------------------------------- Claude Code: history.jsonl
if [ -f "$HISTORY" ]; then
  del_file="$(mktemp)"
  while IFS=$'\t' read -r id path reason; do
    if ! jq -se --arg p "$path" 'any(.[]; .project == $p)' "$HISTORY" >/dev/null 2>&1; then log "$id" skipped "no history entries left"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    printf '%s\n' "$path" >> "$del_file"
    log "$id" applied "removed prompt history entries"
  done < <(rows claude-history '[.id, .path, .reason]')
  if [ -s "$del_file" ]; then
    cp -p "$HISTORY" "$B/history.jsonl"
    snap="$(mktemp)"; new="$(mktemp)"
    cp "$HISTORY" "$snap"
    DEL_FILE="$del_file" perl -MJSON::PP -ne '
      BEGIN { open my $f, "<", $ENV{DEL_FILE} or die; %d = map { chomp; ($_ => 1) } <$f> }
      my $j = eval { JSON::PP->new->decode($_) };
      print unless $j && ref $j eq "HASH" && defined $j->{project} && $d{$j->{project}};' "$snap" > "$new"
    write_if_unchanged "$HISTORY" "$snap" "$new"
    rm -f "$snap" "$new"
  fi
  rm -f "$del_file"
fi

# ---------------------------------------------------------------- VS Code: workspaceStorage
while IFS=$'\t' read -r id path reason sid uri; do
  wd="$WS_DIR/$sid"
  case "$sid" in ""|*/*|.|..) log "$id" skipped "invalid storage id"; continue ;; esac
  if [ ! -f "$wd/workspace.json" ]; then log "$id" skipped "workspace storage already gone"; continue; fi
  now="$(jq -r '.folder // .workspace // .configuration // empty' "$wd/workspace.json")"
  if [ "$now" != "$uri" ]; then log "$id" skipped "storage now belongs to another workspace"; continue; fi
  if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
  mkdir -p "$B/workspaceStorage"; ditto "$wd" "$B/workspaceStorage/$sid"
  rm -rf -- "$wd"
  log "$id" applied "deleted workspace storage $sid"
done < <(rows vscode-workspace-storage '[.id, .path, .reason, .storage_id, .uri]')

# ---------------------------------------------------------------- VS Code: storage.json
if [ -f "$STORAGE_JSON" ]; then
  del_ws="[]"; del_fo="[]"; del_pa="[]"
  while IFS=$'\t' read -r id path reason list uri; do
    field=$([ "$list" = workspaces ] && echo configURIPath || echo folderUri)
    if ! jq -e --arg l "$list" --arg f "$field" --arg u "$uri" '(.backupWorkspaces[$l] // []) | any(.[$f] == $u)' "$STORAGE_JSON" >/dev/null; then log "$id" skipped "restore entry already gone"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    if [ "$list" = workspaces ]; then del_ws="$(jq -c --arg u "$uri" '. + [$u]' <<< "$del_ws")"; else del_fo="$(jq -c --arg u "$uri" '. + [$u]' <<< "$del_fo")"; fi
    log "$id" applied "removed backupWorkspaces.$list entry"
  done < <(rows vscode-backup-workspace '[.id, .path, .reason, .list, .uri]')
  while IFS=$'\t' read -r id path reason uri; do
    if ! jq -e --arg u "$uri" '.profileAssociations.workspaces // {} | has($u)' "$STORAGE_JSON" >/dev/null; then log "$id" skipped "profile association already gone"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    del_pa="$(jq -c --arg u "$uri" '. + [$u]' <<< "$del_pa")"
    log "$id" applied "removed profileAssociations entry"
  done < <(rows vscode-profile-association '[.id, .path, .reason, .uri]')

  if [ "$del_ws$del_fo$del_pa" != "[][][]" ]; then
    cp -p "$STORAGE_JSON" "$B/storage.json"
    snap="$(mktemp)"; new="$(mktemp)"
    cp "$STORAGE_JSON" "$snap"
    jq --argjson ws "$del_ws" --argjson fo "$del_fo" --argjson pa "$del_pa" '
      (if .backupWorkspaces.workspaces then .backupWorkspaces.workspaces |= map(select(.configURIPath as $u | any($ws[]; . == $u) | not)) else . end)
      | (if .backupWorkspaces.folders then .backupWorkspaces.folders |= map(select(.folderUri as $u | any($fo[]; . == $u) | not)) else . end)
      | (if .profileAssociations.workspaces then .profileAssociations.workspaces |= with_entries(select(.key as $k | any($pa[]; . == $k) | not)) else . end)' "$snap" > "$new"
    write_if_unchanged "$STORAGE_JSON" "$snap" "$new"
    rm -f "$snap" "$new"
  fi
fi

# ---------------------------------------------------------------- VS Code: GitHub extension cache
if [ -f "$STATE_DB" ]; then
  del_keys="[]"
  gh="$(sqlite3 "$STATE_DB" "select value from ItemTable where key = 'vscode.github'" 2>/dev/null || true)"
  while IFS=$'\t' read -r id path reason key; do
    if [ -z "$gh" ] || ! jq -e --arg k "$key" 'has($k)' <<< "$gh" >/dev/null; then log "$id" skipped "cache entry already gone"; continue; fi
    if ! still_missing "${reason%% *}" "$path"; then log "$id" skipped "path exists again"; continue; fi
    del_keys="$(jq -c --arg k "$key" '. + [$k]' <<< "$del_keys")"
    log "$id" applied "removed GitHub extension cache entry"
  done < <(rows vscode-github-cache '[.id, .path, .reason, .key]')
  if [ "$del_keys" != "[]" ]; then
    sqlite3 "$STATE_DB" ".backup '$B/state.vscdb'"
    new="$(mktemp)"
    jq -c -j --argjson dk "$del_keys" 'with_entries(select(.key as $k | any($dk[]; . == $k) | not))' <<< "$gh" > "$new"
    sqlite3 "$STATE_DB" "update ItemTable set value = cast(readfile('$new') as text) where key = 'vscode.github'"
    [ "$(sqlite3 "$STATE_DB" 'pragma integrity_check')" = ok ] || die "state database integrity check failed; restore $B/state.vscdb"
    rm -f "$new"
  fi
fi

# ---------------------------------------------------------------- done
echo
echo "applied: $applied, skipped: $skipped"
echo "log: $(printf '%s' "$LOG" | tilde)"
echo "next: reopen VS Code, resume the Claude Code session, and let the skill verify the result."
echo "remove stale entries from File > Open Recent by hand; the backup stays until you confirm."
