# Ultra Project Publisher

協助把專案發布到託管平台。目前支援 GitHub Pages，包含一般靜態網站與 Vite SPA；Vercel、Cloudflare 等平台仍在規劃中。

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

## 為什麼做這個 skill（WHY）

- **部署設定零散且易錯**：
  - 不同平台都有各自的 workflow、權限與專案設定
  - 每次手動查文件、複製設定，很容易漏掉細節或套用錯版本
- **部署是獨立於其他專案階段的關注點**：
  - 專案建立、初始化與部署是不同階段；既然前兩者已有對應 skill，部署也應該有一個可以單獨插入流程的入口
- **同一個專案可能部署到不同平台**：
  - GitHub Pages、Vercel、Cloudflare 等平台的做法不同，但使用者不應該每次都重新判斷流程
  - skill 提供統一入口，再依目標平台分流

## 這個 skill 做什麼（WHAT）

- **依平台部署專案**：
  - 開始時會先確認目標平台，再進入對應的發布流程
  - 目前支援 GitHub Pages，Vercel、Cloudflare 等平台仍在規劃中
- **使用 GitHub Actions 發布 GitHub Pages**：
  - 依官方建議建立 workflow，支援「靜態網站」與「Vite SPA」兩種 build 類型
- **作為可隨時插入的發布階段**：
  - 對應 [`ultra-project-initializer`](../ultra-project-initializer) 之後的發布流程，但不限定只能在初始化後使用
  - 只要專案需要部署，隨時都可以執行
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
  scripts/link-skill.sh ultra-project-publisher
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不會覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

### 設計取向

- **先選平台，再進入專屬流程**：
  - 開始時會用單選確認部署平台，後續 branch 固定使用 `ci/deploy-<platform>`
  - 如果使用者選到尚未實作的平台，會明確告知目前不支援並停止流程
- **GitHub Pages 以官方 Actions workflow 部署**：
  - 支援靜態網站與 Vite SPA 兩種 build 類型，對應模板放在 `assets/`
  - GitHub Pages 的完整流程與版本依據記錄在 [`references/github-pages.md`](references/github-pages.md)
- **完成後提醒開 PR**：
  - workflow commit 完成後，會詢問是否要開 PR（交給 [`ultra-pr-creator`](../ultra-pr-creator) 處理）
- **只負責部署設定，不改原始碼**：
  - 這個 skill 不會自動修改使用者的原始碼（例如：Vite 的 `base` 設定）
  - 若部署需要額外調整，會以提醒方式告知

### 預設與相依

- **支援平台**：
  - 目前支援 GitHub Pages；Vercel、Cloudflare 仍在規劃中
- **workflow 模板**：
  - 模板放在 `assets/`，並依官方範本維護
  - 完整流程與版本請見 [`references/github-pages.md`](references/github-pages.md)
- **委派的 skills**：
  - 後續整理委派給 [`ultra-branch-creator`](../ultra-branch-creator)／[`ultra-commit-creator`](../ultra-commit-creator)／[`ultra-pr-creator`](../ultra-pr-creator)
  - 若無這些 skill，替換為其他 branch／commit／PR 慣例即可
