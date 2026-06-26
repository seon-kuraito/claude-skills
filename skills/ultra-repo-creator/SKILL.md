---
name: ultra-repo-creator
description: Bootstraps a new repository. Use whenever creating a project or binding a remote is in play — starting a new project, spinning up a quick local repo, initializing version control, turning a folder into a git repo, creating or binding a GitHub remote, or scaffolding a meta-repo over sibling projects — regardless of exact wording or language. Lean toward consulting it the moment repo creation or remote-binding comes up.
---

# Ultra Repo Creator

Bootstrap a new repository — **built locally first, then optionally pushed to a remote**. This is the **create** stage of a two-stage project setup; the **initialize** stage (a separate skill) takes over the optional scaffolding afterwards — see *Hand-off*.

This skill covers only creating the repo. The follow-up once it exists — organizing the working tree into commits / branches / PRs — is handled separately by [ultra-branch-creator](../ultra-branch-creator/SKILL.md), [ultra-commit-creator](../ultra-commit-creator/SKILL.md), and [ultra-pr-creator](../ultra-pr-creator/SKILL.md).

## How it runs

Load on the intent — there is **no "should I use this" pre-gate**; just enter the skill and start with the template menu. From there everything is local and reversible until the very end, so it runs without confirmation. The **only** confirmation is the single *Execution gate* before anything touches a remote. Present every `AskUserQuestion` menu exactly as written below: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction and is never shown. Call the tool and act on the answer.

**Pick a template** — present this menu verbatim, even when one template seems obvious; the user makes the call:

```
single-select · header: 「範本」
question: 「要用哪一種範本建立這個 repo？」
options:
  · 「空白專案 Blank」 — 「建立一般專案使用的純 git repo，包含 git init、空白 README 與標準 .gitignore。」
  · 「框架專案 Framework」 — 「建立 Next.js / Vite 等框架專案，尚未模板化時會依需求逐步建立。」
  · 「專案協調層 Meta-Repo」 — 「建立位於多個 <prefix>-* sibling-repo 之上的協調層。」
[Rule, not copy] if .git already exists (resuming a half-built repo), skip the menu and keep the repo as it stands.
```

Per-template detail lives in the sections below ([meta-repo](references/meta-repo.md) carries its own reference). From there:

1. **Build it locally** — run the template's local steps (below) without confirmation.
2. **Remote decision** — once the project stands up locally, the *Execution gate* asks whether to bind a public remote and push, or stay local. Every template passes through it.
3. **Hand off** to the initialize stage — for **all three templates**.

## 🚧 Execution gate

Local steps — `git init`, commits, scaffolding — run freely; they're local and reversible. The **only** gate is the outward-facing one, and it **is** the remote decision:

- **Triggers on** — binding a remote or pushing: `gh repo create`, `git push`, `git remote add`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; confirming means "create the public remote and push," declining means "stay local-only."
- **Never bypass** — never reach a remote without passing this gate.

## blank

**Local (no confirmation):**

1. **Guard first.** If the working directory already has files but is *not* a git repo, flag it before writing anything more — don't wait for the user to notice.
2. `git init`.
3. The **initial commit contains a blank `README.md`** (an empty file) **and a standard `.gitignore`** (copied verbatim from `assets/blank/gitignore.txt` — macOS + editor/IDE + log artifacts), fixed message `chore: initialize repository` (verbatim — not via ultra-commit-creator). The `.gitignore` is infrastructure rather than your work, so it belongs in the first commit — ignore rules should be in place *before* anything gets tracked.
4. Existing work stays **untracked** until the remote decision; don't bundle it into the initial commit unless the user explicitly asks.

**Remote decision (*Execution gate*)** — ask whether to bind a public remote and push:

- **Yes** → ensure the branch is `main` (`git branch -M main`), then:

  ```sh
  gh repo create <name> --public --source . --remote origin --push
  ```

  Always **public** — no visibility question (a deliberate personal-fit default; create a private repo by hand if ever needed). If `gh` is unavailable, fall back to `git remote add origin <url>` → `git branch -M main` → `git push -u origin main`.
- **No** → stay local-only; stop here (still offer the *Hand-off*).

## framework

Framework scaffolding (Next.js, Vite, …) is **not templated yet**. Build it conversationally:

1. Ask which framework / starter the user wants.
2. Run its own init locally, commit as you go. Framework scaffolds normally generate their own `.gitignore`; only if one didn't, offer the standard `assets/blank/gitignore.txt`.
3. **Remote decision (*Execution gate*)** — same as blank.
4. **Hand off** to the initialize stage.

## meta-repo

A coordination layer over `<prefix>-*` siblings — the pattern behind `claude-meta`, `bootcamp-rocket-meta`, and `personal-meta`. Built locally with its own scaffold + git ceremony, then through the **same remote decision and hand-off as the other templates** — the flow is fully uniform. Its scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` comes from the initialize stage's `LICENSE` option like every other project, and labels / branch protection apply there once a remote is bound.

**Full procedure — read it before running: [`references/meta-repo.md`](references/meta-repo.md).**

## Hand-off to the initialize stage

Applies to **all three templates**. Once the repo is built (local, or local + remote), present this menu verbatim:

```
single-select · header: 「下一步」
question: 「要現在進入 initialize 階段嗎？」
options:
  · 「進入 initialize 階段」 — 「接著建立選配的 LICENSE / 空白 CLAUDE.md / GitHub labels / main 分支保護。」
  · 「不進入」 — 「先停在這，後續交給我處理。」
[Rule, not copy] if no initialize skill is available, say so and stop instead of loading one.
```

- **進入 initialize 階段** → load the initialization skill (e.g. `ultra-project-initializer`) if it is available; if it is not present, say so and stop.
- **不進入** → stop here and leave the next move to the user.

The initialize stage holds the optional scaffolding — a blank `.claude/CLAUDE.md`, a `LICENSE`, GitHub labels, and branch protection. `.gitignore` is no longer one of them: the create stage now lays a standard one (blank and meta-repo build it in; framework brings its own). Labels and branch protection need a remote, so they're skipped on a local-only repo. Never auto-enter it — it is always the user's choice.

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — organizing the work that lands after the repo exists.
