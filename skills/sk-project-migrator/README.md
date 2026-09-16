# Project Migrator

搬遷或改名本機專案資料夾，並同步更新 Claude Code 與 VS Code 以路徑保存的狀態。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **狀態綁定專案路徑**：
  - Claude Code 用專案路徑作為 key 保存工作階段、記憶卡與設定紀錄；資料夾換位置後，新路徑找不到原本的工作階段
- **需要同步修改的位置分散**：
  - 工作階段資料夾名稱、工作階段內的 `cwd`、`~/.claude.json`、`history.jsonl` 與 `~/.claude` 內的 symlink 都會記錄舊路徑，漏改任何一處都會留下斷裂紀錄
- **搬遷中的工作階段不適合直接處理自身狀態**：
  - 執行搬遷的工作階段通常就位於要搬的資料夾內，Claude Code 與 VS Code 執行時也會改寫自己的狀態檔
- **舊路徑的殘留與寫死的路徑**：
  - VS Code 不會自動清除舊路徑狀態，專案內寫死的舊路徑也需要另外檢查

　

## 這個 skill 做什麼（WHAT）

- **搬遷一個或多個專案**：
  - 支援任意路徑之間的搬遷與原地改名（例如：移入以 owner 分組的目錄）
- **更新 Claude Code 的狀態**：
  - 工作階段資料夾（含子資料夾的工作階段與記憶卡）、`~/.claude.json` 的 `projects` 與 `githubRepoPaths`、`history.jsonl`，以及指向舊路徑的 `~/.claude` symlink
- **清除舊路徑的 VS Code 狀態**：
  - 已安裝 [`sk-project-cleaner`](../sk-project-cleaner) 時，在同一次終端機執行中一併清除
- **列出專案內寫死的舊路徑**：
  - 只列出位置，由使用者決定是否修改
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
  scripts/link-skill.sh sk-project-migrator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，避免覆蓋直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **先複製，最後才刪除**：
  - 以 `ditto` 複製後比對內容與 git `HEAD`，舊資料夾會保留到使用者在新位置確認結果
  - 刪除前檢查舊資料夾在複製後變動的檔案，新複本缺少相同內容就停止
  - git 在唯讀操作時也會改寫的 `.git/index` 與 `.git/FETCH_HEAD` 不列入檢查
- **先預覽，再交給腳本執行**：
  - 在工作階段內唯讀預覽，產生清單檔（Manifest）
  - 確認後由使用者關閉 VS Code 與 Claude Code，在終端機執行腳本，完成後再到新位置恢復工作階段並檢查結果
- **只改必要欄位**：
  - 只改寫工作階段的 `cwd` 與歷史紀錄的 `project`，對話內容提到的路徑保持原樣
  - 改寫後還原檔案時間，工作階段的排序與 Claude Code 的自動清理時間不受影響
- **先建立備份，並可還原**：
  - 修改前先備份到清單檔旁的 `backup/`
  - 執行中途停止時，由 `restore.sh` 還原 Claude Code 狀態並刪除新複本
- **寫入後逐項檢查**：
  - 驗證複本一致、沒有殘留的舊 `cwd`、工作階段除 `cwd` 外與備份相同，以及設定、歷史紀錄與 symlink 不含舊路徑
- **VS Code 舊狀態由 cleaner 處理**：
  - 舊路徑的 VS Code 狀態由 `sk-project-cleaner` 處理，同一次終端機執行中完成，使用者只需關閉一次 VS Code
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例，行為案例確認流程只產出唯讀 plan，且舊資料夾保留到 finalize
  - `tests/checks/lib-functions.sh` 驗證 `lib.sh` 的純函式，包含欄位改寫只在路徑邊界生效、不會動到相鄰目錄（靜態執行，不需要 LLM）

　

### 預設與相依

- **平台**：
  - 僅支援 macOS 與 VS Code 正式版，其他環境直接停止
- **工具**：
  - 需要 `jq`（例如：`brew install jq`）
  - `perl`、`lsof`、`ditto`、`git` 為 macOS 內建
- **位置**：
  - Claude Code 狀態預設位於 `~/.claude/` 與 `~/.claude.json`，VS Code 狀態位於 `~/Library/Application Support/Code/User/`
  - 清單檔與備份預設存放在 `~/Backups/<時間>-project-migrator/`
  - 各位置皆可用環境變數覆寫，細節見 `scripts/lib.sh`
- **相依的 skill**：
  - 清除舊路徑的 VS Code 狀態需要安裝 [`sk-project-cleaner`](../sk-project-cleaner)，未安裝時略過並提醒
