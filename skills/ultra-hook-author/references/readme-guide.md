# README guide

Every hook in the repo carries a `README.md` beside its `hook.sh` — human-facing (Traditional Chinese, browsed on GitHub). Author it to the same house style as the skill READMEs in `claude-skills`, so hooks and skills read consistently.

## Skeleton

````
# <hook-name>

<one-line tagline — what the hook does and on which event>

　

## 聲明

- **來源**：
  - 原創 ／ 延伸自 [<upstream>](<url>)
- **授權**：
  - <license>
  - 完整條款見同目錄 `LICENSE`〔，衍生改動聲明見 `NOTICE`〕

　

## 概述

<what it does and when it fires, in a sentence or two>

　

## 安裝

- **手動安裝**：
  - 把整個 hook 目錄複製進 `~/.claude/hooks/`
  - 自行建置所需產物（如有），再依下方「註冊」手動登記
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
  4. 完整宣告見 repo 的 `settings.hooks.json`，照抄／合併後存檔即生效

　

## 設計取向

- **<bold label>**：
  - <sub-point>

　

## 預設與相依

- **<bold label>**：
  - <sub-point>
````

## Sections — required vs conditional

- **`# H1` + tagline + `## 聲明` + `## 概述` + `## 安裝`** — always present. The H1 is the hook name in **Title Case** (`Ultra Attention Reminder`) — same acronym / filename rules as skills (`PR`, `CLAUDE.md`); the tagline says what it does and on which event.
- **`## 聲明`** ties to the licensing decision (see `references/publishing.md`):
  - **Original** → `來源`：原創；`授權`：MIT（`LICENSE`）. No `NOTICE`.
  - **Derived** → `來源`：延伸自 `<upstream>`（link）；`授權`：the upstream license, pointing to `LICENSE` and `NOTICE`.
- **`## 概述`** — what the hook does and when it fires: the event, the gate, the side-effect. The README is the hook's main doc, so this may run a touch fuller than a skill's one-liner.
- **`## 安裝`** — always present, and unlike a skill a hook needs registration to work. Three two-level bold bullets: **手動安裝** (copy the hook directory into `~/.claude/hooks/`, build any artifacts, then register), **執行腳本** (`scripts/link-hook.sh <hook-name>` — symlinks, and if an `install.sh` is present runs it to build artifacts and *check* registration), and **註冊到 `settings.json`** as explicit numbered (`1.`) steps. Registration is always manual — declare-and-compare: `settings.hooks.json` declares it, the live `settings.json` is never rewritten by the script — so spell the steps out and state plainly that the script does not register for you.
- **`## 設計取向`** — design choices worth recording (the cadence gate, why a side-effect always exits 0, input / security handling). Include when there's something to say; omit if trivial.
- **`## 預設與相依`** — hard-coded assumptions and swap points (platform, terminal mapping, sound name). Omit if none.

## Tone & language

- **Objective, documentation tone** — no first person (我) and no second person (你). State facts.
- **Traditional Chinese prose; identifiers stay in English.** Wrap file / field / event / tool names in backticks (`Stop`, `hook.sh`, `settings.json`). Translate plain prose words.
- **Git workflow terms stay in English.** `commit` / `branch` / `merge` / `rebase` and the like keep their English form — do *not* translate to 提交 / 分支. Mind the homonym: 分支 in the *non-git* sense (a `case` branch in code, a decision-tree branch) stays Chinese; only the git meaning becomes `branch`.
- **Gloss an English term on first mention, then use the Chinese.** First appearance takes the form 中文（English Title Case）— e.g. 漸進式增強（Progressive Enhancement）; later mentions in the same file use the Chinese alone.
- **Examples take the form 「（例如：X）」.** Fullwidth parentheses, fullwidth colon, no space after `例如` — e.g. （例如：`claude-hooks` → `Claude Hooks`）. Inline mid-sentence examples get the same parenthetical form, not a bare `，例如 …`.
- **Fullwidth punctuation in Chinese prose.** Chinese sentences take fullwidth marks — `，。：；（）「」` — not halfwidth ASCII. Use halfwidth `,.:;()` only where the punctuated content is itself English or code: an English fragment like `Anthropic, PBC`, parentheses wrapping a bare code span or English term, and markdown link syntax `[text](url)` (always halfwidth). Parentheses around Chinese — even Chinese mixed with English — take fullwidth `（）`, e.g. `（可選）`.

## Formatting

- **Heading spacer.** Before every `##` heading, write three lines: a blank line, a line holding one full-width space `　` (U+3000), and a blank line. It renders as breathing room on GitHub; a plain blank line collapses. A `> 附註` belonging to the section above does **not** get a spacer — keep it attached with a single blank line.
- **Two-level bullets.** A bold label ending in a full-width `：` as the top bullet, each point as a 2-space-indented sub-bullet beneath it — even a single point, for consistency.
- **Nest the install code block.** Under `## 安裝`'s **執行腳本** bullet, indent the `sh` code block two spaces so it — and the sub-bullets after it — nest under the bullet; a fence at column 0 ends the list and orphans what follows. The registration steps are an ordered (`1.`) sub-list under their bold label.
- **No trailing period on fragment bullets.** Bullet fragments drop the trailing `。` / `.`; full sentences and prose lines (the tagline) keep theirs.
