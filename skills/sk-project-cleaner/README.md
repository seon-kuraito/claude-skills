# Project Cleaner

診斷並清除本機專案在 Claude Code 與 VS Code 留下的狀態，包含工作階段、記憶卡、設定紀錄與編輯器快取。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **專案刪除後，狀態仍留在工具裡**：
  - Claude Code 與 VS Code 用專案路徑作為 key 保存工作階段、記憶卡、信任設定、編輯器狀態與快取，專案刪除、封存或搬走後不會自動清除
- **殘留分散在多個位置**：
  - 這些紀錄分散在 `~/.claude/`、`~/.claude.json`、VS Code 的 `workspaceStorage`、`storage.json` 與 SQLite 資料庫，手動清理容易遺漏
- **部分狀態無法在執行中修改**：
  - Claude Code 與 VS Code 執行時會改寫自己的狀態檔，直接修改可能被覆蓋，資料庫也可能損毀

　

## 這個 skill 做什麼（WHAT）

- **提供兩種模式**：
  - 指定專案：清除指定路徑相關紀錄，不論路徑是否仍存在
  - 指定專案並加上 `--exact`：僅清除指定路徑本身的紀錄，不包含其子路徑。適用於 `~` 等起始目錄（Launch Pad）；工作階段可由此啟動，子資料夾則分別屬於其他專案
  - 診斷（Diagnose）：未指定專案時，找出路徑已不存在的紀錄，由使用者挑選要清除的項目
- **涵蓋 Claude Code 與 VS Code 的狀態**：
  - Claude Code：工作階段資料夾（含記憶卡）、`~/.claude.json` 的 `projects` 與 `githubRepoPaths`、`history.jsonl`
  - VS Code：`workspaceStorage`、`storage.json` 的視窗還原與 profile 登記、`state.vscdb` 內的終端機目錄歷史與 extension 快取（GitHub、Git、ESLint、GitLens、Python）
- **先預覽，再交給腳本執行**：
  - 在工作階段內唯讀預覽，產生清單檔（Manifest）
  - 確認後由使用者關閉 VS Code 與 Claude Code，在終端機執行腳本，完成後再回到工作階段驗證結果
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
  scripts/link-skill.sh sk-project-cleaner
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，避免覆蓋直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **以清單檔限定執行範圍**：
  - 腳本只執行清單檔中已選取的項目，執行前逐項重新確認，狀態已改變的項目一律跳過
- **避免誤刪**：
  - 診斷模式只提供路徑已不存在的項目；孤兒紀錄與 `/Volumes/` 底下的路徑只列為資訊
  - 執行中的 Claude Code 工作階段所在專案不可選取。由於兩個工具皆以工作目錄作為紀錄的 key，`--exact` 模式只檢查工作目錄與指定路徑完全相符的工作階段，不包含子路徑中其他專案的工作階段
  - 未使用 `--exact` 時，`plan.sh` 會拒絕處理 `~` 等涵蓋所有專案的路徑
  - 工作階段資料夾的路徑以登記紀錄或相符的工作階段 `cwd` 為準，不從資料夾名稱反推
- **先建立備份**：
  - 刪除或修改前，先備份到清單檔旁的 `backup/`，使用者確認結果後再刪除
- **`~/.claude.json` 只修改路徑相關欄位**：
  - 僅修改 `projects` 與 `githubRepoPaths`，其餘欄位由 Claude Code 自行管理
- **`state.vscdb` 只修改路徑相關欄位**：
  - 僅修改 5 個 extension 資料列與終端機目錄歷史中與專案路徑相關的欄位，其餘資料列與欄位（例如：終端機的指令歷史）不動
  - 終端機目錄歷史中屬於遠端機器的路徑不列入判斷
  - 寫入前只備份一次資料庫，所有資料列在同一個交易（Transaction）中寫回
- **可被其他 skill 沿用**：
  - `sk-project-migrator` 搬遷專案時，沿用同一份清單檔格式清除舊路徑的 VS Code 狀態，使用者只需關閉一次 VS Code
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例：行為案例用於確認流程只產出唯讀 plan，實際刪除由使用者執行；起始目錄案例用於確認流程會採用 `--exact`，且清單檔不會納入子路徑中其他專案的紀錄
  - `tests/checks/lib-functions.sh` 驗證 `lib.sh` 的純函式：路徑正規化、專案 key 編碼、前綴比對不會誤傷相鄰目錄（靜態執行，不需要 LLM）
  - `tests/checks/plan-exact.sh` 使用一組由起始目錄及其子專案組成的 fixture 執行 `plan.sh`：驗證 `--exact` 僅選取指定路徑本身、未使用 `--exact` 時拒絕 `$HOME`，以及兩種模式判定執行中工作階段的方式（靜態執行，不需要 LLM）

　

### 預設與相依

- **平台**：
  - 僅支援 macOS 與 VS Code 正式版，其他環境直接停止
- **工具**：
  - 需要 `jq`（例如：`brew install jq`）
  - `sqlite3`、`perl`、`lsof`、`ditto` 為 macOS 內建
- **位置**：
  - Claude Code 狀態預設位於 `~/.claude/` 與 `~/.claude.json`，VS Code 狀態位於 `~/Library/Application Support/Code/User/`
  - 清單檔與備份預設存放在 `~/Backups/<時間>-project-cleaner/`
  - 各位置皆可用環境變數覆寫，細節見 `scripts/lib.sh`
- **Claude Code 的工作階段保留期限**：
  - Claude Code 會自動刪除超過 `cleanupPeriodDays`（預設 30 天）的工作階段紀錄，因此沒有工作階段不代表是殘留
