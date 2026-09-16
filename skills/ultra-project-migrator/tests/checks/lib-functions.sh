#!/usr/bin/env bash
#
# lib-functions.sh — the pure helpers in scripts/lib.sh, asserted against fixed
# inputs. rewrite_field and count_field decide which recorded paths move, so a
# wrong prefix match here silently rewrites another project's sessions.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME="/tmp/migrator-test-home"
export HOME
# shellcheck source=/dev/null
. "$dir/../../scripts/lib.sh"

pass=0
fail=0

is() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL  $1 — got \"$2\", expected \"$3\""
    fail=$((fail + 1))
  fi
}

ok() { if "${@:2}"; then pass=$((pass + 1)); else echo "FAIL  $1 — expected success"; fail=$((fail + 1)); fi; }
no() { if "${@:2}"; then echo "FAIL  $1 — expected failure"; fail=$((fail + 1)); else pass=$((pass + 1)); fi; }

# abspath / encode_key / under / tilde — shared with the cleaner, same contract
is "abspath tilde prefix" "$(abspath '~/Developer/p/')" "$HOME/Developer/p"
is "abspath trailing slashes" "$(abspath '/a/b///')" "/a/b"
is "encode_key path" "$(encode_key '/Users/<user>/Developer/p')" "-Users--user--Developer-p"
ok "under child" under "/a/b/c" "/a/b"
no "under sibling with shared prefix" under "/a/b-old" "/a/b"
is "tilde rewrites home" "$(printf '%s\n' "$HOME/x" | tilde)" "~/x"

# rewrite_field — moves a path prefix only at a path boundary
tmp="$(mktemp -d)"
OLDS="/old/p"
NEWS="/new/q"
export OLDS NEWS
printf '%s\n' '{"cwd":"/old/p","x":1}' '{"cwd":"/old/p/sub","x":2}' '{"cwd":"/old/p-other","x":3}' > "$tmp/in.jsonl"
out="$(rewrite_field cwd "$tmp/in.jsonl")"
is "rewrite_field exact path" "$(printf '%s' "$out" | sed -n 1p)" '{"cwd":"/new/q","x":1}'
is "rewrite_field child path" "$(printf '%s' "$out" | sed -n 2p)" '{"cwd":"/new/q/sub","x":2}'
is "rewrite_field leaves a sibling alone" "$(printf '%s' "$out" | sed -n 3p)" '{"cwd":"/old/p-other","x":3}'
is "rewrite_field leaves another field alone" "$(printf '%s\n' '{"other":"/old/p"}' > "$tmp/o.jsonl"; rewrite_field cwd "$tmp/o.jsonl")" '{"other":"/old/p"}'

# count_field — counts the same matches, and no sibling
is "count_field counts path and child" "$(count_field cwd < "$tmp/in.jsonl")" "2"
is "count_field on no match" "$(printf '%s\n' '{"cwd":"/elsewhere"}' | count_field cwd)" "0"
rm -rf "$tmp"

echo "---"
echo "lib-functions: pass $pass, fail $fail"
[ "$fail" -eq 0 ]
