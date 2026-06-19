# README guide

Every hook in the repo carries a `README.md` beside its `hook.sh` — human-facing (Traditional Chinese, browsed on GitHub). Author it to the same house style as the skill READMEs in `claude-skills`, so hooks and skills read consistently.

## Skeleton

````
# <hook-name>

<one-line tagline — a keyword-bearing gist of what the hook does and on which event>

　

## 聲明

- **來源**：
  - 原創 ／ 延伸自 [<upstream>](<url>)
- **授權**：
  - <license>
  - 完整條款見同目錄 [`LICENSE`](LICENSE)〔，衍生改動聲明見 [`NOTICE`](NOTICE)〕

　

## 為什麼做這個 hook（WHY）

- **<痛點 label>**：
  - <the difficulty this hook addresses, framed as the problem>

　

## 這個 hook 做什麼（WHAT）

- **<bold label>**：
  - <what it does and on which event, more specific than the tagline>
- **主要實作集中在 hook.sh**：
  - 事件解析、判斷與通知的邏輯見 [`hook.sh`](hook.sh)

　

## 如何使用這個 hook（HOW）

### 安裝

- **手動安裝**：
  - 把整個 hook 目錄複製進 `~/.claude/hooks/`
  - 自行建立所需產物（如有），再依下方「註冊」手動登記
- **執行腳本**：

  ```sh
  cd claude-hooks
  scripts/link-hook.sh <hook-name>
  ```

  - 連結進 `~/.claude/hooks/`；若 hook 帶 `install.sh`，連結後會自動執行 post-link 設定，並**檢查（不改寫）**註冊狀態
  - 註冊仍需手動完成（見下方）
- **註冊到 `settings.json`（手動，兩種安裝方式都需要）**：
  1. 打開 `~/.claude/settings.json`（沒有就新建）
  2. 在頂層 `hooks` 下，加入本 hook 對應的事件（matcher 視需要）
  3. 事件的 `command` 指向 `~/.claude/hooks/<hook-name>/hook.sh`
  4. 完整宣告見 repo 的 [`settings.hooks.json`](../../settings.hooks.json)，照抄／合併後存檔即生效

　

### 設計取向

- **<bold label>**：
  - <sub-point>

　

### <companion-program name>

- **<bold label>**：
  - <sub-point — where the companion's source lives, how it's built, its lifecycle, version-control status, signing / dependencies>

　

### 預設與相依

- **<bold label>**：
  - <sub-point>
````

## Sections — required vs conditional

- **`# H1` + tagline + `## 聲明` + the three frame sections** — always present. The H1 is the hook name in **Title Case** (`Ultra Attention Reminder`) — same acronym / filename rules as skills (`PR`, `CLAUDE.md`). The tagline is a one-line, keyword-bearing gist of what the hook does and on which event.
- **The three frame headings are fixed, verbatim** — `## 為什麼做這個 hook（WHY）` / `## 這個 hook 做什麼（WHAT）` / `## 如何使用這個 hook（HOW）` (the skill READMEs use the same form with `skill` in place of `hook`). The trailing `（WHY/WHAT/HOW）` is a deliberate exception to the no-parenthetical / no-English heading rule (see Tone & language).
- **`## 聲明`** ties to the licensing decision (see `references/publishing.md`):
  - **Original** → `來源`：原創；`授權`：MIT（[`LICENSE`](LICENSE)）. No `NOTICE`.
  - **Derived** → `來源`：延伸自 `<upstream>`（link）；`授權`：the upstream license, pointing to [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).
- **`## 為什麼做這個 hook（WHY）`** — the pain points / motivation this hook addresses, as `- **label**：` bullets framed as the problem (the design choices that answer them live in `### 設計取向`).
- **`## 這個 hook 做什麼（WHAT）`** — what the hook does and when it fires: the event, the gate, the side-effect, as bullets more specific than the tagline. The README is the hook's main doc, so this can run a touch fuller than a skill's. A hook has no standalone spec file, so close WHAT with the analog of a skill's `SKILL.md` pointer — **主要實作集中在 hook.sh** → [`hook.sh`](hook.sh) (its `install.sh` and any app source are covered under HOW, not here).
- **`## 如何使用這個 hook（HOW）`** — a wrapper holding these `h3` subsections:
  - **`### 安裝`** — always present, and unlike a skill a hook needs registration to work. Three bold bullets: **手動安裝**, **執行腳本** (`scripts/link-hook.sh <hook-name>` — symlinks, and if an `install.sh` is present runs it to build artifacts and *check* registration), and **註冊到 `settings.json`** as explicit numbered (`1.`) steps. Registration is always manual — declare-and-compare: `settings.hooks.json` declares it, the live `settings.json` is never rewritten by the script — so spell the steps out and state plainly that the script does not register for you.
  - **`### 設計取向`** — design choices worth recording (the cadence gate, why a side-effect always exits 0, input / security handling). Omit if trivial.
  - **`### <companion-program name>`** — optional; present only when the hook ships a companion program alongside `hook.sh` (a bundled `.app`, a helper binary, etc.). The heading is the artifact's literal name (e.g. `Reminder.app`). Document where its source lives, how it's built, its lifecycle (first build / rebuild), what is and isn't version-controlled, and any signing / dependency notes. Omit entirely for a hook that is just `hook.sh`.
  - **`### 預設與相依`** — hard-coded assumptions and swap points (platform, terminal mapping, sound name). Omit if none.

## Tone & language

- **Objective, documentation tone** — no first person (我) and no second person (你). State facts.
- **Traditional Chinese prose; identifiers stay in English.** Wrap file / field / event / tool names in backticks (`Stop`, `hook.sh`, `settings.json`). Translate plain prose words.
- **Git workflow terms stay in English.** `commit` / `branch` / `merge` / `rebase` and the like keep their English form — do *not* translate to 提交 / 分支. Mind the homonym: 分支 in the *non-git* sense (a `case` branch in code, a decision-tree branch) stays Chinese; only the git meaning becomes `branch`.
- **Gloss an English term on first mention, then use the Chinese.** First appearance takes the form 中文（English Title Case）— e.g. 漸進式增強（Progressive Enhancement）; later mentions in the same file use the Chinese alone.
- **Examples take the form 「（例如：X）」.** Fullwidth parentheses, fullwidth colon, no space after `例如` — e.g. （例如：`claude-hooks` → `Claude Hooks`）. Inline mid-sentence examples get the same parenthetical form, not a bare `，例如 …`.
- **Fullwidth punctuation in Chinese prose.** Chinese sentences take fullwidth marks — `，。：；（）「」` — not halfwidth ASCII. Use halfwidth `,.:;()` only where the punctuated content is itself English or code: an English fragment like `Anthropic, PBC`, parentheses wrapping a bare code span or English term, and markdown link syntax `[text](url)` (always halfwidth). Parentheses around Chinese — even Chinese mixed with English — take fullwidth `（）`, e.g. `（可選）`.
- **The three frame headings are bilingual; every other heading is plain Chinese.** Only `## 為什麼做這個 hook（WHY）` / `（WHAT）` / `（HOW）` carry the English marker in fullwidth parentheses. Every other heading — `## 聲明`, `### 安裝`, `### 設計取向`, `### 預設與相依` — stays plain Chinese, no parenthetical and no English.
- **Referenceable pointers become links.** A "見 X" pointer to a repo file — `LICENSE`, `NOTICE`, the repo-root `settings.hooks.json` — becomes a markdown link that keeps the inline-code label: `[`settings.hooks.json`](../../settings.hooks.json)`. The live `~/.claude/settings.json` is runtime state outside the repo, so it stays a plain backtick span; so does any file mentioned descriptively rather than as "go see X".

## Formatting

- **Heading spacer.** Before every `##` *and* `###` heading, write three lines: a blank line, a line holding one full-width space `　` (U+3000), and a blank line. **Exception:** an `###` that immediately follows its parent `##` with nothing between (e.g. `## 如何使用這個 hook（HOW）` → `### 安裝`) gets a single blank line, no spacer. A `> 附註` belonging to the section above also gets no spacer — keep it attached with a single blank line.
- **Two-level bullets.** A bold label ending in a full-width `：` as the top bullet, each point as a 2-space-indented sub-bullet beneath it — even a single point, for consistency.
- **Nest the install code block.** Under `### 安裝`'s **執行腳本** bullet, indent the `sh` code block two spaces so it — and the sub-bullets after it — nest under the bullet; a fence at column 0 ends the list and orphans what follows. The registration steps are an ordered (`1.`) sub-list under their bold label.
- **No trailing period on fragment bullets.** Bullet fragments drop the trailing `。` / `.`; full sentences and prose lines (the tagline) keep theirs.
