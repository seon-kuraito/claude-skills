# Code Tester

在已確認的 seams 進行紅→綠迴圈：先撰寫 E2E 或 integration 測試，再以 unit 測試補足缺口；斷言聚焦於測試意圖，測試與程式碼納入同一個 commit。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [tdd](https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md)
  - 觀念提煉自 [Implicit Assertions](https://www.epicweb.dev/implicit-assertions) 與 [The Testing Trophy and Testing Classifications](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 設計背景（WHY）

- **測試依賴實作細節**：
  - mock 內部協作者或測試私有方法，會使測試在外部行為未變時仍因重構而失敗
- **斷言未清楚表達測試意圖**：
  - 對動作已能證明的結果重複加入顯式斷言，會增加測試篇幅，也可能降低失敗訊息的資訊量
- **完成所有測試後才開始實作**：
  - 批次撰寫的測試容易依據預想行為設計，無法及時反映實際實作的變化
- **未先確認 seams**：
  - 測試可能集中於次要案例，而未涵蓋關鍵路徑；agent 與使用者也可能對驗證位置有不同理解

　

## 功能範圍（WHAT）

- **僅在已確認的 seams 撰寫測試**：
  - 若有 spec，則採用其中的測試決策；若沒有，則先向使用者確認，在確認前不撰寫測試
- **由外而內決定測試層級**：
  - 先撰寫 E2E 或 integration 測試；unit 測試僅用於高層測試無法涵蓋的邏輯或缺口，且只在系統邊界使用 mock
- **精簡斷言**：
  - 移除動作與等值比較已涵蓋的顯式斷言，保留能表達測試意圖的斷言；期望值應取自獨立來源
- **紅→綠迴圈的規則**：
  - 先執行測試並確認失敗，再撰寫實作；每次處理一個切片，refactor 交由 review 處理。測試與程式碼納入同一個 commit，探索用的測試則保留於 scratchpad
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
  scripts/link-skill.sh sk-code-tester
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索及載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **加入測試層級的順序**：
  - 原版僅說明 seams 與迴圈；本版依 Testing Trophy 的主張，先撰寫 E2E 或 integration 測試，再以 unit 測試補足缺口
- **加入 implicit assertions 的規則**：
  - 原版未說明斷言的取捨；本版依 Implicit Assertions 一文，移除結果已由其他操作涵蓋的顯式斷言，並以 if/throw 檢查測試環境
- **seams 的來源**：
  - 若有 spec，則採用其中的測試決策；若沒有，則透過固定文案的 Seams 問題確認
- **commit 與暫時性測試的處理方式**：
  - 同一切片的測試與程式碼納入同一個 commit；探索用的暫時性測試存放於 session scratchpad，不加入 repo
- **由 review 處理 refactor**：
  - 原版使用其附帶的 code-review skill；本版改用 [`sk-code-reviewer`](../sk-code-reviewer)，並移除對 codebase-design 的呼叫
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；`tests/sandbox.sh` 建立零相依的 Node 專案，供行為案例在隔離環境中驗證實際的紅→綠迴圈

> 附註：`references/tests.md` 與 `references/mocking.md` 大致沿用原版內容，僅調整部分字句。

　

### 預設與相依

- **委派對象**：
  - [`sk-spec-planner`](../sk-spec-planner)：spec 中的測試決策是 seams 的來源；若沒有 spec，則改由使用者確認
  - [`sk-code-reviewer`](../sk-code-reviewer)：負責 refactor 與測試審查；若未安裝，則由使用者決定是否進行 refactor
  - [`sk-spec-implementer`](../sk-spec-implementer)：實作流程開頭會載入本 skill；本 skill 也能單獨使用
