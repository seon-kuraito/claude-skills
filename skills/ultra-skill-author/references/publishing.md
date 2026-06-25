# Publishing a skill to the repo

How a skill lands in the user's `claude-skills` repo: pick the right license files by provenance, then run the git workflow. Read this before creating or modifying a repo skill.

## Provenance & licensing

Every skill carries its own license in its directory — an extensionless `LICENSE` (plus a `NOTICE` for derivatives). Emit these when the skill's files are written, based on the provenance gathered in Step 1:

- **Original** — the user wrote it → emit an MIT `LICENSE` from `../assets/license-mit.txt`, replacing `{{YEAR}}` with the current year (the copyright holder is already filled in). No `NOTICE` needed.
- **Derived from a permissive upstream** (MIT / BSD / Apache) → clarify the upstream and its license *before drafting*. After building, emit the upstream's `LICENSE` verbatim (retaining its copyright) plus a `NOTICE` (start from `../assets/NOTICE.tmpl`) stating the source, the original copyright, and your changes. For an Apache-2.0 upstream, the `NOTICE` is required by §4 — not optional.
- **Unclear or copyleft upstream** (GPL and similar) → do not publish; surface this to the user and stop.

## Repository workflow

Any change destined for the user's skills repo `claude-skills` (at `~/Developer/claude-skills`) — **creating a new skill or modifying an existing one** — goes through the sequence below. (This path and the sibling skills used below are personal defaults — see this skill's `README.md` for swapping them.) If that repo is not present — a different machine, or a Claude.ai / Cowork environment — work locally and skip the publishing steps.

1. **Check git state** — confirm the repo is clean and on its default branch. Flag anything uncommitted rather than building on top of it.
2. **Open a branch** — hand off to [ultra-branch-creator](../../ultra-branch-creator/SKILL.md). The type follows the change: `feat/add-<skill-name>` for a new skill; `fix` / `refactor` / `docs` / etc. for editing an existing one.
3. **Make the change** in `skills/<name>/` (the repo is the source of truth):
   - **New skill** — author `SKILL.md` + resources, plus the licensing files above.
   - **Existing skill** — edit in place; touch the licensing files above only if provenance changed.
4. **Sync the catalog** — keep the `Skills 一覽` table in the repo-root `README.md` in step with `skills/`: add a row for a new skill, update it on rename, drop it on removal, refresh `用途` / `來源` when they shift. A plain in-place edit that touches neither name nor purpose needs no change here.
5. **Link** (new skill only) — run `scripts/link-skill.sh <skill-name>` to symlink it into `~/.claude/skills/`. An existing skill is already linked.
6. **Verify** — confirm the skill resolves as an available skill and its files / structure are sound.
7. **Confirmation gate** — stop, show the user what changed and what the commit will contain, and wait for explicit confirmation. Never auto-commit.
8. **Commit** — hand off to [ultra-commit-creator](../../ultra-commit-creator/SKILL.md).

Opening the pull request is **not** part of this flow — hand the branch back to the user after committing.
