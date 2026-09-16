#!/usr/bin/env bash
#
# plan.sh — read-only preview for sk-project-migrator. Checks each move,
# finds the Claude Code state tied to the old paths, lists hard-coded old paths
# inside the projects, asks sk-project-cleaner (when installed) to plan the
# old paths' VS Code state, prints a report, and writes the manifest apply.sh
# executes. Changes nothing but the manifest folder.
#
# Usage: plan.sh --move <old> <new> [--move <old> <new>]... [--out <manifest>]
#
#   --move  one project folder and the path it should live at; <new> must not
#           exist yet, or be an empty folder
#   --out   manifest file (default ~/Backups/<timestamp>-project-migrator/manifest.json)
#
# Exit: 0 when the manifest was written (check its blockers), 1 on error.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

olds=(); news=(); out=""
while [ $# -gt 0 ]; do
  case "$1" in
    --move) [ $# -ge 3 ] || die "--move needs <old> <new>"; olds+=("$(abspath "$2")"); news+=("$(abspath "$3")"); shift 3 ;;
    --out) [ $# -ge 2 ] || die "--out needs a file"; out="$2"; shift 2 ;;
    -h|--help) sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done
require_env
[ "${#olds[@]}" -gt 0 ] || die "give at least one --move <old> <new>"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
for f in pairs keys projects github links mentions warnings blockers; do : > "$tmp/$f"; done
blocker() { jq -nc --arg m "$1" '$m' >> "$tmp/blockers"; }
warning() { jq -nc --arg m "$1" '$m' >> "$tmp/warnings"; }

OLDS="$(printf '%s\n' "${olds[@]}")"; NEWS="$(printf '%s\n' "${news[@]}")"
export OLDS NEWS

# New path for a path at or under one of the old paths; prints nothing otherwise.
remap() {
  local p="$1" i
  for i in "${!olds[@]}"; do
    if under "$p" "${olds[$i]}"; then printf '%s%s' "${news[$i]}" "${p#"${olds[$i]}"}"; return 0; fi
  done
}

# ---------------------------------------------------------------- the moves
for i in "${!olds[@]}"; do
  o="${olds[$i]}"; n="${news[$i]}"
  case "$o" in "/"|"$HOME"|"$HOME/Developer"|"$CLAUDE_DIR"|"$CLAUDE_DIR"/*) blocker "refusing to move $o"; continue ;; esac
  if [ ! -d "$o" ] || [ -L "$o" ]; then blocker "not a folder: $o"; continue; fi
  if [ "$o" = "$n" ]; then blocker "old and new path are the same: $o"; fi
  if [ "$o" != "$n" ] && { under "$n" "$o" || under "$o" "$n"; }; then blocker "one path contains the other: $o -> $n"; fi
  if [ -e "$n" ] || [ -L "$n" ]; then
    if [ ! -d "$n" ] || [ -L "$n" ] || [ -n "$(ls -A "$n")" ]; then blocker "target exists and is not an empty folder: $n"; fi
  fi
  for j in "${!olds[@]}"; do
    [ "$j" -gt "$i" ] || continue
    if under "${olds[$j]}" "$o" || under "$o" "${olds[$j]}"; then blocker "moves overlap: $o and ${olds[$j]}"; fi
    if under "${news[$j]}" "$n" || under "$n" "${news[$j]}"; then blocker "targets overlap: $n and ${news[$j]}"; fi
    if under "${news[$j]}" "$o" || under "$n" "${olds[$j]}"; then blocker "a target lies inside another moved folder: $o and ${olds[$j]}"; fi
  done
  kb="$(du -sk "$o" | cut -f1)"
  anc="$n"; while [ ! -e "$anc" ]; do anc="$(dirname "$anc")"; done
  free_kb="$(df -Pk "$anc" | awk 'NR == 2 { print $4 }')"
  if [ "$kb" -ge "$free_kb" ]; then blocker "not enough free space for $o: needs ${kb} KB, ${free_kb} KB free"; fi
  git_json=null
  if [ -d "$o/.git" ]; then
    git_json="$(jq -nc --arg h "$(git -C "$o" rev-parse HEAD 2>/dev/null || true)" \
      --argjson d "$(git -C "$o" status --porcelain 2>/dev/null | wc -l | tr -d ' ')" '{head: $h, dirty: $d}')"
  fi
  jq -nc --arg o "$o" --arg n "$n" --argjson kb "$kb" --argjson git "$git_json" '{old: $o, new: $n, size_kb: $kb, git: $git}' >> "$tmp/pairs"
done

while IFS= read -r c; do
  if [ -n "$c" ] && [ -n "$(remap "$c")" ]; then warning "a Claude Code session is open in $c — close it before apply.sh and resume it at the new path afterwards"; fi
done <<< "$(live_session_cwds)"
while IFS= read -r c; do
  if [ -n "$c" ] && [ -n "$(remap "$c")" ]; then warning "a process is working inside $c — close it before apply.sh"; fi
done <<< "$(process_cwds)"

# ---------------------------------------------------------------- Claude Code
if [ -f "$CLAUDE_JSON" ]; then
  while IFS= read -r k; do
    t="$(remap "$k")"; [ -n "$t" ] || continue
    # shellcheck disable=SC2088  # a label, not a path
    if jq -e --arg t "$t" '.projects | has($t)' "$CLAUDE_JSON" >/dev/null; then blocker "~/.claude.json already has a project entry for $t"; fi
    jq -nc --arg f "$k" --arg t "$t" '{from: $f, to: $t}' >> "$tmp/projects"
  done < <(jq -r '.projects // {} | keys[]' "$CLAUDE_JSON")
  while IFS=$'\t' read -r repo p; do
    t="$(remap "$p")"; [ -n "$t" ] || continue
    jq -nc --arg r "$repo" --arg f "$p" --arg t "$t" '{repo: $r, from: $f, to: $t}' >> "$tmp/github"
  done < <(jq -r '.githubRepoPaths // {} | to_entries[] | .key as $r | .value[]? | [$r, .] | @tsv' "$CLAUDE_JSON")
fi

history=0
if [ -f "$HISTORY" ]; then history="$(count_field project < "$HISTORY")"; fi

REG=""
if [ -f "$CLAUDE_JSON" ]; then
  REG="$(jq -r '.projects // {} | keys[]' "$CLAUDE_JSON" | while IFS= read -r k; do printf '%s\t%s\n' "$(encode_key "$k")" "$k"; done)"
fi
for d in "$PROJECTS_DIR"/*/; do
  [ -d "$d" ] || continue
  d="${d%/}"; key="${d##*/}"
  reg_path="$(printf '%s\n' "$REG" | awk -F'\t' -v k="$key" '$1 == k { print $2; exit }')"
  path="${reg_path:-$(recorded_cwd "$d" "$key")}"
  to=""
  if [ -n "$path" ]; then to="$(remap "$path")"; fi
  if [ -z "$to" ]; then
    for i in "${!olds[@]}"; do
      if [ "$key" = "$(encode_key "${olds[$i]}")" ]; then path="${olds[$i]}"; to="${news[$i]}"; break; fi
    done
  fi
  [ -n "$to" ] || continue
  to_key="$(encode_key "$to")"
  if [ "${#to_key}" -gt 200 ]; then blocker "new path is too long for a Claude Code session folder name: $to"; fi
  if [ -e "$PROJECTS_DIR/$to_key" ]; then blocker "Claude Code already has a session folder for $to"; fi
  sessions="$(find "$d" -maxdepth 1 -name '*.jsonl' | wc -l | tr -d ' ')"
  memory=0
  if [ -d "$d/memory" ]; then memory="$(find "$d/memory" -maxdepth 1 -name '*.md' ! -name MEMORY.md | wc -l | tr -d ' ')"; fi
  cwd_fields="$(find "$d" -name '*.jsonl' -exec cat {} + 2>/dev/null | count_field cwd)"
  jq -nc --arg fk "$key" --arg tk "$to_key" --arg f "$path" --arg t "$to" \
    --argjson c "$cwd_fields" --argjson s "$sessions" --argjson m "$memory" \
    '{from_key: $fk, to_key: $tk, from: $f, to: $t, cwd_fields: $c, sessions: $s, memory: $m}' >> "$tmp/keys"
done
jq -rs 'group_by(.to_key)[] | select(length > 1) | .[0].to_key' "$tmp/keys" | while IFS= read -r k; do
  jq -nc --arg m "two session folders would both become $k" '$m' >> "$tmp/blockers"
done

while IFS= read -r l; do
  tgt="$(readlink "$l")"
  case "$tgt" in /*) ;; *) continue ;; esac
  t="$(remap "$tgt")"; [ -n "$t" ] || continue
  jq -nc --arg l "$l" --arg f "$tgt" --arg t "$t" '{link: $l, from: $f, to: $t}' >> "$tmp/links"
done < <(find "$CLAUDE_DIR" -maxdepth 2 -type l ! -path "$PROJECTS_DIR/*" 2>/dev/null)

# ---------------------------------------------------------------- hard-coded old paths inside the projects (reported only)
for i in "${!olds[@]}"; do
  o="${olds[$i]}"; [ -d "$o" ] || continue
  pats=("$o")
  # "~/" is the literal text a file may hold.
  # shellcheck disable=SC2088
  case "$o" in "$HOME"/*) pats+=("~/${o#"$HOME"/}") ;; esac
  ob="${o##*/}"; nb="${news[$i]##*/}"
  if [ "$ob" != "$nb" ]; then pats+=("\${workspaceFolder:$ob}"); fi
  for pat in "${pats[@]}"; do
    while IFS= read -r hit; do
      file="${hit%%:*}"; rest="${hit#*:}"; line="${rest%%:*}"; text="${rest#*:}"
      case "$line" in ''|*[!0-9]*) continue ;; esac
      jq -nc --arg o "$o" --arg f "${file#"$o"/}" --argjson l "$line" --arg p "$pat" --arg t "$(printf '%s' "$text" | cut -c1-160)" \
        '{old: $o, file: $f, line: $l, match: $p, text: $t}' >> "$tmp/mentions"
    done < <(grep -rInF --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.build --exclude-dir=.venv \
      --exclude-dir=dist --exclude-dir=build -- "$pat" "$o" 2>/dev/null | head -200 || true)
  done
done

# ---------------------------------------------------------------- manifest folder and VS Code state
[ -n "$out" ] || out="$BACKUP_ROOT/$(date +%Y-%m-%d-%H%M%S)-project-migrator/manifest.json"
mdir="$(dirname "$out")"; mkdir -p "$mdir"; mdir="$(cd "$mdir" && pwd -P)"; out="$mdir/$(basename "$out")"

cleaner='{"installed": false, "dir": null, "manifest": null, "items": 0}'
cdir="$(cleaner_dir)"
if [ -n "$cdir" ] && [ -f "$cdir/scripts/plan.sh" ]; then
  cm="$mdir/cleaner/manifest.json"
  if bash "$cdir/scripts/plan.sh" --paths "${olds[@]}" --only vscode --no-live-guard --out "$cm" > "$mdir/cleaner-plan.txt" 2>&1; then
    cleaner="$(jq -c --arg d "$cdir" --arg m "$cm" '{installed: true, dir: $d, manifest: $m, items: ([.items[] | select(.selected)] | length)}' "$cm")"
  else
    warning "sk-project-cleaner could not plan the old paths' VS Code state (see cleaner-plan.txt)"
    cleaner="$(jq -nc --arg d "$cdir" '{installed: true, dir: $d, manifest: null, items: 0}')"
  fi
else
  warning "sk-project-cleaner is not installed — the old paths' VS Code state will stay behind"
fi

jq -n --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --argjson env "$(env_json)" \
  --slurpfile pairs "$tmp/pairs" --slurpfile keys "$tmp/keys" --slurpfile projects "$tmp/projects" \
  --slurpfile github "$tmp/github" --argjson history "$history" --slurpfile links "$tmp/links" \
  --slurpfile mentions "$tmp/mentions" --argjson cleaner "$cleaner" \
  --slurpfile warnings "$tmp/warnings" --slurpfile blockers "$tmp/blockers" \
  '{tool: "sk-project-migrator", version: 1, created: $created, env: $env, pairs: $pairs,
    claude: {key_dirs: $keys, projects: $projects, github: $github, history_entries: $history, symlinks: $links},
    repo_mentions: $mentions, cleaner: $cleaner, warnings: $warnings, blockers: $blockers}' > "$out"

# ---------------------------------------------------------------- report
jq -r '
  "== sk-project-migrator plan",
  "\nmoves:",
  (.pairs[] | "  \(.old) -> \(.new)  (\(.size_kb) KB" + (if .git then ", git \(.git.head[0:7]), \(.git.dirty) uncommitted" else ", not a git repo" end) + ")"),
  "\nClaude Code:",
  "  session folders: \(.claude.key_dirs | length)",
  (.claude.key_dirs[] | "    \(.from_key) -> \(.to_key)  (sessions: \(.sessions), memory cards: \(.memory), cwd fields: \(.cwd_fields))"),
  "  ~/.claude.json project entries: \(.claude.projects | length), githubRepoPaths values: \(.claude.github | length)",
  "  history entries: \(.claude.history_entries), ~/.claude symlinks: \(.claude.symlinks | length)",
  (.claude.symlinks[] | "    \(.link) -> \(.to)"),
  "\nVS Code state of the old paths: " + (if .cleaner.manifest then "\(.cleaner.items) item(s) via sk-project-cleaner" elif .cleaner.installed then "not planned" else "sk-project-cleaner not installed" end),
  "\nhard-coded old paths inside the projects (reported, not changed): \(.repo_mentions | length)",
  (.repo_mentions[:20][] | "  \(.old)/\(.file):\(.line)  \(.text)"),
  (if (.repo_mentions | length) > 20 then "  … see repo_mentions in the manifest" else empty end),
  (if (.warnings | length) > 0 then "\nwarnings:", (.warnings[] | "  " + .) else empty end),
  "\nblockers: " + (if (.blockers | length) == 0 then "none" else "\(.blockers | length)" end),
  (.blockers[] | "  ! " + .)
' "$out" | tilde
echo "manifest: $(printf '%s' "$out" | tilde)"
