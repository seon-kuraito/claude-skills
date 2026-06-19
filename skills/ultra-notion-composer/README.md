# Ultra Notion Composer

將筆記整理成符合固定 house style 的 Notion 頁面，統一屬性、頁面結構、全形標點與詞彙表。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **筆記排版每次不一致**：
  - 屬性、結構與標點若每次都靠當下判斷，同系列筆記很容易長得不一樣
- **手動套用 house style 重複耗時**：
  - 灰底 Summary、編號 h2、詞彙表與全形標點都有固定規則，手動重做不只耗時，也容易前後不一致
- **規則細節容易漏**：
  - 「Good-to-know」callout、「詞彙表」命名等細節，在整理大量筆記時很容易漏掉

　

## 這個 skill 做什麼（WHAT）

- **把筆記格式化成 Notion 頁面**：
  - 套用固定 house style，讓屬性、頁面結構、全形標點與詞彙表保持一致
- **支援既有頁與新頁建立**：
  - 可格式化既有頁
  - 新建時會先選目標 database，再用該 database 的 template 建立，並支援一次建立多頁
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
  scripts/link-skill.sh ultra-notion-composer
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **完整套用 house style**：
  - house style 視為筆記格式契約，每次整理都應完整套用，不挑選、不省略
  - 同一系列筆記（例如：教學系列）共用同一套結構，以維持一致格式
- **支援既有頁與新頁建立**：
  - 可格式化既有頁面（提供 URL 或 page ID）
  - 新建時先選目標 database（命名為 `XXX Base`），再用該 database 的 page template 建立，並支援一次建立多個頁面
- **統一屬性與頁面結構**：
  - 屬性規則：`Title` 只放筆記本身的標題，`Category` 負責分類（選項依 database 而異），Icon 則用來代表主題
  - 頁面結構：以灰底 Summary 開頭，接著是編號 h2 內容段落，最後以詞彙表收尾
- **使用全形標點符號**：
  - 內文中的中英文標點皆使用全形（。，、（）「」…），只有 inline code 與 code block 例外
  - 灰色括號只用於內文 prose；標題、callout 標題與表格儲存格中的括號維持白色
- **Good-to-know callout**：
  - 每個內容段落都要補上一則「Good-to-know」的補充知識
  - 內容應提供延伸觀念、常見坑或底層原理，讓讀者多得到一點有用資訊，而不是重述該段內容
- **以 Markdown table 詞彙表收尾**：
  - 頁面最後固定放置「詞彙表」
  - 詞彙表使用 Markdown table，欄位固定為「名詞｜英文｜說明」；命名使用「詞彙表」，不使用「名詞解釋」

　

### 預設與相依

- **Notion MCP**：
  - 依賴 Notion 的 MCP 工具（fetch、create-pages、update_page）與 `notion://docs/enhanced-markdown-spec` 規格
- **個人的筆記 databases**：
  - 綁定使用者以 `XXX Base` 命名的筆記 databases；各 database 的 `Category` 選項與 template 不同，新建時會依所選 database 的 schema 調整
- **house style 本身**：
  - 全形標點、詞彙表命名、Good-to-know 必填等規則屬個人偏好，可依需求改寫
