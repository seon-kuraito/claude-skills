# Ultra PR Creator

根據目前 branch 相對於 base branch 的 commits 與 diff，建立 GitHub PR（Pull Request），並撰寫 PR 標題與固定三段式 body。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **PR body 每次長得不一樣**：
  - 格式、段落與詳略各憑當下判斷，reviewer 每次都要重新摸索閱讀方式
- **從零整理 PR 內容重複耗時**：
  - 把 commits 與 diff 收斂成 summary、scope、test plan，每次都要重做一遍
- **gh 指令容易誤操作**：
  - `create`、`merge` 等指令若一氣呵成，可能在未確認前就改動遠端狀態

　

## 這個 skill 做什麼（WHAT）

- **整理 PR 的標題與 body**：
  - 標題沿用 branch 名稱；body 固定三段 📝 Summary／🎯 Scope／✅ Test plan
- **內容取自 branch 變更**：
  - 依目前 branch 相對於 base branch 的 commits 與 diff 整理內容
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
  scripts/link-skill.sh ultra-pr-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **PR body 固定三段式結構**：
  - body 一律包含 Summary、Scope 與 Test plan 三段，並搭配 emoji 標題
  - 固定結構讓 reviewer 每次都能用相同方式掃讀 PR，降低理解成本
- **body 寫進檔案、不倒進終端機**：
  - PR body 一律寫進獨立檔案，透過 `--body-file` 帶入，不把全文倒進終端機，只顯示檔案路徑供開檔審閱
  - 檔案存放原始 markdown，不再外包一層 code fence（那層只為了終端機顯示）
  - section 之間使用全形空格（U+3000）保留間距，讓內容在 GitHub 上更容易掃讀
- **PR title 直接沿用 branch 名稱**：
  - 不另外替 PR title 造句，直接逐字使用目前 branch 名稱
  - branch 命名品質由 [`ultra-branch-creator`](../ultra-branch-creator) 負責把關，PR creator 不重複改寫
- **根據 branch 變更整理 body**：
  - 依據目前 branch 相對於 base branch 的 `git log` 與 `git diff` 整理內容
  - 概述收斂 commits 的主要變更，Scope 從 diff 判斷影響範圍，Test plan 則整理已驗證與應補測的重點
- **執行 gh 高影響指令前先確認**：
  - 執行 `create`、`edit`、`merge`、`close` 前，先攤開 title、body 與影響旗標，交由使用者確認
  - 不把建立 PR 與 merge 串成一步，避免在未確認的情況下改變遠端狀態
- **merge 時保留 commit 歷史與本地 branch**：
  - 預設使用 `--merge` 產生 merge commit，保留已整理過的逐筆 commit
  - 預設不使用 `--delete-branch`，讓本地 branch 標籤保留下來
  - merge 後預設以 `git push origin --delete` 清掉遠端分支，本地標籤仍保留
  - merge 確定後刪除 `--body-file` 用的暫存檔（如 `/tmp/pr-<branch>.md`），PR 開啟期間先保留以便必要時 `gh pr edit`
  - 不對已策展過的 branch 使用 `--squash`，避免抹掉刻意整理好的 commit 歷史
- **將模板與細節拆到 references／assets**：
  - 逐段深入指南放在 `references/`（例如：sections 與 examples）
  - PR body 模板獨立放在 `assets/pr-body-template.md`

　

### 預設與相依

- **PR 的 assignee 與 label**：
  - 預設自我指派（`@me`，即 repo 擁有者 `seon-kuraito`），並貼上 branch type 對應的標籤
  - 依賴 repo 已建好那 10 個 type 標籤（與 branch／commit 同一套）；換到沒有這些標籤的 repo 時，跳過 `--label`
- **預設 main 為 base branch**：
  - 使用 `master`、`develop` 或 feature trunk 時，先自行推斷；不確定時再詢問一次
- **語言慣例**：
  - PR body 一律用英文撰寫，方便後續被 changelog、release note 或其他自動化工具引用
- **委派的 skill**：
  - 標題交給 [`ultra-branch-creator`](../ultra-branch-creator)、commit 訊息交給 [`ultra-commit-creator`](../ultra-commit-creator)
