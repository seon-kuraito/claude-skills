#!/usr/bin/env bash
#
# lib.sh — shared locations and helpers for plan.sh, apply.sh, and finalize.sh.
# Sourced, not run.
#
# Every location can be overridden through the environment, so the scripts can
# be exercised against a throwaway copy of the real state:
#   CLAUDE_DIR       (default ~/.claude)
#   CLAUDE_JSON      (default ~/.claude.json)
#   VSCODE_USER_DIR  (default ~/Library/Application Support/Code/User)
#   BACKUP_ROOT      (default ~/Backups)
#   CLEANER_DIR      (default: ultra-project-cleaner resolved from its install)

# The locations below are read by the scripts that source this file.
# shellcheck disable=SC2034
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
VSCODE_USER_DIR="${VSCODE_USER_DIR:-$HOME/Library/Application Support/Code/User}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/Backups}"

PROJECTS_DIR="$CLAUDE_DIR/projects"
HISTORY="$CLAUDE_DIR/history.jsonl"
SESSIONS_DIR="$CLAUDE_DIR/sessions"
STATE_DB="$VSCODE_USER_DIR/globalStorage/state.vscdb"

die() { echo "error: $*" >&2; exit 1; }

require_env() {
  [ "$(uname)" = Darwin ] || die "macOS only"
  local t
  for t in jq perl lsof ditto git; do
    command -v "$t" >/dev/null || die "missing command: $t (jq: brew install jq)"
  done
}

# The environment a manifest was planned for; apply.sh refuses a mismatch.
env_json() {
  jq -nc --arg a "$CLAUDE_DIR" --arg b "$CLAUDE_JSON" --arg c "$VSCODE_USER_DIR" \
    '{claude_dir: $a, claude_json: $b, vscode_user_dir: $c}'
}

# Absolute form of a path that may not exist yet: expands ~, resolves a relative
# path against $PWD, drops trailing slashes. Does not touch the disk.
abspath() {
  local p="$1"
  # "~/" is matched as literal text on purpose.
  # shellcheck disable=SC2088
  case "$p" in
    "~") p="$HOME" ;;
    "~/"*) p="$HOME/${p#\~/}" ;;
    /*) ;;
    *) p="$PWD/$p" ;;
  esac
  while [ "$p" != "/" ] && [ "${p%/}" != "$p" ]; do p="${p%/}"; done
  printf '%s' "$p"
}

# Claude Code's project key: every non-alphanumeric character becomes "-".
encode_key() { printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'; }

# True when $1 is $2 or lies under it.
under() {
  [ "$1" = "$2" ] && return 0
  case "$1" in "$2"/*) return 0 ;; esac
  return 1
}

# Working directories of live Claude Code sessions, one per line.
live_session_cwds() {
  local f pid cwd
  for f in "$SESSIONS_DIR"/*.json; do
    [ -f "$f" ] || continue
    pid="$(jq -r '.pid // empty' "$f" 2>/dev/null || true)"
    cwd="$(jq -r '.cwd // empty' "$f" 2>/dev/null || true)"
    if [ -n "$pid" ] && [ -n "$cwd" ] && kill -0 "$pid" 2>/dev/null; then printf '%s\n' "$cwd"; fi
  done
}

# Working directories of every running process, one per line.
process_cwds() { lsof -d cwd 2>/dev/null | awk 'NR > 1 { print $NF }' | sort -u || true; }

# The session "cwd" in a key directory that encodes exactly to the key's name —
# the directory the sessions were started in. Empty when no session proves it.
recorded_cwd() {
  local dir="$1" key="$2" c
  while IFS= read -r c; do
    if [ -n "$c" ] && [ "$(encode_key "$c")" = "$key" ]; then printf '%s' "$c"; return 0; fi
  done < <(find "$dir" -maxdepth 1 -name '*.jsonl' -exec grep -hoE '"cwd":"[^"]*"' {} + 2>/dev/null \
    | sed -E 's/^"cwd":"(.*)"$/\1/' | sort -u)
}

# ultra-project-cleaner's directory, resolved from its install; empty when absent.
cleaner_dir() {
  if [ -n "${CLEANER_DIR:-}" ]; then
    (cd "$CLEANER_DIR" 2>/dev/null && pwd -P) || true
  elif [ -e "$CLAUDE_DIR/skills/ultra-project-cleaner" ]; then
    (cd "$CLAUDE_DIR/skills/ultra-project-cleaner" 2>/dev/null && pwd -P) || true
  fi
}

# Snapshot-safe rewrite: $1 = live file, $2 = snapshot taken before computing
# $3 (the new content). Refuses when the live file changed in between, then
# writes in place so the inode and mode stay.
write_if_unchanged() {
  cmp -s "$1" "$2" || die "$1 changed while this ran — nothing written; close every Claude Code session and VS Code, then rerun"
  cat "$3" > "$1"
}

# Replace a JSON string field's path prefix, for every old/new pair given in
# the OLDS / NEWS environment variables (newline-separated, same order).
# rewrite_field <field> <input-file>  → writes the result to stdout.
rewrite_field() {
  FIELD="$1" perl -pe '
    BEGIN { @o = split /\n/, $ENV{OLDS}; @n = split /\n/, $ENV{NEWS}; $f = quotemeta $ENV{FIELD} }
    for my $i (0 .. $#o) { my $q = quotemeta $o[$i]; s{"$f":"$q(?=["/])}{qq{"$ENV{FIELD}":"} . $n[$i]}ge }' "$2"
}

# Count JSON string fields whose value is an old path or lies under one.
# count_field <field> < input
count_field() {
  FIELD="$1" perl -ne '
    BEGIN { @o = map { quotemeta } split /\n/, $ENV{OLDS}; $re = join "|", @o; $f = quotemeta $ENV{FIELD} }
    $c += () = m{"$f":"(?:$re)(?=["/])}g;
    END { print $c + 0 }'
}

# Home shown as ~ for readable output.
tilde() { sed "s|$HOME|~|g"; }
