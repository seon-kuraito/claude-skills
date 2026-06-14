# ultra-notion-formatter

把筆記內容整理成固定 house style 的 Notion 頁面：固定的屬性、結構、全形標點與詞彙表，每次整套套用。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

把一份筆記格式化成 Notion 頁面，遵循固定的 house style——屬性（Title／Type／Tag／Icon）、頁面結構（灰底 Summary → 編號 h2 內容 → 詞彙表）、全形標點與灰括號等規則整套套用。可格式化既有頁，或從筆記 database 的 template 建立新頁（含批次）。詳細規格見 `SKILL.md`。

　

## 設計取向

- **house style 是契約，每次整套套用**：
  - 所有規則一次到位，不挑著做
  - 同一系列筆記（例如教學系列）共用同一套結構，批次處理也保持一致
- **兩條路徑**：
  - 格式化既有頁（給 URL／ID）
  - 或從筆記 database 的 page template 建立新頁，一次可批次多頁
- **固定的屬性與結構**：
  - 屬性：Title 只放筆記本身的標題、`Type`／`Tag` 各自分流、Icon 代表主題
  - 結構：灰底 Summary 開頭 → 編號 h2 內容 → 詞彙表收尾
- **全形標點貫穿**：
  - 連英文內外都用全形（。，、（）「」…），只有 inline code 與 code block 例外
  - 灰括號只用在內文 prose；標題、callout 標題、表格儲存格的括號維持白色
- **每個內容 h2 必附 Good-to-know callout**：
  - 強制附一則補充知識（延伸、常見坑、底層原理），逼自己找一個讀者會慶幸學到的點，而非複述本段
- **詞彙表用 Markdown table 收尾**：
  - 固定三欄「名詞 ｜ 英文 ｜ 說明」，命名為「詞彙表」而非「名詞解釋」

　

## 預設與相依（可依需求抽換）

- **Notion MCP**：
  - 依賴 Notion 的 MCP 工具（fetch、create-pages、update_page）與 `notion://docs/enhanced-markdown-spec` 規格
- **個人的筆記 database**：
  - 綁定特定 database 的 schema、template 與屬性名（`Type`／`Tag`）；換 database 時依實際 schema 調整
- **house style 本身**：
  - 全形標點、詞彙表命名、Good-to-know 強制等屬個人偏好，可依需求改寫
