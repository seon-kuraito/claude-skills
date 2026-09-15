# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

Sections run in flow order: the single-repo flow first (*Template* through *Next step*), then the meta-repo interview and its own gate (*Family name* through *Family remote*, see `meta-repo.md`).

## Template

```
single-select · header: 「範本」
question: 「要用哪一種範本建立這個 repo？」
options:
  · 「空白專案 Blank」 — 「建立一般專案使用的純 git repo，包含 git init、空白 README 與標準 .gitignore。」
  · 「框架專案 Framework」 — 「建立 Next.js / Vite 等框架專案，可選擇已整理好的模板，或依需求逐步建立。」
  · 「專案協調層 Meta-Repo」 — 「建立用來協調多個 sibling repo 的 meta repo。」
[Rule, not copy] if the repo the user means already exists under ~/Developer with a .git (resuming a half-built repo), skip the menu and keep the repo as it stands. Judge by that repo's path, never by the cwd — the cwd is wherever the session happened to start.
```

## Owner directory

```
plain text
question: 「請指定這個 repo 在 ~/Developer 底下的擁有者目錄。目前有：<dirs>。」
[Rule, not copy] substitute <dirs> with the directory names directly under ~/Developer, joined with 「、」. Suggest none of them over the others.
```

## Family organization

```
plain text
question: 「請指定 <family> 家族 repo 的 GitHub organization；該 organization 需事先手動建立。」
[Rule, not copy] substitute the family name for <family>. Never offer an organization name built from the directory name.
```

## Remote

```
single-select · header: 「遠端」
question: 「要把這個 repo 推上 GitHub 的 <account>/<name> 嗎？」
options:
  · 「建立遠端並 push」 — 「在 GitHub 建立 public repo <account>/<name>，並 push。」
  · 「換一個帳號」 — 「改選 GitHub 帳號或 organization，完成後再次確認。」
  · 「先不綁遠端」 — 「停在本機，不建立遠端，也不 push。」
[Rule, not copy] substitute the resolved account and the repo name into every string — the user confirms the destination by reading it.
```

## Account

```
single-select · header: 「帳號」
question: 「請選擇遠端要建立的 GitHub 帳號或 organization。」
options:
  · 「<login>」 — 「建立 <login>/<name>。」
[Rule, not copy] one option per login — the authenticated account from `gh api user --jq .login`, then each organization from `gh api user/orgs --jq '.[].login'`. Past four candidates a menu cannot hold them: ask the **Account (free text)** question instead. An organization missing from the list (a family's organization not created yet) is typed in as free text. Never infer an account from the owner directory's name or from the shape of a login — asking costs one question, guessing sends the repo to the wrong account.
```

## Account (free text)

```
plain text
question: 「請指定遠端要建立的 GitHub 帳號或 organization。可選：<logins>。也可以輸入清單以外的 organization 名稱。」
[Rule, not copy] substitute <logins> with the same logins the **Account** menu would list, in the same order, joined with 「、」.
```

## Framework

```
single-select · header: 「框架模板」
question: 「要用哪一種框架模板？」
options:
  · 「Vite + React」 — 「以 Vite 建立 React（React Compiler、TypeScript）專案。」
  · 「其他（對話式）」 — 「Next.js 或其他框架／模板，尚未整理成固定流程，依需求逐步建立。」
[Rule, not copy] only 「Vite + React」 is templated today; every other framework takes the conversational path. As each one gets templated, add it here as another concrete option.
```

## Next step

```
single-select · header: 「下一步」
question: 「要現在進入 initialize 階段嗎？」
options:
  · 「進入 initialize 階段」 — 「接著建立選配的 LICENSE / 空白 CLAUDE.md / GitHub labels / main 分支保護。」
  · 「不進入」 — 「停在目前狀態，後續由使用者處理。」
[Rule, not copy] if no initialize skill is available, say so and stop instead of loading one.
```

## Family name

```
plain text
question: 「請輸入這個家族的名稱，使用小寫英文。」
[Rule, not copy] no placeholders. Add no example and never propose a name — not from the cwd, directory names, or repo prefixes.
```

## Owner

```
single-select · header: 「擁有者」
question: 「Meta-Repo 要放在哪裡？」
options:
  · 「<family>」 — 「放在 ~/Developer/<family>/，成員不使用家族前綴，協調層名稱為 meta；對應的 GitHub Organization 需事先手動建立。」
  · 「<user>」 — 「放在 ~/Developer/<user>/，成員使用家族前綴，協調層名稱為 <family>-meta。」
[Rule, not copy] substitute the family name for <family> and the local username (`$USER`) for <user>. Both paths follow *Family naming* in `SKILL.md`. Skip the menu when the request names the owner, or describes one that resolves as `meta-repo.md` describes.
```

## Family type

```
single-select · header: 「家族類型」
question: 「這個家族是哪一種？」
options:
  · 「同型家族 Typed」 — 「每個成員類型相同，對應同一種角色；產出的成員表採 1:1 對應。」
  · 「混合家族 Mixed」 — 「成員類型不同，因擁有者或主題而放在同一層協調；產出的說明不預設成員對稱。」
[Rule, not copy] the answer decides which block survives in the templates — keep the chosen one, delete the markers and the other block.
```

## Visibility

```
single-select · header: 「可見性」
question: 「請選擇這 <count> 個 repo 的可見性。」
options:
  · 「Public」 — 「所有人皆可檢視，初始化階段可以套用分支保護。」
  · 「Private」 — 「僅授權使用者可檢視，初始化階段的分支保護不會生效（GitHub 免費方案的 private repo 無法套用 ruleset）。」
[Rule, not copy] <count> counts the layer and every member, as in the **Family remote** menu. The answer becomes <visibility> (public / private) in that menu and in the create command.
```

## Family remote

```
single-select · header: 「遠端」
question: 「是否要將這 <count> 個 repo 推送到 GitHub 的 <account>？」
options:
  · 「建立遠端並 push」 — 「在 GitHub 的 <account> 建立 <repos>，全部設為 <visibility> 並 push。」
  · 「換一個帳號」 — 「改選 GitHub 帳號或 organization，完成後再次確認。」
  · 「先不綁遠端」 — 「保留於本機，不建立遠端，也不 push。」
[Rule, not copy] <count> counts the layer and every member; <repos> lists their names joined with 「、」, the layer first, then the members in list order; <visibility> is the answer from the **Visibility** menu. On 「換一個帳號」, present the **Account** menu; the chosen account applies to every repo, and the visibility stays as answered.
```
