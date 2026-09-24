# CLAUDE.md Composer

將 CLAUDE.md 的寫作原則整理成可執行的建立、審閱與精修流程，協助專案保留真正能讓 agent 上手的脈絡。

　

## 聲明

- **來源**：
  - 觀念提煉自 Kyle Mistele 的 [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)（HumanLayer，2025）
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 設計背景（WHY）

- **CLAUDE.md 篇幅容易膨脹**：
  - 文件會在每個工作階段被載入，每一行都會占用 agent 的注意力
  - 內容過多時，重要的專案脈絡容易被次要資訊稀釋
- **收錄標準不明確**：
  - 專案脈絡、操作方式與風格規則常被混在一起，缺少明確的取捨標準，最後變成什麼都想放
- **`/init` 的草稿常未經整理就沿用**：
  - 過度列舉的檔案清單、內聯程式碼與過細的風格規則，常在沒有整理的情況下被保留下來

　

## 功能範圍（WHAT）

- **建立、審閱與瘦身 CLAUDE.md／AGENTS.md**：
  - 協助整理文件，讓內容更短、更準，也更容易維護
- **支援新檔起稿與既有檔審閱**：
  - 新檔可先用 `/init` 起稿，再依寫作原則修整
  - 使用者層級的 `~/.claude/CLAUDE.md` 適用於所有專案；建立時略過 `/init`，直接從空白檔起稿
  - 既有檔則會依長度、品質與用途判斷該刪、該拆或該保留，也涵蓋 monorepo 中多份 CLAUDE.md 的取捨
- **記憶區段交給 `sk-memory-composer`**：
  - 結尾含有 global-memory 查詢指示的區段，以及記憶寫入的分流規則，均由 [`sk-memory-composer`](../sk-memory-composer) 處理
  - 審閱或精簡 CLAUDE.md 時，應保留這些區段中的規則行
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-claudemd-composer
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **只提煉原則，不轉載原文**：
  - 原文為 HumanLayer 版權所有，且未附可供再散布的開源授權，因此不在公開 repo 收錄或改寫原文段落
  - 本 skill 只將可執行的寫作原則整理成自己的文字，並在 `README.md` 中以連結引用原文、標註出處
- **以專案脈絡、工作邊界與操作方式為核心**：
  - `CLAUDE.md` 應該協助 agent 快速理解：這個專案為什麼存在（WHY）、目前主要在做什麼（WHAT）、實作與協作時該怎麼做（HOW）
  - 與這三項目的無關內容，通常可考慮刪除或移至其他文件
- **控制常駐指令的篇幅**：
  - `CLAUDE.md` 會在每個工作階段被載入，因此每一行都會占用 agent 的注意力與上下文空間
  - 內容應寧短勿長，優先保留真正會影響判斷與操作的資訊；建議目標控制在 300 行以內
  - 當文件過長時，改用漸進式揭露（Progressive Disclosure）：只在 `CLAUDE.md` 保留入口與摘要，把細節移到 `docs/` 等外部文件
- **先用 `/init` 起稿，再人工精修**：
  - `/init` 適合用來產生第一版草稿，協助打破空白頁
  - 產出後仍需要人工修整，刪掉過度列舉的檔案清單、內聯程式碼、過細的風格規則，以及其他不適合長期放在 `CLAUDE.md` 裡的內容
- **與 `sk-memory-composer` 分工**：
  - 本 skill 負責整份 CLAUDE.md，`sk-memory-composer` 負責其中的記憶區段。區段格式統一定義於該 skill，本 skill 僅引用該定義
  - 記憶區段中的規則行應予保留。各項規則的適用時機未納入查詢指示的涵蓋範圍，因此不視為修補累積（Hotfix Accretion）
  - `sk-memory-composer` 需要空白的使用者層級 CLAUDE.md 時，由本 skill 建立空白檔，再交由該 skill 繼續處理
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例；觸發案例用於確認一般請求會路由至本 skill，記憶相關請求會交由 `sk-memory-composer` 處理；行為案例則用於確認產出符合規格

### 預設與相依

- **委派對象**：
  - 記憶區段交由 [`sk-memory-composer`](../sk-memory-composer) 處理。若該 skill 無法使用，應保留區段原文，並在報告中說明
