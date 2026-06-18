# Ultra Hook Author

根據 Anthropic 官方 [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) 與 [Hooks Reference](https://code.claude.com/docs/en/hooks) 撰寫的  hook 版「skill-creator」。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 `LICENSE`

　

## 概述

處理 Claude Code hook 的事件、腳本、註冊、測試、授權與發佈。預設流程是輕量的「訪談 → 草擬 → 審閱」；確定性的 fixture 測試只有需要時才開啟。詳細規格見 `SKILL.md`。

　

## 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh ultra-hook-author
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

## 設計取向

- **沿用建立流程，但依 hook 特性調整**：
  - 保留「訪談 → 草擬 → 審閱」流程、能力選用關卡（Capability Checkpoint）、references 漸進式揭露（Progressive Disclosure）、出身判定與授權產出，以及發佈工作流
  - 整體流程參照 `ultra-skill-author`，但因 hook 的觸發與執行行為更確定，需重新設計註冊、測試與審查方式
- **不做 description tuning**：
  - hook 不靠描述被 agent 觸發，因此沒有觸發描述需要調整
  - 正確性改由 `references/registration.md` 定義，包含事件選擇、`matcher`／`if` 條件，以及腳本的輸入／輸出契約
- **以確定性測試取代 eval**：
  - skill 的測試重點是「執行 skill，評估 LLM 產出是否符合預期」
  - hook 的測試重點則是「以 fixture 事件 JSON 作為輸入，驗證 exit code、stdout 與 side effect 是否符合預期」
  - 因此不沿用 benchmark、eval-viewer 與盲測等綁定 LLM 產出評分的工具，改用 `references/testing.md` 與 `scripts/run-hook-test.sh`
- **補上 hook 註冊流程**：
  - skill 放進目錄後即可被探索與載入
  - hook 則必須登記在 `settings.json` 才會生效，因此發佈流程需增加「在 `settings.hooks.json` 宣告 → 套用到 `settings.json`」這一步
- **保留對抗式審查**：
  - 以 `agents/hook-reviewer.md` 審查草擬中的 hook
  - 審查重點包含事件選擇是否契合、I／O 契約是否明確、阻擋語義是否正確，以及是否存在安全性風險等
- **統一文件與發佈規格**：
  - 每個 hook 都附一份固定格式的 `README.md`，內容包含聲明、概述與設計取向
  - 同步產出 `LICENSE` 與 `NOTICE`
  - 語言、標題 spacer、列點與標點樣式需維持一致，詳細規範見 `references/readme-guide.md`

　

> 附註：本 skill 為原創，內容全部重新撰寫；不沿用 `ultra-skill-author` 那批源自 `skill-creator` 的 Apache 程式碼，因此出身保持原創、授權為 MIT。

　

## 預設與相依

- **目標 repo**：
  - 發佈流程預設在 `~/Developer/claude-hooks` 操作
  - 如需指向其他 hooks repo，改這個路徑即可
  - repo 不存在時，退回「只在本機建立、跳過 git 流程」
- **委派的 skills**：
  - 開 branch 用 `ultra-branch-creator`、發 commit 用 `ultra-commit-creator`
  - 若無這兩個 skill，將對應步驟替換為其他 branch／commit 慣例即可
