---
name: ultra-project-initializer
description: Initializes a project's working setup after its repo exists — adds a root .gitignore, a blank .claude/CLAUDE.md, the Conventional Commits type labels on GitHub, and optional main branch protection. The initialize stage ultra-repo-creator hands off to once the repo is created; also use it directly to add any of these to an existing project. An insertable, project-level stage (a repo may hold several projects). Not git init / remote — that is ultra-repo-creator.
---

# Ultra Project Initializer

Initialize a project's working setup once its repository exists — a root `.gitignore`, a blank `.claude/CLAUDE.md`, the Conventional Commits type labels on GitHub, and optional `main` branch protection. This is the **initialize** stage that pairs with [ultra-repo-creator](../ultra-repo-creator/SKILL.md)'s **create** stage.

## Stage & entry

An **insertable stage**, not a fixed step in a pipeline — run it whenever the need arises (usually right after the repo is created, but any time is fine). It works at the **project** level, and a single repo may hold several projects (a monorepo); when that applies, confirm which project before acting.

**Entry precondition — a repository must already exist:**

- `.gitignore` and `.claude/CLAUDE.md` need a local repo (`git init` done).
- the type labels and branch protection need a GitHub remote — and on GitHub Free, branch protection additionally needs the repo to be **public** (rulesets return `403` on a private repo).

If no repository exists yet, point the user to [ultra-repo-creator](../ultra-repo-creator/SKILL.md) (the create stage) and stop. ultra-repo-creator also offers to hand off here once it finishes — a convenience, not the only entry.

## Companions

Load [ultra-branch-creator](../ultra-branch-creator/SKILL.md) and [ultra-commit-creator](../ultra-commit-creator/SKILL.md) for the branch and commits this stage lands; if either is absent, follow the conventions below without blocking.

## Feature selection

Always present the choice as one `AskUserQuestion` call with `multiSelect: true` — never ask in prose, and never one feature at a time. A single question (e.g. "Which items to set up?") whose options are the four features below; the user picks any combination (or none):

- **`.gitignore`** — a root `.gitignore` from `assets/gitignore-template` (macOS + editor/IDE + log artifacts).
- **`.claude/CLAUDE.md`** — a blank `.claude/CLAUDE.md`.
- **GitHub labels** — replace the repo's default labels with the Conventional Commits type labels in `assets/type-labels.json`.
- **branch protection** — apply the standard ruleset to `main` (require a PR, block deletion + force-push) from `assets/main-protection-ruleset.json`. Needs a public GitHub remote; see *Applying the selection*.

If nothing is selected, stop.

## Applying the selection

The file options land on a dedicated branch; the labels and branch-protection options are GitHub-side effects with no commit.

1. **File options** (`.gitignore`, `.claude/CLAUDE.md`) — if any is selected, create the branch `chore/initial-project-setup` (hand to ultra-branch-creator), then apply each selected one as its own commit, using these **fixed messages verbatim** (they do *not* go through ultra-commit-creator):
   - `.gitignore` → `chore: add gitignore for macOS and editor artifacts`
   - `.claude/CLAUDE.md` → `chore: add CLAUDE.md`
2. **GitHub labels** — make the repo's labels *exactly* the type set, in two steps:
   - **Delete the defaults first.** A new GitHub repo ships nine default labels — `bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`. Remove each that is present with `gh label delete <name> --yes`. Touch only these defaults — leave any custom labels alone.
   - **Then create the types.** For each entry in `assets/type-labels.json`, run `gh label create <name> --color <color> --description <description>` (each entry carries `name`, `color`, and `description`); pass `--force` to overwrite a same-named label. This makes no commit.
3. **Branch protection** — apply the standard ruleset to the default branch so `main` requires a PR to merge and blocks deletion + force-push. A GitHub side-effect, no commit.
   - **Precondition (GitHub Free):** rulesets apply only to a **public** repo — a private repo returns `403 Upgrade to Pro`. If the repo has no remote or is private (and not on Pro / Team / Enterprise), explain that and **skip this item** rather than erroring.
   - **Pre-flight (read-only):**

     ```sh
     gh auth status                                          # logged in + repo admin scope
     gh api /repos/<owner>/<repo>/rulesets --jq '.[].name'   # avoid duplicating a ruleset
     ```

   - **Apply** (after the Execution gate). `owner` / `repo` live in the URL, so `assets/main-protection-ruleset.json` is reused verbatim for any repo:

     ```sh
     gh api --method POST -H "Accept: application/vnd.github+json" \
       /repos/<owner>/<repo>/rulesets \
       --input <skill-dir>/assets/main-protection-ruleset.json
     ```

   - **Verify:**

     ```sh
     gh api /repos/<owner>/<repo>/rules/branches/main --jq '[.[].type]'
     # expect: ["deletion","non_fast_forward","pull_request"]
     ```

   - **Gotchas:**
     - **Solo repo → `required_approving_review_count` must be 0.** You cannot approve your own PR; any higher count deadlocks every PR. The bundled config uses 0 — raise it only for a collaborative repo.
     - **No admin bypass by default.** Rulesets ship with an empty bypass list, so the owner is also forced through PRs on `main` — that is the intent.
     - **`~DEFAULT_BRANCH`** tracks whichever branch is default, so renaming the default branch never breaks the rule.

## Wrap up — open a PR

The file commits land on `chore/initial-project-setup`, which always needs a PR to reach `main`. After the commits, ask the user whether to open one now:

- **Yes** → hand to [ultra-pr-creator](../ultra-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

If only side-effect options were selected (GitHub labels and/or branch protection), there is no branch or commit — skip this step.

## Execution gate

Before any command that writes to the remote or the repo's settings — `gh label delete`, `gh label create`, the ruleset `gh api --method POST`, `git push` — stop, show exactly what will run, and wait for explicit confirmation. Never chain the whole selection into one uninterrupted run.

## Related

- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage (git init / remote) this stage follows.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commits this stage lands.
- `ultra-project-publisher` (planned) — a future **publish** stage; like this one, an insertable, project-level stage.
