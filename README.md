# Claude Skills

個人撰寫的 Claude Code [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills)。以這個 repo 作為 single source of truth 進行版控，再透過 symlink 映射進 Claude Code 的執行環境。

　

## 運作方式

Claude Code 會掃描 `~/.claude/skills/` 來探索可用的 skill。本 repo 不直接對該執行目錄做版控（那裡混有第三方安裝的 skill，也緊鄰私人 session 資料），而是保存真正的檔案，並逐一把 skill 連結過去：

```
~/Developer/claude-skills/skills/<name>/   ← single source of truth（本 repo）
~/.claude/skills/<name>                    ← symlink，逐一建立
```

不論透過哪一邊的路徑編輯，改動的都是同一份檔案：變更立即生效，git 也隨時看得到。直接安裝在 `~/.claude/skills/` 的第三方 skill 永遠不會進入本 repo。

　

## 使用方式

把 repo 中的 skill 連結進 Claude Code 執行環境：

```sh
scripts/link-skill.sh <skill-name>
```

`<skill-name>` 是 skill 在 `skills/` 中的資料夾名（例如 `ultra-skill-author`）。

腳本具備「冪等性」（Idempotence）：對已連結的 skill 重複執行不會有任何動作，也不會覆蓋任何非自身 symlink 的目標（例如同名的第三方 skill）。

　

## 新增 skill

1. 在 `skills/<skill-name>/` 下撰寫 skill（內含 `SKILL.md` 的資料夾）。
2. 執行 `scripts/link-skill.sh <skill-name>` 讓它出現在 `~/.claude/skills/`。
3. 為 skill 撰寫一份自己的 `README.md`，說明：
   - **用途**：解決什麼問題、何時觸發
   - **來源**：原創，或衍生自哪個上游專案
   - **授權**：適用的 license 與相關聲明
4. commit 前確認出處：
   - **原創作品**：採用本 repo 的授權
   - **衍生自寬鬆授權的上游**：保留上游授權，並在 skill 資料夾內以 `NOTICE` 標明來源、作者與修改內容
   - **來源不明或授權不相容**：不收入本 repo
