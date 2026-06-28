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

Present every `AskUserQuestion` menu in this skill (and its references) exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (field labels, the `[Rule, not copy]` line) is English direction, never shown.

```
single-select · header: 「部署平台」
question: 「要部署到哪一個平台？」
options:
  · 「GitHub Pages」 — 「已實作，可部署為 GitHub Pages 網站。」
  · 「Vercel」 — 「規劃中，尚未實作。」
  · 「Cloudflare Pages」 — 「規劃中，尚未實作。」
[Rule, not copy] for a planned platform, say it is not yet supported and stop. Each platform has its own flow and its own branch named `ci/deploy-<platform>` (e.g. `ci/deploy-github-pages`, `ci/deploy-vercel`).
```

## GitHub Pages

Deploy via **GitHub Actions** (the modern Pages publishing source). First settle the **deploy branch** (see *Choose the deploy branch*), then follow `references/github-pages.md` for the full flow — choosing the build type (static / Vite SPA), the bundled workflow templates and their action versions, enabling Pages, allowing a non-`main` deploy branch in the `github-pages` environment, the Vite caveat, and the fixed commit `ci: add github pages deploy workflow` on `ci/deploy-github-pages`.

## Choose the deploy branch

Present this menu verbatim — but **first read the repo's branches** (`git branch --list develop preparing` plus `git ls-remote --heads origin develop preparing`) and build the option set from what actually exists, not a fixed list:

```
single-select · header: 「選擇部署分支」
question: 「要使用哪一條部署分支？」
options:
  · 「main」 — 「推送到 main 時即進行部署，維持最簡單的原本行為。」
  · 「develop」 — 「整合分支（integration branch）。」
  · 「preparing」 — 「測試環境分支（testing environment branch）。」
  · 「custom」 — 「使用其他任一分支，若不存在則從 main 開出並推送。」
[Rule, not copy] `main` is always offered. Include `develop` / `preparing` each only if it already exists (created by ultra-project-initializer's deploy-branch option) — typically just one is present, presented by what it is, not by a flow label. For `custom`, ask for the name and, if it does not exist, create it from `main` and push it (proceed conversationally, the same shape as ultra-repo-creator's `framework` option).
```

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

**Render framed.** Wrap this gate in a `---` rule above and below, each padded by a full-width `　` spacer on its inner side (facing the gate) — with a blank line between every line, so `　` + `---` never parses as a setext heading.

- **Triggers on** — any command that writes to the remote or the repo's settings: `gh api .../pages`, `git push`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold the steps into one uninterrupted run.

## References

- `references/github-pages.md` — the full GitHub Pages flow: build types, workflow templates, action versions, enabling Pages, the Vite caveat, and the version choices. Each future platform gets its own `references/<platform>.md`.

## Related

- [ultra-project-initializer](../ultra-project-initializer/SKILL.md) — the **initialize** stage; this is its deploy counterpart, the same insertable, project-level shape.
- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage, needed before a remote exists.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — branch, commit, and PR hand-offs.
