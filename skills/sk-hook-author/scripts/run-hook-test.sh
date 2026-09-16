#!/usr/bin/env bash
#
# run-hook-test.sh — feed a fixture event payload to a hook on stdin and report
# its exit code, stdout, and stderr. The deterministic test harness for command
# hooks (see references/testing.md).
#
# Usage: run-hook-test.sh <hook-script> <fixture.json> [expected-exit-code]
#
# Exit: 0 if the hook ran (and matched expected-exit-code when given), 1 otherwise.
set -uo pipefail

hook="${1:-}"
fixture="${2:-}"
expected="${3:-}"

if [ -z "$hook" ] || [ -z "$fixture" ]; then
  echo "usage: run-hook-test.sh <hook-script> <fixture.json> [expected-exit-code]" >&2
  exit 1
fi
if [ ! -f "$hook" ]; then echo "error: hook not found: $hook" >&2; exit 1; fi
if [ ! -f "$fixture" ]; then echo "error: fixture not found: $fixture" >&2; exit 1; fi

out_file="$(mktemp)"
err_file="$(mktemp)"
trap 'rm -f "$out_file" "$err_file"' EXIT

# Run the script directly when executable; otherwise via bash so a missing
# chmod +x doesn't block the test.
if [ -x "$hook" ]; then
  runner=("$hook")
else
  runner=(bash "$hook")
fi

< "$fixture" "${runner[@]}" > "$out_file" 2> "$err_file"
code=$?

echo "exit: $code"
echo "--- stdout ---"; cat "$out_file"
echo "--- stderr ---"; cat "$err_file"

if [ -n "$expected" ]; then
  if [ "$code" -eq "$expected" ]; then
    echo "ok: exit code matches expected ($expected)"
    exit 0
  fi
  echo "FAIL: exit $code, expected $expected" >&2
  exit 1
fi
exit 0
