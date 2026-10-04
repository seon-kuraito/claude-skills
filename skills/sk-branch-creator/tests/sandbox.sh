#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer holding one repo with a finished,
# uncommitted change, so the behavior case has real work to name a branch for
# without touching the machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the repo the prompt names.
#
# The change is the point of this fixture. The repo sits on `main` with one
# commit, and src/button.css carries an edit in the working tree: the hover
# transition goes from a linear 120ms to an eased 180ms. That is user-visible
# polish — neither a new feature nor code formatting — so the type the case
# expects can be read from the diff. With no such change anywhere, a run finds
# no target, stops before it loads the skill, and the case measures nothing.
#
# This is a naming case. The brief keeps the plan-only constraint, so a run
# proposes the branch name and creates nothing: the fixture only gives the
# request something real to read. The remote is a bare repo inside the sandbox,
# so `git ls-remote --heads origin` answers for real — `main` and nothing else,
# which is how the run learns where a work branch is cut from.
#
# Nothing here runs npm or uv, so no cache override is needed.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-app"
remote="$sb/remotes/demo-app.git"

mkdir -p "$target/src" "$sb/remotes"

printf '<!doctype html>\n<title>demo-app</title>\n<button class="cta">Send</button>\n' > "$target/index.html"
printf '.cta { transition: background-color 120ms linear; }\n' > "$target/src/button.css"

git init -q -b main "$target"
git -C "$target" config user.name "Sandbox"
git -C "$target" config user.email "sandbox@example.invalid"
git -C "$target" add -A
git -C "$target" commit -q -m "feat: scaffold the demo app"

git init -q --bare "$remote"
git -C "$target" remote add origin "$remote"
git -C "$target" push -q -u origin main

printf '.cta { transition: background-color 180ms cubic-bezier(0.4, 0, 0.2, 1); }\n' > "$target/src/button.css"

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
