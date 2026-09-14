# Ultra Skill Author

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
- **嚴謹與輕便難兩全**：
  - 完整評測有其成本，但「只是想快速建一個」不該被重流程綁住
- **個人 skill 容易各長各的**：
  - 命名與文件樣式若沒有規範，久了風格就容易發散

　

## 這個 skill 做什麼（WHAT）

- **涵蓋完整 skill 工作流**：
  - 支援 skill 的建立、改寫、重構、命名、授權與評估
- **預設流程保持輕量**：
  - 以「訪談 → 草擬 → 審閱」作為主線，讓常見情境可以快速完成
- **進階機制需要時再啟用**：
  - 建立新 skill 時，evals 與 description 調校先由能力選用關卡（Capability Checkpoint）確認，使用者選入後再執行
  - 修改既有 skill 時略過關卡；完成修改後，再提議執行 evals 與新舊版盲測
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
  scripts/link-skill.sh ultra-skill-author
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **預設流程保持輕量**：
  - 原版把完整評測流程放在主線中，適合高嚴謹度情境，但也會讓一般建立流程變重
  - 本版將預設流程收斂為「訪談 → 草擬 → 審閱」三步，讓常見情境可以順手完成
  - 評測相關機制由能力選用關卡（Capability Checkpoint）確認，使用者主動選入後再展開
  - 修改既有 skill 時範圍通常已明確，因此略過關卡；完成修改後再提議評測
- **評測需能分辨新舊版差異**：
  - eval prompt 維持中性，不在題目中提示測試重點，避免新舊版都因題目提示而通過
  - 需要詢問使用者的 skill，評測時使用沙盒與答案表；遇到答案表未涵蓋的問題就停止
  - 盲測前先移除輸出中可辨識版本的路徑，並避免把 assertion 交給 comparator
- **統一個人 skill 命名**：
  - 採用 `ultra-<single-token>-<verber>` 命名格式，讓個人 skill 共用一致語彙
  - 遇到不符合規範的既有 skill，會主動提醒並提出改名建議
- **審閱階段聚焦於決策**：
  - 審閱時只呈現關鍵結構、取捨與待確認事項
  - 不把整份 `SKILL.md` 直接倒進終端機；全文應留在編輯器中閱讀與修改
- **限制 description 的責任範圍**：
  - `description` 只保留觸發 skill 所需的辨識訊號
  - 範本、涵蓋清單、輸出格式與執行細節應移到 body 或 references
  - 因為 `description` 會在每個工作階段常駐，塞入過多規格不會讓觸發更準，只會稀釋訊號
- **以漸進式揭露（Progressive Disclosure）拆分 references**：
  - 將原本集中在單體文件中的內容，拆成 `writing-guide`、`evals`、`description-tuning`、`blind-comparison` 與 `environments`
  - 主線只保留必要規則，細節依任務需要再載入，讓常駐內容維持精簡
- **以 Claude Code 作為主要使用環境**：
  - 能力選用關卡以 `AskUserQuestion` 實作，對齊 Claude Code 的互動方式
  - Claude.ai 與 Cowork 等其他環境的使用情境，收進 `environments` 參考檔，不直接寫進主流程
- **內建出身判定與授權產出**：
  - 建立 skill 時先判定來源是原創或衍生，並依結果產出對應授權文件
  - 原創 skill 自動附上 MIT `LICENSE`
  - 衍生 skill 需先釐清上游來源，再補上對應的 `LICENSE` 與 `NOTICE`
- **內建發佈工作流**：
  - 在 `claude-skills` repo 中建立或調整 skill，並串起「檢查 git 狀態 → 開 branch → 建立／調整 → symlink（新建）→ 驗證 → commit」
  - branch 與 commit 分別委派給 [`ultra-branch-creator`](../ultra-branch-creator) 與 [`ultra-commit-creator`](../ultra-commit-creator)
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

　

> 附註：`scripts/`、`agents/`、`eval-viewer/` 與 `assets/eval_review.html` 大致沿用 `skill-creator` 原樣（`assets/license-mit.txt` 與 `agents/skill-reviewer.md` 為原創）；改動主要集中在工作流程與 `SKILL.md` 的取捨。

　

### 預設與相依

- **目標 repo**：
  - 發佈流程從本 skill 的 symlink 反推 `claude-skills` 的位置：以 `realpath` 解析安裝路徑，往上兩層即為 repo 根目錄
  - 不以工作目錄（Working Directory）為準，工作階段從哪個目錄啟動都不影響
  - 如需指向其他 skills repo，從該 repo 執行 `scripts/link-skill.sh` 重新連結即可
  - 解析結果不是 git repo 時（例如：以複製而非 symlink 安裝），會退回「只在本機建立、跳過 git 流程」
- **委派的 skills**：
  - 開 branch 用 [`ultra-branch-creator`](../ultra-branch-creator)、發 commit 用 [`ultra-commit-creator`](../ultra-commit-creator)
  - 若無這兩個 skill，將對應步驟替換為其他 branch／commit 慣例即可
