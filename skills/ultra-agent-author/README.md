# Ultra Agent Author

用於建立、改寫與評估 Claude Code subagent 定義的個人化流程。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **subagent 需要照顧的面向很容易散開**：
  - 一個 agent 檔會同時牽涉分類、觸發描述、工具白名單、model 選擇與驗證方式；如果缺少固定流程，每次都容易變成臨場發揮
- **persona 式寫法看似專業，其實很難驗證**：
  - 如果把 agent 寫成「人設」而不是「評估準則」，輸出也許很有口吻，卻缺少能檢查、能比較的落點
- **思考型與執行型 agent 很容易混在一起**：
  - subagent 的隔離可以用來保護判斷，也可以用來節省 context、處理繁瑣工作；兩種目的不同，工具、model 與驗證方式也應該分開設計

　

## 這個 skill 做什麼（WHAT）

- **建立完整的 subagent 工作流**：
  - 涵蓋命名、分類（思考型／執行型）、觸發描述、工具與 model 裁剪、系統提示與驗證
- **預設流程保持輕量**：
  - 先用 `claude-agents` 的實際需求收斂規格，避免在第一版就把流程寫得太滿
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
  scripts/link-skill.sh ultra-agent-author
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **沿用建立流程，但依 subagent 特性調整**：
  - 保留「訪談 → 草擬 → 審閱」這條主線，以及命名、授權、README 與發佈工作流
  - 整體流程參照 [`ultra-skill-author`](../ultra-skill-author)，但 subagent 會在獨立 context window 裡執行，因此需要重新處理觸發描述、工具白名單、model 選擇與驗證方式
- **先區分思考型與執行型**：
  - 思考型（evaluator）主要追求獨立判斷，應偏向唯讀工具、明確評估準則與對抗性任務
  - 執行型（worker）主要追求 context 經濟與並行，重點是把可寫、可跑、可整理的工作留在主對話之外
- **不把 agent 寫成想像出來的人設**：
  - 評估準則應寫成問題，並錨定在該領域既有、可查證的框架
  - 角色語氣可以幫助理解，但不能取代判斷標準、輸出格式與驗證方法
- **驗證要看得出差異**：
  - 驗證屬於能力選用項目（Capability Checkpoint），選擇開啟後沿用 skills 的 eval 套件執行
  - 思考型 agent 需能通過鑑別力測試、分歧測試與可行動測試；執行型則依任務性質補上 fixture、dry run 或輸出檢查
- **管轄涵蓋所有自建 subagent**：
  - 全域 agent 一律建立於 `claude-agents` repo，再逐檔 symlink 進 `~/.claude/agents/`；純屬單一專案的 agent 則作為例外，直接放進該專案的版控
  - 第三方直接安裝的 agent 不在管轄範圍
- **權威定義集中於本 skill**：
  - 定位、分類與設計準則以 [`SKILL.md`](SKILL.md) 為唯一權威，`claude-agents` 的文件僅保留指標
  - 不預先規劃 agent 清單，等真實重複需求出現才建檔

　

### 預設與相依

- **家族路徑**：
  - agent 定義存放於 `claude-agents` repo，位置從本 skill 的 symlink 反推：以 `realpath` 解析安裝路徑，往上兩層取得 `claude-skills`，其同層即為 `claude-agents`
  - 不以工作目錄（Working Directory）為準，工作階段從哪個目錄啟動都不影響
  - 發佈流程沿用 [`ultra-skill-author`](../ultra-skill-author) 的規範，目標 repo 則改為 `claude-agents`
- **委派的 skills**：
  - 開 branch 用 [`ultra-branch-creator`](../ultra-branch-creator)、發 commit 用 [`ultra-commit-creator`](../ultra-commit-creator)
  - 若無這兩個 skill，將對應步驟替換為其他 branch／commit 慣例即可
