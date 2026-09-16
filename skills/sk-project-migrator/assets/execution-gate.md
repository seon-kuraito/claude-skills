## 🚧 Execution gate

| 項目 | 說明 |
| --- | --- |
| 觸發條件 | 把 `apply.sh` 交給使用者執行（它會複製專案、搬移 session 資料夾，並改寫 `~/.claude.json`、歷史紀錄、symlink 與舊路徑的 VS Code 狀態），以及執行會永久刪除舊資料夾的 `finalize.sh`。 |
| 列出內容 | `apply.sh` 列出每項搬移的大小與未 commit 的變更、要搬移的 Claude Code 狀態、要清除的 VS Code 項目、留給使用者處理的硬編碼舊路徑、manifest 路徑，以及要在 Terminal 執行的完整指令；`finalize.sh` 列出它的 `--dry-run` 輸出。 |
| 確認 | 取得明確確認後，再提供關閉程式與執行步驟，或刪除舊資料夾。 |
| 分開執行 | `apply.sh` 與 `finalize.sh` 分開確認，兩者之間需先在新路徑檢查結果。 |
