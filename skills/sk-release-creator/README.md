# Release Creator

透過 release branch、release PR、版本 tag 與 GitHub Release 管理專案的版本發布流程。

　

## 聲明

- **來源**：
  - 原創
- **授權**：
  - MIT
  - 完整條款見同目錄 [`LICENSE`](LICENSE)

　

## 設計背景（WHY）

- **版本發布包含多個步驟**：
  - 建立 release branch、彙整 PR、建立 release PR、建立 tag 與發布 GitHub Release 涉及多個指令，手動執行時可能遺漏步驟或順序不一致
- **work branch 的 PR 需要明確的目的地**：
  - 採用 release 流程的 repo 不會將 PR 直接合併至 `main`，因此需要固定規則來決定 base branch
- **多個 repo 共用版本號時需要集中追蹤**：
  - 同一版本可能涵蓋多個 repo，需要集中記錄各 repo 的參與狀態

　

## 功能範圍（WHAT）

- **開始一個版本**：
  - 詢問版本號並提供預設值；main 流程會從 `main` 建立 `release/x.y.z`
- **發布一個版本**：
  - 建立合併至 `main` 的 release PR，merge 後建立版本 tag 與 GitHub Release，再刪除遠端 release branch
- **兩套流程**：
  - main 流程：開始版本時從 `main` 建立 release branch，work branch 的 PR 以 release branch 為 base；repo 有 `staging` 時，先合併至 `staging`
  - develop 流程：work branch 的 PR 以 `develop` 為 base，發布時再從 `develop` 建立 release branch
- **可隨時插入的階段**：
  - 專案選擇需要 release 流程時，由 [`sk-project-initializer`](../sk-project-initializer) 交接；也可在版本開始或發布時直接使用
- **完整規格集中在 SKILL.md**：
  - 詳細流程與規則見 [`SKILL.md`](SKILL.md)

　

## 使用方式（HOW）

### 安裝

- **手動複製**：
  - 把整個 skill 目錄複製進 `~/.claude/skills/` 即可
  - skill 不依賴 symlink，但 repo 更新不會自動反映
- **執行腳本**：

  ```sh
  cd claude-skills
  scripts/link-skill.sh sk-release-creator
  ```

  - 把 skill 連結進 `~/.claude/skills/`，讓 Claude Code 探索並載入
  - 不會覆寫同名的實體目錄，藉此保護直接安裝在 `~/.claude/skills/` 的第三方 skill

　

### 設計取向

- **根據 branch 判斷流程**：
  - 根據遠端是否有 `develop` 判斷 repo 採用的流程，不另行儲存設定
- **release PR 與 Release 使用連結清單**：
  - 內文以條列列出所含 PR（`- #<n>`），詳細內容保留在各 PR 中
  - release PR 不使用 [`sk-pr-creator`](../sk-pr-creator) 的三段式 body
- **release branch 不直接加入 commit**：
  - 版本號修改也透過 work branch 提交，以確保變更先經過測試環境
- **tag 與 Release 一次建立**：
  - 使用 `gh release create` 同時建立 lightweight tag 與 Release；Release 之後仍可編輯
- **協調 repo 最後發布**：
  - 多個 repo 共用版本時，先發布成員 repo，再發布協調 repo
  - 協調 repo（`meta`／`*-meta`）的 release PR 會連結各成員的 release PR，Release 則連結各成員的 Release
- **高影響操作前先確認**：
  - 執行 push、建立 PR、merge、建立 Release 或刪除遠端 branch 前，先列出指令並取得確認；各步驟需分別確認，並在檢查執行結果後再進行下一步
- **提供確定性檢查**：
  - `tests/sandbox.sh` 建立帶有本機 remote 的測試專案，`tests/verify.sh` 逐條檢查執行結果
  - `tests/model.json` 收錄觸發案例與行為案例

　

### 預設與相依

- **版本號預設規則**：
  - 依事件決定版本號：原型前使用 `0.0.z`，原型使用 `0.1.0`，首次交付使用者時使用 `1.0.0`；其間新增功能遞增 minor，僅修正問題時遞增 patch（[`references/version-numbers.md`](references/version-numbers.md)）
  - 僅作為預設建議，以使用者回答的版本號為準
- **`release` 標籤**：
  - release PR 使用 `release` 標籤，由 [`sk-project-initializer`](../sk-project-initializer) 與 type 標籤一併建立；repo 沒有該標籤時略過 `--label`
- **委派對象**：
  - work branch 的 PR（包含 base 判斷與合併至 `staging`）由 [`sk-pr-creator`](../sk-pr-creator) 處理，work branch 的命名由 [`sk-branch-creator`](../sk-branch-creator) 處理
  - 若未提供上述 skill，則依 [`references/flows.md`](references/flows.md) 列出的步驟處理
