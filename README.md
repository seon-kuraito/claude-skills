# Claude Skills

個人維護的 Claude Code [Skills](https://docs.claude.com/en/docs/claude-code/skills)。這個 repo 保存實際檔案並負責版控，再透過 symlink 掛進 Claude Code 的執行環境。

在 claude-* 家族的分工裡，skill 負責「專業能力」：把做事的方式與偏好載入當前 session，引導 AI 按特定流程工作。獨立視角與隔離歸 `claude-agents`，強制性規則歸 `claude-hooks`。

　

## Skills 一覽

本 repo 目前維護以下 skill：

| skill | 用途 | 來源 |
| --- | --- | --- |
| [`sk-agent-author`](skills/sk-agent-author) | 建立、改寫與驗證 Claude Code subagent 定義 | 原創 |
| [`sk-branch-creator`](skills/sk-branch-creator) | 依 Conventional Commits 語彙命名 branch | 原創 |
| [`sk-claudemd-composer`](skills/sk-claudemd-composer) | 建立、審閱與精修 CLAUDE.md | 觀念提煉自 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) |
| [`sk-commit-creator`](skills/sk-commit-creator) | 撰寫 Conventional Commits 訊息 | 原創 |
| [`sk-decision-griller`](skills/sk-decision-griller) | 逐一釐清計畫或設計中的關鍵決策 | 延伸自 [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) |
| [`sk-hook-author`](skills/sk-hook-author) | 建立、改寫與驗證 Claude Code hook | 原創 |
| [`sk-notion-composer`](skills/sk-notion-composer) | 將筆記整理成固定樣式的 Notion 頁面 | 原創 |
| [`sk-pr-creator`](skills/sk-pr-creator) | 建立 GitHub PR 並撰寫三段式 body | 原創 |
| [`sk-project-cleaner`](skills/sk-project-cleaner) | 診斷並清除專案在 Claude Code 與 VS Code 留下的狀態 | 原創 |
| [`sk-project-deployer`](skills/sk-project-deployer) | 把專案部署到代管平台（例如：GitHub Pages） | 原創 |
| [`sk-project-initializer`](skills/sk-project-initializer) | 補齊 repo 建立後的專案設定 | 原創 |
| [`sk-project-migrator`](skills/sk-project-migrator) | 搬遷本機專案路徑，並一併帶走 Claude Code 與 VS Code 的狀態 | 原創 |
| [`sk-react-publisher`](skills/sk-react-publisher) | 全自動從零建立並部署一個 GitHub Pages 上的 React 專案 | 原創 |
| [`sk-repo-creator`](skills/sk-repo-creator) | 依模板建立本地端與 GitHub repo | 原創 |
| [`sk-skill-author`](skills/sk-skill-author) | 建立、改寫與驗證 Claude Code skill | 延伸自 [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) |

　

## 運作方式

Claude Code 會掃描 `~/.claude/skills/` 來探索可用的 skill。本 repo 不直接版控執行目錄，因為裡面可能有第三方安裝的 skill，也緊鄰私人 session 資料。這裡只保存自己維護的檔案，並逐一連結過去：

```
~/Developer/<owner>/claude-skills/skills/<name>/   ← 實際檔案（本 repo）
~/.claude/skills/<name>                            ← symlink，逐一建立
```

skill 會逐一連結到執行環境：不論從哪個路徑編輯，改到的都是同一份檔案，且變更會立即生效，git 也看得到。直接安裝在 `~/.claude/skills/` 的第三方 skill 不會進入本 repo。

　

## 使用方式

把 repo 裡的 skill 連結到 Claude Code 執行環境：

```sh
scripts/link-skill.sh <skill-name>
```

`<skill-name>` 是 `skills/` 下的資料夾名稱（例如：`sk-skill-author`）。

腳本可重複執行：已連結的 skill 會略過，也不會覆蓋非自身管理的 symlink（例如：同名的第三方 skill）。

　

## 驗證

提交前檢查 repo 裡的 skill：

```sh
scripts/run-checks.sh              # 全部 skill
scripts/run-checks.sh <skill-name> # 單一 skill
```

這支腳本執行結構層與腳本層檢查，兩者都不消耗模型 token。模型層的觸發與行為案例由 [`sk-skill-author`](skills/sk-skill-author) 在流程末端執行；詳細規格見 [`verification.md`](skills/sk-skill-author/references/verification.md)。

　

## 新增 skill

1. 在 `skills/<skill-name>/` 下撰寫 skill（內含 `SKILL.md` 的資料夾）。
2. 執行 `scripts/link-skill.sh <skill-name>` 讓它出現在 `~/.claude/skills/`。
3. 為 skill 撰寫一份自己的 `README.md`，說明：
   - **用途**：解決什麼問題、何時觸發
   - **來源**：原創，或衍生自哪個上游專案
   - **授權**：適用的 license 與相關聲明
4. commit 前確認來源與授權：
   - **原創作品**：採用本 repo 的授權
   - **衍生自寬鬆授權的上游**：保留上游授權，並在 skill 資料夾內以 `NOTICE` 標明來源、作者與修改內容
   - **來源不明或授權不相容**：不收入本 repo
