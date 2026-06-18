# Ultra CLAUDE.md Author

把撰寫 CLAUDE.md 的原則，整理成一套可執行的建立與精修流程。

　

## 聲明

- **來源**：
  - 原創
  - 觀念提煉自 Kyle Mistele 的 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)（HumanLayer，2025）
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

建立、精修、瘦身 CLAUDE.md／AGENTS.md，優化 agent 每個工作階段都會載入的專案上手文件。新檔先用 `/init` 起稿，再依原則修整；既有檔則按長度與品質審閱，判斷哪些內容該刪、哪些該拆出去，也涵蓋 monorepo 多份 CLAUDE.md 的取捨。詳細規格見 `SKILL.md`。

　

## 安裝

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

　

## 設計取向

- **只提煉原則，不轉載原文**：
  - 原文為 HumanLayer 版權所有，且未附可供再散布的開源授權，因此不隨公開 repo 收錄或改寫原文段落
  - 本 skill 只將可執行的寫作原則整理成自己的文字，並在 `README.md` 中以連結引用原文、標註出處
- **以專案脈絡、工作邊界與操作方式為核心**：
  - `CLAUDE.md` 應該協助 agent 快速理解：這個專案為什麼存在（WHY）、目前主要在做什麼（WHAT）、實作與協作時該怎麼做（HOW）
  - 不服務這三件事的內容，通常就是刪除或外移候選
- **控制常駐指令的篇幅**：
  - `CLAUDE.md` 會在每個工作階段被載入，因此每一行都會占用 agent 的注意力與上下文空間
  - 內容應寧短勿長，優先保留真正會影響判斷與操作的資訊；建議目標控制在 300 行以內
  - 當文件過長時，改用漸進式揭露（Progressive Disclosure）：只在 `CLAUDE.md` 保留入口與摘要，把細節移到 `docs/` 等外部文件
- **先用 /init 起稿，再人工精修**：
  - `/init` 適合用來產生第一版草稿，協助打破空白頁
  - 產出後仍需要人工修整，刪掉過度列舉的檔案清單、內聯程式碼、過細的風格規則，以及其他不該長期放在 `CLAUDE.md` 裡的內容
