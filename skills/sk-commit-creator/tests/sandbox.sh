#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer holding one repo with a staged
# change on a work branch, so the behavior case has a real diff to write a
# commit message for without touching the machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the repo the prompt names.
#
# The staged diff is the point of this fixture. README.md's install steps go
# from npm to pnpm, and nothing else changes, so the type and the description
# can be read from the diff. With no such change anywhere, a run finds no
# target, stops before it loads the skill, and writes no message — the case
# then measures nothing.
#
# The repo sits on a work branch, not on `main`: the skill's branch check sends
# a commit on a long-lived branch to a new branch first, and that detour is not
# what this case measures. The branch name says nothing about the change, so
# the type is still the run's own reading of the diff.
#
# This is a writing case. The brief keeps the plan-only constraint, so a run
# proposes the message and commits nothing. The remote is a bare repo inside
# the sandbox and holds `main` only.
#
# Nothing here runs npm or uv, so no cache override is needed.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-app"
remote="$sb/remotes/demo-app.git"

mkdir -p "$target/src" "$sb/remotes"

printf 'export const answer = 42\n' > "$target/src/index.js"
cat > "$target/README.md" <<'MD'
# demo-app

A small demo application.

## Install

```sh
npm install
npm run dev
```
MD

git init -q -b main "$target"
git -C "$target" config user.name "Sandbox"
git -C "$target" config user.email "sandbox@example.invalid"
git -C "$target" add -A
git -C "$target" commit -q -m "feat: scaffold the demo app"

git init -q --bare "$remote"
git -C "$target" remote add origin "$remote"
git -C "$target" push -q -u origin main

git -C "$target" switch -q -c work/next-change
cat > "$target/README.md" <<'MD'
# demo-app

A small demo application.

## Install

```sh
pnpm install
pnpm dev
```
MD
git -C "$target" add README.md

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
