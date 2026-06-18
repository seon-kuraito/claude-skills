# Ultra Branch Creator

參考 [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) 的格式替 git branch 命名，和 commit 使用同一套語言。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

替 git branch 命名，格式固定為 `<type>/<kebab-description>`（例如：`feat/00-blank-intro-animation`）。type 沿用 Conventional Commits 的十種詞彙，讓 branch 與 `ultra-commit-creator` 共用同一套詞彙。詳細規格見 `SKILL.md`。

　

## 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-branch-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

## 設計取向

- **沿用 ultra-commit-creator 的 type 定義**：
  - branch type 與 Conventional Commits 完全一致，定義來源交給 `ultra-commit-creator` 維護
  - branch 與 commit 因此共用同一套語彙，避免出現 `feature/` 搭配 feat: 這類不一致格式
- **scope 前置，讓相關 branch 自然群聚**：
  - `feat(00-blank): ...` 對應的 branch 寫成 `feat/00-blank-...`
  - 透過字母排序時，同一 scope 的 branch 會自然排在一起，方便瀏覽與管理
- **branch 名應預示後續 commit**：
  - branch description 應清楚描述這條分支預期完成的變更
  - 好的 branch 名應讓接下來的 commit message 大致可預期，而不是只描述模糊方向
- **攔截常見不良 branch 格式**：
  - `feature/`、`bug/`、`hotfix/`、人名前綴、camelCase、snake_case、非英文命名等情況，都會被改寫為一致格式
- **附帶 evals**：
  - `evals/evals.json` 收錄測試案例，用於觸發條件與輸出格式驗證

　

## 預設與相依

- **語言慣例**：
  - 一律英文、kebab-case（git／web 慣例）
- **委派的 skill**：
  - type 詞彙的完整定義交給 `ultra-commit-creator`；沒有該 skill 時，改參照 Conventional Commits 規格即可
