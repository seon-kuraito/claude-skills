# Ultra Project Initializer

在 repo 建立後，補齊常用的專案設定與 GitHub 端設定。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **repo 建好後還有一串瑣碎設定**：
  - `LICENSE`、`CLAUDE.md`、main 分支保護、GitHub 標籤與部署分支等設定常常要手動補上，容易遺漏或不一致
- **repo 建立與 project 設定要分開處理**：
  - `git init`／遠端通常只做一次；`LICENSE`、`CLAUDE.md` 這類設定則跟著實際 project 走，monorepo 裡可能需要處理多次
- **標籤要與 commit／branch／PR 對齊**：
  - [`ultra-pr-creator`](../ultra-pr-creator) 會使用 `--label <type>` 且假設標籤已存在，所以需要先準備好 type 標籤

　

## 這個 skill 做什麼（WHAT）

- **補齊專案初始化設定**：
  - 可依需要建立 `LICENSE`、空白 `.claude/CLAUDE.md`，或用 Conventional Commits type 標籤取代 GitHub 預設標籤
  - 可以替 `main` 套用分支保護，或建立發布時使用的部署分支（`develop`／`preparing`）
- **可隨時插入的階段**：
  - 相對於 [`ultra-repo-creator`](../ultra-repo-creator) 的「建立」階段，這個 skill 負責「初始化」階段；通常在 repo 建好後先執行，也可在任意時間點插入
- **project 層級**：
  - 一個 repo 可能包含多個 project（monorepo），必要時先確認要對哪個 project 操作
- **建立部署分支後可接續發布**：
  - 若選擇建立部署分支，完成後會詢問是否進入部署階段
  - 遠端分支的部署設定交給 [`ultra-project-publisher`](../ultra-project-publisher) 處理
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
  scripts/link-skill.sh ultra-project-initializer
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不會覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **可隨時插入的獨立階段**：
  - 不綁定在流程開頭或結尾，任意時間點都能執行；通常在 repo 剛建好後最先做
  - 與未來的「發布」階段（`ultra-project-publisher`）同樣是可插入的 project 層級階段
- **執行前只要求已有 repo**：
  - `LICENSE`／`.claude/CLAUDE.md` 只需要已完成 `git init`；標籤與分支保護需要已有 GitHub 遠端，且分支保護在 GitHub 免費方案還要求 repo 為 public
  - 如果 repo 還沒建立，則先指向 [`ultra-repo-creator`](../ultra-repo-creator)
- **用分組多選確認要做哪些項目**：
  - 一律使用 `AskUserQuestion` 的多選（`multiSelect`）列出選項，避免用文字來回或逐題確認
  - 依照「是否需要遠端」分成兩組：Q1 本地檔案（`LICENSE`／`.claude/CLAUDE.md`）、Q2 GitHub／遠端項目（type 標籤／分支保護／部署分支）
  - 沒有遠端時，Q2 會整題省略
- **檔案建立走固定 branch 與 commit**：
  - 只要選到檔案建立項目，就建立 `chore/initial-project-setup` branch，並讓每個項目各產生一個固定訊息的 commit
  - 標籤會先刪除 GitHub 的 9 個預設標籤，再建立 type 標籤；分支保護使用 ruleset 套到 `main`
  - 標籤與分支保護都只改 GitHub 端，不會產生 commit
- **完成後提醒開 PR**：
  - 檔案 commit 會放在 `chore/initial-project-setup`，最後詢問是否開 PR（交給 [`ultra-pr-creator`](../ultra-pr-creator) 處理）
  - 只選會直接改 GitHub 端的項目（標籤／分支保護）時，沒有 branch／commit，也就沒有 PR
- **只負責初始化，不重做建立階段**：
  - 不處理 `git init`／遠端（由 [`ultra-repo-creator`](../ultra-repo-creator) 負責）
  - branch、commit 的命名與撰寫委派給 [`ultra-branch-creator`](../ultra-branch-creator) 與 [`ultra-commit-creator`](../ultra-commit-creator)
- **高影響操作前先確認**：
  - `gh label delete`、`gh label create`、套用 ruleset 的 `gh api --method POST`、push 前先列出即將執行的內容並取得確認
- **提供確定性檢查**：
  - `evals/check-assets.py` 用來驗證 `type-labels.json`、ruleset 與 `licenses/` 模板（靜態執行，不需要 LLM）

　

### 預設與相依

- **`LICENSE` 模板**：
  - 內建 MIT、Apache-2.0、GPL-3.0 三種（[`assets/licenses/`](assets/licenses)），清單外的授權（例如：BSD-3-Clause）則視需要從標準來源取得
  - 年份以 `{{YEAR}}` placeholder 表示，套用時替換成當年；著作權人固定為 `Seon Kuraito`
  - GPL-3.0 依 FSF 要求逐字保留，年份／作者寫在各檔案標頭而非 `LICENSE`，因此不做替換
- **type 標籤**：
  - 取自 Conventional Commits 的 11 種分類（[`assets/type-labels.json`](assets/type-labels.json)，含名稱、顏色與描述）
  - 建立前先刪除 GitHub 的 9 個預設標籤（`bug`、`documentation`、`duplicate`、`enhancement`、`good first issue`、`help wanted`、`invalid`、`question`、`wontfix`），自訂標籤保留
- **分支保護 ruleset**：
  - [`assets/main-protection-ruleset.json`](assets/main-protection-ruleset.json)（鎖定 `~DEFAULT_BRANCH`、review count 0、無 admin bypass）
  - 要求透過 PR merge，並禁止刪除與 force push；協作 repo 可依需要調高 review count
  - GitHub 免費方案的 ruleset 只對 public repo 生效
- **部署分支**：
  - 可以選擇 `develop`（整合線）與 `preparing`（預備上線線），分支會從 `main` 開出並推上遠端
  - 依照個人使用習慣整理出的分支命名，不完全等同於標準的 git-flow／gitlab-flow
  - 只在分支不存在時補建，不設定保護，也不處理合併流程（分支管理不在這個 skill 的範圍內）
  - 可以交給 [`ultra-project-publisher`](../ultra-project-publisher) 作為部署來源分支
- **空白檔**：
  - `.claude/CLAUDE.md` 建為空白檔
- **委派的 skills**：
  - 後續整理委派給 [`ultra-branch-creator`](../ultra-branch-creator)／[`ultra-commit-creator`](../ultra-commit-creator)／[`ultra-pr-creator`](../ultra-pr-creator)
  - 若無這些 skill，改用其他 branch／commit／PR 慣例即可
