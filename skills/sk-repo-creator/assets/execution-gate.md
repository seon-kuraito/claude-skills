## 🚧 Execution gate

本機步驟（`git init`、commit、建立骨架）可以直接執行；這些步驟只在本機發生，也可以復原。gate 只設在對外動作之前，並作為遠端決策使用：

| 項目 | 說明 |
| --- | --- |
| 觸發條件 | 綁定遠端或 push：`gh repo create`、`git push`、`git remote add`。 |
| 列出內容 | 執行前列出將要執行的內容。 |
| 確認 | 等待遠端決策：確認後在列出的 `<account>/<name>` 建立 public 遠端並 push；換帳號會用新選的帳號重新顯示 gate；拒絕則只留在本機。 |
| 遠端操作 | 通過這個 gate 後，才進行遠端相關操作。 |
