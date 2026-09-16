# Skill Author

建立、改寫、評估 Claude Code skill 的個人化流程。

　

## 聲明

- **來源**：
  - 延伸自 Anthropic 的 [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator)
- **授權**：
  - Apache License 2.0（Copyright 2026 Anthropic, PBC）
  - 完整條款見同目錄 [`LICENSE`](LICENSE)，衍生改動聲明見 [`NOTICE`](NOTICE)

　

## 為什麼做這個 skill（WHY）

- **要顧的太多、太散**：
  - 建立一個 skill 牽涉 `SKILL.md` 結構、description 觸發、授權、README、測試，缺一條統一流程就容易漏、每次品質不一
- **嚴謹度與執行成本需要平衡**：
  - 完整評測成本較高，例行流程需要可預估、可執行的驗證範圍
- **個人 skill 容易各長各的**：
  - 命名與文件樣式若沒有規範，久了風格就容易發散

　

## 這個 skill 做什麼（WHAT）

- **涵蓋完整 skill 工作流**：
  - 支援 skill 的建立、改寫、重構、命名、授權與評估
- **預設流程保持輕量**：
  - 以「訪談 → 草擬 → 審閱」作為主線，讓常見情境可以快速完成
- **固定執行驗證**：
  - 驗證分為結構、腳本、模型三層；結構與腳本層不消耗模型 token，模型層每個案例使用一個 sub-agent
  - 新建與後續修改皆納入驗證流程
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
  scripts/link-skill.sh sk-skill-author
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **預設流程保持輕量，並保留固定驗證**：
  - 原版把完整評測流程放在主線中，適合高嚴謹度情境，但也會讓一般建立流程變重
  - 本版將主線收斂為「訪談 → 草擬 → 審閱」三步，最後固定接上驗證
  - 驗證分為三層：結構與腳本層不消耗模型 token，模型層只在觸發與行為兩種案例上各使用一個 sub-agent
  - 新建與修改都會執行同一套驗證流程
- **驗證成本需可估算**：
  - 一個案例對應一個 sub-agent，執行次數可在開始前估算
  - 案例的 prompt 維持中性，不在題目中提示測試重點
  - 觸發案例的期望可指向其他 skill，用於確認相近觸發條件的邊界
- **統一個人 skill 命名**：
  - 採用 `sk-<single-token>-<verber>` 命名格式，讓個人 skill 共用一致語彙
  - 遇到不符合規範的既有 skill，會主動提醒並提出改名建議
- **審閱階段聚焦於決策**：
  - 審閱時只呈現關鍵結構、取捨與待確認事項
  - 不把整份 `SKILL.md` 直接倒進終端機；全文應留在編輯器中閱讀與修改
- **限制 description 的責任範圍**：
  - `description` 只保留觸發 skill 所需的辨識訊號
  - 範本、涵蓋清單、輸出格式與執行細節應移到 body 或 references
  - 因為 `description` 會在每個工作階段常駐，塞入過多規格不會讓觸發更準，只會稀釋訊號
- **以漸進式揭露（Progressive Disclosure）拆分 references**：
  - 將原本集中在單體文件中的內容，拆成 `writing-guide`、`verification`、`publishing`、`readme-guide` 與 `environments`
  - 主線只保留必要規則，細節依任務需要再載入，讓常駐內容維持精簡
- **以 Claude Code 作為主要使用環境**：
  - 驗證的結構與腳本層以 shell 執行，模型層以 sub-agent 執行，兩者皆依賴 Claude Code 的環境
  - Claude.ai 與 Cowork 等其他環境的使用情境，收進 `environments` 參考檔，不直接寫進主流程
- **內建出身判定與授權產出**：
  - 建立 skill 時先判定來源是原創或衍生，並依結果產出對應授權文件
  - 原創 skill 自動附上 MIT `LICENSE`
  - 衍生 skill 需先釐清上游來源，再補上對應的 `LICENSE` 與 `NOTICE`
- **內建發佈工作流**：
  - 在 `claude-skills` repo 中建立或調整 skill，並串起「檢查 git 狀態 → 開 branch → 建立／調整 → symlink（新建）→ 驗證 → commit」
  - branch 與 commit 分別委派給 [`sk-branch-creator`](../sk-branch-creator) 與 [`sk-commit-creator`](../sk-commit-creator)
  - commit 前會停下讓使用者確認；PR 不會自動建立
- **統一文件與發佈規格**：
  - 每個 skill 都附一份固定格式的 `README.md`，規範見 [`references/readme-guide.md`](references/readme-guide.md)
  - 同步產出 `LICENSE` 與 `NOTICE`
  - 語言、標題 spacer、列點與標點樣式需維持一致
- **適用範圍包含所有自建 skill**：
  - 全域 skill 統一放在 `claude-skills` repo，再將整包目錄逐一 symlink 到 `~/.claude/skills/`；只服務單一專案的 skill 則作為例外，直接放進該專案版控
  - 直接透過第三方安裝的 skill 不納入這套流程
- **保留對抗式審查**：
  - 以 `agents/skill-reviewer.md` 審查草擬中的 skill
  - 審查重點包含 description 觸發正確性、結構與行數紀律、bundled resources 擺放、機器路徑是否在執行時推導，以及文件與授權合規

　

> 附註：`scripts/package_skill.py` 與 `scripts/quick_validate.py` 大致沿用 `skill-creator` 原樣（`assets/license-mit.txt` 與 `agents/skill-reviewer.md` 為原創）；上游的 eval、description 調校與盲測工具已移除，改動主要集中在工作流程與 `SKILL.md` 的取捨。
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；前者確認請求會路由到這個 skill，後者確認產出符合規格
  - `tests/checks/quick-validate.py` 驗證 `quick_validate.py` 對 frontmatter 的判定，涵蓋缺欄位、命名格式與長度上限（靜態執行，不需要 LLM）

　

### 預設與相依

- **目標 repo**：
  - 發佈流程從本 skill 的 symlink 反推 `claude-skills` 的位置：以 `realpath` 解析安裝路徑，往上兩層即為 repo 根目錄
  - 不以工作目錄（Working Directory）為準，工作階段從哪個目錄啟動都不影響
  - 如需指向其他 skills repo，從該 repo 執行 `scripts/link-skill.sh` 重新連結即可
  - 解析結果不是 git repo 時（例如：以複製而非 symlink 安裝），會退回「只在本機建立、跳過 git 流程」
- **委派的 skills**：
  - 開 branch 用 [`sk-branch-creator`](../sk-branch-creator)、發 commit 用 [`sk-commit-creator`](../sk-commit-creator)
  - 若無這兩個 skill，將對應步驟替換為其他 branch／commit 慣例即可
