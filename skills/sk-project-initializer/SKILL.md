---
name: sk-project-initializer
description: Initializes a project's working setup after its repo exists — adds a LICENSE, a blank .claude/CLAUDE.md, the Conventional Commits type labels on GitHub, optional main branch protection, and an optional deploy branch (develop / preparing) for sk-project-deployer. The initialize stage sk-repo-creator hands off to once the repo is created; also use it directly to add any of these to an existing project. An insertable, project-level stage (a repo may hold several projects). Not git init / remote — that is sk-repo-creator.
---

# Project Initializer

Initialize a project's working setup once its repository exists — a `LICENSE`, a blank `.claude/CLAUDE.md`, the Conventional Commits type labels on GitHub, and optional `main` branch protection. This is the **initialize** stage that pairs with [sk-repo-creator](../sk-repo-creator/SKILL.md)'s **create** stage.

## Stage & entry

An **insertable stage**, not a fixed step in a pipeline — run it whenever the need arises (usually right after the repo is created, but any time is fine). It works at the **project** level, and a single repo may hold several projects (a monorepo); when that applies, confirm which project before acting.

**Entry precondition — a repository must already exist:**

- the `LICENSE` and `.claude/CLAUDE.md` files need a local repo (`git init` done).
- the type labels and branch protection need a GitHub remote — and on GitHub Free, branch protection additionally needs the repo to be **public** (rulesets return `403` on a private repo).

If no repository exists yet, point the user to [sk-repo-creator](../sk-repo-creator/SKILL.md) (the create stage) and stop. sk-repo-creator also offers to hand off here once it finishes — a convenience, not the only entry.

## Companions

Load [sk-branch-creator](../sk-branch-creator/SKILL.md) for the branch this stage lands; if it is absent, follow the conventions below without blocking. Do not load [sk-commit-creator](../sk-commit-creator/SKILL.md) for the commits: their messages are fixed copy in `references/applying-selection.md`, so there is nothing for it to author.

## Feature selection

Every menu this skill asks lives in `references/menus.md` — present each as written there.

Present the **Features** menu — **one `AskUserQuestion` call with up to two `multiSelect` questions**; the `questions` array renders as tabs in a single interaction (never split into separate calls, never ask one feature at a time).

## License template

Only when `LICENSE` is selected. Present the **License** menu.

Write the chosen template to `./LICENSE` (extensionless), substituting `{{YEAR}}` → the current year (`date +%Y`). The copyright holder is already filled in (`Seon Kuraito`, a personal-fit constant). The per-license shape differs:

- **MIT / Apache-2.0 / Proprietary** carry a `Copyright {{YEAR}} Seon Kuraito` line — substitute `{{YEAR}}`.
- **GPL-3.0** ships **verbatim**: the FSF requires the license document be unchanged, and the project's own year/author live in per-file header notices, not the `LICENSE` file — so there is no `{{YEAR}}` to substitute.

## Deploy branch

Only when **deploy branch** is selected. Present the **Deploy branch** menu.

A project runs one branching model, so pick exactly one (like the license template). They are personal-fit names, not textbook git-flow / gitlab-flow.

Create the chosen branch **from `main` and push it to `origin`** — the single shared rule for these branches, kept identical in [sk-project-deployer](../sk-project-deployer/SKILL.md) (which create-if-absent's the same way at deploy time). This skill only *creates* the branch — it sets no protection and manages no merge / lifecycle (out of scope). A GitHub-side effect that needs the remote; it makes no commit.

## Existing labels

Only when **GitHub labels** is selected. List the repo's labels first (read-only — see `references/applying-selection.md`). With none, create the type labels without asking. With any — a GitHub default or a label that was already there, never told apart — present the **Existing labels** menu.

## Applying the selection

How each selected option is carried out — the full `gh`-command procedure (commands, ruleset pre-flight / verify, and the solo-repo gotchas) lives in [`references/applying-selection.md`](references/applying-selection.md); read it before running any of these:

- **File options** (`LICENSE`, `.claude/CLAUDE.md`) land as their own fixed-message commits on a dedicated `chore/initial-project-setup` branch.
- **GitHub labels, branch protection, and the deploy branch** are GitHub-side effects with no commit — each needs a remote (skip on a local-only repo; branch protection on GitHub Free also needs a public repo).

## Wrap up — open a PR

The file commits land on `chore/initial-project-setup`, which always needs a PR to reach `main`. After the commits, ask the user whether to open one now:

- **Yes** → hand to [sk-pr-creator](../sk-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

If only side-effect options were selected (GitHub labels, branch protection, and/or deploy branch), there is no branch or commit — skip this step.

## Hand-off to the deploy stage

Only when the **deploy branch** option was selected — that branch exists precisely to be deployed from. After the wrap-up, present the **Next step** menu.

- **進入部署階段** → load [sk-project-deployer](../sk-project-deployer/SKILL.md) if available; if it is not present, say so and stop.
- **不進入** → stop here and leave the next move to the user.

Never auto-enter it — always the user's choice (the same shape as sk-repo-creator's hand-off into this stage).

## Execution gate

Before any command that writes to the remote or repo settings (`gh label …`, the ruleset `gh api --method POST`, `git push`), stop at an execution gate, show the exact commands, and wait for an explicit go. The selected features run one at a time, each through its own gate.

## Related

- [sk-repo-creator](../sk-repo-creator/SKILL.md) — the **create** stage (git init / remote) this stage follows.
- [sk-branch-creator](../sk-branch-creator/SKILL.md) — the branch this stage lands.
- [sk-commit-creator](../sk-commit-creator/SKILL.md) — the convention the fixed commit messages follow; this stage does not load it.
- `sk-project-deployer` — the **deploy** stage; like this one, an insertable, project-level stage.
