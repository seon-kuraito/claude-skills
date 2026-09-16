#!/usr/bin/env bash
#
# lib-functions.sh — the pure helpers in scripts/lib.sh, asserted against fixed
# inputs. These decide which path a record belongs to, so a wrong answer here
# deletes the wrong project's sessions.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME="/tmp/cleaner-test-home"
export HOME
# shellcheck source=/dev/null
. "$dir/../../scripts/lib.sh"

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

# abspath — expands ~, resolves against PWD, drops trailing slashes, never touches disk
is "abspath tilde alone" "$(abspath '~')" "$HOME"
is "abspath tilde prefix" "$(abspath '~/Developer/p/')" "$HOME/Developer/p"
is "abspath trailing slashes" "$(abspath '/a/b///')" "/a/b"
is "abspath relative" "$(cd /tmp && abspath 'rel/x')" "$(cd /tmp && printf '%s' "$PWD/rel/x")"
is "abspath root stays root" "$(abspath '/')" "/"
is "abspath keeps a missing path" "$(abspath '/no/such/place')" "/no/such/place"

# encode_key — Claude Code's project key
is "encode_key path" "$(encode_key '/Users/<user>/Developer/p')" "-Users--user--Developer-p"
is "encode_key punctuation" "$(encode_key '/a.b_c')" "-a-b-c"

# uri_to_path — percent decoding, and nothing for a non-file URI
is "uri_to_path decodes space" "$(uri_to_path 'file:///a%20b')" "/a b"
is "uri_to_path ignores other schemes" "$(uri_to_path 'vscode://x')" ""

# under — the prefix test that keeps a sibling directory out
ok "under self" under "/a/b" "/a/b"
ok "under child" under "/a/b/c" "/a/b"
no "under sibling with shared prefix" under "/a/b-old" "/a/b"
no "under unrelated" under "/x" "/a/b"

# tilde — home shown as ~
is "tilde rewrites home" "$(printf '%s\n' "$HOME/x" | tilde)" "~/x"

# write_if_unchanged — refuses when the live file moved under it
tmp="$(mktemp -d)"
printf 'a\n' > "$tmp/live"
cp "$tmp/live" "$tmp/snap"
printf 'b\n' > "$tmp/new"
ok "write_if_unchanged writes" write_if_unchanged "$tmp/live" "$tmp/snap" "$tmp/new"
is "write_if_unchanged content" "$(cat "$tmp/live")" "b"
printf 'c\n' > "$tmp/live"
no "write_if_unchanged refuses a changed file" bash -c '. "$1"; write_if_unchanged "$2/live" "$2/snap" "$2/new" 2>/dev/null' _ "$dir/../../scripts/lib.sh" "$tmp"
rm -rf "$tmp"

echo "---"
echo "lib-functions: pass $pass, fail $fail"
[ "$fail" -eq 0 ]
