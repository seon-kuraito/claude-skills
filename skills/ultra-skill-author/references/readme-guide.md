# README guide

Every skill in the repo carries a `README.md` beside its `SKILL.md`. They serve different readers: `SKILL.md` is agent-facing (English, the runtime contract); `README.md` is human-facing (Traditional Chinese, browsed on GitHub). Author the README to this spec so every skill reads consistently.

## Skeleton

````
# <Skill Name>

<one-line tagline — a keyword-bearing gist of what the skill does>

　

## 聲明

- **來源**：
  - 原創 ／ 延伸自 [<upstream>](<url>)
- **授權**：
  - <license>
  - 完整條款見 [`LICENSE`](LICENSE)〔，衍生改動聲明見 [`NOTICE`](NOTICE)〕

　

## 為什麼做這個 skill（WHY）

- **<痛點 label>**：
  - <the difficulty this skill addresses, framed as the problem>

　

## 這個 skill 做什麼（WHAT）

- **<bold label>**：
  - <what it does, more specific than the tagline>
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 如何使用這個 skill（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh <skill-name>
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **<bold label>**：
  - <sub-point>

> 附註：<honest caveat, e.g. which parts are carried verbatim from upstream>

　

### 預設與相依

- **<bold label>**：
  - <sub-point>
````

## Sections — required vs conditional

- **`# H1` + tagline + `## 聲明` + the three frame sections** — always present. The H1 is the skill name in **Title Case** (`Ultra Repo Creator`), matching the SKILL.md H1 — same acronym / filename rules (`PR`, `CLAUDE.md`). The tagline is a one-line, keyword-bearing gist of what the skill does (not just provenance).
- **The three frame headings are fixed, verbatim** — `## 為什麼做這個 skill（WHY）` / `## 這個 skill 做什麼（WHAT）` / `## 如何使用這個 skill（HOW）`. Don't paraphrase them per skill; only swap `skill` → `hook` for a hook README. The trailing `（WHY/WHAT/HOW）` is a deliberate exception to the no-parenthetical / no-English heading rule (see Tone & language).
- **`## 聲明`** ties to the `Licensing` decision:
  - **Original** → `來源`：原創；`授權`：MIT（[`LICENSE`](LICENSE)）. No `NOTICE`.
  - **Derived** → `來源`：延伸自 `<upstream>`（link）；`授權`：the upstream license, pointing to [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
- **`## 為什麼做這個 skill（WHY）`** — the pain points / motivation this skill addresses, as `- **label**：` bullets. Each is a difficulty that existed *before* the skill; the design choices that answer them live in `### 設計取向`, so frame WHY as the problem, not the solution.
- **`## 這個 skill 做什麼（WHAT）`** — what the skill does and when to use it, as bullets, more specific than the tagline. Kept consistent in scope with the skill's `description` (not narrower); no deep spec — point to [`SKILL.md`](SKILL.md).
- **`## 如何使用這個 skill（HOW）`** — a wrapper holding three `h3` subsections:
  - **`### 安裝`** — always present. Two methods (**手動複製** / **執行腳本**), the `sh` code block indented two spaces to nest under 執行腳本.
  - **`### 設計取向`** — for a *derived* skill, the deltas from the upstream (named in `## 聲明`'s `來源`, not the heading). For an original skill, include only if there are design choices worth recording.
  - **`### 預設與相依`** — only when the skill hard-codes environment / personal assumptions (a repo path, sibling skills). Omit if none.
- **`> 附註`** — only when there is something to disclose honestly (e.g. bundled code carried verbatim from upstream). Attaches to the section above it.

## Tone & language

- **Objective, documentation tone** — no first person (我) and no second person (你). State facts, not authorial intent.
- **Traditional Chinese prose; identifiers stay in English.** Proper nouns (Anthropic, Claude Code) and technical keywords keep their English form; wrap code-like identifiers — file / field / tool / repo / skill names, the `ultra-<single-token>-<verber>` pattern — in backticks. Translate plain-English prose words: bullet → 條列, session → 工作階段, body → 內文.
- **Git workflow terms stay in English.** `commit` / `branch` / `merge` / `rebase` and the like keep their English form — do *not* translate to 提交 / 分支 — matching how the commits themselves are written. Mind the homonym: 分支 in the *non-git* sense (a `case` branch in code, a decision-tree branch) stays Chinese; only the git meaning becomes `branch`.
- **Gloss an English term on first mention, then use the Chinese.** First appearance takes the form 中文（English Title Case）— e.g. 漸進式揭露（Progressive Disclosure）, 能力選用關卡（Capability Checkpoint）; later mentions in the same file use the Chinese alone. The English inside the parentheses is Title Case.
- **Examples take the form 「（例如：X）」.** Fullwidth parentheses, fullwidth colon, no space after `例如` — e.g. （例如：`feat/00-blank-intro-animation`）or （例如：教學系列）. Inline mid-sentence examples get the same parenthetical form, not a bare `，例如 …`.
- **Fullwidth punctuation in Chinese prose.** Chinese sentences take fullwidth marks — `，。：；（）「」` — not halfwidth ASCII. Use halfwidth `,.:;()` only where the punctuated content is itself English or code: an English fragment like `Anthropic, PBC`, parentheses wrapping a bare code span or English term, and markdown link syntax `[text](url)` (always halfwidth). Parentheses around Chinese — even Chinese mixed with English — take fullwidth `（）`, e.g. `（可選）`.
- **The three frame headings are bilingual; every other heading is plain Chinese.** Only `## 為什麼做這個 skill（WHY）` / `（WHAT）` / `（HOW）` carry the English marker in fullwidth parentheses. Every other heading — `## 聲明`, `### 安裝`, `### 設計取向`, `### 預設與相依` — stays plain Chinese, no parenthetical and no English.
- **Referenceable pointers become links.** A "見 X" pointer to a repo file (`LICENSE`, `SKILL.md`, `references/readme-guide.md`) or a sibling skill (`ultra-branch-creator`) becomes a markdown link that keeps the inline-code label: `[`SKILL.md`](SKILL.md)`, `[`ultra-branch-creator`](../ultra-branch-creator)` — a sibling skill links to its directory `../<name>`. A file mentioned descriptively, not as "go see X", stays a plain backtick span.

## Formatting

- **Heading spacer.** Before every `##` *and* `###` heading, write three lines: a blank line, a line holding one full-width space `　` (U+3000), and a blank line. It renders as breathing room on GitHub; a plain blank line collapses. **Exception:** an `###` that immediately follows its parent `##` with nothing between (e.g. `## 如何使用這個 skill（HOW）` → `### 安裝`) gets a single blank line, no spacer. A footnote (`> 附註`) belonging to the section above also gets no spacer — keep it attached with a single blank line.
- **Two-level bullets.** Every labeled list — `## 聲明`, the WHY / WHAT bullets, and the `### 安裝` / `### 設計取向` / `### 預設與相依` lists — is two-level: a bold label, ending with a full-width `：`, as the top bullet, each point as a sub-bullet beneath (2-space indent), even a single point, for consistency.
- **Nest the install code block.** Under `### 安裝`'s **執行腳本** bullet, indent the `sh` code block two spaces so it — and the sub-bullets after it — nest under the bullet; a fence at column 0 ends the list and orphans what follows.
- **No trailing period on bullets.** Bullet items read as fragments — drop the trailing `。`. The tagline (the one prose line) keeps its period; a `> 附註` footnote keeps its too.
