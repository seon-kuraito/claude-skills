# Ultra Project Migrator

搬遷或改名本機專案資料夾，並把 Claude Code 與 VS Code 以路徑保存的狀態一併帶到新位置。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **狀態綁定專案路徑**：
  - Claude Code 以專案路徑為 key 保存工作階段、記憶卡與設定紀錄，資料夾換位置後，新路徑找不到原本的工作階段
- **需要同步修改的位置分散**：
  - 工作階段資料夾名稱、工作階段內的 `cwd`、`~/.claude.json`、`history.jsonl` 與 `~/.claude` 內的 symlink 都記錄著舊路徑，漏改任何一處都會留下斷裂的紀錄
- **搬遷中的工作階段無法處理自己**：
  - 執行搬遷的工作階段通常就位於要搬的資料夾內，Claude Code 與 VS Code 執行時也會改寫自己的狀態檔
- **舊路徑的殘留與寫死的路徑**：
  - VS Code 的舊路徑狀態不會自動清除，專案內寫死的舊路徑也不會自動更新

　

## 這個 skill 做什麼（WHAT）

- **搬遷一個或多個專案**：
  - 支援任意路徑之間的搬遷與原地改名（例如：移入以 owner 分組的目錄）
- **帶走 Claude Code 的狀態**：
  - 工作階段資料夾（含子資料夾的工作階段與記憶卡）、`~/.claude.json` 的 `projects` 與 `githubRepoPaths`、`history.jsonl`、指向舊路徑的 `~/.claude` symlink
- **清除舊路徑的 VS Code 狀態**：
  - 已安裝 [`ultra-project-cleaner`](../ultra-project-cleaner) 時，在同一次終端機執行中一併清除
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
  scripts/link-skill.sh ultra-project-migrator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **先複製，最後才刪除**：
  - 以 `ditto` 複製後比對內容與 git `HEAD`，舊資料夾保留到使用者在新位置確認結果
  - 刪除前檢查舊資料夾在複製後是否有變動，有變動就停止
- **先預覽，再交給腳本執行**：
  - 在工作階段內唯讀預覽，產生清單檔（Manifest）
  - 確認後由使用者關閉 VS Code 與 Claude Code，在終端機執行腳本，再到新位置恢復工作階段檢查結果
- **只改欄位，不改內文**：
  - 只改寫工作階段的 `cwd` 與歷史紀錄的 `project`，對話內容提到的路徑保持原樣
  - 改寫後還原檔案時間，工作階段的排序與 Claude Code 的自動清理時間不受影響
- **一律先備份，並可還原**：
  - 修改前先備份到清單檔旁的 `backup/`
  - 執行中途停止時，由 `restore.sh` 還原 Claude Code 狀態並刪除新複本
- **寫入後逐項驗證**：
  - 驗證複本一致、沒有殘留的舊 `cwd`、工作階段除 `cwd` 外與備份相同，以及設定、歷史紀錄與 symlink 不含舊路徑
- **清理交給另一個 skill**：
  - 舊路徑的 VS Code 狀態由 `ultra-project-cleaner` 處理，使用者只需關閉一次 VS Code

　

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
  - 清除舊路徑的 VS Code 狀態需要安裝 [`ultra-project-cleaner`](../ultra-project-cleaner)，未安裝時略過並提醒
