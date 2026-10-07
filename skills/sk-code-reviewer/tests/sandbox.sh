#!/usr/bin/env bash
# Builds a throwaway repo with a main branch and a work branch that carries a change to
# review, and prints the environment lines that point a run at it. Nothing outside the
# printed directory is touched.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(mktemp -d "${TMPDIR:-/tmp}/sk-code-reviewer.XXXXXX")"
project="$root/project"
g() { git -C "$project" -c user.name=fixture -c user.email=fixture@example.com "$@"; }

cp -R "$here/fixtures/project/base" "$project"
g init -q -b main
g add -A
g commit -q -m "chore: fixture"
g switch -q -c feat/export-csv
cp -R "$here/fixtures/project/branch/." "$project/"
g add -A
g commit -q -m "feat: export records as csv"

echo "PROJECT_DIR=$project"
