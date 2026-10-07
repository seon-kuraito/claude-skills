#!/usr/bin/env bash
# Builds a throwaway copy of a single-repo project for the model cases and prints the
# environment lines that point a run at it. Nothing outside the printed directory is touched.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(mktemp -d "${TMPDIR:-/tmp}/sk-spec-planner.XXXXXX")"
project="$root/project"

cp -R "$here/fixtures/project" "$project"
git -C "$project" init -q
git -C "$project" -c user.name=fixture -c user.email=fixture@example.com add -A
git -C "$project" -c user.name=fixture -c user.email=fixture@example.com commit -q -m "chore: fixture"

echo "PROJECT_DIR=$project"
