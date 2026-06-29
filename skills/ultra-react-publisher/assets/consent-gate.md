
　

---

　

## 🛑 Consent gate

這個 skill 會一口氣完成一連串對外且難以復原的動作，過程中不會再停下來詢問：

- 在你的 GitHub 帳號建立一個 public repo
- 設定 `main` 分支保護 ruleset
- 開 PR 並自動合併（self-merge）
- 啟用 GitHub Pages，部署一個公開可見的網站

執行前需要先具備以下條件；這些狀態 skill 無法自行確認，也無法代你授權：

- 已在 bypass-permissions session 啟動：`claude --dangerously-skip-permissions`
- 系統需要有 `gh`（且已登入）、`git`、`node`
- 已安裝 6 個相依 skill：
  - `ultra-repo-creator`
  - `ultra-project-initializer`
  - `ultra-project-deployer`
  - `ultra-branch-creator`
  - `ultra-commit-creator`
  - `ultra-pr-creator`

過程中只要出現任何授權提示，就代表目前不是 bypass 模式；skill 會立刻停止，不會繼續跑到一半。

確認以上都已就緒後，要現在開始嗎？回覆 `yes` 開始，其他任何回覆都會停下。

　

---

　
