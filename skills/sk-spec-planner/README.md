# Spec Planner

將討論中已定案的決策整理成 spec、決策紀錄與詞彙表，並將規模較大的工作拆分為可在一個 context window 內完成的 phase spec。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [to-spec](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-spec/SKILL.md) 與 [to-tickets](https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md)
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 設計背景（WHY）

- **討論結果未形成文件**：
  - 決策分散在對話中，實作時需要重新整理，也不易延續至後續工作階段
- **spec 與現況不一致**：
  - 單一長篇文件同時記錄決策、做法與進度，內容過期後難以辨識仍然有效的部分
- **工作無法在單一工作階段內完成**：
  - 缺少拆分規則時，agent 可能一次處理整項功能，並在 context window 用盡後影響產出品質
- **各 repo 的詞彙命名不一致**：
  - 同一概念在使用不同語言的 repo 中可能採用不同的識別字

　

## 功能範圍（WHAT）

- **將已定案的決策整理成 spec**：
  - 不再重複訪談，直接彙整對話中已定案的內容，撰寫為包含七個章節的繁體中文 spec
- **先與使用者確認測試 seams**：
  - 撰寫 spec 前先提出用於驗證的 seams，經使用者確認後再開始撰寫
- **拆分為 phase spec**：
  - 將超過一個 context window 的工作拆分為 tracer bullet 形式的 phase；每份對應一條 branch 與一個 PR，並列出 blocking 關係
- **維護決策紀錄與詞彙表**：
  - `DECISIONS.md` 僅記錄當前狀態並包含版本表；`GLOSSARY.md` 則在撰寫 spec 時同步更新
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
  scripts/link-skill.sh sk-spec-planner
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索及載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **將兩個 skill 整合為單一流程**：
  - 原版分別呼叫 to-spec 與 to-tickets；本版在同一流程中撰寫 spec 並拆分 phase
- **只產出本機文件**：
  - 原版將 spec 與 ticket 發布至 issue tracker；本版僅在 repo 根目錄（家族則為協調層 repo）建立 markdown 檔，不建立 issue、ticket 或 Release
- **ticket 改成 phase spec**：
  - 每個 phase 使用一份獨立的 spec 檔，並對應一條 branch 與一個 PR；相依的 phase 列於 spec 開頭
- **加入持續維護的文件**：
  - 原版以 GLOSSARY.md 與 ADR 記錄長期資訊；本版改用 `DECISIONS.md`（當前狀態、已否決的選項與版本表）及 `GLOSSARY.md`
- **由此流程決定版本號**：
  - spec 定案時，依 [`sk-release-creator`](../sk-release-creator) 的版本號規則提出建議，並記錄於版本表；release branch 則由實作流程建立
- **銜接前後流程**：
  - 現有脈絡不足以撰寫 spec 時，載入 [`sk-decision-griller`](../sk-decision-griller) 釐清決策，再返回本流程；spec 定案後，可直接載入 [`sk-spec-implementer`](../sk-spec-implementer) 進行實作
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；`tests/sandbox.sh` 建立暫時性的單一 repo，供行為案例在隔離環境中驗證實際流程
- **spec 用繁體中文**：
  - 依 `assets/spec-template.md` 的七個章節撰寫；refactor 以 developer story 取代 user story

> 附註：先確認 seams 再撰寫、使用七節模板、採用 tracer bullet 與 blocking edges、先進行 prefactor、wide refactor 採用 expand–contract，以及 spec 不包含路徑與程式碼等規則，均沿用自原版。

　

### 預設與相依

- **檔案位置**：
  - 家族專案將 `specs/`、`DECISIONS.md` 與 `GLOSSARY.md` 存放於協調層 repo 的根目錄；單一 repo 則存放於自身的根目錄
- **委派對象**：
  - [`sk-decision-griller`](../sk-decision-griller)：脈絡不足時接續進行決策訪談；若未安裝，則暫停流程並請使用者補充必要的決策
  - [`sk-spec-implementer`](../sk-spec-implementer)：spec 定案後接手實作；未安裝時說明並結束
  - [`sk-release-creator`](../sk-release-creator)：提供版本號規則；未安裝時直接請使用者指定版本
