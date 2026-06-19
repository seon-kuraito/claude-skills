# Ultra CLAUDE.md Author

把 CLAUDE.md 的寫作原則整理成可執行的建立、審閱與精修流程。

　

## 聲明

- **來源**：
  - 觀念提煉自 Kyle Mistele 的 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)（HumanLayer，2025）
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **CLAUDE.md 容易越長越肥**：
  - 每一行都會占用 agent 的注意力，塞太多內容反而稀釋真正重要的脈絡
- **不知道什麼該放進去**：
  - 專案脈絡、操作方式、風格規則常混在一起，缺少清楚的取捨標準
- **`/init` 的草稿常未經整理就沿用**：
  - 過度列舉的檔案清單、內聯程式碼與過細的風格規則，常在沒有整理的情況下被保留下來

　

## 這個 skill 做什麼（WHAT）

- **建立、審閱與瘦身 CLAUDE.md／AGENTS.md**：
  - 優化 agent 每個工作階段都會載入的專案上手文件
- **新檔起稿、既有檔審閱**：
  - 先用 `/init` 起稿再依原則修整
  - 既有檔則依長度與品質判斷該刪、該拆或該保留，也涵蓋 monorepo 多份 CLAUDE.md 的取捨
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
  scripts/link-skill.sh ultra-claudemd-author
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **只提煉原則，不轉載原文**：
  - 原文為 HumanLayer 版權所有，且未附可供再散布的開源授權，因此不隨公開 repo 收錄或改寫原文段落
  - 本 skill 只將可執行的寫作原則整理成自己的文字，並在 `README.md` 中以連結引用原文、標註出處
- **以專案脈絡、工作邊界與操作方式為核心**：
  - `CLAUDE.md` 應該協助 agent 快速理解：這個專案為什麼存在（WHY）、目前主要在做什麼（WHAT）、實作與協作時該怎麼做（HOW）
  - 不能服務這三件事的內容，通常就是刪除或外移候選
- **控制常駐指令的篇幅**：
  - `CLAUDE.md` 會在每個工作階段被載入，因此每一行都會占用 agent 的注意力與上下文空間
  - 內容應寧短勿長，優先保留真正會影響判斷與操作的資訊；建議目標控制在 300 行以內
  - 當文件過長時，改用漸進式揭露（Progressive Disclosure）：只在 `CLAUDE.md` 保留入口與摘要，把細節移到 `docs/` 等外部文件
- **先用 /init 起稿，再人工精修**：
  - `/init` 適合用來產生第一版草稿，協助打破空白頁
  - 產出後仍需要人工修整，刪掉過度列舉的檔案清單、內聯程式碼、過細的風格規則，以及其他不適合長期放在 `CLAUDE.md` 裡的內容
