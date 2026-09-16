#!/usr/bin/env bash
#
# harness.sh — the two shipped scripts, asserted against fixture inputs.
# run-hook-test.sh is how every hook in the family gets tested, and
# validate-registration.sh guards what lands in settings.json.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scripts="$dir/../../scripts"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

pass=0
fail=0

expect_code() { # expect_code <label> <expected> <command...>
  local label="$1" want="$2"; shift 2
  "$@" > /dev/null 2>&1
  local got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
  else
    echo "FAIL  $label — exit $got, expected $want"
    fail=$((fail + 1))
  fi
}

# --- run-hook-test.sh -------------------------------------------------------
printf '%s\n' '#!/usr/bin/env bash' 'cat > /dev/null' 'echo "{\"ok\":true}"' 'exit 0' > "$tmp/ok-hook.sh"
printf '%s\n' '#!/usr/bin/env bash' 'cat > /dev/null' 'echo "blocked" >&2' 'exit 2' > "$tmp/deny-hook.sh"
printf '%s\n' '{"hook_event_name":"Stop","stop_hook_active":false}' > "$tmp/stop.json"

expect_code "runs a hook and reports it" 0 bash "$scripts/run-hook-test.sh" "$tmp/ok-hook.sh" "$tmp/stop.json"
expect_code "matches the expected exit code" 0 bash "$scripts/run-hook-test.sh" "$tmp/ok-hook.sh" "$tmp/stop.json" 0
expect_code "catches a wrong exit code" 1 bash "$scripts/run-hook-test.sh" "$tmp/ok-hook.sh" "$tmp/stop.json" 2
expect_code "accepts a blocking hook's exit 2" 0 bash "$scripts/run-hook-test.sh" "$tmp/deny-hook.sh" "$tmp/stop.json" 2
expect_code "rejects a missing hook" 1 bash "$scripts/run-hook-test.sh" "$tmp/nope.sh" "$tmp/stop.json"
expect_code "rejects a missing fixture" 1 bash "$scripts/run-hook-test.sh" "$tmp/ok-hook.sh" "$tmp/nope.json"
expect_code "rejects a call with no arguments" 1 bash "$scripts/run-hook-test.sh"

# a non-executable hook still runs, so a missing chmod +x never blocks a test
printf '%s\n' '#!/usr/bin/env bash' 'cat > /dev/null' 'exit 0' > "$tmp/plain-hook.sh"
chmod -x "$tmp/plain-hook.sh"
expect_code "runs a hook that is not executable" 0 bash "$scripts/run-hook-test.sh" "$tmp/plain-hook.sh" "$tmp/stop.json" 0

# --- validate-registration.sh ----------------------------------------------
cat > "$tmp/good.json" <<'JSON'
{"hooks":{"Stop":[{"hooks":[{"type":"command","command":"~/.claude/hooks/x/hook.sh"}]}]}}
JSON
cat > "$tmp/unknown-event.json" <<'JSON'
{"hooks":{"WhenPigsFly":[{"hooks":[{"type":"command","command":"x"}]}]}}
JSON
cat > "$tmp/no-command.json" <<'JSON'
{"hooks":{"Stop":[{"hooks":[{"type":"command","command":""}]}]}}
JSON
cat > "$tmp/not-array.json" <<'JSON'
{"hooks":{"Stop":{"hooks":[{"type":"command","command":"x"}]}}}
JSON
printf '%s\n' '{"hooks":' > "$tmp/broken.json"
printf '%s\n' '{"settings":{}}' > "$tmp/no-hooks.json"

expect_code "accepts a well-formed block" 0 bash "$scripts/validate-registration.sh" "$tmp/good.json"
expect_code "rejects invalid JSON" 1 bash "$scripts/validate-registration.sh" "$tmp/broken.json"
expect_code "rejects a file with no hooks object" 1 bash "$scripts/validate-registration.sh" "$tmp/no-hooks.json"
expect_code "rejects an unknown event name" 1 bash "$scripts/validate-registration.sh" "$tmp/unknown-event.json"
expect_code "rejects a command handler with no command" 1 bash "$scripts/validate-registration.sh" "$tmp/no-command.json"
expect_code "rejects an event value that is not an array" 1 bash "$scripts/validate-registration.sh" "$tmp/not-array.json"
expect_code "rejects a missing file" 1 bash "$scripts/validate-registration.sh" "$tmp/nope.json"

echo "---"
echo "harness: pass $pass, fail $fail"
[ "$fail" -eq 0 ]
