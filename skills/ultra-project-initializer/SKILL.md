---
name: ultra-project-initializer
description: Initializes a project's working setup after its repo exists — adds a LICENSE, a blank .claude/CLAUDE.md, the Conventional Commits type labels on GitHub, optional main branch protection, and an optional deploy branch (develop / preparing) for ultra-project-publisher. The initialize stage ultra-repo-creator hands off to once the repo is created; also use it directly to add any of these to an existing project. An insertable, project-level stage (a repo may hold several projects). Not git init / remote — that is ultra-repo-creator.
---

# Ultra Project Initializer

Initialize a project's working setup once its repository exists — a `LICENSE`, a blank `.claude/CLAUDE.md`, the Conventional Commits type labels on GitHub, and optional `main` branch protection. This is the **initialize** stage that pairs with [ultra-repo-creator](../ultra-repo-creator/SKILL.md)'s **create** stage.

## Stage & entry

An **insertable stage**, not a fixed step in a pipeline — run it whenever the need arises (usually right after the repo is created, but any time is fine). It works at the **project** level, and a single repo may hold several projects (a monorepo); when that applies, confirm which project before acting.

**Entry precondition — a repository must already exist:**

- the `LICENSE` and `.claude/CLAUDE.md` files need a local repo (`git init` done).
- the type labels and branch protection need a GitHub remote — and on GitHub Free, branch protection additionally needs the repo to be **public** (rulesets return `403` on a private repo).

If no repository exists yet, point the user to [ultra-repo-creator](../ultra-repo-creator/SKILL.md) (the create stage) and stop. ultra-repo-creator also offers to hand off here once it finishes — a convenience, not the only entry.

## Companions

Load [ultra-branch-creator](../ultra-branch-creator/SKILL.md) and [ultra-commit-creator](../ultra-commit-creator/SKILL.md) for the branch and commits this stage lands; if either is absent, follow the conventions below without blocking.

## Feature selection

Present the features as **one `AskUserQuestion` call with up to two `multiSelect` questions** — the `questions` array renders as tabs in a single interaction (never split into separate calls, never ask one feature at a time). Each question caps at 4 options, so the features split into two groups by whether they need the GitHub remote:

**Q1 — local files** (always shown):

- **`LICENSE`** — a root `LICENSE` from a bundled template (`assets/licenses/`). If selected, a follow-up single-select picks the template — see *License template*.
- **`.claude/CLAUDE.md`** — a blank `.claude/CLAUDE.md`.

**Q2 — GitHub / remote** — include **only when a remote exists** (check `git remote`, or the ultra-repo-creator hand-off state); on a local-only repo, omit this whole question, since every option here needs the remote:

- **GitHub labels** — replace the repo's default labels with the Conventional Commits type labels in `assets/type-labels.json`.
- **branch protection** — apply the standard ruleset to `main` (require a PR, block deletion + force-push) from `assets/main-protection-ruleset.json`. On GitHub Free also needs the repo to be **public**; see *Applying the selection*.
- **deploy branch** — create a deploy branch (`develop` or `preparing`) off `main` for [ultra-project-publisher](../ultra-project-publisher/SKILL.md) to deploy from. If selected, a follow-up single-select picks which — see *Deploy branch*.

If nothing is selected across both questions, stop.

## License template

Only when `LICENSE` is selected. Present a **second** `AskUserQuestion` (single-select) over the bundled templates in `assets/licenses/` — **MIT** (the personal-fit default), **Apache-2.0**, **GPL-3.0** — plus the auto-provided *Other* for anything else (e.g. BSD-3-Clause), which you fetch verbatim from a canonical source (GitHub's `/licenses/<key>` API) rather than typing from memory.

Write the chosen template to `./LICENSE` (extensionless), substituting `{{YEAR}}` → the current year (`date +%Y`). The copyright holder is already filled in (`Seon Kuraito`, a personal-fit constant). The per-license shape differs:

- **MIT / Apache-2.0** carry a `Copyright {{YEAR}} Seon Kuraito` line — substitute `{{YEAR}}`.
- **GPL-3.0** ships **verbatim**: the FSF requires the license document be unchanged, and the project's own year/author live in per-file header notices, not the `LICENSE` file — so there is no `{{YEAR}}` to substitute.

## Deploy branch

Only when **deploy branch** is selected. Present a **second** single-select `AskUserQuestion` over the two names — **`develop`** (an integration branch) / **`preparing`** (a pre-release branch). A project runs one branching model, so pick exactly one (like the license template). They are personal-fit names, not textbook git-flow / gitlab-flow.

Create the chosen branch **from `main` and push it to `origin`** — the single shared rule for these branches, kept identical in [ultra-project-publisher](../ultra-project-publisher/SKILL.md) (which create-if-absent's the same way at deploy time). This skill only *creates* the branch — it sets no protection and manages no merge / lifecycle (out of scope). A GitHub-side effect that needs the remote; it makes no commit.

The file options land on a dedicated branch; the labels, branch-protection, and deploy-branch options are GitHub-side effects with no commit (the deploy branch forks from `main`, so it carries no new commit of its own).

1. **File options** (`LICENSE`, `.claude/CLAUDE.md`) — if any is selected, create the branch `chore/initial-project-setup` (hand to ultra-branch-creator), then apply each selected one as its own commit, using these **fixed messages verbatim** (they do *not* go through ultra-commit-creator):
   - `LICENSE` → `chore: add <license> LICENSE` (the chosen id, e.g. `chore: add MIT LICENSE`)
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
4. **Deploy branch** — create the chosen branch (`develop` / `preparing`) from `main` and push it to `origin` (see *Deploy branch*). A GitHub side-effect: needs a remote to push to, makes no commit. If the repo is local-only, explain and skip this item.

   ```sh
   git branch <name> main      # fork from main
   git push -u origin <name>   # publish so the publisher can deploy from it
   ```

## Wrap up — open a PR

The file commits land on `chore/initial-project-setup`, which always needs a PR to reach `main`. After the commits, ask the user whether to open one now:

- **Yes** → hand to [ultra-pr-creator](../ultra-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

If only side-effect options were selected (GitHub labels, branch protection, and/or deploy branch), there is no branch or commit — skip this step.

## Hand-off to the publish stage

Only when the **deploy branch** option was selected — that branch exists precisely to be deployed from. After the wrap-up, ask whether to continue into the publish stage with `AskUserQuestion` (*enter the publish stage now?*):

- **Yes** → load [ultra-project-publisher](../ultra-project-publisher/SKILL.md) if available; if it is not present, say so and stop.
- **No** → stop here and leave the next move to the user.

Never auto-enter it — always the user's choice (the same shape as ultra-repo-creator's hand-off into this stage).

## 🚧 Execution gate

- **Triggers on** — any command that writes to the remote or the repo's settings: `gh label delete`, `gh label create`, the ruleset `gh api --method POST`, `git push`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold the whole selection into one uninterrupted run.

## Related

- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage (git init / remote) this stage follows.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commits this stage lands.
- `ultra-project-publisher` (planned) — a future **publish** stage; like this one, an insertable, project-level stage.
