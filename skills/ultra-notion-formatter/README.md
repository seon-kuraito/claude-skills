# Ultra Notion Formatter

把筆記整理成固定 house style 的 Notion 頁面，包含屬性、結構、全形標點與詞彙表。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

把筆記格式化成 Notion 頁面，套用固定的 house style，包含：屬性（Title／Type／Tag／Icon）、頁面結構（灰底 Summary → 編號 h2 內容 → 詞彙表）、全形標點與灰括號等規則。可以格式化既有頁，也能從筆記 database 的 template 建立新頁（含批次）。詳細規格見 `SKILL.md`。

　

## 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-notion-formatter
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

## 設計取向

- **完整套用 house style**：
  - house style 視為筆記格式契約，每次整理都應完整套用，不挑選、不省略
  - 同一系列筆記（例如：教學系列）共用同一套結構，維持一致格式
- **支援既有頁與新頁建立**：
  - 可格式化既有頁面（提供 URL 或 page ID）
  - 也可從筆記 database 的 page template 建立新頁，並支援一次建立多頁
- **統一屬性與頁面結構**：
  - 屬性規則：`Title` 只放筆記本身的標題，`Type` 與 `Tag` 分別承擔分類與標籤用途，Icon 用來代表主題
  - 頁面結構：以灰底 Summary 開頭，接著是編號 h2 內容段落，最後以詞彙表收尾
- **使用全形標點符號**：
  - 內文中的中英文標點皆使用全形（。，、（）「」…），只有 inline code 與 code block 例外
  - 灰色括號只用於內文 prose；標題、callout 標題與表格儲存格中的括號維持白色
- **Good-to-know callout**：
  - 每個內容段落都要補上一則 Good-to-know 的 callout block
  - 內容應提供延伸觀念、常見坑或底層原理，補出讀者會覺得有收穫的資訊，而不是重述該段內容
- **以 Markdown table 詞彙表收尾**：
  - 頁面最後固定放置「詞彙表」
  - 詞彙表使用 Markdown table，欄位固定為「名詞｜英文｜說明」，命名使用「詞彙表」，不使用「名詞解釋」

　

## 預設與相依

- **Notion MCP**：
  - 依賴 Notion 的 MCP 工具（fetch、create-pages、update_page）與 `notion://docs/enhanced-markdown-spec` 規格
- **個人的筆記 database**：
  - 綁定特定 database 的 schema、template 與屬性名（`Type`／`Tag`），換 database 時需要根據 schema 調整
- **house style 本身**：
  - 全形標點、詞彙表命名、Good-to-know 必填等屬個人偏好，可依需求改寫
