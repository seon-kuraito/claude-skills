# Ultra Repo Creator

從零建立 repo 時，先選一種模板（blank／meta-repo／framework），最後再確認要不要綁定遠端 repo。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **開 repo 需要重複跑一串步驟**：
  - 每次都要處理 `git init`、建立遠端、綁定 remote 等流程，手動做容易漏掉細節
- **初始 commit 容易塞太多**：
  - 遠端還沒綁好就把一批檔案寫進歷史，後面要整理會比較麻煩

　

## 這個 skill 做什麼（WHAT）

- **依模板建立對應的 repo**：
  - 一律先選模板：blank／meta-repo／framework
  - blank＝本地空白 repo
  - meta-repo＝協調層（scaffold＋git ceremony）
  - framework＝對話式建立
- **先完成本地流程再碰遠端**：
  - 先在本地把 repo 建好（`git init`＋commit／scaffold），中途不再額外確認
  - 結尾再確認是否綁 public 遠端並 push
- **可接續既有 repo**：
  - 若已有 `.git`，跳過模板選擇，直接補完缺的步驟
- **建立完成後可接續初始化專案**：
  - 三種模板建好後都會詢問是否進入初始化階段
  - `.gitignore`、`.claude/CLAUDE.md`、GitHub Labels、branch 保護等選配項目，交給初始化 skill 處理
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
  scripts/link-skill.sh ultra-repo-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **直接執行本地建立流程**：
  - 使用意圖明確就直接載入，一律先顯示模板選單
  - 選定後，本地步驟（`git init`、commit、scaffold）直接執行、免確認
- **兩階段模型與接續既有 repo**：
  - 專案設定分「建立」（本 skill）與「初始化」（另一個 skill）兩階段
  - 若已是 git repo，依目前狀態接續建立流程，只處理還沒完成的本地或遠端步驟
- **模板只影響本地建立內容**：
  - blank 建空白 repo；framework 依對話建立 starter；meta-repo 則建立覆蓋 sibling projects 的協調層
  - 本地完成後，三種模板都走同一個遠端確認與初始化交接流程
- **只負責 repo 建立與編排**：
  - 本 skill 專注於建立 repo 與綁定遠端
  - branch 保護交由 [`ultra-project-initializer`](../ultra-project-initializer) 在「初始化專案」階段選配
- **高影響操作前先確認**：
  - 綁遠端／push（`gh repo create`、`git push`）前，先列出即將執行的內容並取得確認
  - 這道確認同時決定要建立 public 遠端並 push，或先停在本機
  - 若選擇綁遠端，固定 public，不再詢問可見性（要 private 時自行手動建立）
- **初始 commit 保持最小化**：
  - 只放一份完全空白的 `README.md`，固定訊息為 `chore: initialize repository`
  - `.gitignore` 不在此階段寫入，改由「初始化專案」階段選配
  - 既有檔案先留在工作區並維持 untracked，之後再依實際需求整理到後續 commit

　

### 預設與相依

- **遠端託管**：
  - 預設 GitHub，透過 `gh` CLI／`gh api` 操作
  - 換其他託管平台時，改遠端建立方式即可
- **預設 branch**：
  - 一律使用 `main`（`git branch -M main`）
- **可見性**：
  - 若綁遠端則固定 public、不提供 private 選項
- **接續的初始化 skill**：
  - 三種模板建好後都可接續交給「初始化專案」skill（例如：[`ultra-project-initializer`](../ultra-project-initializer)）
  - 該 skill 尚未建立或不存在時，確認後略過即可
