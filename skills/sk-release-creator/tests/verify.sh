#!/usr/bin/env bash
#
# verify.sh — judge what a real run left on disk, one PASS or FAIL line per
# rule, so two rounds of the same behavior case are judged the same way.
#
#   verify.sh <repo-dir> [version]
#
# <repo-dir>   the project sandbox.sh built, after the flow ran on it.
# version      defaults to 0.0.1, which is what the behavior case answers.
#
# Two rules carry the case. The release branch has to sit on main's commit: it
# is cut from main and takes no commit of its own. The remote rule lists the
# heads of the bare remote: it accepts a push, so a run that pushed before the
# Execution gate leaves the release branch there.
#
# It reads only. Exit 0 when every rule passes, exit 1 otherwise.
set -uo pipefail

fail=0

ok()  { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
rule() { if eval "$2" > /dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

repo="${1:?usage: verify.sh <repo-dir> [version]}"
version="${2:-0.0.1}"
release="release/$version"

rule "branch — $release exists" "git -C '$repo' rev-parse --verify --quiet 'refs/heads/$release'"
rule "branch — $release sits on main's commit" \
  "[ \"\$(git -C '$repo' rev-parse 'refs/heads/$release')\" = \"\$(git -C '$repo' rev-parse main)\" ]"
rule "branch — no branch was invented beside main and $release" \
  "[ -z \"\$(git -C '$repo' for-each-ref --format='%(refname:short)' refs/heads | grep -vx -e main -e '$release')\" ]"
rule "tag — no version tag was created" "[ -z \"\$(git -C '$repo' tag)\" ]"

rule "main — no commit landed on main" \
  "[ \"\$(git -C '$repo' rev-parse main)\" = \"\$(git -C '$repo' rev-parse origin/main)\" ]"
rule "remote — origin holds main and nothing else" \
  "[ \"\$(git -C '$repo' ls-remote --heads origin | awk '{print \$2}')\" = 'refs/heads/main' ]"

echo "---"
if [ "$fail" = 0 ]; then echo "verify: every rule passed"; else echo "verify: at least one rule failed"; fi
exit "$fail"
