#!/usr/bin/env bash
#
# link-siblings.sh — symlink the sibling <prefix>-* repos into this coordination
# repo so an agent working here sees the whole family in one tree. The real repos
# stay at ~/Developer/<prefix>-* (the single source of truth); these links are
# gitignored — a local view, not tracked content. Edits made through a link land
# in the real sibling repo, where its own git ceremony happens.
#
# Usage: scripts/link-siblings.sh
#
# Idempotent: re-running is safe. Refuses to overwrite anything it doesn't own
# (a real file/dir, or a symlink already pointing elsewhere). The family prefix
# is derived from this repo's own name (strip the "-meta" suffix), so the script
# is portable across meta layers; a new family member links with no edit here
# (add its name to .gitignore so the link stays untracked).
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
self="$(basename "$repo_root")"        # <prefix>-meta — never link self
family="${self%-meta}"                  # <prefix> — the shared family prefix
parent="$(cd "$repo_root/.." && pwd)"  # the directory holding the family

linked=0
for src in "$parent/$family-"*/; do
  src="${src%/}"                       # strip the trailing slash the glob adds
  name="$(basename "$src")"
  [ "$name" = "$self" ] && continue    # skip this repo
  [ -d "$src" ] || continue            # no matches → glob stays literal; skip

  dest="$repo_root/$name"
  target="../$name"                    # relative link: survives moving the parent dir

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$target" ]; then
      echo "ok: already linked — $name"
      continue
    fi
    echo "error: $dest already links elsewhere ($(readlink "$dest"))" >&2
    exit 1
  elif [ -e "$dest" ]; then
    # A real file/dir is in the way → refuse to clobber it.
    echo "error: $dest exists and is not a symlink — refusing to overwrite" >&2
    exit 1
  fi

  ln -s "$target" "$dest"
  echo "linked: $dest -> $target"
  linked=$((linked + 1))
done

echo "done: $linked new link(s)"
