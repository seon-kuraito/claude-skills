## 🚧 Execution gate

| 項目 | 說明 |
| --- | --- |
| 觸發條件 | 任何 `gh` 指令（`pr create`、`pr edit`、`pr merge`、`pr close` 等），以及合併後刪除遠端分支（`git push origin --delete`）。 |
| 列出內容 | 列出標題、可點開的 body 檔案連結（例如 `[/tmp/pr-<branch>.md](vscode://file/tmp/pr-<branch>.md)`，在編輯器開啟審閱，不貼全文），以及會影響行為的旗標（合併方式、`--delete-branch`、`--assignee`、`--label`）。 |
| 確認 | 取得明確確認後再執行。 |
| 分開執行 | 建立 PR 與合併 PR 需分成兩個步驟處理。 |
