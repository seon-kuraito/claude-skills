# Ultra Hook Author

在 Anthropic 官方文件 [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) 以及 [Hooks Reference](https://code.claude.com/docs/en/hooks) 的基礎上撰寫的 skill。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## Summary

處理 Claude Code hook 的各種工作——選事件、撰寫腳本、註冊進 settings、測試、授權、發佈到 hooks repo。預設走輕量的訪談 → 草擬 → 審閱三步；確定性的 fixture 測試則按需開啟。詳細規格見 `SKILL.md`。

　

## 設計取向（相對於 ultra-skill-author 的取捨）

- **沿用骨架，根據 hook 性質重寫**：
  - 保留「訪談 → 草擬 → 審閱」流程、capability checkpoint、references 漸進揭露、出身判定與授權產出、發佈工作流
  - 流程比照 ultra-skill-author，但為 hook 的確定性本質重新設計
- **沒有 description-tuning**：
  - hook 不靠描述觸發，因此沒有觸發描述可調
  - 對應的正確性改由 `references/registration.md` 定義，包含事件選擇、matcher／`if`、腳本的輸入／輸出契約
- **eval 改成確定性測試**：
  - skill 的測試是「跑 skill、評 LLM 產出」
  - hook 則是「以 fixture 事件 JSON 作為輸入、驗證 exit code、stdout 與 side-effect 是否符合預期」
  - 因此捨棄 benchmark／eval-viewer／盲測那批（綁定 LLM 產出評分），改用 `references/testing.md` 與 `scripts/run-hook-test.sh`
- **多一個註冊步驟**：
  - skill 放進目錄就被檢索
  - hook 則需要在 `settings.json` 登記才生效，發佈流程因此多了「在 `settings.hooks.json` 宣告 → 套用到 `settings.json`」一段
- **保留審查 agent**：
  - 以 `agents/hook-reviewer.md` 對草擬的 hook 做對抗式審查（事件契合、I／O 契約、阻擋語義、安全）
- **一致的文件規範**：
  - 每個 hook 附一份固定格式的 `README.md`（聲明／Summary／設計取向），與 `LICENSE`／`NOTICE` 一同產出
  - 語言、標題 spacer、列點與標點樣式統一，規範見 `references/readme-guide.md`

　

> 附註：本 skill 為原創，內容全部重新撰寫；不沿用 ultra-skill-author 那批源自 skill-creator 的 Apache 程式碼，因此出身保持原創、授權為 MIT。

　

## 預設與相依（可依需求抽換）

「內建發佈工作流」依賴以下兩項預設；改用其他環境時調整即可：

- **目標 repo**：
  - 發佈流程預設在 `~/Developer/claude-hooks` 操作
  - 如需指向其他 hooks repo，改這個路徑即可
  - repo 不存在時，退回「只在本機建立、跳過 git 流程」
- **委派的 skills**：
  - 開分支用 `ultra-branch-creator`、commit 用 `ultra-commit-creator`
  - 若無這兩個 skill，將對應步驟替換為其他分支／commit 慣例即可
