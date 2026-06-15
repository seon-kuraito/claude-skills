# README guide

Every skill in the repo carries a `README.md` beside its `SKILL.md`. They serve different readers: `SKILL.md` is agent-facing (English, the runtime contract); `README.md` is human-facing (Traditional Chinese, browsed on GitHub). Author the README to this spec so every skill reads consistently.

## Skeleton

```
# <Skill Name>

<one-line tagline — what the skill is>

　

## 聲明

- **來源**：
  - 原創 ／ 延伸自 [<upstream>](<url>)
- **授權**：
  - <license>
  - 完整條款見 `LICENSE`〔，衍生改動聲明見 `NOTICE`〕

　

## Summary

<capability + when to use, in a sentence or two — no deep spec; point to `SKILL.md`>

　

## 設計取向（<naming the comparison, e.g. 相對於 X 的取捨>）

- **<bold label>**：
  - <sub-point>
  - <sub-point>

　

> 附註：<honest caveat, e.g. which parts are carried verbatim from upstream>

　

## 預設與相依（可依需求抽換）

- **<bold label>**：
  - <sub-point>
```

## Sections — required vs conditional

- **`# H1` + tagline + `## 聲明` + `## Summary`** — always present. The H1 is the skill name in **Title Case** (`Ultra Repo Creator`), matching the SKILL.md H1 — same acronym / filename rules (`PR`, `CLAUDE.md`).
- **`## 聲明`** ties to the `Licensing` decision:
  - **Original** → `來源`：原創；`授權`：MIT（`LICENSE`）. No `NOTICE`.
  - **Derived** → `來源`：延伸自 `<upstream>`（link）；`授權`：the upstream license, pointing to `LICENSE` and `NOTICE`.
- **`## Summary`** — what the skill does and when to use it, kept consistent in scope with the skill's `description` (not narrower). No spec detail — that lives in `SKILL.md`.
- **`## 設計取向`** — for a *derived* skill, the deltas from the upstream (the heading names the comparison). For a purely original skill, include only if there are design choices worth recording; otherwise omit.
- **`> 附註`** — only when there is something to disclose honestly (e.g. bundled code carried verbatim from upstream). Attaches to the section above it.
- **`## 預設與相依（可依需求抽換）`** — only when the skill hard-codes environment / personal assumptions (a repo path, sibling skills). List each as a swap point. Omit if none.

## Tone & language

- **Objective, documentation tone** — no first person (我) and no second person (你). State facts, not authorial intent.
- **Traditional Chinese prose; identifiers stay in English.** Proper nouns (Anthropic, Claude Code) and technical keywords keep their English form; wrap code-like identifiers — file / field / tool / repo / skill names, the `ultra-<single-token>-<verber>` pattern — in backticks. Translate plain-English prose words: bullet → 條列, session → 工作階段, body → 內文.
- **Fullwidth punctuation in Chinese prose.** Chinese sentences take fullwidth marks — `，。：；（）「」` — not halfwidth ASCII. Use halfwidth `,.:;()` only where the punctuated content is itself English or code: an English fragment like `Anthropic, PBC`, parentheses wrapping a bare code span or English term, and markdown link syntax `[text](url)` (always halfwidth). Parentheses around Chinese — even Chinese mixed with English — take fullwidth `（）`, e.g. `（可依需求抽換）`.

## Formatting

- **Heading spacer.** Before every `##` heading, write three lines: a blank line, a line holding one full-width space `　` (U+3000), and a blank line. It renders as breathing room on GitHub; a plain blank line collapses. A footnote (`> 附註`) belonging to the section above does **not** get a spacer — keep it attached with a single blank line.
- **Two-level bullets.** The labeled lists (`## 聲明`, `## 設計取向`, `## 預設與相依`) are two-level: a bold label — ending with a full-width `：` — as the top bullet, each point as a sub-bullet beneath (2-space indent), even a single point, for consistency.
- **No trailing period on bullets.** Bullet items read as fragments — drop the trailing `。`. Prose lines (the tagline, the Summary paragraph, the footnote) keep their periods.
