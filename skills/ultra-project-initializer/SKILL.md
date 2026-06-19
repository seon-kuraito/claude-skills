---
name: ultra-project-initializer
description: Initializes a project's working setup after its repo exists — adds a root .gitignore, a blank .claude/CLAUDE.md, and the Conventional Commits type labels on GitHub. The initialize stage ultra-repo-creator hands off to once the repo is created; also use it directly to add any of these to an existing project. An insertable, project-level stage (a repo may hold several projects). Not git init / remote / branch protection — that is ultra-repo-creator.
---

# Ultra Project Initializer

Initialize a project's working setup once its repository exists — a root `.gitignore`, a blank `.claude/CLAUDE.md`, and the Conventional Commits type labels on GitHub. This is the **initialize** stage that pairs with [ultra-repo-creator](../ultra-repo-creator/SKILL.md)'s **create** stage.

## Stage & entry

An **insertable stage**, not a fixed step in a pipeline — run it whenever the need arises (usually right after the repo is created, but any time is fine). It works at the **project** level, and a single repo may hold several projects (a monorepo); when that applies, confirm which project before acting.

**Entry precondition — a repository must already exist:**

- `.gitignore` and `.claude/CLAUDE.md` need a local repo (`git init` done).
- the type labels need a GitHub remote.
- branch protection is **not** a precondition.

If no repository exists yet, point the user to [ultra-repo-creator](../ultra-repo-creator/SKILL.md) (the create stage) and stop. ultra-repo-creator also offers to hand off here once it finishes — a convenience, not the only entry.

## Companions

Load [ultra-branch-creator](../ultra-branch-creator/SKILL.md) and [ultra-commit-creator](../ultra-commit-creator/SKILL.md) for the branch and commits this stage lands; if either is absent, follow the conventions below without blocking.

## Feature selection

Always present the choice as one `AskUserQuestion` call with `multiSelect: true` — never ask in prose, and never one feature at a time. A single question (e.g. "Which items to set up?") whose options are the three features below; the user picks any combination (or none):

- **`.gitignore`** — a root `.gitignore` from `assets/gitignore-template` (macOS + editor/IDE + log artifacts).
- **`.claude/CLAUDE.md`** — a blank `.claude/CLAUDE.md`.
- **GitHub labels** — replace the repo's default labels with the Conventional Commits type labels in `assets/type-labels.json`.

If nothing is selected, stop.

## Applying the selection

The file options land on a dedicated branch; the labels option is a GitHub-side effect with no commit.

1. **File options** (`.gitignore`, `.claude/CLAUDE.md`) — if any is selected, create the branch `chore/initial-project-setup` (hand to ultra-branch-creator), then apply each selected one as its own commit, using these **fixed messages verbatim** (they do *not* go through ultra-commit-creator):
   - `.gitignore` → `chore: add gitignore for macOS and editor artifacts`
   - `.claude/CLAUDE.md` → `chore: add CLAUDE.md`

   Hand the branch back to the user afterward — the PR is not opened automatically (that is ultra-pr-creator).
2. **GitHub labels** — make the repo's labels *exactly* the type set, in two steps:
   - **Delete the defaults first.** A new GitHub repo ships nine default labels — `bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`. Remove each that is present with `gh label delete <name> --yes`. Touch only these defaults — leave any custom labels alone.
   - **Then create the types.** For each entry in `assets/type-labels.json`, run `gh label create <name> --color <color>` (no description, mirroring the source); pass `--force` to overwrite a same-named label. This makes no commit.

## Execution gate

Before any command that writes to the remote or the repo's settings — `gh label delete`, `gh label create`, `git push` — stop, show exactly what will run, and wait for explicit confirmation. Never chain the whole selection into one uninterrupted run.

## Related

- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage (git init / remote / branch protection) this stage follows.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commits this stage lands.
- `ultra-project-publisher` (planned) — a future **publish** stage; like this one, an insertable, project-level stage.
