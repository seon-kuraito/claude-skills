# Publishing a hook to the repo

How a hook lands in the user's `claude-hooks` repo: license by provenance, then run the git + registration workflow. Read this before creating or modifying a repo hook.

## Provenance & licensing

Every hook carries its own license in its directory — an extensionless `LICENSE` (plus a `NOTICE` for derivatives). Pick by the provenance gathered in Step 1:

- **Original** — the user wrote it → emit an MIT `LICENSE` from `../assets/license-mit.txt`, replacing `[year]` with the current year (the copyright holder is filled in). No `NOTICE`.
- **Derived from a permissive upstream** (MIT / BSD / Apache) → clarify the upstream and its license *before drafting*. After building, emit the upstream's `LICENSE` verbatim plus a `NOTICE` (from `../assets/notice-template.txt`) stating the source, original copyright, and your changes. Apache-2.0 requires the `NOTICE` by §4.
- **Unclear or copyleft upstream** (GPL and similar) → do not publish; surface this to the user and stop.

## Repository workflow

Any change destined for `claude-hooks` (at `~/Developer/claude-hooks`) — creating or modifying a hook — goes through the sequence below. (This path and the sibling skills are personal defaults — see this skill's `README.md` to swap them.) If the repo isn't present — a different machine, or a non-Claude-Code host — work locally and skip the publishing steps.

1. **Check git state** — the repo is clean and on its default branch. Flag anything uncommitted rather than building on top of it.
2. **Open a branch** — hand off to [ultra-branch-creator](../../ultra-branch-creator/SKILL.md). The type follows the change: `feat/add-<hook-name>` for a new hook; `fix` / `refactor` / `docs` for editing one.
3. **Make the change** in `hooks/<name>/` (the repo is the source of truth):
   - **New hook** — author `hook.sh` + `README.md` + the licensing files above.
   - **Existing hook** — edit in place; touch licensing only if provenance changed.
4. **Sync the catalog** — keep the `Hooks 一覽` table in the repo-root `README.md` in step with `hooks/`: add a row for a new hook, update it on rename, drop it on removal, refresh `用途` / `來源` when they shift. A plain in-place edit that touches neither name nor purpose needs no change here.
5. **Link** (new hook only) — run `scripts/link-hook.sh <hook-name>` to symlink it into `~/.claude/hooks/`.
6. **Register** — declare the registration in `settings.hooks.json`, then apply it to the live `~/.claude/settings.json` (see `references/registration.md`). This step is unique to hooks — skills don't have it. Applying to the live file touches the user's runtime config: show the merge, confirm before writing, and consider handing the edit to the `update-config` skill.
7. **Verify** — `/hooks` shows it under the right event, and a fixture run behaves (see `references/testing.md`).
8. **Confirmation gate** — stop, show the user what changed and what the commit will contain, and wait for explicit confirmation. Never auto-commit.
9. **Commit** — hand off to [ultra-commit-creator](../../ultra-commit-creator/SKILL.md).

Opening the pull request is **not** part of this flow — hand the branch back to the user after committing.
