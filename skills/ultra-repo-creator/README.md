# Ultra Repo Creator

把建立新 repo 的流程拆成兩個可接續的階段：本地初始化與遠端建立。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **開 repo 是重複的多步驟**：
  - 每次都要跑繁瑣的 `git init`、建立遠端、綁定 remote 等流程
- **初始 commit 容易塞太多**：
  - 遠端還沒綁好就把一批檔案寫進歷史，之後會比較難整理

　

## 這個 skill 做什麼（WHAT）

- **從零建立 repository**：
  - 本地 `git init` → 在 GitHub 建立 public 遠端，兩個階段可以分開執行
- **可從任一階段切入，並自動偵測進度**：
  - 會先偵測 `git init` 與遠端的完成狀態，只補尚未完成的部分
- **建立完成後可接續初始化專案**：
  - 兩階段都完成後，詢問是否進入初始化階段
  - `.gitignore`、`.claude/CLAUDE.md`、GitHub Labels、branch 保護等選配項目，交由其他 skill 處理
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

- **兩階段模型與自動進度偵測**：
  - 把專案設定分成「建立專案」（本 skill）與「初始化專案」（另一個 skill）兩階段
  - 開頭先偵測是否已完成 `git init` 與 GitHub 遠端，再決定要從哪一步接續
  - 兩項都完成就視為建立階段結束，接著詢問是否進入初始化階段；否則只補尚未完成的步驟
  - 偵測採 best-effort；判斷不明時，改用詢問確認
- **只負責 repo 建立與編排**：
  - 本 skill 專注於建立 repo 與綁定遠端
  - branch 保護交由 [`ultra-project-initializer`](../ultra-project-initializer) 在「初始化專案」階段選配
- **高影響操作前先確認**：
  - 建立 repo、push 前，先列出即將執行的指令與影響範圍
  - 不把多個階段串成一次跑完，避免在未確認的情況下連續改變本地與遠端狀態
- **初始 commit 保持最小化**：
  - 只放一份完全空白的 `README.md`，固定訊息為 `chore: initialize repository`
  - `.gitignore` 不在此階段寫入，改由「初始化專案」階段選配
  - 既有檔案先留在工作區並維持 untracked，等遠端綁定完成後，再依實際需求整理進後續 commit
- **固定建立 public repo**：
  - 一律建立 public，不再詢問可見性（若有需要 private 可自行手動建立）
  - GitHub 免費方案的 ruleset 只對 public repo 生效

　

### 預設與相依

- **遠端託管**：
  - 預設 GitHub，透過 `gh` CLI／`gh api` 操作
  - 換其他託管平台時，改遠端建立方式即可
- **預設 branch**：
  - 一律使用 `main`（`git branch -M main`）
- **可見性**：
  - 固定 public，不提供 private 選項
- **接續的初始化 skill**：
  - 建立階段完成後，可接續交給「初始化專案」skill（例如：`ultra-project-initializer`）
  - 該 skill 尚未建立或不存在時，詢問後略過即可
- **委派的 skills**：
  - 後續整理委派給 [`ultra-project-initializer`](../ultra-project-initializer)
