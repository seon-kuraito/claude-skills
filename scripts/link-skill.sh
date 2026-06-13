#!/usr/bin/env bash
#
# link-skill.sh — symlink a skill from this repo into ~/.claude/skills so
# Claude Code discovers and loads it at runtime.
#
# Usage: scripts/link-skill.sh <skill-name>
#
# Idempotent: re-running is safe. Refuses to overwrite a real directory
# (e.g. a third-party skill installed directly into ~/.claude/skills).
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_skills="$(cd "$script_dir/.." && pwd)/skills"
runtime_skills="$HOME/.claude/skills"

name="${1:-}"
if [ -z "$name" ]; then
  echo "usage: link-skill.sh <skill-name>" >&2
  exit 1
fi

src="$repo_skills/$name"
dest="$runtime_skills/$name"

if [ ! -d "$src" ]; then
  echo "error: skill not found in repo: $src" >&2
  exit 1
fi

# Already linked to the right place → nothing to do.
if [ -L "$dest" ]; then
  if [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok: already linked — $name"
    exit 0
  fi
  echo "error: $dest already links elsewhere ($(readlink "$dest"))" >&2
  exit 1
fi

# A real file/dir is in the way → refuse to clobber it.
if [ -e "$dest" ]; then
  echo "error: $dest exists and is not a symlink — refusing to overwrite" >&2
  exit 1
fi

mkdir -p "$runtime_skills"
ln -s "$src" "$dest"
echo "linked: $dest -> $src"
