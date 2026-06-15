# Ultra CLAUDE.md Author

把寫好 CLAUDE.md 的原則，提煉成一套可執行的建立與精修流程。

　

## 聲明

- **來源**：
  - 原創；觀念提煉自 Kyle Mistele 的 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)（HumanLayer，2025）
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

建立、精修、瘦身 CLAUDE.md／AGENTS.md——優化 agent 在每個工作階段都會載入的專案上手文件。新檔以 `/init` 起手再依原則修整，既有檔則按長度與品質審閱、判斷哪些內容該拆出去，並涵蓋 monorepo 多份 CLAUDE.md 的取捨。詳細規格見 `SKILL.md`。

　

## 設計取向

- **只收觀念，不轉載原文**：
  - 原文為 HumanLayer 版權所有、未附開源授權，無法隨公開 repo 散布
  - 因此只把可執行的原則用自有文字寫進 `SKILL.md`，原文改以連結引用並標註出處
- **WHY／WHAT／HOW 為主幹**：
  - 把「一份好的 CLAUDE.md 該涵蓋什麼」收斂成三個維度
  - 不服務這三個維度的內容，即為刪除候選
- **把指令預算當真**：
  - 強調 CLAUDE.md 每一行都吃掉模型有限的指令注意力，主張寧短勿長（目標 < 300 行）
  - 過長時改用漸進揭露，把細節移到 `docs/` 等外部檔
- **`/init` 是鷹架不是成品**：
  - 將 `/init` 定位為第一版草稿，列出常見要修掉的樣態（列舉式檔案清單、內聯程式碼、風格規則）
  - 用意：用它打破空白頁，但不直接出貨
