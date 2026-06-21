---
name: ultra-repo-creator
description: Bootstraps a new repository end to end — local git init and public remote creation on GitHub. Use whenever creating or setting up a repo is in play — starting a new project, initializing version control, turning a folder into a git repo, creating a GitHub remote, or a directory that has files but isn't yet a git repo — regardless of exact wording or language. Lean toward consulting it the moment repo creation or first-time setup comes up.
---

# Ultra Repo Creator

Bootstrap a new repository in two composable phases — **local init → remote**. This is the **create** stage of a two-stage project setup; once both phases are done the repo is built, and the **initialize** stage (a separate skill) takes over the optional scaffolding — including branch protection — see *Hand-off*. Enter at whichever phase fits and skip what's already done.

This skill covers only init and remote. The follow-up once the repo exists — organizing the working tree into commits / branches / PRs — is handled separately by [ultra-branch-creator](../ultra-branch-creator/SKILL.md), [ultra-commit-creator](../ultra-commit-creator/SKILL.md), and [ultra-pr-creator](../ultra-pr-creator/SKILL.md).

## Stages & routing

Project setup runs in two stages:

- **Create** (this skill) — local `git init` and a public GitHub remote.
- **Initialize** (a separate skill, e.g. `ultra-project-initializer`) — optional scaffolding once the repo exists: `.gitignore`, a blank `.claude/CLAUDE.md`, GitHub labels, and branch protection.

Start by detecting how far the create stage has progressed, then route:

- **`git init`** — does a `.git` directory exist?
- **remote** — is a GitHub remote bound? (`git remote`)

Routing from the two signals:

- **Both done** → the create stage is complete; don't redo it — go to *Hand-off*.
- **Neither done (brand-new)** → run Phases 1–2 in one pass.
- **Partially done** → run only the missing phase.

Detection is best-effort; when a signal is ambiguous, ask the user instead of guessing.

## Execution gate

Before running **any** command that creates a repo or pushes (`gh repo create`, `git push`), stop and show the user exactly what will run — including behavior-affecting flags like `--delete-branch` — and wait for explicit confirmation. Never chain phases into one uninterrupted run.

## Phase 1 — Local init

The convention for a brand-new project:

1. **Guard first.** If the working directory already has files but is *not* a git repo, flag it before writing anything more — don't wait for the user to notice.
2. `git init`.
3. The **initial commit contains only a blank `README.md`** (an empty file), committed with the fixed message `chore: initialize repository`. This bootstrap commit uses that message verbatim — it does not go through ultra-commit-creator.
4. **Existing work stays in the working tree, untracked**, until the user binds a remote (Phase 2).
5. Do **not** bundle existing files into the initial commit unless the user explicitly asks.

`.gitignore` is **not** written here — it moved to the initialize stage as an opt-in (see *Hand-off*). After the remote is bound, organize the working-tree work into commits / branches — that is where ultra-branch-creator / ultra-commit-creator / ultra-pr-creator take over.

## Phase 2 — Remote creation

1. **Always public.** This skill creates **public** repos and does not ask about visibility — a deliberate personal-fit default (create a private repo by hand if ever needed). Public is also what lets the later branch-protection option (now in the initialize stage) work on GitHub Free, where rulesets need a public repo.
2. **Ensure the branch is `main` before pushing** — `git init` may have left the repo on `master`:

   ```sh
   git branch -M main
   ```

3. Create and bind in one step (after the Execution gate):

   ```sh
   gh repo create <name> --public --source . --remote origin --push
   ```

   This creates the repo, binds it as `origin`, and pushes the blank-README initial commit to `main`.
4. If `gh` is unavailable or unauthenticated, fall back to creating the repo in the web UI, then run GitHub's canonical push snippet:

   ```sh
   git remote add origin <url>
   git branch -M main
   git push -u origin main
   ```

## Hand-off to the initialize stage

Once the remote is bound (Phase 2), the create stage is complete. Ask whether to continue into the **initialize** stage with `AskUserQuestion` (*enter the initialize stage now?*):

- **Yes** → load the initialization skill (e.g. `ultra-project-initializer`) if it is available; if it is not present, say so and stop.
- **No** → stop here and leave the next move to the user.

The initialize stage is where the optional scaffolding lives — `.gitignore`, a blank `.claude/CLAUDE.md`, GitHub labels, and **branch protection** (moved here from this skill). Never auto-enter it — it is always the user's choice. (That skill, in turn, confirms the create stage is done before it begins.)

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — organizing the work that lands after the repo exists.
