# README guide

Every hook in the repo carries a `README.md` beside its `hook.sh` — human-facing (Traditional Chinese, browsed on GitHub). Author it to the same house style as the skill READMEs in `claude-skills`, so hooks and skills read consistently.

## Skeleton

```
# <hook-name>

<one-line tagline — what the hook does and on which event>

　

## 聲明

- **來源**：
  - 原創 ／ 延伸自 [<upstream>](<url>)
- **授權**：
  - <license>
  - 完整條款見同目錄 `LICENSE`〔，衍生改動聲明見 `NOTICE`〕

　

## Summary

<what it does and when it fires, in a sentence or two>

　

## 設計取向

- **<bold label>**：
  - <sub-point>

　

## 預設與相依（可依需求抽換）

- **<bold label>**：
  - <sub-point>
```

## Sections — required vs conditional

- **`# H1` + tagline + `## 聲明` + `## Summary`** — always present. The H1 is the hook name in **Title Case** (`Ultra Attention Reminder`) — same acronym / filename rules as skills (`PR`, `CLAUDE.md`); the tagline says what it does and on which event.
- **`## 聲明`** ties to the licensing decision (see `references/publishing.md`):
  - **Original** → `來源`：原創；`授權`：MIT（`LICENSE`）. No `NOTICE`.
  - **Derived** → `來源`：延伸自 `<upstream>`（link）；`授權`：the upstream license, pointing to `LICENSE` and `NOTICE`.
- **`## Summary`** — what the hook does and when it fires: the event, the gate, the side-effect. The README is the hook's main doc, so this may run a touch fuller than a skill's one-liner.
- **`## 設計取向`** — design choices worth recording (the cadence gate, why a side-effect always exits 0, input / security handling). Include when there's something to say; omit if trivial.
- **`## 預設與相依（可依需求抽換）`** — hard-coded assumptions and swap points (platform, terminal mapping, sound name). Omit if none.

## Tone & language

- **Objective, documentation tone** — no first person (我) and no second person (你). State facts.
- **Traditional Chinese prose; identifiers stay in English.** Wrap file / field / event / tool names in backticks (`Stop`, `hook.sh`, `settings.json`). Translate plain prose words.
- **Fullwidth punctuation in Chinese prose.** Chinese sentences take fullwidth marks — `，。：；（）「」` — not halfwidth ASCII. Use halfwidth `,.:;()` only where the punctuated content is itself English or code: an English fragment like `Anthropic, PBC`, parentheses wrapping a bare code span or English term, and markdown link syntax `[text](url)` (always halfwidth). Parentheses around Chinese — even Chinese mixed with English — take fullwidth `（）`, e.g. `（可依需求抽換）`.

## Formatting

- **Heading spacer.** Before every `##` heading, write three lines: a blank line, a line holding one full-width space `　` (U+3000), and a blank line. It renders as breathing room on GitHub; a plain blank line collapses. A `> 附註` belonging to the section above does **not** get a spacer — keep it attached with a single blank line.
- **Two-level bullets.** A bold label ending in a full-width `：` as the top bullet, each point as a 2-space-indented sub-bullet beneath it — even a single point, for consistency.
- **No trailing period on fragment bullets.** Bullet fragments drop the trailing `。` / `.`; full sentences and prose lines (the tagline) keep theirs.
