# Claude Skills

個人維護的 Claude Code [Skills](https://docs.claude.com/en/docs/claude-code/skills)。這個 repo 保存實際檔案並負責版控，再透過 symlink 掛進 Claude Code 的執行環境。

　

## Skills 一覽

本 repo 目前維護以下 skill：

| skill | 用途 | 來源 |
| --- | --- | --- |
| [`ultra-skill-author`](skills/ultra-skill-author) | 建立、改寫與評估 skill | 延伸自 [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) |
| [`ultra-claudemd-author`](skills/ultra-claudemd-author) | 建立、審閱與精修 CLAUDE.md | 觀念提煉自 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) |
| [`ultra-hook-author`](skills/ultra-hook-author) | 建立與審閱 Claude Code hook | 原創 |
| [`ultra-branch-creator`](skills/ultra-branch-creator) | 依 Conventional Commits 語彙命名 branch | 原創 |
| [`ultra-commit-creator`](skills/ultra-commit-creator) | 撰寫 Conventional Commits 訊息 | 原創 |
| [`ultra-pr-creator`](skills/ultra-pr-creator) | 建立 GitHub PR 並撰寫三段式 body | 原創 |
| [`ultra-repo-creator`](skills/ultra-repo-creator) | 以本地、遠端與 branch 保護三階段建立 repo | 原創 |
| [`ultra-decision-griller`](skills/ultra-decision-griller) | 逐一釐清計畫或設計中的關鍵決策 | 延伸自 [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md) |
| [`ultra-notion-formatter`](skills/ultra-notion-formatter) | 將筆記整理成固定樣式的 Notion 頁面 | 原創 |

　

## 運作方式

Claude Code 會掃描 `~/.claude/skills/` 來探索可用的 skill。本 repo 不直接版控執行目錄，因為裡面可能有第三方安裝的 skill，也緊鄰私人 session 資料。這裡只保存自己維護的檔案，並逐一連結過去：

```
~/Developer/claude-skills/skills/<name>/   ← 實際檔案（本 repo）
~/.claude/skills/<name>                    ← symlink，逐一建立
```

skill 會逐一連結到執行環境：不論從哪個路徑編輯，改到的都是同一份檔案，且變更會立即生效，git 也看得到。直接安裝在 `~/.claude/skills/` 的第三方 skill 不會進入本 repo。

　

## 使用方式

把 repo 裡的 skill 連結到 Claude Code 執行環境：

```sh
scripts/link-skill.sh <skill-name>
```

`<skill-name>` 是 `skills/` 下的資料夾名稱（例如：`ultra-skill-author`）。

腳本可重複執行：已連結的 skill 會略過，也不會覆蓋非自身管理的 symlink（例如：同名的第三方 skill）。

　

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
