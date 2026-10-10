#!/usr/bin/env bash
#
# verify.sh — judge what a real run left on disk, one PASS or FAIL line per
# rule, so two rounds of the same behavior case are judged the same way.
#
#   verify.sh <repo-dir> <deploy-branch> [static|vite]
#
# <repo-dir>       the project sandbox.sh built, after the flow ran on it.
# <deploy-branch>  the branch the run was told to deploy from.
# build type       defaults to vite, which is what the behavior case answers.
#
# The load-bearing rule is the workflow comparison: the template is substituted
# here and compared byte for byte with what the run wrote, so "only
# {{DEPLOY_BRANCH}} was replaced" is decided by diff rather than by reading the
# run's own account of itself.
#
# Note for anyone extending this: the template also carries
# `${{ steps.deployment.outputs.page_url }}`, which is GitHub Actions syntax and
# not a placeholder. A rule that looks for a leftover `{{` fails on a correct
# result; look for `{{DEPLOY_BRANCH}}` instead.
#
# It reads only. Exit 0 when every rule passes, exit 1 otherwise.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
assets="$here/../assets"
fail=0

ok()  { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
rule() { if eval "$2" > /dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

repo="${1:?usage: verify.sh <repo-dir> <deploy-branch> [static|vite]}"
branch="${2:?usage: verify.sh <repo-dir> <deploy-branch> [static|vite]}"
build="${3:-vite}"

tmpl="$assets/pages-$build.yml.tmpl"
workflow="$repo/.github/workflows/deploy-pages.yml"
ci_branch="ci/deploy-github-pages"
subject="ci: add github pages deploy workflow"

rule "template — pages-$build.yml.tmpl exists" "[ -f '$tmpl' ]"
rule "workflow — .github/workflows/deploy-pages.yml exists" "[ -f '$workflow' ]"

expected="$(mktemp)"
trap 'rm -f "$expected"' EXIT
if [ -f "$tmpl" ]; then
  sed "s|{{DEPLOY_BRANCH}}|$branch|g" "$tmpl" > "$expected"
fi

rule "workflow — equals the template with only {{DEPLOY_BRANCH}} replaced" \
  "[ -f '$workflow' ] && cmp -s '$workflow' '$expected'"
rule "workflow — no {{DEPLOY_BRANCH}} placeholder is left" \
  "[ -f '$workflow' ] && ! grep -q -F '{{DEPLOY_BRANCH}}' '$workflow'"

rule "branch — $ci_branch exists" "git -C '$repo' rev-parse --verify --quiet '$ci_branch'"
rule "branch — the deploy branch $branch exists" "git -C '$repo' rev-parse --verify --quiet '$branch'"
rule "branch — no branch was invented beside the two the fixture holds" \
  "[ -z \"\$(git -C '$repo' for-each-ref --format='%(refname:short)' refs/heads | grep -vx -e main -e develop -e '$ci_branch')\" ]"

rule "commit — the tip of $ci_branch has the fixed subject" \
  "[ \"\$(git -C '$repo' log -1 --format=%s '$ci_branch')\" = '$subject' ]"
rule "commit — it changes the workflow file and nothing else" \
  "[ \"\$(git -C '$repo' show --name-only --format= '$ci_branch')\" = '.github/workflows/deploy-pages.yml' ]"

rule "remote — nothing was pushed to the deploy branch" \
  "[ \"\$(git -C '$repo' rev-parse '$branch')\" = \"\$(git -C '$repo' rev-parse 'origin/$branch')\" ]"

echo "---"
if [ "$fail" = 0 ]; then echo "verify: every rule passed"; else echo "verify: at least one rule failed"; fi
exit "$fail"
