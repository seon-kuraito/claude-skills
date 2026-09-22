#!/usr/bin/env bash
#
# plan-exact.sh — plan.sh's --exact mode against a fixture: a launch pad whose
# sub-folder holds another project, and a live session in that project. Subtree
# mode must refuse the pad when it is $HOME and must lock every record under a
# live session; exact mode must take the pad's records alone and leave them
# selectable, because a session in a project under the pad does not use them.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plan="$dir/../../scripts/plan.sh"

if [ "$(uname)" != Darwin ]; then echo "SKIP  plan-exact — plan.sh runs on macOS only"; exit 0; fi

pass=0
fail=0

is() { # is <label> <actual> <expected>
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL  $1 — got \"$2\", expected \"$3\""
    fail=$((fail + 1))
  fi
}

ok() { # ok <label> <command...> — expects success
  if "${@:2}"; then pass=$((pass + 1)); else echo "FAIL  $1 — expected success"; fail=$((fail + 1)); fi
}

no() { # no <label> <command...> — expects failure
  if "${@:2}"; then echo "FAIL  $1 — expected failure"; fail=$((fail + 1)); else pass=$((pass + 1)); fi
}

sb="$(mktemp -d)"
trap 'rm -rf "$sb"' EXIT
pad="$sb/home"
child="$pad/dev/app"
mkdir -p "$child"
export CLAUDE_DIR="$sb/claude" CLAUDE_JSON="$sb/claude.json" VSCODE_USER_DIR="$sb/vscode-user" BACKUP_ROOT="$sb/backups"
key() { printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'; }

# The pad and the project under it each get a session folder, a project entry,
# a history line, and a workspace storage; the project also has a GitHub path.
for p in "$pad" "$child"; do
  mkdir -p "$CLAUDE_DIR/projects/$(key "$p")"
  printf '{"cwd":"%s","type":"user"}\n' "$p" > "$CLAUDE_DIR/projects/$(key "$p")/s.jsonl"
  printf '{"project":"%s","display":"x"}\n' "$p" >> "$CLAUDE_DIR/history.jsonl"
done
mkdir -p "$VSCODE_USER_DIR/workspaceStorage/aaaa0001" "$VSCODE_USER_DIR/workspaceStorage/aaaa0002"
printf '{ "folder": "file://%s" }\n' "$pad" > "$VSCODE_USER_DIR/workspaceStorage/aaaa0001/workspace.json"
printf '{ "folder": "file://%s" }\n' "$child" > "$VSCODE_USER_DIR/workspaceStorage/aaaa0002/workspace.json"
cat > "$CLAUDE_JSON" <<JSON
{ "projects": { "$pad": {}, "$child": {} }, "githubRepoPaths": { "owner/app": ["$child"] } }
JSON

# A live session in the project under the pad: this check's own pid stays
# alive for as long as plan.sh runs.
mkdir -p "$CLAUDE_DIR/sessions"
printf '{"pid":%s,"cwd":"%s"}\n' "$$" "$child" > "$CLAUDE_DIR/sessions/live.json"

run() { # run <home> <manifest> <plan.sh args...>
  env HOME="$1" bash "$plan" --out "$2" "${@:3}" > /dev/null 2>&1
}
paths() { jq -r '[.items[].path] | unique | join(" ")' "$1"; }
count() { jq -r "[.items[] | select($2)] | length" "$1"; }

# --exact needs --paths
no "exact alone" run "$HOME" "$sb/m0.json" --exact
no "exact with diagnose" run "$HOME" "$sb/m0.json" --diagnose --exact

# the pad as $HOME: refused in subtree mode, planned in exact mode
no "home refused in subtree mode" run "$pad" "$sb/m1.json" --paths "$pad"
ok "home planned in exact mode" run "$pad" "$sb/m2.json" --paths "$pad" --exact
is "exact takes the pad alone" "$(paths "$sb/m2.json")" "$pad"
is "exact finds every record of the pad" "$(count "$sb/m2.json" true)" 4
is "exact keeps the pad selectable beside a live session under it" "$(count "$sb/m2.json" '.selectable and .selected')" 4
is "manifest records exact" "$(jq -r .exact "$sb/m2.json")" true

# a folder between the pad and the project: subtree mode takes the project and
# locks it under the live session; exact mode finds no record at the folder
ok "subtree plans a folder above the project" run "$HOME" "$sb/m3.json" --paths "$pad/dev"
is "subtree takes the project under the target" "$(paths "$sb/m3.json")" "$child"
is "subtree finds every record of the project" "$(count "$sb/m3.json" true)" 5
is "subtree locks records under a live session" "$(count "$sb/m3.json" '.selectable | not')" 5
is "manifest records subtree" "$(jq -r .exact "$sb/m3.json")" false
ok "exact plans a folder without records" run "$HOME" "$sb/m4.json" --paths "$pad/dev" --exact
is "exact takes nothing for a folder without records" "$(count "$sb/m4.json" true)" 0

# the live session's own path stays locked in exact mode
ok "exact plans the live project" run "$HOME" "$sb/m5.json" --paths "$child" --exact
is "exact still locks the live session's own records" "$(count "$sb/m5.json" '.selectable | not')" 5

echo "---"
echo "plan-exact: pass $pass, fail $fail"
[ "$fail" -eq 0 ]
