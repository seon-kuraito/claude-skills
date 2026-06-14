# ultra-branch-creator

以 `<type>/<kebab-description>` 格式命名 git 分支，與 commit 共用同一套 Conventional Commits 詞彙。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

替 git 分支命名，採 `<type>/<kebab-description>` 格式（例如 `feat/00-blank-intro-animation`）。type 沿用 Conventional Commits 的十種詞彙，讓分支與後續落在其上的 commit 講同一種語言。詳細規格見 `SKILL.md`。

　

## 設計取向

- **與 commit 共用同一套詞彙**：
  - type 與 Conventional Commits 完全一致，定義交給 `ultra-commit-creator`，不重複維護
  - 分支與 commit 因此語彙一致，不會出現 `feature/` 配 `feat:` 這種對不上的情況
- **scope 前置，讓相關分支群聚**：
  - `feat(00-blank): …` 對應的分支寫成 `feat/00-blank-…`
  - 字母排序時，同 scope 的分支自然排在一起
- **分支名預示 commit**：
  - description 寫得讓接下來的 commit 訊息一望即知
- **擋掉常見壞格式**：
  - `feature/`、`bug/`、`hotfix/`、人名前綴、camelCase／snake_case、非英文，都會被改寫
- **附帶 evals**：
  - `evals/evals.json` 收了測試案例，供觸發與輸出驗證

　

## 預設與相依（可依需求抽換）

- **委派的 skill**：
  - type 詞彙的完整定義交給 `ultra-commit-creator`；無該 skill 時，改參照 Conventional Commits 規格即可
- **語言慣例**：
  - 一律英文、kebab-case（git／web 慣例）
