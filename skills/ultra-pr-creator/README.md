# Ultra PR Creator

根據目前 branch 相對於 base branch 的 commits 與 diff，開啟 GtiHub PR（Pull Request），並撰寫 PR 的標題和固定三段式 body。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

body 文案一律包含 📝 Summary／🎯 Scope／✅ Test plan，並包在單一可複製的 code block 裡。內容根據目前 branch 相對於 base branch 的 commits 與 diff 整理，標題則直接沿用 branch 名稱。詳細規格見 `SKILL.md`。

　

## 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-pr-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

## 設計取向

- **PR body 固定三段式結構**：
  - body 一律包含 Summary、Scope 與 Test plan 三段，並搭配 emoji 標題
  - 固定結構讓 reviewer 每次都能用相同方式掃讀 PR，降低理解成本
- **整份 body 包成單一可複製區塊**：
  - PR body 會包在 plain code block 中，不加語言標籤，避免部分 renderer 的 copy button 失效
  - section 之間使用全形空格（U+3000）保留間距，讓內容在 GitHub 上更有呼吸感
- **PR title 直接沿用 branch 名稱**：
  - 不另外替 PR title 造句，直接逐字使用目前 branch 名稱
  - branch 命名品質由 `ultra-branch-creator` 負責把關，PR creator 不重複改寫
- **根據 branch 變更整理 body**：
  - 依據目前 branch 相對於 base branch 的 `git log` 與 `git diff` 整理內容
  - 概述收斂 commits 的主要變更，Scope 從 diff 判斷影響範圍，Test plan 則整理已驗證與應補測的重點
- **執行 gh 高影響指令前先確認**：
  - 執行 `create`、`edit`、`merge`、`close` 前，先攤開 title、body 與影響旗標，交由使用者確認
  - 不把建立 PR 與 merge 串成一步，避免在未確認的情況下直接改變遠端狀態
- **merge 時保留 commit 歷史與本地 branch**：
  - 預設使用 `--merge` 產生 merge commit，保留已整理過的逐筆 commit
  - 預設不使用 `--delete-branch`，讓本地 branch 標籤保留下來
  - 不對已策展過的 branch 使用 `--squash`，避免抹掉刻意整理好的 commit 歷史
- **將模板與細節拆到 references／assets**：
  - 逐段深入指南放在 `references/`（例如：sections 與 examples）
  - PR body 模板獨立放在 `assets/pr-body-template.md`

　

## 預設與相依

- **PR 的 assignee 與 label**：
  - 預設自我指派（`@me`，即 repo 擁有者 `seon-kuraito`），並貼上 branch type 對應的標籤
  - 依賴 repo 已建好那 10 個 type 標籤（與 branch／commit 同一套）；換到沒有這些標籤的 repo 時，跳過 `--label`
- **預設 main 為 base branch**：
  - 用 `master`／`develop`／feature trunk 時自行推斷或問一次
- **語言慣例**：
  - PR body 一律用英文撰寫，方便後續被 changelog、release note 或其他自動化工具引用
- **委派的 skill**：
  - 標題交給 `ultra-branch-creator`、commit 訊息交給 `ultra-commit-creator`
