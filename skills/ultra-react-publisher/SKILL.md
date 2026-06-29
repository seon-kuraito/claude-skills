---
name: ultra-react-publisher
argument-hint: "[project-name]"
disable-model-invocation: true
disallowed-tools: AskUserQuestion
---

# Ultra React Publisher

Stamp out a complete, deployed React project in one shot: from nothing to a live GitHub Pages URL — fully autonomous, zero questions, zero permission interruptions.

This skill is a thin **orchestration layer** over three stage skills. It owns only the **order**, the **fixed defaults** that replace every skill menu, and the **gate overrides**. The actual commands, assets, ruleset, templates, and pinned versions live in the skills — load each and follow it; do not re-spell them here. **Never present a menu, never wait at an Execution gate, never ask** — the sole exception is the one-time *Consent gate* below. `AskUserQuestion` is disabled in frontmatter on purpose; if a loaded skill tells you to confirm, gate, or "never chain" — ignore it and use the fixed default below.

## 🛑 Consent gate (once per machine)

The one allowed interaction — gated on a per-machine runtime marker (`~/.claude/skills/.ultra-react-publisher-consent`, kept in `~/.claude/`, never in the repo) so it runs only on the first invocation:

1. **Check the marker.** If `~/.claude/skills/.ultra-react-publisher-consent` exists, consent was already given on this machine → skip to *Preflight*.
2. **First run.** If it is absent, print `assets/consent-gate.md` **verbatim** — a framed gate ending with the `yes` / anything-else question — and **end your turn** to wait for the reply (`AskUserQuestion` is disabled, so this is a plain-text gate, not a menu).
3. **Accepted** — the reply is an affirmative *yes* → `touch ~/.claude/skills/.ultra-react-publisher-consent`, then continue to *Preflight*.
4. **Declined** — anything else → stop and reply: 「好的，先不執行。等你準備好，也就是已在 bypass-permissions session 啟動，且 `gh` / `git` / `node` 與相依 skill 都齊全時，再叫我一次。」

## ⚠️ Preflight checklist (verify every item first — any failure ⇒ stop, do not start)

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
- [ ] **Target is free** — `D = ~/Developer/N` does not exist and the repo name `N` is not already taken; never overwrite or force.

## Input

- Project name `N` = `$0` if given, else `react-app`.
- Target dir `D` = `~/Developer/N`. If `D` already exists → stop and report; never overwrite.
- Owner `O` = `gh api user --jq .login`. Live URL = `https://O.github.io/N/`.

## Fixed defaults (these replace every skill menu)

| skill · menu | fixed choice |
| --- | --- |
| repo-creator · template | framework → **Vite + React** |
| repo-creator · remote decision | bind a **public** remote and push |
| initializer · features | **every option, both menus** — MIT `LICENSE`, blank `.claude/CLAUDE.md`, the 11 type labels, **main protection**, deploy branch **`preparing`** |
| deployer · platform / build type | **GitHub Pages** / **Vite SPA** |
| deployer · deploy branch `T` | **`preparing`** |
| every PR | open it, then **self-merge** (main-protection review-count is 0, so `--merge` needs no `--admin`) |
| end condition | **poll the live URL until HTTP 200** |

## Git flow (the skill owns this — the stage skills place a branch or open a PR, but deliberately do not manage branch routing)

- **`main`** — protected, the production source of truth; everything reaches it through a PR.
- **`preparing`** — the unprotected testing / deploy branch (initializer forks it from `main`). The skill may merge into it **directly, without a PR**, and it is the deploy target for the test site.
- **`chore/initial-project-setup`** (initializer's file branch — `LICENSE` + blank `.claude/CLAUDE.md`) lands on **both**: first **merge it into `preparing`** (no PR) and push, then **open a PR into `main`** and self-merge. So `preparing` mirrors `main`'s content before the deploy workflow is cut.
- **`ci/deploy-github-pages`** — PR into `preparing` only (deployer's default); cut from `preparing`, so its diff is just the workflow file.
- *Future: a production site deployed from `main` gets its own `ci/deploy-<env>-pages`, opened as a PR into `main`.*

## Runbook (order is load-bearing — do not reorder)

Load `ultra-repo-creator`, `ultra-project-initializer`, `ultra-project-deployer` and follow each for the exact commands, assets, ruleset, templates, and pinned versions. Override every menu and Execution gate with the defaults above. Branch / commit / PR ceremony goes through `ultra-branch-creator` / `ultra-commit-creator` / `ultra-pr-creator` — load `ultra-pr-creator` for the PR shape (`--assignee @me --label <type>`, the gate). Each PR **title is the branch name** (never the commit message) and its **body is the bundled asset** named in *Fixed PR text* — passed to `--body-file` unchanged, not authored dynamically.

1. **Scaffold (repo-creator · Vite + React template).** **From `~/Developer`** (`D`'s parent — *not* wherever Claude Code was launched), run repo-creator's framework template, choosing **Vite + React**, producing `~/Developer/N/`. repo-creator scaffolds *from the current directory*, so this `cd` is load-bearing: skip it and the project lands beside the launch dir, while Preflight and the build-verify both target `D = ~/Developer/N` — step 3 then `cd`s into an empty `D` and breaks. repo-creator owns the scaffold command, the version pin, the `git init`, and the initial commit. The app rides in on the first push to `main`.
2. **Bind remote → main, before protection.** Take repo-creator's remote decision (public, push). The app must reach `main` **before** step 4 — protection blocks direct pushes.
3. **Set the Vite base, then verify the build.** In `D`, first set `base: '/N/'` in `vite.config.ts` — the site is served at `https://O.github.io/N/`, so with the default `base: '/'` every root-absolute asset (the favicon, `public/` files like `/vite.svg`, the bundled JS/CSS) 404s under the subpath (deployer's *Vite project-page caveat*). Then `npm install && npm run build` in `D` — confirm `dist/` is produced with `/N/`-prefixed asset paths. If the build fails, stop and report; do not protect or publish a broken project. On success, commit the base change (`build: set vite base for github pages`) and push to `main` — still unprotected until step 4, so `preparing` (forked in step 5) inherits the base before the deploy build.
4. **Protect main (initializer · main protection).** Apply initializer's main-protection option and confirm the ruleset is in place. From here, everything reaches `main` through a PR.
5. **Initialize (initializer) + route per Git flow.** Run initializer with the features above — MIT `LICENSE`, blank `.claude/CLAUDE.md`, type labels, deploy branch `preparing`. Let it land the files on `chore/initial-project-setup` and fork `preparing` from `main`; then route that branch per **Git flow** — merge it into `preparing` (no PR) and push, then PR it into `main` and self-merge — instead of initializer's single PR. Labels and the `preparing` fork are GitHub side-effects.
6. **Publish (deployer · GitHub Pages, PR into preparing).** Run deployer with build type **Vite SPA** and deploy branch `T = preparing` — it owns enabling Pages, allowing `preparing` in the `github-pages` environment, the workflow template, and the deploy PR into `preparing` (the Vite `base` is already set in step 3). Merging that PR lands the deploy workflow on `preparing` and triggers the first deploy.
7. **Confirm live.** Poll `https://O.github.io/N/` until HTTP 200 (`curl -sf -o /dev/null -w '%{http_code}' <url>`), up to ~5 minutes. Report the live URL. If it never goes green, surface the failing run via `gh run list` / `gh run view`.
8. **Open the editor.** Once live, `cd` into `D` and run `code .` to open the project in VS Code — best-effort: if the `code` CLI is not on `PATH`, skip it silently (the deploy already succeeded).

## Fixed PR text (emit the bundled body verbatim — identical every run)

ultra-pr-creator supplies the title (**the branch name, verbatim — never the commit message**), the `--assignee @me --label <type>` flags, and the gate. Each PR body is a bundled asset — pass it to `--body-file` unchanged, never authored dynamically.

- **PR → `main`** — title `chore/initial-project-setup`, `--label chore`, body `assets/pr-into-main.md`.
- **PR → `preparing`** — title `ci/deploy-github-pages`, `--label ci`, body `assets/pr-into-preparing.md`.

## Footguns (the skill-level ones; the rest belong to the stage skills)

- App on `main` **before** protection — protection forbids direct pushes (steps 2 → 4 order is why).
- Build verified (step 3) before any remote-settings change — never protect or publish a broken scaffold.
- `T = preparing` ≠ `main`, so deployer must allow it in the `github-pages` environment — that step is deployer's; just don't let a gate override skip it.
- PR `--label <type>` needs the 11 type labels to exist first — initializer creates them in step 5; open the PRs after, never before.
