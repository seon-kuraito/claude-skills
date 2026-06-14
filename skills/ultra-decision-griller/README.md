# ultra-decision-griller

像拷問一樣，逐一逼問計畫或設計裡的每個決策，沿決策樹一次一個分支往下，直到雙方達成共識。

　

## 聲明

- **來源**：
  - 延伸自 Matt Pocock 的 [grill-me](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)，非原創
- **授權**：
  - MIT（Copyright 2026 Matt Pocock）
  - 完整條款見同目錄 `LICENSE`，衍生改動聲明見 `NOTICE`

　

## Summary

針對一份計畫或設計，逐一逼問其中的每個決策。決策樹一次只走一個分支、先解決上游依賴，直到雙方達成共識。收尾時把已定的決策整理成條列，並可選擇存成檔案。詳細規格見 `SKILL.md`。

　

## 設計取向（相對於 grill-me 的取捨）

- **反轉建議順序，讓使用者先表態**：
  - 原版每題先給出 AI 的建議答案
  - 本版改成使用者先回答、AI 再回應
  - 同意則簡短帶過，不同意則先幫使用者的論點補強，之後再反駁（steel-man）
  - 用意：AI 先給建議會錨定使用者；讓使用者先表態，才會浮現真正的分歧，而非附和的點頭
- **結構化成三段**：
  - 原版是一整段散文
  - 本版拆成 `How to ask`／`How to recommend`／`When to stop` 三段
- **納入 `AskUserQuestion`**：
  - 當分支有 2–4 個合理答案時改用多選，比開放式問答收斂更快
- **明確的收尾**：
  - 定義停止條件；收束時把決策整理成「分支 → 決定 → 一句理由」，並詢問是否存檔

　

> 附註：核心概念與部分措辭（一次一分支的逼問、「能用 codebase 回答就去查 codebase」）沿用自原版。
