#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer holding one repo with a real remote,
# so the behavior case has a project to start a version in without touching the
# machine or GitHub.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the project the prompt names.
#
# The remote is the point of this fixture. It is a bare repo inside the sandbox,
# so `git ls-remote --heads origin` answers for real and `git push` succeeds: a
# run that pushes the release branch before the Execution gate leaves that branch
# on the remote, and verify.sh catches it. With no remote the flow has nothing to
# read its branches from, and "it did not push" passes without being tested.
#
# The project holds `main` with one commit, no `develop`, no `staging`, and no
# version tag: the main flow, before its first version.
#
# Not covered: the GitHub half. The release PR, the merge, and the Release go
# through the GitHub API, which a bare repo cannot answer — test those by hand.
# The behavior case therefore starts a version and stops at the push. Nothing
# here runs npm or uv, so no cache override is needed.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-app"
remote="$sb/remotes/demo-app.git"

mkdir -p "$target/src" "$sb/remotes"

printf '<!doctype html>\n<title>demo-app</title>\n' > "$target/index.html"
printf 'export const answer = 42\n' > "$target/src/index.js"

git init -q -b main "$target"
git -C "$target" config user.name "Sandbox"
git -C "$target" config user.email "sandbox@example.invalid"
git -C "$target" add -A
git -C "$target" commit -q -m "chore: initialize repository"

git init -q --bare "$remote"
git -C "$target" remote add origin "$remote"
git -C "$target" push -q -u origin main

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
