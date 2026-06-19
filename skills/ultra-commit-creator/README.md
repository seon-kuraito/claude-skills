# Ultra Commit Creator

使用 [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) 格式撰寫 git commit 訊息，並將 description 收斂為單句、祈使語氣的英文。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **commit message 隨手寫**：
  - `wip`、`update X`、`fix stuff` 這類訊息，事後從 git log 很難看出實際變更
- **格式飄移**：
  - type、scope 與語氣每次不同，跨專案更難維持一致
- **一個 commit 混多件事**：
  - review 和 revert 都會變難，歷史也不容易讀懂

　

## 這個 skill 做什麼（WHAT）

- **產生一致的 git commit 訊息**：
  - 格式固定 Conventional Commits 的 `<type>(<scope>): <description>`（例如：`feat(00-blank): add intro fade-in animation`）
- **description 收斂成單句祈使句**：
  - description 使用英文單句，並與 branch 共用同一套 type 詞彙
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
  scripts/link-skill.sh ultra-commit-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **與 [`ultra-branch-creator`](../ultra-branch-creator) 共用同一套 type 語彙**：
  - type 採用 Conventional Commits 的十種類型，並與 `ultra-branch-creator` 保持一致
  - `ultra-commit-creator` 是 type 定義的維護來源，branch 命名只引用這套語彙，不重複定義
- **description 採單句祈使句**：
  - description 使用小寫開頭的祈使句，不加句尾句點，並盡量控制在 50 字以內
  - 如果一句話無法清楚描述變更，通常代表這個 commit 過於複雜，應該重新拆分
- **預設不寫 prose body**：
  - commit message 以 subject 一行為主，只在需要時補上 `BREAKING CHANGE`、`Co-Authored-By` 等 trailer
  - 延伸脈絡應留給 PR 說明，不放進 commit body；但也不為了避開 body，把一個完整改動拆得過碎
- **依序判定 scope**：
  - scope 依固定順序判定：專案 `CLAUDE.md` 定義的 scope 詞彙 → 變更檔案路徑 → 邏輯模組 → 省略
  - 只有在 scope 能幫助理解變更範圍時才使用，避免為了格式完整而硬加
- **攔截常見不良 commit message**：
  - `wip`、`update X`、`fix stuff`、非英文訊息、多段 prose body、單一 commit 混入多件事等情況，都會被改寫或要求拆分
- **附帶 evals**：
  - `evals/evals.json` 收錄測試案例，用於觸發條件與輸出格式驗證

　

### 預設與相依

- **語言慣例**：
  - description 與 body 一律以英文撰寫（可以根據需求調整）
- **委派的 skill**：
  - branch 命名交給 [`ultra-branch-creator`](../ultra-branch-creator)；沒有該 skill 時，branch 改依 `<type>/<kebab-description>` 慣例自行命名即可
