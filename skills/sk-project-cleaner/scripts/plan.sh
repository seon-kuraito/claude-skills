#!/usr/bin/env bash
#
# plan.sh — read-only preview for sk-project-cleaner. Finds the state Claude
# Code and VS Code keep for project paths, prints a report, and writes the
# manifest apply.sh executes later. Changes nothing but the manifest file.
#
# Usage:
#   plan.sh --diagnose         [--only claude|vscode] [--out <manifest>]
#   plan.sh --paths <path>...  [--only claude|vscode] [--out <manifest>]
#
#   --diagnose  every record whose project path no longer exists is a candidate;
#               paths under /Volumes/ are skipped; nothing starts selected
#   --paths     every record at or under the given paths is a candidate, whether
#               or not the path still exists; candidates start selected
#   --only      plan one side only
#   --out       manifest file (default ~/Backups/<timestamp>-project-cleaner/manifest.json)
#   --no-live-guard
#               for a caller that closes every Claude Code session before
#               apply.sh: records under a live session stay selectable here
#               (apply.sh still refuses to start while a session is open)
#
# Exit: 0 when the manifest was written, 1 on error.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=lib.sh
. "$here/lib.sh"

mode=""; only=""; out=""; targets=(); live_guard=1
while [ $# -gt 0 ]; do
  case "$1" in
    --diagnose) mode=diagnose; shift ;;
    --no-live-guard) live_guard=0; shift ;;
    --paths)
      mode=paths; shift
      while [ $# -gt 0 ] && [ "${1#--}" = "$1" ]; do targets+=("$(abspath "$1")"); shift; done ;;
    --only) [ $# -ge 2 ] || die "--only needs claude or vscode"; only="$2"; shift 2 ;;
    --out) [ $# -ge 2 ] || die "--out needs a file"; out="$2"; shift 2 ;;
    -h|--help) sed -n '3,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done
require_env
[ -n "$mode" ] || die "choose --diagnose or --paths <path>..."
case "$only" in ""|claude|vscode) ;; *) die "--only takes claude or vscode" ;; esac
if [ "$mode" = paths ]; then
  [ "${#targets[@]}" -gt 0 ] || die "--paths needs at least one path"
  for t in "${targets[@]}"; do
    case "$t" in "/"|"$HOME"|"$HOME/Developer"|"$CLAUDE_DIR"*) die "refusing a path that would match everything: $t" ;; esac
  done
fi

LIVE="$(live_session_cwds)"
items="$(mktemp)"; info="$(mktemp)"; scanned="$(mktemp)"
trap 'rm -f "$items" "$info" "$scanned"' EXIT
n=0

# Candidate reason for a record's path: targeted | missing | volume | (empty).
reason_for() {
  local p="$1" t
  if [ "$mode" = paths ]; then
    for t in "${targets[@]}"; do
      if under "$p" "$t"; then echo targeted; return 0; fi
    done
    return 0
  fi
  case "$p" in /Volumes/*) echo volume; return 0 ;; esac
  [ -e "$p" ] || echo missing
}

# True when a live Claude Code session runs at or under the record's path, or —
# in --paths mode — anywhere under the target that contains the record.
protected() {
  local c t
  while IFS= read -r c; do
    [ -n "$c" ] || continue
    if under "$c" "$1"; then return 0; fi
    if [ "$mode" = paths ]; then
      for t in "${targets[@]}"; do
        if under "$c" "$t" && under "$1" "$t"; then return 0; fi
      done
    fi
  done <<< "$LIVE"
  return 1
}

# emit <kind> <path> <reason> <extra-json>
emit() {
  local selectable=true selected=false reason="$3"
  n=$((n + 1))
  if [ "$live_guard" = 1 ] && protected "$2"; then selectable=false; reason="$reason (live Claude Code session)"; fi
  if [ "$mode" = paths ] && [ "$selectable" = true ]; then selected=true; fi
  jq -nc --arg id "i$n" --arg kind "$1" --arg path "$2" --arg reason "$reason" \
    --argjson selectable "$selectable" --argjson selected "$selected" --argjson extra "$4" \
    '{id: $id, kind: $kind, path: $path, reason: $reason, selectable: $selectable, selected: $selected} + $extra' >> "$items"
}

# note <kind> <path> <extra-json>
note() {
  jq -nc --arg kind "$1" --arg path "$2" --argjson extra "$3" '{kind: $kind, path: $path} + $extra' >> "$info"
}

consider() { # consider <kind> <path> <extra-json>
  local r
  echo "$1" >> "$scanned"
  r="$(reason_for "$2")"
  case "$r" in
    missing|targeted) emit "$1" "$2" "$r" "$3" ;;
    volume) note skipped-volume "$2" "$(jq -nc --arg k "$1" '{record: $k}')" ;;
  esac
}

# ---------------------------------------------------------------- Claude Code
if [ "$only" != vscode ]; then
  if [ -f "$CLAUDE_JSON" ]; then
    while IFS= read -r k; do
      consider claude-json-project "$k" '{}'
    done < <(jq -r '.projects // {} | keys[]' "$CLAUDE_JSON")

    while IFS=$'\t' read -r repo p; do
      consider claude-json-github-path "$p" "$(jq -nc --arg r "$repo" '{repo: $r}')"
    done < <(jq -r '.githubRepoPaths // {} | to_entries[] | .key as $r | .value[]? | [$r, .] | @tsv' "$CLAUDE_JSON")
  fi

  if [ -f "$HISTORY" ]; then
    while IFS=$'\t' read -r count p; do
      consider claude-history "$p" "{\"entries\": $count}"
    done < <(jq -r '.project // empty' "$HISTORY" 2>/dev/null | sort | uniq -c | perl -pe 's/^\s*(\d+) /$1\t/')
  fi

  REG=""
  [ -f "$CLAUDE_JSON" ] && REG="$(jq -r '.projects // {} | keys[]' "$CLAUDE_JSON" | while IFS= read -r k; do printf '%s\t%s\n' "$(encode_key "$k")" "$k"; done)"

  for d in "$PROJECTS_DIR"/*/; do
    [ -d "$d" ] || continue
    echo claude-key-dir >> "$scanned"
    d="${d%/}"; key="${d##*/}"
    reg_path="$(printf '%s\n' "$REG" | awk -F'\t' -v k="$key" '$1 == k { print $2; exit }')"
    cwd="$(recorded_cwd "$d" "$key")"
    path="${reg_path:-$cwd}"
    sessions="$(find "$d" -maxdepth 1 -name '*.jsonl' | wc -l | tr -d ' ')"
    memory=0
    if [ -d "$d/memory" ]; then memory="$(find "$d/memory" -maxdepth 1 -name '*.md' ! -name MEMORY.md | wc -l | tr -d ' ')"; fi
    extra="$(jq -nc --arg key "$key" --argjson s "$sessions" --argjson m "$memory" --arg size "$(du -sh "$d" | cut -f1 | tr -d ' ')" \
      --argjson registered "$([ -n "$reg_path" ] && echo true || echo false)" \
      '{key: $key, sessions: $s, memory: $m, size: $size, registered: $registered}')"

    if [ "$mode" = paths ]; then
      for t in "${targets[@]}"; do
        if [ "$key" = "$(encode_key "$t")" ] || { [ -n "$path" ] && under "$path" "$t"; }; then
          emit claude-key-dir "${path:-$t}" targeted "$extra"; break
        fi
      done
      continue
    fi

    if [ -z "$path" ]; then note unknown-path-key-dir "" "$extra"; continue; fi
    case "$path" in /Volumes/*) note skipped-volume "$path" "$extra"; continue ;; esac
    if [ ! -e "$path" ]; then
      emit claude-key-dir "$path" missing "$extra"
    elif [ -z "$reg_path" ]; then
      note orphan-key-dir "$path" "$extra"
    fi
  done
fi

# ---------------------------------------------------------------- VS Code
if [ "$only" != claude ]; then
  inuse="$(lsof -c Code 2>/dev/null | grep -F "/workspaceStorage/" | sed -E 's#.*/workspaceStorage/([^/]+)/.*#\1#' | sort -u || true)"
  for d in "$WS_DIR"/*/; do
    [ -f "$d/workspace.json" ] || continue
    sid="$(basename "$d")"
    uri="$(jq -r '.folder // .workspace // .configuration // empty' "$d/workspace.json" 2>/dev/null || true)"
    p="$(uri_to_path "$uri")"
    [ -n "$p" ] || continue
    now="$(printf '%s\n' "$inuse" | grep -qx "$sid" && echo true || echo false)"
    consider vscode-workspace-storage "$p" "$(jq -nc --arg s "$sid" --arg u "$uri" --argjson i "$now" '{storage_id: $s, uri: $u, in_use_now: $i}')"
  done

  if [ -f "$STORAGE_JSON" ]; then
    while IFS=$'\t' read -r list uri; do
      p="$(uri_to_path "$uri")"; [ -n "$p" ] || continue
      consider vscode-backup-workspace "$p" "$(jq -nc --arg l "$list" --arg u "$uri" '{list: $l, uri: $u}')"
    done < <(jq -r '((.backupWorkspaces.workspaces // [])[] | ["workspaces", .configURIPath]),
                    ((.backupWorkspaces.folders // [])[] | ["folders", .folderUri]) | @tsv' "$STORAGE_JSON")
    while IFS= read -r uri; do
      p="$(uri_to_path "$uri")"; [ -n "$p" ] || continue
      consider vscode-profile-association "$p" "$(jq -nc --arg u "$uri" '{uri: $u}')"
    done < <(jq -r '.profileAssociations.workspaces // {} | keys[]' "$STORAGE_JSON")
  fi

  if [ -f "$STATE_DB" ]; then
    gh="$(state_row vscode.github)"
    if [ -n "$gh" ]; then
      while IFS= read -r k; do
        p="$(uri_to_path "${k#branchProtection:}")"; [ -n "$p" ] || continue
        consider vscode-github-cache "$p" "$(jq -nc --arg k "$k" '{key: $k}')"
      done < <(jq -r 'keys[] | select(startswith("branchProtection:file://"))' <<< "$gh")
    fi

    # One entry names two paths; it is a candidate when either one is.
    gitc="$(state_row vscode.git)"
    if [ -n "$gitc" ]; then
      while IFS=$'\t' read -r remote folder wp rp; do
        echo vscode-git-repo-cache >> "$scanned"
        extra="$(jq -nc --arg r "$remote" --arg f "$folder" --arg w "$wp" --arg p "$rp" \
          '{remote: $r, folder: $f, workspace_path: $w, repository_path: $p}')"
        rr="$(reason_for "$rp")"; rw="$(reason_for "$wp")"
        case "$rr:$rw" in
          missing:*|targeted:*) emit vscode-git-repo-cache "$rp" "$rr" "$extra" ;;
          *:missing|*:targeted) emit vscode-git-repo-cache "$wp" "$rw" "$extra" ;;
          volume:*) note skipped-volume "$rp" '{"record": "vscode-git-repo-cache"}' ;;
          *:volume) note skipped-volume "$wp" '{"record": "vscode-git-repo-cache"}' ;;
        esac
      done < <(jq -r '(.["git.repositoryCache"] // [])[] | .[0] as $r | (.[1] // [])[]
        | [$r, .[0], .[1].workspacePath, .[1].repositoryPath]
        | select(all(.[]; type == "string" and length > 0)) | @tsv' <<< "$gitc")
    fi

    es="$(state_row dbaeumer.vscode-eslint)"
    if [ -n "$es" ]; then
      while IFS= read -r uri; do
        p="$(uri_to_path "$uri")"; [ -n "$p" ] || continue
        consider vscode-eslint-flag "$p" "$(jq -nc --arg u "$uri" '{uri: $u}')"
      done < <(jq -r '.noESLintMessageShown.workspaces // {} | keys[]' <<< "$es")
    fi

    gl="$(state_row eamodio.gitlens)"
    if [ -n "$gl" ]; then
      while IFS= read -r p; do
        consider vscode-gitlens-visibility "$p" '{}'
      done < <(jq -r '(.["gitlens:repoVisibility"] // [])[] | .[0] | select(type == "string" and length > 0)' <<< "$gl" | sort -u)
    fi

    # One item per path, covering every key, registry row, and copy marker that names it.
    py="$(state_row ms-python.python)"
    if [ -n "$py" ]; then
      while IFS=$'\t' read -r count p; do
        consider vscode-python-state "$p" "{\"entries\": $count}"
      done < <(jq -r "$PY_PATH_JQ"'
          (keys[] | pypath),
          ((.PYTHON_GLOBAL_STORAGE_KEYS // [])[] | .key? | pypath),
          ((.remoteWorkspaceFolderKeysForWhichTheCopyIsDone_Key // [])[], (.remoteWorkspaceKeysForWhichTheCopyIsDone_Key // [])[]
            | select(type == "string" and startswith("/")))' <<< "$py" \
        | sort | uniq -c | perl -pe 's/^\s*(\d+) /$1\t/')
    fi

    # An entry with a remoteAuthority names a path on another machine; only local entries count.
    td="$(state_row terminal.history.entries.dirs)"
    if [ -n "$td" ]; then
      while IFS= read -r p; do
        consider vscode-terminal-dir-history "$p" '{}'
      done < <(jq -r '(.entries // [])[] | select((.value.remoteAuthority? // "") == "") | .key
        | select(type == "string" and startswith("/"))' <<< "$td" | sort -u)
    fi
  fi
fi

# ---------------------------------------------------------------- manifest
[ -n "$out" ] || out="$BACKUP_ROOT/$(date +%Y-%m-%d-%H%M%S)-project-cleaner/manifest.json"
mkdir -p "$(dirname "$out")"
targets_json="$(printf '%s\n' ${targets[@]+"${targets[@]}"} | jq -R . | jq -sc 'map(select(length > 0))')"
jq -n --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg mode "$mode" --arg only "${only:-all}" \
  --argjson targets "$targets_json" --argjson env "$(env_json)" \
  --slurpfile items "$items" --slurpfile info "$info" \
  --argjson scanned "$(sort "$scanned" | uniq -c | awk '{ print $2 "\t" $1 }' | jq -R 'split("\t") | {(.[0]): (.[1] | tonumber)}' | jq -sc 'add // {}')" \
  '{tool: "sk-project-cleaner", version: 1, created: $created, mode: $mode, only: $only,
    targets: $targets, env: $env, scanned: $scanned, items: $items, info: $info}' > "$out"

# ---------------------------------------------------------------- report
echo "== sk-project-cleaner plan — $mode${only:+ ($only only)}"
jq -r '
  if (.items | length) == 0 then "\nno candidates"
  else .items | group_by(.path)[] |
    ("\n" + .[0].path + "  [" + .[0].reason + "]"),
    (.[] | "  " + .id + "  " + .kind
      + (if .key then "  " + .key else "" end)
      + (if .repo then "  " + .repo else "" end)
      + (if .remote then "  " + .remote else "" end)
      + (if .entries then "  entries: \(.entries)" else "" end)
      + (if .sessions != null then "  sessions: \(.sessions), memory cards: \(.memory), \(.size)" else "" end)
      + (if .selectable then "" else "  NOT SELECTABLE" end)
      + (if .selected then "  [selected]" else "" end))
  end,
  (if (.info | length) > 0 then
    "\n-- info (never selectable)",
    (.info[] | "  " + .kind + "  " + (if .path == "" then "(path unknown)" else .path end)
      + (if .key then "  " + .key + "  sessions: \(.sessions), memory cards: \(.memory)" else "" end))
  else empty end),
  "\nscanned: " + (.scanned | to_entries | map("\(.key)=\(.value)") | join(", ")),
  "candidates: \(.items | length), selectable: \([.items[] | select(.selectable)] | length), selected: \([.items[] | select(.selected)] | length)"
' "$out" | tilde
echo "manifest: $(printf '%s' "$out" | tilde)"
