#!/usr/bin/env bash
#
# verify.sh — judge what a real run left on disk, one PASS or FAIL line per
# rule, so two rounds of the same behavior case are judged the same way.
#
#   verify.sh blank  <repo-dir>
#   verify.sh family <owner-dir> <family> <token>...
#
# blank   the folder sandbox.sh built, after the blank template ran on it.
# family  a new family after the meta-repo template ran: the layer, every
#         member, and the workspace. Names follow *Family naming* in
#         references/meta-repo.md: when the owner directory carries the family
#         name, the layer is `meta` and a member is `<token>`; otherwise they are
#         `<family>-meta` and `<family>-<token>`.
#
# It reads only. Exit 0 when every rule passes, exit 1 otherwise.
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
assets="$here/../assets"
fail=0

ok()  { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
rule() { if eval "$2" > /dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

if command -v uv > /dev/null 2>&1; then
  python_cmd=(uv run --quiet python)
else
  python_cmd=(python3)
fi

# one_commit <dir> <label> <subject> <asset for .gitignore> <tracked files, sorted, space-joined>
one_commit() {
  local d="$1" label="$2" subject="$3" ignore="$4" tracked="$5"
  rule "$label — is a git repo" "git -C '$d' rev-parse --git-dir"
  rule "$label — holds exactly one commit" "[ \"\$(git -C '$d' rev-list --count HEAD)\" = 1 ]"
  rule "$label — commit subject is '$subject'" "[ \"\$(git -C '$d' log -1 --format=%s)\" = '$subject' ]"
  rule "$label — tracks exactly: $tracked" "[ \"\$(git -C '$d' ls-tree -r --name-only HEAD | sort | tr '\n' ' ' | sed 's/ \$//')\" = '$tracked' ]"
  rule "$label — committed .gitignore equals $(basename "$(dirname "$ignore")")/gitignore.txt" "git -C '$d' show HEAD:.gitignore | cmp -s - '$ignore'"
  rule "$label — has no remote" "[ -z \"\$(git -C '$d' remote)\" ]"
}

mode="${1:-}"
case "$mode" in
  blank)
    repo="${2:?usage: verify.sh blank <repo-dir>}"
    one_commit "$repo" "repo" "chore: initialize repository" "$assets/blank/gitignore.txt" ".gitignore README.md"
    rule "repo — committed README.md is empty" "[ \"\$(git -C '$repo' cat-file -s HEAD:README.md)\" = 0 ]"
    rule "repo — the existing work stays untracked" "git -C '$repo' status --porcelain | grep -q '^?? '"
    ;;
  family)
    owner="${2:?usage: verify.sh family <owner-dir> <family> <token>...}"
    family="${3:?usage: verify.sh family <owner-dir> <family> <token>...}"
    shift 3
    [ $# -gt 0 ] || { echo "usage: verify.sh family <owner-dir> <family> <token>..."; exit 1; }

    if [ "$(basename "$owner")" = "$family" ]; then prefix=""; else prefix="$family-"; fi
    layer="${prefix}meta"
    members=()
    for token in "$@"; do members+=("${prefix}${token}"); done

    one_commit "$owner/$layer" "layer $layer" "chore: scaffold $family coordination layer" \
      "$assets/meta-repo/gitignore.txt" ".gitignore CLAUDE.md README.md"
    rule "layer $layer — no placeholder is left in CLAUDE.md or README.md" \
      "[ -f '$owner/$layer/CLAUDE.md' ] && [ -f '$owner/$layer/README.md' ] && ! grep -q -F '{{' '$owner/$layer/CLAUDE.md' '$owner/$layer/README.md'"

    # The member tables keep the list order, then a self-row for the layer.
    for doc in CLAUDE.md README.md; do
      last=0; ordered=1
      for name in "${members[@]}"; do
        line="$(grep -n -F "../$name" "$owner/$layer/$doc" 2> /dev/null | head -1 | cut -d: -f1)"
        if [ -z "$line" ] || [ "$line" -le "$last" ]; then ordered=0; break; fi
        last="$line"
      done
      if [ "$ordered" = 1 ]; then ok "layer $layer — $doc lists every member at ../<name>, in list order"
      else bad "layer $layer — $doc lists every member at ../<name>, in list order"; fi
    done

    for name in "${members[@]}"; do
      one_commit "$owner/$name" "member $name" "chore: initialize $name repository" \
        "$assets/blank/gitignore.txt" ".gitignore README.md"
      rule "member $name — committed README.md is empty" "[ \"\$(git -C '$owner/$name' cat-file -s HEAD:README.md)\" = 0 ]"
    done

    ws="$owner/$family.code-workspace"
    rule "workspace — $family.code-workspace sits in the owner directory" "[ -f '$ws' ]"
    rule "workspace — the owner directory is not a git repo, so nothing tracks it" "[ ! -e '$owner/.git' ]"
    expected="$layer ${members[*]}"
    # A workspace file is JSONC: drop a trailing comma before it is parsed.
    if WS="$ws" EXPECTED="$expected" LAYER="$layer" "${python_cmd[@]}" - << 'PY' > /dev/null 2>&1
import json, os, re, sys
text = open(os.environ["WS"], encoding="utf-8").read()
data = json.loads(re.sub(r",(\s*[\]}])", r"\1", text))
names = [f["name"] for f in data["folders"]]
paths = [f["path"] for f in data["folders"]]
want = os.environ["EXPECTED"].split()
ok = names == want and paths == ["./" + n for n in want]
ok = ok and data["settings"]["terminal.integrated.cwd"] == "${workspaceFolder:" + os.environ["LAYER"] + "}"
sys.exit(0 if ok else 1)
PY
    then ok "workspace — folders are the layer, then every member in list order; the terminal opens in the layer"
    else bad "workspace — folders are the layer, then every member in list order; the terminal opens in the layer"; fi
    ;;
  *)
    echo "usage: verify.sh blank <repo-dir> | verify.sh family <owner-dir> <family> <token>..."
    exit 1
    ;;
esac

echo "---"
if [ "$fail" = 0 ]; then echo "verify: every rule passed"; else echo "verify: at least one rule failed"; fi
exit "$fail"
