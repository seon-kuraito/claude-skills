# Ultra Commit Creator

以 Conventional Commits 的 `<type>(<scope>): <description>` 格式撰寫 git commit 訊息，外加一條規則：description 必須是單句、祈使語氣的英文。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

替 git commit 撰寫訊息，嚴格遵循 Conventional Commits 的 `<type>(<scope>): <description>` 格式（例如 `feat(00-blank): add intro fade-in animation`）。type 是與 `ultra-branch-creator` 共用的同一套詞彙；description 收斂成單句祈使句，延伸脈絡則留給 PR。詳細規格見 `SKILL.md`。

　

## 設計取向

- **與分支共用同一套詞彙**：
  - type 採 Conventional Commits 的十種，與 `ultra-branch-creator` 完全一致
  - 這個 skill 是該詞彙的定義所在，分支命名反過來引用它
- **description 只寫單句祈使句**：
  - 祈使、小寫開頭、無句尾句點，盡量 50 字內
  - 一句講不完，代表這個 commit 太過複雜，應該要進一步拆分
- **不寫 prose body**：
  - 訊息只有 subject 一行（加上 `BREAKING CHANGE` footer 與 `Co-Authored-By` 等 trailer）
  - 延伸脈絡放 PR，不放 commit body；也不為了避開 body 而硬拆一個完整的改動
- **scope 有固定的判定順序**：
  - 專案 `CLAUDE.md` 的 scope 詞彙 → 變更檔案路徑 → 邏輯模組 → 省略
- **擋掉常見壞訊息**：
  - `wip`、`update X`、`fix stuff`、非英文、多段 body、一個 commit 混多件事，都會被改寫或要求拆分
- **附帶 evals**：
  - `evals/evals.json` 收了測試案例，供觸發與輸出驗證

　

## 預設與相依（可依需求抽換）

- **委派的 skill**：
  - 分支命名交給 `ultra-branch-creator`，共用同一套 type 詞彙；無該 skill 時，分支改依 `<type>/<kebab-description>` 慣例自行命名即可
- **語言慣例**：
  - description 與 body 一律英文（changelog／release-note 等工具預設英文）
