---
name: ultra-project-deployer
description: Deploys a project to a hosting platform — currently GitHub Pages (static or Vite SPA), with Vercel / Cloudflare planned. Asks which platform, then sets up that platform's deployment (a GitHub Actions workflow for Pages) on a per-platform branch. An insertable, project-level stage; the deploy counterpart to ultra-project-initializer. Use when deploying, publishing, or putting a site / app online.
---

# Ultra Project Deployer

Deploy a project to a hosting platform. This is the **deploy** stage — an insertable, project-level stage, the counterpart to [ultra-project-initializer](../ultra-project-initializer/SKILL.md). Scope today: **GitHub Pages**; Vercel and Cloudflare are planned.

## Stage & entry

An **insertable stage** — run it whenever a deploy is wanted, not only at the very end (it can follow initialization directly). It works at the **project** level; in a monorepo, confirm which project to deploy.

**Entry precondition:** a GitHub remote must exist — Pages and the deploy workflow live on GitHub. If there is no repo / remote yet, point the user to [ultra-repo-creator](../ultra-repo-creator/SKILL.md).

## Pick the platform

Every menu this skill asks lives in `references/menus.md` — present each as written there. Present the **Platform** menu.

## GitHub Pages

Deploy via **GitHub Actions** (the modern Pages publishing source). First settle the **deploy branch** (see *Choose the deploy branch*), then follow `references/github-pages.md` for the full flow — choosing the build type (static / Vite SPA), the bundled workflow templates and their action versions, enabling Pages, allowing a non-`main` deploy branch in the `github-pages` environment, the Vite caveat, and the fixed commit `ci: add github pages deploy workflow` on `ci/deploy-github-pages`.

## Choose the deploy branch

Present the **Deploy branch** menu — but **first read the repo's branches** (`git branch --list develop preparing` plus `git ls-remote --heads origin develop preparing`) and build the option set from what actually exists, not a fixed list.

The chosen branch is the deploy target `T`, and everything keys off it uniformly — so `T = main` is exactly the original flow:

- The workflow triggers `on: push` to `T` — substitute `{{DEPLOY_BRANCH}}` → `T` when writing the template (see `references/github-pages.md`).
- `ci/deploy-github-pages` is cut **from `T`** (not from `main`), so its PR diff is only the workflow file.
- The setup PR merges **into `T`**; that merge is the first push to `T`, and it triggers the first deploy.

**Ensure `T` is on `origin`.** A menu-listed `develop` / `preparing` already exists; only a custom name might not — create it from `main` and push it before cutting `ci/deploy-github-pages`. `T = main` needs nothing. (Creating a deploy branch from `main` is the single shared rule, kept identical in [ultra-project-initializer](../ultra-project-initializer/SKILL.md).)

**Allow `T` in the `github-pages` environment** (when `T` ≠ `main`). Enabling Pages auto-creates a `github-pages` environment that defaults to deploying only the default branch — a non-`main` `T` is otherwise blocked with `Branch "<T>" is not allowed to deploy to github-pages`. The flow in `references/github-pages.md` adds `T` to that environment's deployment branch policy.

**Scope — branch only, no management.** This skill creates `T` only when you name a new branch via Custom; it sets no protection, no merge policy, no lifecycle. `T` is left unprotected, so a direct push deploys; `main` protection (if any) is ultra-project-initializer's concern and stays untouched.

## Wrap up — open a PR

The workflow commit lands on `ci/deploy-github-pages`, which needs a PR to reach the deploy branch `T` (the first deploy runs once merged). After the commit, ask whether to open a PR now:

- **Yes** → hand to [ultra-pr-creator](../ultra-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

## 🚧 Execution gate

Before any command that writes to the remote or repo settings (`gh api .../pages`, `git push`), render `assets/execution-gate.md` (the framed gate) and wait for confirmation.

## References

- `references/menus.md` — every menu this skill asks (platform, build type, deploy branch), with the menu contract at its top
- `references/github-pages.md` — the full GitHub Pages flow: build types, workflow templates, action versions, enabling Pages, the Vite caveat, and the version choices. Each future platform gets its own `references/<platform>.md`.

## Related

- [ultra-project-initializer](../ultra-project-initializer/SKILL.md) — the **initialize** stage; this is its deploy counterpart, the same insertable, project-level shape.
- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage, needed before a remote exists.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — branch, commit, and PR hand-offs.
