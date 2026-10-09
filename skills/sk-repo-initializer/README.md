# Repo Initializer

在 repo 建立後，補齊常用的本地與 GitHub 設定。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 設計背景（WHY）

- **repo 建立後仍有零散設定待補**：
  - `LICENSE`、`CLAUDE.md`、main 分支保護、GitHub 標籤與部署分支等設定通常需要手動補齊，可能發生遺漏或不一致
- **repo 建立與初始化設定分階段處理**：
  - `git init` 與遠端綁定由建立階段處理；`LICENSE`、`CLAUDE.md`、標籤及分支設定則由初始化階段處理
- **標籤需與 commit／branch／PR 類型一致**：
  - [`sk-pr-creator`](../sk-pr-creator) 會使用 `--label <type>`，因此需預先建立對應的 type 標籤

　

## 功能範圍（WHAT）

- **補齊專案初始化設定**：
  - 可依需求建立 `LICENSE`、空白 `.claude/CLAUDE.md`，或新增 Conventional Commits type 標籤
  - 可為 `main` 套用分支保護，或建立部署分支（`develop`／`staging`）
- **確認是否需要 release 流程**：
  - repo 有遠端時，每次都會詢問；選擇採用後，由 [`sk-release-creator`](../sk-release-creator) 開始第一個版本
  - 設定檔的 PR merge 後，再確認是否立即發布該版本
- **可獨立執行的階段**：
  - 此 skill 負責 [`sk-repo-creator`](../sk-repo-creator)「建立」階段之後的「初始化」工作，通常在 repo 建立後執行，也可視需要於其他時間執行
- **repo 層級**：
  - 標籤、分支保護、部署分支與 release 流程皆以 repo 為設定單位
- **建立部署分支後可接續部署**：
  - 若選擇建立部署分支，完成後會詢問是否進入部署階段
  - 遠端分支的部署設定交給 [`sk-repo-deployer`](../sk-repo-deployer) 處理
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 將整個 skill 目錄複製至 `~/.claude/skills/`
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-repo-initializer
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索並載入
  - 不會覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **可獨立執行的階段**：
  - 可於流程中的任意時間執行，通常在 repo 建立後優先處理
  - 與「部署」階段（`sk-repo-deployer`）皆為 repo 層級的獨立階段
- **執行前需確認 repo 已建立**：
  - `LICENSE`／`.claude/CLAUDE.md` 僅需完成 `git init`；標籤與分支保護需設定 GitHub 遠端，且 GitHub 免費方案僅支援 public repo 的分支保護
  - 若 repo 尚未建立，請先使用 [`sk-repo-creator`](../sk-repo-creator)
- **以分組多選確認項目**：
  - 使用 `AskUserQuestion` 的多選（`multiSelect`）列出選項，無須透過文字或逐題確認
  - 依照「是否需要遠端」分成兩組：Q1 本地檔案（`LICENSE`／`.claude/CLAUDE.md`）、Q2 GitHub／遠端項目（type 標籤／分支保護／部署分支）
  - 沒有遠端時，Q2 會整題省略
- **檔案建立使用固定 branch 與 commit**：
  - 選取檔案建立項目時，建立 `chore/initial-project-setup` branch，並為每個項目分別建立使用固定訊息的 commit
  - repo 已有標籤時，先詢問要刪除後新增、保留後新增，或沿用現有標籤；分支保護使用 ruleset 套到 `main`
  - 標籤與分支保護都只改 GitHub 端，不會產生 commit
- **完成後提醒開 PR**：
  - 檔案 commit 會放在 `chore/initial-project-setup`，最後詢問是否開 PR（交給 [`sk-pr-creator`](../sk-pr-creator) 處理）
  - PR 的 base 由 `sk-pr-creator` 根據 repo branch 判斷，因此部署分支與 release branch 會先推送至遠端
  - 僅選取 GitHub 端項目（標籤／分支保護）時，不會建立 branch、commit 或 PR
- **初始化範圍**：
  - 不處理 `git init`／遠端（由 [`sk-repo-creator`](../sk-repo-creator) 負責）
  - branch 命名交由 [`sk-branch-creator`](../sk-branch-creator) 處理；commit 訊息使用固定文案，無須載入 [`sk-commit-creator`](../sk-commit-creator)
- **高影響操作前先確認**：
  - `gh label delete`、`gh label create`、套用 ruleset 的 `gh api --method POST`、push 前先列出即將執行的內容並取得確認
- **提供確定性檢查**：
  - `tests/checks/check-assets.py` 用來驗證 `type-labels.json`、ruleset 與 `licenses/` 模板（靜態執行，不需要 LLM）
  - `tests/model.json` 收錄觸發案例與行為案例

　

### 預設與相依

- **`LICENSE` 模板**：
  - 內建 MIT、Apache-2.0、GPL-3.0、Proprietary 四種（[`assets/licenses/`](assets/licenses)），清單外的授權（例如：BSD-3-Clause）則視需要從標準來源取得
  - 年份以 `{{YEAR}}` placeholder 表示，套用時替換成當年；著作權人固定為 `Seon Kuraito`
  - GPL-3.0 依 FSF 要求逐字保留；年份與作者記載於各檔案標頭，不替換 `LICENSE` 內容
  - Proprietary 保留所有權利，不授予任何開源權利，適用於不對外開源的專案
- **type 標籤**：
  - 包含 Conventional Commits 的 11 種分類，以及 release PR 專用的 `release`，共 12 個（[`assets/type-labels.json`](assets/type-labels.json)，含名稱、顏色與描述）
  - 建立前先列出 repo 現有的標籤；若已存在標籤，詢問要刪除後新增、保留後新增，或沿用現有標籤
  - 選擇保留後新增時，已存在的同名標籤維持原樣，不會被覆寫
  - 不區分 GitHub 預設標籤與原本就有的標籤，皆列出供使用者決定
- **分支保護 ruleset**：
  - [`assets/main-protection-ruleset.json`](assets/main-protection-ruleset.json)（鎖定 `~DEFAULT_BRANCH`、review count 0、無 admin bypass）
  - 要求透過 PR merge，並禁止刪除與 force push；協作 repo 可依需要調高 review count
  - GitHub 免費方案的 ruleset 只對 public repo 生效，repo 之後轉為 private 會讓保護失效
- **部署分支**：
  - 可以選擇 `develop`（整合線）與 `staging`（測試環境線），分支會從 `main` 開出並推上遠端
  - 分支名稱依個人工作習慣設計，與標準 git-flow／gitlab-flow 的定義可能不同
  - 只在分支不存在時補建，不設定保護，也不處理合併流程（分支管理不在這個 skill 的範圍內）
  - 建立的分支可由 [`sk-repo-deployer`](../sk-repo-deployer) 設為部署來源
- **release 流程**：
  - 此 skill 負責確認是否採用 release 流程；流程判斷、版本建立與發布均由 [`sk-release-creator`](../sk-release-creator) 處理
  - 若無法使用該 skill，則說明原因，並依未採用 release 流程的方式繼續
- **空白檔**：
  - `.claude/CLAUDE.md` 建為空白檔
- **委派對象**：
  - 後續的 branch 與 PR 整理由 [`sk-branch-creator`](../sk-branch-creator)／[`sk-pr-creator`](../sk-pr-creator) 處理
  - 若未提供上述 skill，則依現有的 branch／PR 慣例處理
