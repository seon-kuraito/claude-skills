# Ultra Skill Author

在 Anthropic skill-creator 的基礎上延伸而成的版本。

　

## 聲明

- **來源**：
  - 延伸自 Anthropic 的 [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator)，非原創
- **授權**：
  - Apache License 2.0（Copyright 2026 Anthropic, PBC）
  - 完整條款見同目錄 `LICENSE`，衍生改動聲明見 `NOTICE`

　

## Summary

處理 Claude agent skill 的各種工作——建立、改寫、重構、命名、授權、評估。預設走輕量的訪談 → 草擬 → 審閱三步；evals、description 調校、新舊版盲測等重型流程則按需開啟。詳細規格見 `SKILL.md`。

　

## 設計取向（相對於 skill-creator 的取捨）

- **預設輕量，重型流程選配**：
  - 原版把整條評測流程當作主線
  - 本版將預設收斂成「訪談 → 草擬 → 審閱」三步，評測類機制改由能力選用關卡（capability checkpoint）讓使用者主動選入
  - 用意：不讓常見情境被繁重型流程拖慢
- **命名規範**：
  - 加入 `ultra-<single-token>-<verber>` 命名格式，讓個人 skill 共用一致的語彙
  - 遇到不合規的既有 skill，會主動提議改名
- **用決策審閱，不傾倒全文**：
  - 審閱階段以重點條列呈現結構決策
  - 刻意不把整份 `SKILL.md` 倒進終端機，全文留給編輯器閱讀
- **為 description 設限，擋掉規格滲入**：
  - 把範本、涵蓋清單、輸出格式、執行細節從 `description` 移進內文（body）
  - 用意：`description` 每個工作階段都常駐，規格塞進去不會提升觸發、只會稀釋整體訊號
- **拆成漸進揭露的 references**：
  - 把單體文件拆成 `writing-guide`／`evals`／`description-tuning`／`blind-comparison`／`environments`
  - 按需載入，讓常駐表面保持精簡
- **以 Claude Code 為主環境**：
  - 能力選用關卡以 `AskUserQuestion` 實作
  - Claude.ai／Cowork 的情境收進 `environments` 參考檔，而非寫死在主線
- **內建出身判定與授權產出**：
  - 建立 skill 時先判定原創或衍生，把授權合規收進建立流程
  - 原創：自動附一份 MIT `LICENSE`
  - 衍生：釐清上游後，補上對應的 `LICENSE` 與 `NOTICE`
- **內建發佈工作流**：
  - 在 `claude-skills` repo 建立或調整 skill，串起「檢查 git 狀態 → 開分支 → 建立／調整 → symlink（新建）→ 驗證 → commit」
  - 分支與 commit 委派給 `ultra-branch-creator`／`ultra-commit-creator`
  - commit 前停下確認；PR 不自動開
- **一致的文件規範**：
  - 每個 skill 附一份固定格式的 `README.md`（聲明／Summary／設計取向），與 `LICENSE`／`NOTICE` 一同產出
  - 語言、標題 spacer、列點與標點樣式統一，規範見 `references/readme-guide.md`

　

> 附註：`scripts/`、`agents/`、`eval-viewer/` 與 `assets/eval_review.html` 大致沿用 skill-creator 原樣（`assets/license-mit.txt` 為原創）；改動主要集中在工作流程與 SKILL.md 的取捨。

　

## 預設與相依（可依需求抽換）

「內建發佈工作流」依賴以下兩項預設；改用其他環境時調整即可：

- **目標 repo**：
  - 發佈流程預設在 `~/Developer/claude-skills` 操作
  - 如需指向其他 skills repo，改這個路徑即可
  - repo 不存在時，會退回「只在本機建立、跳過 git 流程」
- **委派的 skills**：
  - 開分支用 `ultra-branch-creator`、commit 用 `ultra-commit-creator`
  - 若無這兩個 skill，將對應步驟替換為其他分支／commit 慣例即可
