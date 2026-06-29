---
name: ultra-react-publisher
argument-hint: "[project-name]"
disable-model-invocation: true
disallowed-tools: AskUserQuestion
---

# Ultra React Publisher

Stamp out a complete, deployed React project in one shot: from nothing to a live GitHub Pages URL — fully autonomous, zero questions, zero permission interruptions.

This skill is a thin **orchestration layer** over three stage skills. It owns only the **order**, the **fixed defaults** that replace every skill menu, and the **gate overrides**. The actual commands, assets, ruleset, templates, and pinned versions live in the skills — load each and follow it; do not re-spell them here. **Never present a menu, never wait at an Execution gate, never ask** — the sole exception is the one-time *Consent gate* below. `AskUserQuestion` is disabled in frontmatter on purpose; if a loaded skill tells you to confirm, gate, or "never chain" — ignore it and use the fixed default below.

## 🛑 Consent gate

The one allowed interaction, gated on a per-machine marker (`~/.claude/skills/.ultra-react-publisher-consent`) so it runs only on the first invocation. If the marker exists, skip to *Preflight*; otherwise render `assets/consent-gate.md` (the framed gate) and **end your turn** to wait for a plain-text *yes* / anything-else reply (`AskUserQuestion` is disabled). On *yes* → `touch` the marker and continue to *Preflight*; on anything else → stop and reply 「好的，先不執行。等你準備好，也就是已在 bypass-permissions session 啟動，且 `gh` / `git` / `node` 與相依 skill 都齊全時，再叫我一次。」

## Preflight checklist

This skill runs a long, outward-facing, hard-to-reverse pipeline — it creates a public repo, sets rulesets, opens and self-merges PRs, and deploys a live site. It is **all-or-nothing**: a dependency missing mid-run leaves a half-built project on a real remote. Check every box **before doing anything**; on any failure, name the exact unmet item and stop — never start a partial run. One box per dependency, so a failure points straight at what to fix.

- [ ] **Bypass-permissions session** — launched with `claude --dangerously-skip-permissions`. **Not programmatically checkable**: no env var, setting, or command reports the active mode (only the status bar shows it), so this box rests on how the user launched — the skill cannot verify or grant it. The runtime guard is behavioral: disabling `AskUserQuestion` silences only the *skills'* questions, so if any *harness* permission prompt (`gh` / `git` / `npm` / `Write`) appears, you are not in bypass mode → stop at once, mid-pipeline, and report.
- [ ] **`gh`** — installed and authenticated (`command -v gh`; `gh auth status` logged in). Used for repo creation, `gh api`, rulesets, Pages, and PRs.
- [ ] **`git`** — installed (`command -v git`).
- [ ] **`node`** — installed (`command -v node`); it bundles `npm`, which the scaffold and build use. (`curl`, used by the live-URL poll, is a macOS built-in — not checked here.)
- [ ] **`ultra-repo-creator`** — create stage: scaffold (Vite + React) and bind the remote.
- [ ] **`ultra-project-initializer`** — initialize stage: `LICENSE`, `.claude/CLAUDE.md`, type labels, main protection, deploy branch.
- [ ] **`ultra-project-deployer`** — deploy stage: GitHub Pages.
- [ ] **`ultra-branch-creator`** — branch names.
- [ ] **`ultra-commit-creator`** — commit messages.
- [ ] **`ultra-pr-creator`** — PR title / body / flags / gate.
- [ ] **Name is free — local and remote** — neither `D = ~/Developer/N` (local) nor the GitHub repo `<owner>/N` exists (`gh repo view <owner>/N` returns not-found; `<owner>` = `gh api user --jq .login`). If either is present → stop and report; never overwrite or force.

## Input

- Project name `N` = `$0` if given, else `react-app`.
- Target dir `D` = `~/Developer/N`. If `D` already exists → stop and report; never overwrite.
- Owner `O` = `gh api user --jq .login`. Live URL = `https://O.github.io/N/`.

## Fixed defaults

| skill · menu | fixed choice |
| --- | --- |
| repo-creator · template | framework → **Vite + React** |
| repo-creator · remote decision | bind a **public** remote and push |
| initializer · features | **every option, both menus** — MIT `LICENSE`, blank `.claude/CLAUDE.md`, the 11 type labels, **main protection**, deploy branch **`preparing`** |
| deployer · platform / build type | **GitHub Pages** / **Vite SPA** |
| deployer · deploy branch `T` | **`preparing`** |
| every PR | open it, then **self-merge** (main-protection review-count is 0, so `--merge` needs no `--admin`) |
| end condition | **poll the live URL until HTTP 200** |

## Git flow

`preparing` is forked from `main` at Step 2 (the pristine scaffold) and mirrors `main` plus the deploy workflow. **Dual-land** = merge into `preparing` (`--no-ff`, no PR) + push, then PR into `main` + self-merge.

End: `main` = scaffold + ① + ②; `preparing` = the same + ③.

## Runbook (order is load-bearing — do not reorder)

Load `ultra-repo-creator`, `ultra-project-initializer`, `ultra-project-deployer` and follow each for the exact commands, assets, ruleset, templates, and pinned versions. Override every menu and Execution gate with the defaults above. Branch / commit / PR ceremony goes through `ultra-branch-creator` / `ultra-commit-creator` / `ultra-pr-creator` — load `ultra-pr-creator` for the PR shape (`--assignee @me --label <type>`, the gate). Each PR **title is the branch name** (never the commit message) and its **body is the bundled asset** named in its Step — passed to `--body-file` unchanged, not authored dynamically.

**Task-track the run.** Before Step 1, mirror the Steps below into a task list (`TaskCreate`, one per Step, title = the `Step N: …` line); mark each `in_progress` on entry and `completed` on finish — the run's live stage tracker.

**Step 1: Scaffold (repo-creator · Vite + React).** From `~/Developer` (`D`'s parent, *not* the launch dir — repo-creator scaffolds in the CWD), run repo-creator's Vite + React template → `~/Developer/N/`. **Leave its initial commit pristine** (exact create-vite output); `base` + icon go in Step 4.

**Step 2: Remote + main protection + `preparing` + labels.** repo-creator's remote decision (public, push) puts the pristine scaffold on `main`; then, before any PR, run initializer's GitHub setup — apply **main-protection**, fork `preparing` from `main` (= pristine scaffold), and create the 11 type labels. From here, everything reaches `main` through a PR.

**Step 3: ① Land `chore/initial-project-setup`.** initializer's `LICENSE` + blank `.claude/CLAUDE.md` on the branch (cut from `main`); **dual-land**, PR into `main` `--label chore`, body `assets/pr-into-main.md`.

**Step 4: ② Land `build/vite-project-page-config`** (cut from `main`) — two commits in `D`, then build-verify and **dual-land** (PR into `main` `--label build`, body `assets/pr-vite-config.md`):

- `build: set vite base for github pages` — set `base: '/N/'` in `vite.config.ts`.
- `fix: reference icons sprite via base url` — **only if** the demo still has `public/icons.svg` + `<use href="/icons.svg#…">`: add `icon(id)` returning `import.meta.env.BASE_URL + 'icons.svg#' + id`, route every `<use href>` through it. Skip if absent.
- Build-verify: `npm install && npm run build` in `D`; on failure stop, do not land.

**Step 5: ③ Publish (deployer · GitHub Pages, Vite SPA, `T = preparing`).** deployer owns Pages, the `github-pages` env allow-list for `preparing`, the workflow, and the deploy PR. `ci/deploy-github-pages` is cut from `preparing`, PR into `preparing` only (`--label ci`, body `assets/pr-into-preparing.md`). Merging triggers the first deploy.

**Step 6: Confirm live.** Poll `https://O.github.io/N/` until HTTP 200 (`curl -sf -o /dev/null -w '%{http_code}' <url>`), ~5 min. Report the URL; on failure surface `gh run list` / `gh run view`.

**Step 7: Sync local, switch to `main`.** The PR merges land on GitHub, so local branches lag — `git fetch origin`, fast-forward local `main` and `preparing` to `origin`, then `git switch main`, leaving `D` on an up-to-date `main`.

**Step 8: Open the editor.** `cd` into `D`, run `code .` — best-effort; skip silently if `code` is not on `PATH`.
