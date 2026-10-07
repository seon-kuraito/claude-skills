#!/usr/bin/env bash
# Builds a throwaway single repo with a settled spec, a decision record whose version table
# lists it, a glossary, and a bare remote, so the behavior case can start the version for
# real without touching the machine or GitHub. Prints the environment lines for the brief.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(mktemp -d "${TMPDIR:-/tmp}/sk-spec-implementer.XXXXXX")"
project="$root/project"
remote="$root/remotes/project.git"
g() { git -C "$project" -c user.name=fixture -c user.email=fixture@example.com "$@"; }

cp -R "$here/fixtures/project" "$project"
mkdir -p "$(dirname "$remote")"
git init -q --bare -b main "$remote"
g init -q -b main
g add -A
g commit -q -m "chore: fixture"
g remote add origin "$remote"
g push -q -u origin main

echo "PROJECT_DIR=$project"
