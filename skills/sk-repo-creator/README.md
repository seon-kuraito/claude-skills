# Repo Creator

從零建立 repo 時，先選一種模板（blank／framework／meta-repo），最後再確認要不要推上遠端。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 為什麼做這個 skill（WHY）

- **開 repo 需要重複跑一串步驟**：
  - 每次都要處理 `git init`、建立遠端、綁定 remote 等流程，手動做容易漏掉細節
- **初始 commit 容易塞太多**：
  - 遠端還沒綁好就把一批檔案寫進歷史，後面要整理會比較麻煩

　

## 這個 skill 做什麼（WHAT）

- **依模板建立對應的 repo**：
  - 一律先選模板：blank／framework／meta-repo
  - blank＝本地空白 repo
  - framework＝已整理好的框架模板，或依對話逐步建立
  - meta-repo＝新家族的協調層（scaffold＋git ceremony）與成員專案
- **本機目錄與 GitHub 帳號分開處理**：
  - repo 一律建在 `~/Developer/<owner>/<repo>`；`<owner>` 是本機目錄，預設為本機使用者名稱
  - GitHub 帳號在 push 前決定，預設使用 `gh` 目前登入的帳號，不從目錄名稱推導
  - 家族成員是否保留家族名前綴，依 `<owner>` 目錄與家族名的關係決定，規則見 [`SKILL.md`](SKILL.md)
- **meta-repo 的家族名稱與擁有者需明確確認**：
  - 家族名稱與擁有者都以使用者請求為準；請求未提供時，先詢問家族名稱，再詢問要放在哪裡
  - 判斷範圍為整個 `~/Developer`，不以目前所在專案為準
  - 擁有者候選限於家族自己的目錄，以及與本機使用者名稱同名的目錄
  - 若同一家族已存在 meta repo，停止建立流程
- **meta-repo 建立新的家族**：
  - 提供固定格式的清單供使用者複製修改，只需填寫成員名稱，順序依清單排列
  - 清單上的成員比照 blank 建立成新專案，帶標準 `.gitignore` 與空白 `README.md`
  - push 確認前先詢問可見性（public/private）；確認後 meta repo 與所有成員一起建立遠端；初始化只交接 meta repo
  - 建立時選擇先不綁定遠端的家族，後續可從 push 確認步驟繼續；已有遠端的 repo 不會列入確認清單
  - 既有專案併入家族屬於搬遷，不在本 skill 範圍
- **先完成本地流程再碰遠端**：
  - 先在本地把 repo 建好（`git init`＋commit／scaffold），中途不再額外確認
  - 結尾再確認要不要推上遠端
- **可接續既有 repo**：
  - 若目標 repo 已有 `.git`，跳過模板選擇，直接補完缺的步驟
- **建立完成後可接續初始化專案**：
  - 三種模板建好後都會詢問是否進入初始化階段
  - `LICENSE`、`.claude/CLAUDE.md`、GitHub Labels、branch 保護等選配項目交給 [`sk-project-initializer`](../sk-project-initializer) 處理
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
  scripts/link-skill.sh sk-repo-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **直接執行本地建立流程**：
  - 使用意圖明確時直接載入，一律先顯示模板選單
  - 選定後，本地步驟（`git init`、commit、scaffold）直接執行，不再逐步確認
- **兩階段模型與接續既有 repo**：
  - 專案設定分「建立」（本 skill）與「初始化」（另一個 skill）兩階段
  - 若目標已是 git repo，依目前狀態接續建立流程，只處理尚未完成的本地或遠端步驟
- **模板只影響本地建立內容**：
  - 模板只決定一開始要產生哪些本地檔案與 commit 節奏，不影響後面的遠端與初始化流程
  - 本地完成後，三種模板都進入 push 確認與初始化交接流程；meta-repo 的 push 確認涵蓋所有成員，初始化只交接 meta repo
- **只負責 repo 建立與編排**：
  - 本 skill 只處理 repo 建立與遠端綁定
  - branch 保護交由 [`sk-project-initializer`](../sk-project-initializer) 在「初始化專案」階段選配
- **遠端操作前先確認**：
  - 綁遠端／push（`gh repo create`、`git push`）前，先列出即將執行的內容並取得確認
  - 確認時顯示完整的 `<account>/<name>`，選項包含直接 push、改選帳號、暫不綁遠端
  - 若選擇綁遠端，blank 與 framework 一律建立 public repo；meta-repo 在確認前先詢問可見性（public/private）
- **初始 commit 維持精簡**：
  - 放一份完全空白的 `README.md` 與一份標準 `.gitignore`
  - `.gitignore` 視為基礎設定，在追蹤任何檔案前先放好（blank 與 meta-repo 內建；framework 通常自帶）
  - 既有檔案先留在工作區並維持 untracked，之後再依實際需求整理到後續 commit
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例，用於確認觸發正確，且關鍵行為與安全前提符合規格
  - `tests/checks/templates.py` 驗證要複製的模板都存在，且 meta-repo 模板的佔位符都有文件說明（靜態執行，不需要 LLM）

　

### 預設與相依

- **遠端託管**：
  - 預設 GitHub，透過 `gh` CLI／`gh api` 操作
  - 換其他託管平台時，改遠端建立方式即可
- **預設 branch**：
  - 一律使用 `main`（`git branch -M main`）
- **可見性**：
  - blank 與 framework 綁遠端時固定 public，不提供 private 選項
  - meta-repo 在 push 確認前詢問可見性（public/private），該設定套用到協調層與所有成員
  - GitHub 免費方案的 private repo 無法套用 ruleset，初始化階段的分支保護不會生效
- **擁有者目錄**：
  - 預設為與本機使用者名稱同名的目錄；請求只指定 Organization 時，另外詢問要放在哪個目錄
  - meta-repo 的擁有者候選限於家族自己的目錄，以及與本機使用者名稱同名的目錄
- **GitHub 帳號**：
  - 預設使用 `gh api user` 的登入帳號；Organization 名稱取自 `gh api user/orgs`
  - 家族自己的目錄可對應到名稱不同的 Organization；該 Organization 需先手動建立，push 前再詢問名稱
  - 指令一律寫成 `gh repo create <account>/<name>`
- **接續的初始化 skill**：
  - 三種模板建好後都可接續交給「初始化專案」skill（例如：[`sk-project-initializer`](../sk-project-initializer)）
  - 該 skill 尚未建立或不存在時，確認後略過即可
