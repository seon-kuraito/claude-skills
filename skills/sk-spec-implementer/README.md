# Spec Implementer

依據已定案的 spec 完成實作並建立 PR，流程涵蓋版本啟動、分支建立、測試、code、審查與 commit。每個步驟載入對應的 skill，並在需要使用者檢視內容時暫停。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [implement](https://github.com/mattpocock/skills/blob/main/skills/engineering/implement/SKILL.md)
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 設計背景（WHY）

- **實作流程缺少固定順序**：
  - 版本啟動、分支建立、測試、審查、commit 與 PR 分別由不同 skill 處理，跨工作階段執行時容易遺漏步驟
- **缺少供使用者檢視內容的節點**：
  - 若測試、程式碼與審查結果在同一流程中連續完成，使用者難以在進入下一步前逐項檢視
- **相依 phase 的分支起點不明確**：
  - 若所有工作分支都從 `main` 建立，需要使用前一個 phase 程式碼的 spec 將無法直接開始實作

　

## 功能範圍（WHAT）

- **以 spec 為前提**：
  - 若缺少 spec 或內容不完整，則載入 [`sk-spec-planner`](../sk-spec-planner) 補齊後再開始實作
- **涵蓋版本啟動至 PR 建立**：
  - 若 release 分支不存在，則載入 [`sk-release-creator`](../sk-release-creator) 啟動版本；後續依序交由 [`sk-branch-creator`](../sk-branch-creator)、[`sk-code-tester`](../sk-code-tester)、[`sk-code-reviewer`](../sk-code-reviewer)、[`sk-commit-creator`](../sk-commit-creator) 與 [`sk-pr-creator`](../sk-pr-creator) 處理
- **設置三個檢查點**：
  - 測試、程式碼與審查結果完成後分別暫停，由使用者檢視內容，再決定繼續或修改
- **相依 phase 使用堆疊分支**：
  - 若 spec 開頭列有相依 phase，則從該 phase 的工作分支建立新分支，PR 仍以 release 分支為 base
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
  scripts/link-skill.sh sk-spec-implementer
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索及載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **擴充實作前後流程**：
  - 原版僅包含依 spec 實作、使用 tdd、執行檢查、code review 與 commit；本版在實作前加入 spec 檢查、版本啟動與分支建立，並在完成後加入 PR 建立流程
- **每一步交給對應的 skill**：
  - 原版呼叫其附帶的 tdd 與 code-review；本版在每個步驟載入對應的 skill，本 skill 僅負責流程順序與檢查點
- **檢查點使用固定文案**：
  - 測試、程式碼與審查三個檢查點共用 Checkpoint 選單，由使用者選擇「繼續」或「需要修改」
- **可由 planner 載入**：
  - 原版需手動呼叫；本版不設定 `disable-model-invocation`，並以明確的 description 限定觸發條件，使 [`sk-spec-planner`](../sk-spec-planner) 可在流程結束時直接載入
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；`tests/sandbox.sh` 建立包含 spec、決策紀錄、詞彙表與本機 remote 的暫時性 repo，`tests/verify.sh` 逐項檢查執行結果

　

### 預設與相依

- **委派對象（required）**：
  - [`sk-spec-planner`](../sk-spec-planner)、[`sk-release-creator`](../sk-release-creator)、[`sk-branch-creator`](../sk-branch-creator)、[`sk-code-tester`](../sk-code-tester)、[`sk-code-reviewer`](../sk-code-reviewer)、[`sk-commit-creator`](../sk-commit-creator)、[`sk-pr-creator`](../sk-pr-creator)
