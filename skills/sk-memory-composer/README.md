# Memory Composer

管理與稽核 Claude Code 的專案記憶和全域記憶，並維護兩層記憶架構。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **跨專案規則分散於個別專案**：
  - 專案記憶僅在該專案的工作階段載入，無法套用至其他專案
  - 相同的溝通偏好或檢查規則可能重複記錄於多個專案，內容也可能不一致
- **全域規則缺少載入機制**：
  - Claude Code 不會自動讀取使用者自訂的規則目錄，必須提供明確的查詢指示
- **專案異動造成記憶失效**：
  - 專案改名、搬移或刪除後，相關連結、路徑、索引及清單可能失效

　

## 這個 skill 做什麼（WHAT）

- **定義兩層記憶架構**：
  - 專案記憶：放在各專案的記憶資料夾，由 `MEMORY.md` 索引
  - 全域記憶：依查詢時機分成 case 目錄，放在 `~/.claude/global-memory/`，由使用者層級 CLAUDE.md 的查詢指示（Lookup Line）帶入
- **涵蓋所有記憶相關工作**：
  - 初始化、寫入與分流、新增或改名 case、稽核、拆分、合併、搬遷與刪除
  - 工作期間新增的記憶也適用相同流程
- **區分架構與使用者偏好**：
  - skill 負責定義架構
  - 記憶使用的語言、欄位、內文格式與拆分粒度，由使用者的全域記憶定義
- **以腳本檢查架構**：
  - `scripts/check.py` 以唯讀方式檢查查詢指示、命名、連結與索引，不消耗模型 token
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 如何使用這個 skill（HOW）

### 安裝

- **手動複製**：
  - 將整個 skill 目錄複製至 `~/.claude/skills/`
  - 此方式不依賴 symlink，但 repo 的後續更新不會自動套用
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-memory-composer
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索及載入
  - 腳本不會覆寫同名的實體目錄，以免影響直接安裝於 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **CLAUDE.md 僅保留入口**：
  - 每個 case 在 CLAUDE.md 中以一行查詢指示結尾；規則本文存放於 case 目錄，並於需要時讀取
  - CLAUDE.md 固定保留一行寫入入口，使未載入 skill 的工作階段在寫入記憶前仍會判斷存放層級
- **case 以查詢時機命名**：
  - 名稱應描述查詢情境，並與查詢指示所指定的時機一致
  - case 清單不寫入記憶，使用 `ls` 查詢實際目錄
- **變更前先備份與確認**：
  - 修改多個檔案前，先備份至工作階段的暫存目錄（Scratchpad），並於同一個工作階段內完成檢查
  - 移動、改寫或刪除記憶前，須先完成執行確認（Execution Gate）
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例，用於確認稽核僅回報結果而不修改檔案、工作期間寫入記憶前會載入此 skill，以及新工作階段會依查詢指示讀取規則
  - `tests/checks/` 使用臨時目錄驗證 `check.py` 與 `backup.py` 的判斷及輸出；測試採靜態執行，不需要 LLM
  - `tests/sandbox.sh` 建立臨時的 Claude Code 目錄，供寫入與稽核案例實際執行，避免存取使用者的真實記憶

　

### 預設與相依

- **執行方式**：
  - 兩支腳本僅依賴 Python 標準函式庫；環境中若有 uv，則使用 `uv run`，否則使用 `python3`
- **位置**：
  - 全域記憶固定放在 `~/.claude/global-memory/`，查詢指示寫在 `~/.claude/CLAUDE.md`
  - 備份存放於工作階段的暫存目錄；若無該目錄，則使用系統暫存目錄。工作階段結束或系統重新開機後，備份不予保留
- **相依的 skill**：
  - 使用者層級的 CLAUDE.md 不存在時，由 [`sk-claudemd-composer`](../sk-claudemd-composer) 建立空白檔；若未安裝該 skill，則直接建立空白檔
- **驗證案例的前提**：
  - 查詢指示的行為案例須在已完成初始化，且有 case 涵蓋 `git push` 時機的環境中執行
