#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer that holds one plain folder, so a
# behavior case has a real folder to turn into a repo without touching the
# machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the folder the prompt names.
# The folder holds work and no .git: the case is "existing files, not a repo
# yet". Tell the subagent to treat PROJECTS_DIR as the user's ~/Developer, so
# the folder already sits under an owner directory and nothing has to move.
#
# A family case needs nothing more: the meta-repo template creates the family's
# own directory under PROJECTS_DIR, and no such directory exists here. Judge
# either result with verify.sh, beside this file.
#
# Not covered: the remote half. The run stops at the Execution gate, so
# `gh repo create` and `git push` never run — test those by hand.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-app"

mkdir -p "$target/src"
printf '<!doctype html>\n<title>demo-app</title>\n' > "$target/index.html"
printf 'export const answer = 42\n' > "$target/src/index.js"

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
