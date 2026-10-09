# Repo Deployer

將 repo 中的網站或 app 部署至託管平台。目前支援 GitHub Pages，可部署一般靜態網站與 Vite SPA；Vercel、Cloudflare 等平台仍在規劃中。

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

## 設計背景（WHY）

- **部署設定零散且易錯**：
  - 不同平台各有對應的 workflow、權限與專案設定
  - 手動查閱文件與複製設定時，可能遺漏細節或套用不適用的版本
- **部署可作為獨立階段執行**：
  - 專案建立、初始化與部署分屬不同階段，部署 skill 可依需要加入流程
- **支援不同部署平台**：
  - GitHub Pages、Vercel、Cloudflare 等平台使用不同的部署方式
  - skill 提供統一入口，並依目標平台執行相應流程

## 功能範圍（WHAT）

- **依平台部署專案**：
  - 先確認目標平台，再執行對應的部署流程
  - 目前支援 GitHub Pages，Vercel、Cloudflare 等平台仍在規劃中
- **使用 GitHub Actions 部署 GitHub Pages**：
  - 依官方建議建立 workflow，支援「靜態網站」與「Vite SPA」兩種 build 類型
- **作為可隨時插入的部署階段**：
  - 可在 [`sk-repo-initializer`](../sk-repo-initializer) 完成後接續執行，也可於其他階段獨立使用
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 將整個 skill 目錄複製至 `~/.claude/skills/`
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-repo-deployer
  ```

  - 將 skill 連結至 `~/.claude/skills/`，供 Claude Code 探索並載入
  - 不會覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

### 設計取向

- **先選平台，再進入專屬流程**：
  - 使用單選確認部署平台，後續 branch 固定使用 `ci/deploy-<platform>`
  - 若選擇尚未實作的平台，則說明目前尚未支援並停止流程
- **GitHub Pages 以官方 Actions workflow 部署**：
  - 支援靜態網站與 Vite SPA 兩種 build 類型，對應模板放在 `assets/`
  - GitHub Pages 的完整流程與版本依據記錄在 [`references/github-pages.md`](references/github-pages.md)
- **可選擇部署來源分支**：
  - 部署前會先讀取 repo 的現有分支；選單只列出 `main`、已建立的 `develop`／`staging` 與自訂分支
  - workflow 會改成由選定分支觸發；若選的是尚未存在的自訂分支，則從 `main` 建立並推上遠端
  - 非 `main` 分支會自動加入 `github-pages` environment 的部署分支允許清單，否則會被「只允許預設分支」的預設規則擋下
  - 只在分支不存在時補建，不設定保護，也不處理合併流程（分支管理不在這個 skill 的範圍內）
  - 可使用 [`sk-repo-initializer`](../sk-repo-initializer) 建立的分支作為部署來源
- **release 流程中的 workflow 會隨版本進入 `main`**：
  - 部署分支為 `staging` 且 repo 採用 release 流程時，workflow branch 從 `main` 開出，先合併至 `staging` 以觸發首次部署，再透過 PR 合併至進行中的 release branch
  - `staging` 與 `main` 使用內容相同的 workflow 檔案。觸發條件僅包含部署分支，因此 push 至 `main` 不會觸發部署
  - 未採用 release 流程時，branch 從部署分支開出，PR 也以部署分支為 base
- **完成後提醒開 PR**：
  - workflow commit 完成後，會詢問是否建立 PR（交由 [`sk-pr-creator`](../sk-pr-creator) 處理）
- **只負責部署設定，不改原始碼**：
  - 這個 skill 不會自動修改使用者的原始碼（例如：Vite 的 `base` 設定）
  - 若部署需要額外調整，會以提醒方式告知
- **收錄驗證案例**：
  - `tests/model.json` 收錄觸發案例與行為案例，用於確認觸發正確，且關鍵行為與安全前提符合規格
  - `tests/checks/workflow-templates.py` 驗證兩份 Pages workflow 模板的權限、併發設定與 action 版本（靜態執行，不需要 LLM）

### 預設與相依

- **支援平台**：
  - 目前支援 GitHub Pages；Vercel、Cloudflare 仍在規劃中
- **workflow 模板**：
  - 模板放在 `assets/`，並依官方範本維護
  - 完整流程與版本請見 [`references/github-pages.md`](references/github-pages.md)
- **委派對象**：
  - 後續整理委派給 [`sk-branch-creator`](../sk-branch-creator)／[`sk-commit-creator`](../sk-commit-creator)／[`sk-pr-creator`](../sk-pr-creator)
  - 若未提供上述 skill，則依現有的 branch／commit／PR 慣例處理
