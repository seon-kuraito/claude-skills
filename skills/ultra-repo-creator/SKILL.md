---
name: ultra-repo-creator
description: Bootstraps a new repository end to end — local git init, remote creation on GitHub, and branch protection. Use whenever creating or setting up a repo is in play — starting a new project, initializing version control, turning a folder into a git repo, creating a GitHub remote, or a directory that has files but isn't yet a git repo — regardless of exact wording or language. Lean toward consulting it the moment repo creation or first-time setup comes up.
---

# Ultra Repo Creator

Bootstrap a new repository in three composable phases — **local init → remote → branch protection**. Enter at whichever phase fits and skip what's already done (e.g. the repo already exists and only needs protection).

This skill orchestrates; it hands off to [ultra-branch-creator](../ultra-branch-creator/SKILL.md), [ultra-commit-creator](../ultra-commit-creator/SKILL.md), and [ultra-pr-creator](../ultra-pr-creator/SKILL.md) for the work that lands after the repo exists.

## Execution gate

Before running **any** command that creates a repo, pushes, or changes repo settings (`gh repo create`, `git push`, ruleset `POST` / `PUT` / `DELETE`), stop and show the user exactly what will run — including behavior-affecting flags like visibility and `--delete-branch` — and wait for explicit confirmation. Never chain phases into one uninterrupted run.

## Phase 1 — Local init

The convention for a brand-new project:

1. **Guard first.** If the working directory already has files but is *not* a git repo, flag it before writing anything more — don't wait for the user to notice.
2. `git init` and write a `.gitignore`.
3. The **initial commit contains only a blank `README.md`** (an empty file).
4. **Existing work stays in the working tree, untracked**, until the user binds a remote (Phase 2).
5. Do **not** bundle existing files into the initial commit unless the user explicitly asks.

After the remote is bound, organize the working-tree work into commits / branches — that is where ultra-branch-creator / ultra-commit-creator / ultra-pr-creator take over.

## Phase 2 — Remote creation

1. **Default to public.** On GitHub Free, branch protection (Phase 3) works only on public repos — a private repo returns `403 Upgrade to Pro`. A repo that wants protection must therefore be public from the start; choose private only when skipping Phase 3 (or on Pro / Team / Enterprise). Confirm visibility with the user.
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

## Phase 3 — Branch protection

Apply the standard ruleset to the default branch so `main` requires a PR to merge and blocks deletion + force-push.

> **Precondition (GitHub Free):** rulesets apply only to **public** repos — a private repo returns `403 Upgrade to Pro`. Make the repo public in Phase 2 first (or use Pro / Team / Enterprise).

**Pre-flight (read-only):**

```sh
gh auth status                                          # logged in + repo admin scope
gh api /repos/<owner>/<repo>/rulesets --jq '.[].name'   # avoid duplicating a ruleset
```

**Apply** (after the Execution gate). The config is bundled at `assets/main-protection-ruleset.json` in this skill's directory; owner / repo live in the URL, so the file is reused verbatim for any repo:

```sh
gh api --method POST -H "Accept: application/vnd.github+json" \
  /repos/<owner>/<repo>/rulesets \
  --input <skill-dir>/assets/main-protection-ruleset.json
```

**Verify:**

```sh
gh api /repos/<owner>/<repo>/rules/branches/main --jq '[.[].type]'
# expect: ["deletion","non_fast_forward","pull_request"]
```

### Protection gotchas

- **Solo repo → `required_approving_review_count` must be 0.** You cannot approve your own PR; any higher count deadlocks every PR. The bundled config uses 0 — raise it only for a collaborative repo.
- **No admin bypass by default.** Rulesets ship with an empty bypass list, so the owner is also forced through PRs on `main` — that is the intent.
- **`~DEFAULT_BRANCH`** tracks whichever branch is default, so renaming the default branch never breaks the rule.
- Optional config-as-code: `gh api /repos/<owner>/<repo>/rulesets/<id> > main-protection.json` to commit the ruleset for reuse.

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — organizing the work that lands after the repo exists.
