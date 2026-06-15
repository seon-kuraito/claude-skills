# Ultra PR Creator

根據目前分支與 base 分支之間的 commits 與 diff，自動產生 GitHub pull request 的標題與固定三段式 body。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

替 GitHub PR 產生標題與固定三段式 body。body 一律包含 📝 Summary／🎯 Scope／✅ Test plan，並包在單一可複製的 code block 裡；內容會根據目前分支相對於 base 分支的 commits 與 diff 整理而成，標題則直接沿用分支名稱。詳細規格見 `SKILL.md`。

　

## 設計取向

- **固定三段式 body**：
  - 一律包含 Summary／Scope／Test plan 三段，並搭配 emoji 標題
  - 結構固定、形狀可預測，讓 reviewer 每次都能用相同方式快速掃讀 PR
- **單一可複製的 code block**：
  - 整份 body 包在 plain ``` fence 裡，不加語言標籤，避免某些 renderer 的 copy button 失效
  - section 之間用全形空格（U+3000）保留間距，讓內容在 GitHub 上更有呼吸感
- **標題沿用分支名稱**：
  - 不另外替 PR title 造句，直接逐字沿用目前分支名稱
  - 分支命名品質由 `ultra-branch-creator` 負責把關
- **body 根據分支變更整理，不憑空撰寫**：
  - 讀取 `git log`／`git diff`，根據目前分支相對於 base 分支的 commits 與 diff 整理內容
  - 將 commits 收斂成 Summary 條列，並從 diff 判斷影響範圍與測試重點
- **任何 gh 指令前先確認**：
  - 執行 `create`／`edit`／`merge`／`close` 前，先攤開 title、body 與影響旗標，交由使用者確認
  - 不把 PR 建立與 merge 串成一步，避免在未確認的情況下直接改變遠端狀態
- **merge 保留歷史與本地標籤**：
  - 預設使用 `--merge`，產生 merge commit，保留策展過的逐筆 commit
  - 預設不使用 `--delete-branch`，保留本地分支標籤
  - 不對已策展過的分支使用 `--squash`
- **拆 references／assets**：
  - 將逐段深入指南放在 `references/`（例如 sections、examples）
  - 將 body 模板抽到 `assets/pr-body-template.md`

　

## 預設與相依（可依需求抽換）

- **委派的 skill**：
  - 標題交給 `ultra-branch-creator`、逐筆 commit 訊息交給 `ultra-commit-creator`
- **PR 的 assignee 與 label**：
  - 預設自我指派（`@me`，即 repo 擁有者 `seon-kuraito`），並貼上分支 type 對應的標籤
  - 依賴 repo 已建好那 10 個 type 標籤（與 branch／commit 同一套）；換的 repo 若沒有，跳過 `--label`
- **預設 main 為 base 分支**：
  - 用 `master`／`develop`／feature trunk 時自行推斷或問一次
- **語言慣例**：
  - PR body 一律英文（changelog／release-note 等工具預設英文）
