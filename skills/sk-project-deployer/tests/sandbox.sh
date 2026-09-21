#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway ~/Developer holding one Vite SPA with a real
# remote, so the behavior case has a project to deploy without touching the
# machine or GitHub.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines for the brief, then the project the prompt names.
#
# The project carries the two markers the build-type menu reads — a `vite`
# devDependency and a vite.config.ts — plus the lockfile the Vite template needs
# (`npm ci` fails without one). Shape taken from a real Vite project, not from
# the skill's documentation.
#
# Branches are the point of this fixture. `main` and `develop` exist; `preparing`
# does not. The deploy-branch menu is built from what exists, so a run that
# offers `preparing` has invented an option and the assert catches it. The remote
# is a bare repo inside the sandbox, so `git ls-remote --heads origin` answers
# for real and nothing reaches GitHub.
#
# Not covered: the remote half at GitHub. The run stops at the Execution gate, so
# `gh api .../pages` and the environment's branch policy never run — test those
# by hand. Nothing here runs npm or uv, so no cache override is needed.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
mkdir -p "$sb"

owner="$(id -un)"
target="$sb/Developer/$owner/demo-site"
remote="$sb/remotes/demo-site.git"

mkdir -p "$target/src" "$sb/remotes"

cat > "$target/package.json" <<'JSON'
{
  "name": "demo-site",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "devDependencies": {
    "vite": "^7.1.0"
  }
}
JSON

cat > "$target/package-lock.json" <<'JSON'
{
  "name": "demo-site",
  "version": "0.1.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "demo-site",
      "version": "0.1.0",
      "devDependencies": {
        "vite": "^7.1.0"
      }
    }
  }
}
JSON

cat > "$target/vite.config.ts" <<'TS'
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [],
});
TS

printf '<!doctype html>\n<title>demo-site</title>\n<div id="app"></div>\n<script type="module" src="/src/main.ts"></script>\n' > "$target/index.html"
printf 'document.querySelector("#app").textContent = "demo-site"\n' > "$target/src/main.ts"

git init -q -b main "$target"
git -C "$target" config user.name "Sandbox"
git -C "$target" config user.email "sandbox@example.invalid"
git -C "$target" add -A
git -C "$target" commit -q -m "feat: scaffold the vite site"
git -C "$target" branch develop

git init -q --bare "$remote"
git -C "$target" remote add origin "$remote"
git -C "$target" push -q origin main develop

cat <<ENV
PROJECTS_DIR=$sb/Developer
TARGET=$target
ENV
