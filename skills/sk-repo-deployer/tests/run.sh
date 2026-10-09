#!/usr/bin/env bash
#
# run.sh — the script tier for this skill: every deterministic check under checks/.
# Called by the repo's scripts/run-checks.sh; runnable on its own.
#
# A Python check declares its dependencies inline (PEP 723) and runs through
# `uv run`; without uv it falls back to python3, which only suits a stdlib check.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fail=0

if command -v uv > /dev/null 2>&1; then
  python_cmd=(uv run --quiet)
else
  python_cmd=(python3)
fi

for check in "$dir"/checks/*; do
  [ -f "$check" ] || continue
  name="$(basename "$check")"
  case "$check" in
    *.py) cmd=("${python_cmd[@]}" "$check") ;;
    *.sh) cmd=(bash "$check") ;;
    *) echo "FAIL  $name — unsupported check extension"; fail=1; continue ;;
  esac
  if "${cmd[@]}"; then
    echo "PASS  $name"
  else
    echo "FAIL  $name"
    fail=1
  fi
done

exit $fail
