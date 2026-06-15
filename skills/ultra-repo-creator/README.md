# Ultra Repo Creator

把建立一個新 repo 拆成三個可組合的階段：本地初始化、遠端、分支保護。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

從零 bootstrap 一個新 repository——本地 `git init`、在 GitHub 建立遠端、套用分支保護三個階段，可從任一階段進入、跳過已完成的部分。建立 repo 之後的 commit 與分支整理，交棒給 `ultra-branch-creator`／`ultra-commit-creator`／`ultra-pr-creator`。詳細規格見 `SKILL.md`。

　

## 設計取向

- **三階段可組合，從任一階段進入**：
  - 本地初始化 → 遠端 → 分支保護，各自獨立
  - 既有 repo 只缺保護時，可直接從第三階段切入
- **自身只當編排者，後續動作外包**：
  - 只負責把 repo 生出來
  - commit／branch／PR 的撰寫交棒給 `ultra-branch-creator`／`ultra-commit-creator`／`ultra-pr-creator`
- **破壞性操作前先確認**：
  - 建 repo、push、改 repo 設定前停下，把指令與影響旗標攤給使用者確認
  - 不把多個階段串成一次跑完
- **初始 commit 只放一份空 `README.md`**：
  - 既有檔案先留在工作區、untracked，直到綁定遠端後才整理進 commit
  - 用意：遠端綁定前不把一堆檔案塞進歷史
- **預設 public repo**：
  - GitHub Free 的 ruleset 只在 public repo 生效，private 會回 `403`
  - 要分支保護的 repo 從一開始就 public；選 private 等於放棄第三階段
- **分支保護以 ruleset 一鍵套用**：
  - 設定收在 `assets/main-protection-ruleset.json`，owner／repo 走 URL，任何 repo 重用同一份
  - 鎖定 `~DEFAULT_BRANCH`：要求 PR 才能 merge、擋刪除與 force-push
- **為單人 repo 校準**：
  - `required_approving_review_count` 設 0（無法核可自己的 PR，設更高會把每個 PR 卡死）
  - 預設不給 admin bypass，擁有者一樣走 PR——這是刻意的

　

## 預設與相依（可依需求抽換）

以下假設可依環境抽換：

- **遠端託管**：
  - 預設 GitHub，經 `gh` CLI／`gh api` 操作
  - 換其他託管商時，改遠端建立與 ruleset 套用方式即可
- **預設分支**：
  - 一律 `main`(`git branch -M main`)
- **委派的 skills**：
  - 後續整理委派給 `ultra-branch-creator`／`ultra-commit-creator`／`ultra-pr-creator`
  - 若無這些 skill，替換為其他 branch／commit／PR 慣例即可
- **分支保護設定**：
  - `assets/main-protection-ruleset.json`（review count 0、無 bypass）
  - 協作 repo 可調高 review count
