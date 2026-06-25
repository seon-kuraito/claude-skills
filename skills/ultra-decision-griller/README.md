# Ultra Decision Griller

逐一追問計畫或設計中的關鍵決策，沿決策樹一次走一個分支，直到雙方達成共識。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 為什麼做這個 skill（WHY）

- **決策常沒被逐一檢視**：
  - 一次討論太多面向時，容易跳過或含糊帶過關鍵選擇
- **AI 先給建議會錨定人**：
  - 每題先看到 AI 的答案時，討論常變成形式上的同意，反而看不到真正的分歧
- **討論容易發散、不知何時該停**：
  - 沒有明確的停止條件，訪談就無限延伸

　

## 這個 skill 做什麼（WHAT）

- **逐一追問計畫／設計裡的決策**：
  - 決策樹一次只走一個分支，並先處理上游依賴
- **收尾整理成條列**：
  - 將已定案的內容整理成列點，必要時存成檔案
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
  scripts/link-skill.sh ultra-decision-griller
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **先讓使用者表態，再給出建議**：
  - 原版每題會先提供 AI 的建議答案，容易錨定使用者，使訪談變成形式上的確認
  - 本版改為先請使用者回答，再由 AI 回應；讓使用者先表態，才看得到真正的分歧與偏好
  - 若雙方判斷一致，簡短確認即可；若判斷不同，先替使用者的論點補強，再提出反駁或替代觀點（steel-man）
- **將訪談流程拆成三段**：
  - 原版以散文方式描述訪談原則
  - 本版改成 `How to ask`、`How to recommend`、`When to stop` 三段，讓 agent 更容易依序執行
- **在明確分支中使用 AskUserQuestion**：
  - 當問題有 2–4 個合理選項時，改用 `AskUserQuestion` 提供多選
  - 相較於開放式問答，多選能更快收斂，也能降低使用者重新組織答案的負擔
- **明確定義收尾方式**：
  - 設定停止條件，避免訪談無限延伸
  - 收束時將決策整理成「分支 → 決定 → 一句理由」，並詢問是否存檔
- **收錄 evals 測試案例**：
  - `evals/evals.json` 用來驗證關鍵行為與安全前提

　

> 附註：核心概念與部分措辭（一次只追問一個分支、「能用 codebase 回答就去查 codebase」）沿用自原版。

　

### 預設與相依

- **相依的工具**：
  - `AskUserQuestion`：Claude 內建 tool，2–4 個答案時用多選收斂，沒有此 tool 的環境退回純文字問答
- **收尾存檔**：
  - 預設把已定案決策整理成 `decisions.md`，也可附加到當前文件
