# Ultra Repo Creator

把建立新 repo 的流程拆成三個可組合的階段：本地初始化、遠端、branch 保護。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

從零建立一個 repository：本地 `git init`、在 GitHub 建立遠端、套用 branch 保護。三個階段彼此獨立，可從任一階段進入，也可跳過已完成的部分。建立 repo 之後的 commit 與 branch 整理，交給 `ultra-branch-creator`／`ultra-commit-creator`／`ultra-pr-creator`。詳細規格見 `SKILL.md`。

　

## 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-repo-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

## 設計取向

- **支援從任意階段切入**：
  - 本地初始化、遠端建立與 branch 保護三個階段彼此獨立
  - 若既有 repo 只缺 branch 保護，可直接從第三階段開始，不必重跑前面的初始化流程
- **只負責 repo 建立與設定編排**：
  - 本 skill 專注於建立 repo、綁定遠端與套用基礎保護設定
  - commit、branch 與 PR 的命名和撰寫，分別委派給 `ultra-commit-creator`、`ultra-branch-creator` 與 `ultra-pr-creator`
- **高影響操作前先確認**：
  - 建立 repo、push、修改 repo 設定前，先攤開即將執行的指令與影響範圍
  - 不把多個階段串成一次跑完，避免在未確認的情況下連續改變本地與遠端狀態
- **初始 commit 保持最小化**：
  - 初始 commit 只放一份空的 `README.md`
  - 既有檔案先保留在工作區並維持 untracked，等遠端綁定完成後，再依實際需求整理進後續 commit
  - 避免在遠端建立與保護設定完成前，就把一批檔案寫進歷史
- **預設建立 public repo**：
  - GitHub 免費方案的 ruleset 只對 public repo 生效，private repo 套用時會回傳 `403`
  - 若 repo 需要 branch 保護，應在建立時選擇 public；選擇 private 即代表放棄第三階段的保護設定
- **以 ruleset 套用 branch 保護**：
  - branch 保護設定集中在 `assets/main-protection-ruleset.json`
  - owner 與 repo 由 URL 帶入，因此同一份 ruleset 可重用於不同 repo
  - 保護目標鎖定 `~DEFAULT_BRANCH`，要求透過 PR merge，並禁止刪除與 force push
- **針對單人 repo 校準規則**：
  - `required_approving_review_count` 設為 0，避免單人 repo 因無法核可自己的 PR 而卡住
  - 預設不開放 admin bypass，repo 擁有者也必須走 PR 流程（刻意保留的自我約束）

　

## 預設與相依

- **遠端託管**：
  - 預設 GitHub，透過 `gh` CLI／`gh api` 操作
  - 換其他託管平台時，改遠端建立與 ruleset 套用方式即可
- **預設 branch**：
  - 一律 `main`(`git branch -M main`)
- **branch 保護設定**：
  - `assets/main-protection-ruleset.json`（review count 0、無 bypass）
  - 協作 repo 可調高 review count
- **委派的 skills**：
  - 後續整理委派給 `ultra-branch-creator`／`ultra-commit-creator`／`ultra-pr-creator`
  - 若無這些 skill，替換為其他 branch／commit／PR 慣例即可
