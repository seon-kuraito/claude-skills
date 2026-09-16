## 🚧 Execution gate

| 項目 | 說明 |
| --- | --- |
| 觸發條件 | 任何寫入遠端或 repo 設定的指令：`gh label delete`、`gh label create`、ruleset 的 `gh api --method POST`、`git push`。 |
| 列出內容 | 執行前列出將要執行的內容。 |
| 確認 | 取得明確確認後再執行。 |
| 分開執行 | 整批選取項目需分次處理。 |
