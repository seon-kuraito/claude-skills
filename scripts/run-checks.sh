#!/usr/bin/env bash
#
# run-checks.sh — the structure and script tiers for this repo, per
# skills/sk-skill-author/references/verification.md.
#
#   scripts/run-checks.sh            every skill
#   scripts/run-checks.sh <skill>    one skill
#
# Exit 0 passes, exit 1 fails.
set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runner="$repo/scripts/runner"

if command -v uv > /dev/null 2>&1; then
  python_cmd=(uv run --quiet)
else
  python_cmd=(python3)
fi

if [ $# -gt 0 ]; then
  items=("$@")
else
  items=()
  for dir in "$repo"/skills/*/; do
    [ -f "$dir/SKILL.md" ] && items+=("$(basename "$dir")")
  done
fi


fail=0

# Drift check — every shared rule in the spec must have an implementation here.
spec="$repo/skills/sk-skill-author/references/verification.md"
[ -f "$spec" ] || spec="$repo/../claude-skills/skills/sk-skill-author/references/verification.md"
if [ -f "$spec" ]; then
  shared=$(awk '/^## Shared rules/{f=1; next} /^## Routed-item rules/{f=1; next} /^## /{f=0} f' "$spec" | grep -oE '^\| `[a-z][a-z-]*`' | tr -d '|` ')
  for rule in $shared; do
    if ! compgen -G "$runner/$rule.*" > /dev/null; then
      echo "FAIL  runner — shared rule '$rule' has no file in scripts/runner/"
      fail=1
    fi
  done
else
  echo "SKIP  drift check — no verification.md beside this repo"
fi

# An empty repo is a valid state — the drift check above still applies to its
# runner, and bash 3.2 errors on "${items[@]}" under set -u.
if [ ${#items[@]} -eq 0 ]; then
  echo "---"
  if [ $fail -eq 0 ]; then echo "no items to check"; else echo "checks failed"; fi
  exit $fail
fi

# Structure tier.
for rule_file in "$runner"/*; do
  [ -f "$rule_file" ] || continue
  rule="$(basename "${rule_file%.*}")"
  case "$rule" in _*) continue ;; esac
  case "$rule_file" in
    *.py) runner_cmd=("${python_cmd[@]}" "$rule_file") ;;
    *.sh) runner_cmd=(bash "$rule_file") ;;
    *) echo "FAIL  $rule — unsupported rule file extension"; fail=1; continue ;;
  esac
  if "${runner_cmd[@]}" "$repo" "${items[@]}"; then
    echo "PASS  $rule"
  else
    fail=1
  fi
done

# Script tier.
for item in "${items[@]}"; do
  item_tests="$repo/skills/$item/tests/run.sh"
  if [ -f "$item_tests" ]; then
    echo "---   $item tests/run.sh"
    if bash "$item_tests"; then
      echo "PASS  $item script tier"
    else
      echo "FAIL  $item script tier"
      fail=1
    fi
  fi
done

echo "---"
if [ $fail -eq 0 ]; then echo "all checks passed"; else echo "checks failed"; fi
exit $fail
