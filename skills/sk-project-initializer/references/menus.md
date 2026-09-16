# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Features

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
    · 「GitHub 標籤」 — 「新增 Conventional Commits 類型標籤；repo 已有標籤時，會先詢問處理方式。」
    · 「分支保護」 — 「對 main 套用標準 ruleset，要求 PR 並禁止刪除與強制推送。（GitHub 免費方案只對 public repo 生效）」
    · 「部署分支」 — 「從 main 建立部署分支供 deployer 使用，選擇後再指定 develop 或 preparing。」
[Rule, not copy] include Q2 only when a remote exists (check `git remote` or the sk-repo-creator hand-off state); on a local-only repo, omit Q2 entirely — every option there needs the remote. Each question caps at 4 options. If nothing is selected across both questions, stop.
```

## License

```
single-select · header: 「授權條款」
question: 「LICENSE 要使用哪一個模板？」
options:
  · 「MIT」 — 「寬鬆授權，幾乎不加限制。」
  · 「Apache-2.0」 — 「寬鬆授權，並包含明確的專利授權條款。」
  · 「GPL-3.0」 — 「Copyleft 授權，衍生作品須以相同條款開源。」
  · 「Proprietary」 — 「保留所有權利，不授予任何開源權利，適合不對外開源的專案。」
[Rule, not copy] the auto-provided *Other* covers anything else. For a **named** license (e.g. BSD-3-Clause), fetch it verbatim from a canonical source (GitHub's `/licenses/<key>` API), never type it from memory. A **bespoke** notice has no canonical source — write it directly, starting from the bundled `Proprietary` template rather than from scratch.
```

## Deploy branch

```
single-select · header: 「建立部署分支」
question: 「要建立哪一條部署分支？」
options:
  · 「develop」 — 「整合分支（integration branch）。」
  · 「preparing」 — 「測試環境分支（testing environment branch）。」
```

## Existing labels

```
single-select · header: 「現有標籤」
question: 「這個 repo 已有 <count> 個標籤：<labels>。請選擇處理方式。」
options:
  · 「刪除現有標籤並新增」 — 「刪除上面列出的所有標籤，再新增 Conventional Commits 類型標籤。」
  · 「保留現有標籤並新增」 — 「保留上面列出的標籤，再新增 Conventional Commits 類型標籤；已存在的同名標籤維持原樣，不會覆寫。」
  · 「沿用現有標籤」 — 「不刪除也不新增任何標籤，沿用 repo 目前的標籤。」
[Rule, not copy] substitute <count> and <labels> — every existing label name, joined with 「、」 — from the listing. Never guess which labels are GitHub defaults: the menu shows what is there and the user decides.
```

## Next step

```
single-select · header: 「下一步」
question: 「要現在進入部署階段嗎？」
options:
  · 「進入部署階段」 — 「載入 sk-project-deployer，使用這條部署分支部署。」
  · 「不進入」 — 「先停在這，後續交給我處理。」
[Rule, not copy] if the deployer skill is unavailable, say so and stop instead of loading one.
```
