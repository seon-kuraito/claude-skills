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

Present every `AskUserQuestion` menu in this skill exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (field labels, the `[Rule, not copy]` line) is English direction, never shown.

Present the features as **one `AskUserQuestion` call with up to two `multiSelect` questions** — the `questions` array renders as tabs in a single interaction (never split into separate calls, never ask one feature at a time):

```
multiSelect · two questions in one call (questions array → tabs)
Q1 · header: 「本機檔案」
  question: 「要建立哪些本機檔案？（可複選／全部不選）」
  options:
    · 「授權檔 LICENSE」 — 「在根目錄建立一份由內建模板產生的 LICENSE，選擇後會再詢問使用哪一個模板。」
    · 「專案說明書 CLAUDE.md」 — 「建立一份空白的 .claude/CLAUDE.md。」
Q2 · header: 「GitHub / 遠端」
  question: 「要套用哪些 GitHub 設定？（可複選／全部不選）」
  options:
    · 「GitHub 標籤」 — 「將 repo 的預設標籤替換為 Conventional Commits 類型標籤。」
    · 「分支保護」 — 「對 main 套用標準 ruleset，要求 PR 並禁止刪除與強制推送。」
    · 「部署分支」 — 「從 main 建立部署分支供 publisher 使用，選擇後再指定 develop 或 preparing。」
[Rule, not copy] include Q2 only when a remote exists (check `git remote` or the ultra-repo-creator hand-off state); on a local-only repo, omit Q2 entirely — every option there needs the remote. Each question caps at 4 options. If nothing is selected across both questions, stop.
```

## License template

Only when `LICENSE` is selected. Present this menu verbatim:

```
single-select · header: 「授權條款」
question: 「LICENSE 要使用哪一個模板？」
options:
  · 「MIT」 — 「寬鬆授權，幾乎不加限制。」
  · 「Apache-2.0」 — 「寬鬆授權，並包含明確的專利授權條款。」
  · 「GPL-3.0」 — 「Copyleft 授權，衍生作品須以相同條款開源。」
[Rule, not copy] the auto-provided *Other* covers anything else (e.g. BSD-3-Clause) — fetch it verbatim from a canonical source (GitHub's `/licenses/<key>` API), never type it from memory.
```

Write the chosen template to `./LICENSE` (extensionless), substituting `{{YEAR}}` → the current year (`date +%Y`). The copyright holder is already filled in (`Seon Kuraito`, a personal-fit constant). The per-license shape differs:

- **MIT / Apache-2.0** carry a `Copyright {{YEAR}} Seon Kuraito` line — substitute `{{YEAR}}`.
- **GPL-3.0** ships **verbatim**: the FSF requires the license document be unchanged, and the project's own year/author live in per-file header notices, not the `LICENSE` file — so there is no `{{YEAR}}` to substitute.

## Deploy branch

Only when **deploy branch** is selected. Present this menu verbatim:

```
single-select · header: 「建立部署分支」
question: 「要建立哪一條部署分支？」
options:
  · 「develop」 — 「整合分支（integration branch）。」
  · 「preparing」 — 「測試環境分支（testing environment branch）。」
```

A project runs one branching model, so pick exactly one (like the license template). They are personal-fit names, not textbook git-flow / gitlab-flow.

Create the chosen branch **from `main` and push it to `origin`** — the single shared rule for these branches, kept identical in [ultra-project-publisher](../ultra-project-publisher/SKILL.md) (which create-if-absent's the same way at deploy time). This skill only *creates* the branch — it sets no protection and manages no merge / lifecycle (out of scope). A GitHub-side effect that needs the remote; it makes no commit.

## Applying the selection

How each selected option is carried out — the full `gh`-command procedure (commands, ruleset pre-flight / verify, and the solo-repo gotchas) lives in [`references/applying-selection.md`](references/applying-selection.md); read it before running any of these:

- **File options** (`LICENSE`, `.claude/CLAUDE.md`) land as their own fixed-message commits on a dedicated `chore/initial-project-setup` branch.
- **GitHub labels, branch protection, and the deploy branch** are GitHub-side effects with no commit — each needs a remote (skip on a local-only repo; branch protection on GitHub Free also needs a public repo).

## Wrap up — open a PR

The file commits land on `chore/initial-project-setup`, which always needs a PR to reach `main`. After the commits, ask the user whether to open one now:

- **Yes** → hand to [ultra-pr-creator](../ultra-pr-creator/SKILL.md).
- **No** → leave the branch in place for the user.

If only side-effect options were selected (GitHub labels, branch protection, and/or deploy branch), there is no branch or commit — skip this step.

## Hand-off to the publish stage

Only when the **deploy branch** option was selected — that branch exists precisely to be deployed from. After the wrap-up, present this menu verbatim:

```
single-select · header: 「下一步」
question: 「要現在進入 publish 階段嗎？」
options:
  · 「進入 publish 階段」 — 「載入 ultra-project-publisher，使用這條部署分支部署。」
  · 「不進入」 — 「先停在這，後續交給我處理。」
[Rule, not copy] if the publisher skill is unavailable, say so and stop instead of loading one.
```

- **進入 publish 階段** → load [ultra-project-publisher](../ultra-project-publisher/SKILL.md) if available; if it is not present, say so and stop.
- **不進入** → stop here and leave the next move to the user.

Never auto-enter it — always the user's choice (the same shape as ultra-repo-creator's hand-off into this stage).

## 🚧 Execution gate

**Render framed.** Wrap this gate in a `---` rule above and below, each padded by a full-width `　` spacer on its inner side (facing the gate) — with a blank line between every line, so `　` + `---` never parses as a setext heading.

- **Triggers on** — any command that writes to the remote or the repo's settings: `gh label delete`, `gh label create`, the ruleset `gh api --method POST`, `git push`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold the whole selection into one uninterrupted run.

## Related

- [ultra-repo-creator](../ultra-repo-creator/SKILL.md) — the **create** stage (git init / remote) this stage follows.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commits this stage lands.
- `ultra-project-publisher` (planned) — a future **publish** stage; like this one, an insertable, project-level stage.
