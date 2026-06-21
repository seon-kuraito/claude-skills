# Ultra Project Initializer

在 repo 建立後，補齊常用的專案設定與 GitHub 設定。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **repo 建好後仍有一串瑣碎設定**：
  - `.gitignore`、`CLAUDE.md`、main 分支保護、GitHub 標籤每次都要手動補上，容易遺漏或不一致
- **repo 建立與 project 設定要分開處理**：
  - `git init`／遠端通常只做一次；`.gitignore`、`CLAUDE.md` 這類設定則跟實際 project 走，monorepo 裡可能需要處理多次
- **標籤要與 commit／branch／PR 對齊**：
  - [`ultra-pr-creator`](../ultra-pr-creator) 會使用 `--label <type>` 且假設標籤已存在，因此需要先把 type 標籤建好

　

## 這個 skill 做什麼（WHAT）

- **補齊專案初始化設定**：
  - 可選擇建立 `.gitignore`、空白 `.claude/CLAUDE.md`，用 Conventional Commits type 標籤取代 GitHub 預設標籤，或對 `main` 套用分支保護
- **可隨時插入的階段**：
  - 相對於 [`ultra-repo-creator`](../ultra-repo-creator) 的「建立」階段，本 skill 屬於「初始化」階段；通常在 repo 建好後先執行，也可在任意時間點插入
- **project 層級**：
  - 一個 repo 可包含多個 project（monorepo），必要時先確認要對哪個 project 操作
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
- **執行前只要求 repo 存在**：
  - `.gitignore`／`.claude/CLAUDE.md` 只需要已完成 `git init`；標籤與分支保護需要已有 GitHub 遠端，且分支保護在 GitHub 免費方案還要求 repo 為 public
  - 如果 repo 還沒建立，則先指向 [`ultra-repo-creator`](../ultra-repo-creator)
- **用多選確認要做哪些項目**：
  - 一律用 `AskUserQuestion` 的多選（`multiSelect`）一次列出四個選項，不用文字來回或逐題詢問
- **檔案建立走固定 branch 與 commit**：
  - 有選到檔案建立項目時，建立 `chore/initial-project-setup` branch，並逐項各發一個固定訊息的 commit
  - 標籤會先刪除 GitHub 的 9 個預設標籤，再建立 type 標籤；分支保護使用 ruleset 套到 `main`
  - 標籤與分支保護都只改 GitHub 端，不會產生 commit
- **完成後提醒開 PR**：
  - 檔案 commit 落在 `chore/initial-project-setup`，最後詢問是否開 PR（交給 [`ultra-pr-creator`](../ultra-pr-creator) 處理）
  - 只選會直接改 GitHub 端的項目（標籤／分支保護）時，沒有 branch／commit，也就沒有 PR
- **只負責初始化，不重做建立階段**：
  - 不處理 `git init`／遠端（由 [`ultra-repo-creator`](../ultra-repo-creator) 負責）
  - branch、commit 的命名與撰寫委派給 [`ultra-branch-creator`](../ultra-branch-creator) 與 [`ultra-commit-creator`](../ultra-commit-creator)
- **高影響操作前先確認**：
  - `gh label delete`、`gh label create`、套用 ruleset 的 `gh api --method POST`、push 前先列出即將執行的內容並取得確認

　

### 預設與相依

- **`.gitignore` 模板**：
  - 內容為 macOS、編輯器／IDE 與 log 產物（[`assets/gitignore-template`](assets/gitignore-template)）
- **type 標籤**：
  - 取自 Conventional Commits 的十個 type（[`assets/type-labels.json`](assets/type-labels.json)，含名稱與顏色，無描述）
  - 建立前先刪除 GitHub 的 9 個預設標籤（`bug`、`documentation`、`duplicate`、`enhancement`、`good first issue`、`help wanted`、`invalid`、`question`、`wontfix`），自訂標籤保留
- **分支保護 ruleset**：
  - [`assets/main-protection-ruleset.json`](assets/main-protection-ruleset.json)（鎖定 `~DEFAULT_BRANCH`、review count 0、無 admin bypass）
  - 要求透過 PR merge，並禁止刪除與 force push；協作 repo 可依需要調高 review count
  - GitHub 免費方案的 ruleset 只對 public repo 生效
- **空白檔**：
  - `.claude/CLAUDE.md` 建為空白檔
- **委派的 skills**：
  - 後續整理委派給 [`ultra-branch-creator`](../ultra-branch-creator)／[`ultra-commit-creator`](../ultra-commit-creator)／[`ultra-pr-creator`](../ultra-pr-creator)
  - 若無這些 skill，替換為其他 branch／commit／PR 慣例即可
