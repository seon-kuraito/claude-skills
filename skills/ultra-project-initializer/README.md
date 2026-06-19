# Ultra Project Initializer

在 repo 建立後，補齊專案初始化需要的基礎設定：`.gitignore`、空白 `.claude/CLAUDE.md` 與 GitHub 的 Conventional Commits type 標籤。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **repo 建好後仍有一串瑣碎設定**：
  - `.gitignore`、`CLAUDE.md`、GitHub 標籤每次都要手動補上，容易遺漏或不一致
- **這些設定與「建 repo」是不同層級**：
  - `git init`／遠端／分支保護是 repo 層級；上述 scaffold 是 project 層級，一個 repo（例如：monorepo）可能需要執行多次
- **標籤要與 commit／branch／PR 對齊**：
  - [`ultra-pr-creator`](../ultra-pr-creator) 會使用 `--label <type>` 且假設標籤已存在，因此需要先把 type 標籤建好

　

## 這個 skill 做什麼（WHAT）

- **補齊專案初始化設定**：
  - 可選擇建立 `.gitignore`、空白 `.claude/CLAUDE.md`、GitHub 的 Conventional Commits type 標籤
- **可隨時插入的階段**：
  - 相對於 [`ultra-repo-creator`](../ultra-repo-creator) 的「建立」階段，本 skill 屬於「初始化」階段；通常在 repo 建好後先執行，也可在任意時間點插入
- **project 層級**：
  - 一個 repo 可包含多個 project（monorepo），必要時先確認要對哪個 project 操作
- **完整規格放在 SKILL.md**：
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
  - `.gitignore`／`.claude/CLAUDE.md` 需要已完成 `git init`；標籤需要已有 GitHub 遠端
  - 分支保護不是前提；若連 repo 都還沒有，則指向 [`ultra-repo-creator`](../ultra-repo-creator)
- **用多選確認要做哪些項目**：
  - 用 `AskUserQuestion` 列出選項，讓使用者自由勾選組合
- **檔案建立走固定 branch 與 commit**：
  - 有選到檔案建立項目時，建立 `chore/initial-project-setup` branch，並逐項各發一個固定訊息的 commit
  - 建立標籤只會改動 GitHub 端，不會產生 commit
- **只負責初始化，不重做建立階段**：
  - 不處理 `git init`／遠端／保護（由 [`ultra-repo-creator`](../ultra-repo-creator) 負責）
  - branch、commit 的命名與撰寫委派給 [`ultra-branch-creator`](../ultra-branch-creator) 與 [`ultra-commit-creator`](../ultra-commit-creator)
- **高影響操作前先確認**：
  - `gh label create`、push 前先列出即將執行的內容並取得確認

　

### 預設與相依

- **`.gitignore` 模板**：
  - 內容為 macOS、編輯器／IDE 與 log 產物（[`assets/gitignore-template`](assets/gitignore-template)）
- **type 標籤**：
  - 取自 Conventional Commits 的十個 type（[`assets/type-labels.json`](assets/type-labels.json)，含名稱與顏色，無描述）
- **空白檔**：
  - `.claude/CLAUDE.md` 建為空白檔
- **委派的 skills**：
  - 開 branch 用 [`ultra-branch-creator`](../ultra-branch-creator)、發 commit 用 [`ultra-commit-creator`](../ultra-commit-creator)
  - 若無這兩個 skill，將對應步驟替換為其他 branch／commit 慣例即可