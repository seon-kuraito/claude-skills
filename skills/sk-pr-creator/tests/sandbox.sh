#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer holding one repo whose feature
# branch is ready to describe, so the behavior case has a real diff to write a
# PR body from without touching the machine or GitHub.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the repo the prompt names.
#
# The repo sits on `improve/button-hover-easing` with two commits ahead of
# `main`, so the Summary has a floor of two bullets and the branch name doubles
# as the PR title. The remote is a bare repo inside the sandbox: the branch is
# unpushed, so `git log origin/main..HEAD` answers for real and nothing reaches
# GitHub.
#
# The repo carries scripts/run-checks.sh but no record that it ran on this
# branch. That is deliberate: the skill blocks the Execution gate without a
# passing run, so the case measures the block. The reply in model.json answers
# the question the flow asks about what covers the change; it names the script
# and says it has not run, and the run must stop before the gate.
#
# The brief sends the PR body file under TARGET, so a run that writes one leaves
# nothing outside the sandbox.
#
# Not covered: `git push` and `gh pr create`. The run stops at the Execution
# gate, so neither fires — test those by hand. Nothing here runs npm or uv, so
# no cache override is needed.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-app"
remote="$sb/remotes/demo-app.git"

mkdir -p "$target/src" "$target/scripts" "$sb/remotes"

printf '<!doctype html>\n<title>demo-app</title>\n<button class="cta">Send</button>\n' > "$target/index.html"
printf '.cta { transition: background-color 120ms linear; }\n' > "$target/src/button.css"

cat > "$target/scripts/run-checks.sh" <<'SH'
#!/usr/bin/env bash
# Stand-in for the repo's own verification. It is never run by the case.
set -euo pipefail
echo "all checks passed"
SH
chmod +x "$target/scripts/run-checks.sh"

git init -q -b main "$target"
git -C "$target" config user.name "Sandbox"
git -C "$target" config user.email "sandbox@example.invalid"
git -C "$target" add -A
git -C "$target" commit -q -m "feat: scaffold the demo app"

git init -q --bare "$remote"
git -C "$target" remote add origin "$remote"
git -C "$target" push -q origin main

git -C "$target" switch -q -c improve/button-hover-easing
printf '.cta { transition: background-color 180ms cubic-bezier(0.4, 0, 0.2, 1); }\n' > "$target/src/button.css"
git -C "$target" commit -q -am "improve: soften the hover transition easing"
printf '.cta:hover { background-color: #2f6feb; }\n' >> "$target/src/button.css"
git -C "$target" commit -q -am "improve: raise the hover contrast"

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
