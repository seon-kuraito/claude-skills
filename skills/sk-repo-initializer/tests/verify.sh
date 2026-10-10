#!/usr/bin/env bash
#
# verify.sh — judge what a real run left on disk, one PASS or FAIL line per
# rule, so two rounds of the same behavior case are judged the same way.
#
#   verify.sh <repo-dir> [license-id]
#
# <repo-dir>   the project sandbox.sh built, after the flow ran on it.
# license id   defaults to MIT, which is what the behavior case answers.
#
# Two rules carry the case. The LICENSE comparison substitutes the template here
# and compares it byte for byte with what the run committed, so "only {{YEAR}}
# was replaced" is decided by diff rather than by reading the run's own account
# of itself. The remote rule lists the heads of the bare remote: it accepts a
# push, so a run that pushed before the Execution gate leaves a branch there.
#
# GPL-3.0 ships verbatim and carries no {{YEAR}}; the substitution is then a
# no-op and the comparison still holds. The LICENSE is read from the setup
# branch, not from the working tree, so the result does not depend on which
# branch the run left checked out.
#
# It reads only. Exit 0 when every rule passes, exit 1 otherwise.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
assets="$here/../assets"
fail=0

ok()  { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
rule() { if eval "$2" > /dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

repo="${1:?usage: verify.sh <repo-dir> [license-id]}"
license="${2:-MIT}"

tmpl="$assets/licenses/$license.txt"
setup="chore/initial-project-setup"
subject="chore: add $license LICENSE"

expected="$(mktemp)"
actual="$(mktemp)"
trap 'rm -f "$expected" "$actual"' EXIT
if [ -f "$tmpl" ]; then
  sed "s|{{YEAR}}|$(date +%Y)|g" "$tmpl" > "$expected"
fi
git -C "$repo" show "$setup:LICENSE" > "$actual" 2> /dev/null

rule "template — licenses/$license.txt exists" "[ -f '$tmpl' ]"

rule "branch — $setup exists" "git -C '$repo' rev-parse --verify --quiet '$setup'"
rule "branch — no branch was invented beside the setup and the deploy branch" \
  "[ -z \"\$(git -C '$repo' for-each-ref --format='%(refname:short)' refs/heads | grep -vx -e main -e develop -e '$setup')\" ]"

rule "license — LICENSE is committed on $setup" "[ -s '$actual' ]"
rule "license — equals the template with only {{YEAR}} replaced" \
  "[ -s '$actual' ] && cmp -s '$actual' '$expected'"
rule "license — no {{YEAR}} placeholder is left" \
  "[ -s '$actual' ] && ! grep -q -F '{{YEAR}}' '$actual'"

rule "commit — the tip of $setup has the fixed subject" \
  "[ \"\$(git -C '$repo' log -1 --format=%s '$setup')\" = '$subject' ]"
rule "commit — it changes LICENSE and nothing else" \
  "[ \"\$(git -C '$repo' show --name-only --format= '$setup')\" = 'LICENSE' ]"
rule "commit — $setup is one commit ahead of main" \
  "[ \"\$(git -C '$repo' rev-list --count 'main..$setup')\" = '1' ]"

rule "main — no commit landed on main" \
  "[ \"\$(git -C '$repo' rev-parse main)\" = \"\$(git -C '$repo' rev-parse origin/main)\" ]"
rule "remote — origin holds main and nothing else" \
  "[ \"\$(git -C '$repo' ls-remote --heads origin | awk '{print \$2}')\" = 'refs/heads/main' ]"

echo "---"
if [ "$fail" = 0 ]; then echo "verify: every rule passed"; else echo "verify: at least one rule failed"; fi
exit "$fail"
