# React Publisher

一鍵從零建立並部署一個 React 專案，從 scaffold、初始化到部署到 GitHub Pages 都全程自動完成，過程不發問，也不停在授權提示。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 設計背景（WHY）

- **完整流程需要手動串接多個階段**：
  - 從 scaffold、綁定遠端、保護 `main`、初始化、設定部署到確認上線，流程涉及多次工具與 branch 切換；手動執行容易遺漏步驟或順序錯誤
- **各個 skill 會在關卡停下來問**：
  - 各階段的 skill 預設會出選單、停在 Execution gate 等待確認
  - 需要連續執行完整 pipeline 時，這些互動會中斷流程
- **分支路由需要集中處理**：
  - 各階段的 skill 只負責開 branch 或發 PR，不處理 merge 路線與 PR 策略，所以需要一層編排統一決定

　

## 功能範圍（WHAT）

- **連續執行 create → initialize → publish**：
  - 從空目錄到 GitHub Pages 上的 live URL，全程自動、不提問
- **薄編排層，驅動三個階段 skill**：
  - 只負責順序、取代選單的固定預設、gate 覆寫與 git 分支路由
  - 實際指令、assets、模板與版本仍交給相依的 skill
- **固定的 git flow**：
  - `main` 受到保護，所有變更都必須透過 PR 進入；`preparing` 則是不受保護的測試／部署 branch，內容維持與 `main` 同步
  - 非部署變更（初始化檔案、Vite 設定）一律先 merge 進 `preparing`，確認沒問題再發 PR 進 `main`
  - 部署 workflow 只保留在 `preparing`
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-react-publisher
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索為 `/sk-react-publisher`（`disable-model-invocation`，只由使用者手動觸發）
  - 不覆寫同名的實體目錄，避免影響直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **harness engineering 的編排層**：
  - 這個 skill 負責把 scaffold、初始化與部署串成一條固定路徑，並處理順序、固定預設與 gate 覆寫
  - 各階段的實際做法仍交給對應 skill，避免重複定義後慢慢偏掉
- **覆寫各階段 skill 的互動模型**：
  - frontmatter 以 `disable-model-invocation` 限定只由使用者手動觸發，並停用 `AskUserQuestion`
  - 載入的階段 skill 若要求確認或停在 gate，一律用固定預設覆寫
- **集中處理 git 分支路由**：
  - 各階段的 skill 不處理 branch 的建立與合併方式；branch 的合併目標，以及採用 PR 或直接合併，均由此編排層決定
- **首次執行先取得同意**：
  - 第一次在某台機器執行時，先顯示固定的風險警告並要求同意
  - 之後用 `~/.claude/` 底下的 per-machine marker 記住，不再重複詢問（runtime 狀態，不進版控）
- **收錄驗證案例**：
  - `tests/checks/pr-templates.py` 驗證兩份 PR body 模板的段落順序與全形間隔，以及同意閘門的標記（靜態執行，不需要 LLM）
  - 這個 skill 由使用者輸入名稱直接呼叫，模型不會路由到它，因此不收錄模型層案例

　

### 預設與相依

- **固定預設**：
  - 框架使用 Vite + React（React Compiler、TypeScript）
  - 遠端 repo 建成 public，部署 branch 固定為 `preparing`
  - 部署目標是 GitHub Pages（Vite SPA）
  - 自動把 `vite.config.ts` 的 `base` 設為 `/<專案名>/`，讓 GitHub Pages 子路徑下的資源能正確載入
  - 最後反覆檢查 live URL，直到回傳 HTTP 200，並以 `code .` 開啟 VS Code
- **委派對象（required）**：
  - [`sk-repo-creator`](../sk-repo-creator)
  - [`sk-project-initializer`](../sk-project-initializer)
  - [`sk-project-deployer`](../sk-project-deployer)
  - [`sk-branch-creator`](../sk-branch-creator)
  - [`sk-commit-creator`](../sk-commit-creator)
  - [`sk-pr-creator`](../sk-pr-creator)
- **執行環境**：
  - 需在 bypass-permissions 工作階段執行，啟動指令為 `claude --dangerously-skip-permissions`
  - 停用 `AskUserQuestion` 只會略過 skill 的提問，harness 對 `gh`／`git`／`npm` 的授權提示仍要靠 bypass 模式才會靜默
