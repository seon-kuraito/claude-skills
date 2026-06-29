# Ultra React Publisher

一鍵從零建立並部署一個 React 專案，從 scaffold、初始化到部署到 GitHub Pages 都全程自動完成，過程不發問，也不停在授權提示。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **完整流程手動串起來太繁瑣**：
  - 從 scaffold、綁遠端、保護 `main`、初始化、設定部署到確認上線，每一步都要切換工具與 branch，手動跑很容易漏掉細節或弄錯順序
- **各個 skill 會在關卡停下來問**：
  - 各階段的 skill 預設會出選單、停在 Execution gate 等待確認
  - 要一口氣跑完整條 pipeline 時，這些互動反而會卡住流程
- **分支路由需要集中處理**：
  - 各階段的 skill 只負責開 branch 或發 PR，不處理 merge 路線與 PR 策略，所以需要一層編排統一決定

　

## 這個 skill 做什麼（WHAT）

- **一口氣跑完 create → initialize → publish**：
  - 從空目錄到 GitHub Pages 上的 live URL，全程自動、不提問
- **薄編排層，驅動三個階段 skill**：
  - 只負責順序、取代選單的固定預設、gate 覆寫與 git 分支路由
  - 實際指令、assets、模板與版本仍交給相依的 skill
- **固定的 git flow**：
  - `main` 受保護，所有變更都經 PR 進入
  - `preparing` 是不受保護的測試／部署 branch
  - 初始化檔案先 merge 進 `preparing`，再發 PR 給 `main`
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 如何使用這個 skill（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-react-publisher
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索為 `/ultra-react-publisher`（`disable-model-invocation`，只由使用者手動觸發）
  - 不覆寫同名的實體目錄，避免影響直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **harness engineering 的編排層**：
  - 這個 skill 負責把 scaffold、初始化與部署串成一條固定路徑，並處理順序、固定預設與 gate 覆寫
  - 各階段的實際做法仍交給對應 skill，避免重複定義後慢慢偏掉
- **覆寫各階段 skill 的互動模型**：
  - frontmatter 以 `disable-model-invocation` 限定只由使用者手動觸發，並停用 `AskUserQuestion`
  - 載入的階段 skill 若要求確認或停在 gate，一律用固定預設覆寫
- **集中處理 git 分支路由**：
  - 各階段的 skill 不管 branch 要怎麼開、怎麼合，因此哪條 branch merge 去哪、要發 PR 或直接合，都由這個編排層決定
- **首次執行先取得同意**：
  - 第一次在某台機器執行時，先顯示固定的風險警告並要求同意
  - 之後用 `~/.claude/` 底下的 per-machine marker 記住，不再重複詢問（runtime 狀態，不進版控）

　

### 預設與相依

- **固定預設**：
  - 框架使用 Vite + React（React Compiler、TypeScript）
  - 遠端 repo 建成 public，部署 branch 固定為 `preparing`
  - 部署目標是 GitHub Pages（Vite SPA）
  - 自動把 `vite.config.ts` 的 `base` 設為 `/<專案名>/`，讓 GitHub Pages 子路徑下的資源（favicon、`/vite.svg` 等）能正確載入
  - 最後反覆檢查 live URL，直到回傳 HTTP 200，並以 `code .` 開啟 VS Code
- **相依的 skill（required）**：
  - [`ultra-repo-creator`](../ultra-repo-creator)
  - [`ultra-project-initializer`](../ultra-project-initializer)
  - [`ultra-project-deployer`](../ultra-project-deployer)
  - [`ultra-branch-creator`](../ultra-branch-creator)
  - [`ultra-commit-creator`](../ultra-commit-creator)
  - [`ultra-pr-creator`](../ultra-pr-creator)
- **執行環境**：
  - 需在 bypass-permissions 工作階段執行，啟動指令為 `claude --dangerously-skip-permissions`
  - 停用 `AskUserQuestion` 只會擋掉 skill 的提問，harness 對 `gh`／`git`／`npm` 的授權提示仍要靠 bypass 模式才會靜默
