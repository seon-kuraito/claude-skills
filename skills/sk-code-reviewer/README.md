# Code Reviewer

從 standards、spec、資安與簡化四個面向分別審查變更，每個面向由一個 subagent 處理；結果並列呈現，不合併或排序。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [code-review](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md)、Anthropic 的 [claude-code-security-review](https://github.com/anthropics/claude-code-security-review) 與 DietrichGebert 的 [ponytail-review](https://github.com/DietrichGebert/ponytail)
  - OWASP Top 10 速查表觀念提煉自 GitHub 的 [awesome-copilot](https://github.com/github/awesome-copilot)
- **授權**：
  - 三個上游都是 MIT（Copyright 2026 Matt Pocock、2025 Anthropic、2026 DietrichGebert）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 設計背景（WHY）

- **不同審查面向可能互相影響**：
  - 將規範符合度與功能正確性等面向合併於同一份報告，可能使部分問題未獲充分呈現
- **資安審查缺少明確篩選標準**：
  - 若未設定信心門檻與排除清單，報告可能包含過多理論風險，使可實際利用的漏洞不易辨識
- **過度設計未被明確識別**：
  - 只有單一實作的工廠，或重複實作標準函式庫既有功能等情況，通常不會在一般 review 中列為可移除項目
- **審查過程同時修改程式碼**：
  - 審查與修改同時進行時，使用者無法先取得完整的發現清單，也難以自行決定修正範圍

　

## 功能範圍（WHAT）

- **四個面向各自審查**：
  - standards（repo 規範與 smell 基線）、spec（對照原始 spec）、資安（具有實際利用路徑的漏洞）、簡化（可移除、可改用標準函式庫或平台，以及可精簡的部分）
- **先定比較點與來源**：
  - 確認 fixed point、spec 與規範來源後，再分派審查工作；若沒有 spec，則略過該面向並加以註明
- **分派前確認執行方式**：
  - 說明所需的 subagent 數量，由使用者選擇平行或循序執行
- **僅列出發現，不進行修改**：
  - 並列呈現四份報告，並為每個面向提供一行摘要；修正範圍由使用者或實作流程決定
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
  scripts/link-skill.sh sk-code-reviewer
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索及載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **從兩個面向擴充為四個**：
  - Matt 的原版僅包含 standards 與 spec；本版加入以 Anthropic security-review 指令為基礎的資安面向，以及以 ponytail-review 為基礎的簡化面向
- **smell 基線重新分配**：
  - Fowler 的 Duplicated Code、Speculative Generality 與 Middle Man 改由簡化面向依其 tag 處理，standards 面向保留其餘九項
- **從本機文件取得 spec**：
  - 原版透過 issue tracker 取得 spec；本版依序檢查使用者提供的路徑、`DECISIONS.md` 版本表，以及 `specs/` 中的同名檔案
- **執行方式交給使用者**：
  - 原版固定平行；本版派工前呈現固定文案的 Run mode 選單
- **subagent 的讀取範圍**：
  - brief 要求先讀取 diff，再讀取變更涉及的檔案及其直接 import，並先使用 grep 定位內容，再進行 read
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；`tests/sandbox.sh` 建立含工作分支的暫時性 repo，並在分支中分別加入四類問題；完整流程的案例預設關閉

> 附註：`references/smells.md` 的九個 smell、`references/simplicity.md` 的 tag 與格式、`references/security.md` 的類別與判例，分別沿用自三個上游，只做字句修整與濃縮。

　

### 預設與相依

- **subagent**：
  - 每個面向使用一個 general-purpose subagent，設定為 `model: opus` 並在背景執行；prompt 內嵌於 `SKILL.md`，不依賴 agent 定義檔
- **委派對象**：
  - [`sk-spec-planner`](../sk-spec-planner)：spec 面向對照的文件由它產出；沒有 spec 時該面向跳過
  - [`sk-spec-implementer`](../sk-spec-implementer)：實作流程結尾會載入本 skill；本 skill 也能單獨使用
