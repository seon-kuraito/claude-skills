# Decision Griller

逐一追問計畫或設計中的關鍵決策，沿決策樹一次走一個分支，直到雙方達成共識。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 設計背景（WHY）

- **決策未逐項檢視**：
  - 同時討論過多面向時，關鍵選擇容易遭到省略或缺乏明確結論
- **AI 先給建議會錨定人**：
  - 若每題都先顯示 AI 的答案，使用者可能直接接受建議，難以呈現實際的分歧
- **討論缺乏範圍與停止條件**：
  - 沒有明確的停止條件，訪談就無限延伸

　

## 功能範圍（WHAT）

- **逐一追問計畫／設計裡的決策**：
  - 決策樹一次只走一個分支，並先處理上游依賴
- **收尾時先確認理解，再整理摘要**：
  - 訪談結束時，先用一句話重述使用者的核心目標與待解決的問題；經確認後，再以條列方式摘要已定案的內容
- **由規格流程建立文件**：
  - 詢問是否要將決策整理成文件；若需要，交由 [`sk-spec-planner`](../sk-spec-planner) 決定檔案與內容
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-decision-griller
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **先讓使用者表態，再給出建議**：
  - 原版每題會先提供 AI 的建議答案，容易錨定使用者，使訪談變成形式上的確認
  - 本版先請使用者回答，再由 AI 回應，以便記錄使用者原先的判斷、分歧與偏好
  - 若雙方判斷一致，簡短確認即可；若判斷不同，先替使用者的論點補強，再提出反駁或替代觀點（steel-man）
- **將訪談流程拆成三段**：
  - 原版以散文方式描述訪談原則
  - 本版改成 `How to ask`、`How to recommend`、`When to stop` 三段，讓 agent 更容易依序執行
- **在明確分支中使用 AskUserQuestion**：
  - 當問題有 2–4 個合理選項時，改用 `AskUserQuestion` 提供多選
  - 相較於開放式問答，多選能更快收斂，也能降低使用者重新組織答案的負擔
- **事實與決策分開**：
  - agent 自行查明環境中的事實（例如 codebase、檔案與工具輸出），僅將需要取捨的決策交由使用者確認
- **明確定義收尾方式**：
  - 設定停止條件，避免訪談無限延伸
  - 收尾時先用一句話重述目標與問題，確認訪談方向無誤，再將決策整理成「分支 → 決定 → 一句理由」
- **由 sk-spec-planner 建立文件**：
  - 先前版本預設將決策存成 `DECISIONS.md`；目前改為詢問是否要整理成文件，再由規格流程決定檔案與內容
  - 此 skill 不包含文件格式規則，也可單獨使用
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例，用於確認觸發正確，且關鍵行為與安全前提符合規格

　

> 附註：核心概念與部分措辭（一次只追問一個分支、「能用 codebase 回答就去查 codebase」）沿用自原版。

　

### 預設與相依

- **相依的工具**：
  - `AskUserQuestion`：Claude 內建 tool，2–4 個答案時用多選收斂，沒有此 tool 的環境退回純文字問答
- **後續處理**：
  - [`sk-spec-planner`](../sk-spec-planner)：接續建立規格文件，並決定檔案與內容
  - 若未安裝，則詢問摘要的儲存位置，並依使用者指示寫入
