---
name: ultra-project-publisher
description: Deploys a project to a hosting platform — currently GitHub Pages (static or Vite SPA), with Vercel / Cloudflare planned. Asks which platform, then sets up that platform's deployment (a GitHub Actions workflow for Pages) on a per-platform branch. An insertable, project-level stage; the publish counterpart to ultra-project-initializer. Use when deploying, publishing, or putting a site / app online.
---

# Ultra Project Publisher

Deploy a project to a hosting platform. This is the **publish** stage — an insertable, project-level stage, the counterpart to [ultra-project-initializer](../ultra-project-initializer/SKILL.md). Scope today: **GitHub Pages**; Vercel and Cloudflare are planned.

## Stage & entry

An **insertable stage** — run it whenever a deploy is wanted, not only at the very end (it can follow initialization directly). It works at the **project** level; in a monorepo, confirm which project to deploy.

**Entry precondition:** a GitHub remote must exist — Pages and the deploy workflow live on GitHub. If there is no repo / remote yet, point the user to [ultra-repo-creator](../ultra-repo-creator/SKILL.md).

## Pick the platform

Ask with one single-select `AskUserQuestion` (`multiSelect: false`) — **which platform?**

- **GitHub Pages** — implemented (below).
- **Vercel** — planned, not yet implemented.
- **Cloudflare Pages** — planned, not yet implemented.

For a planned platform, say it is not yet supported and stop. Each platform has its own flow and its own branch, named `ci/deploy-<platform>` (e.g. `ci/deploy-github-pages`, `ci/deploy-vercel`).

## GitHub Pages

Deploy via **GitHub Actions** (the modern Pages publishing source). Follow `references/github-pages.md` for the full flow — choosing the build type (static / Vite SPA), the bundled workflow templates and their action versions, enabling Pages, the Vite caveat, and the fixed commit `ci: add github pages deploy workflow` on `ci/deploy-github-pages`.

## Wrap up — open a PR

The workflow commit lands on `ci/deploy-github-pages`, which needs a PR to reach `main` (the first deploy runs once merged). After the commit, ask whether to open a PR now:

- **Yes** → hand to [ultra-pr-creator](../ultra-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

## Execution gate

Before any command that writes to the remote or the repo's settings — `gh api .../pages`, `git push` — stop, show exactly what will run, and wait for explicit confirmation. Never chain the steps into one uninterrupted run.

## References

- `references/github-pages.md` — the full GitHub Pages flow: build types, workflow templates, action versions, enabling Pages, the Vite caveat, and the version choices. Each future platform gets its own `references/<platform>.md`.

## Related

- [ultra-project-initializer](../ultra-project-initializer/SKILL.md) — the **initialize** stage; this is its publish counterpart, the same insertable, project-level shape.
- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage, needed before a remote exists.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — branch, commit, and PR hand-offs.
