# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Platform

```
single-select · header: 「部署平台」
question: 「要部署到哪一個平台？」
options:
  · 「GitHub Pages」 — 「已實作，可部署為 GitHub Pages 網站。」
  · 「Vercel」 — 「規劃中，尚未實作。」
  · 「Cloudflare Pages」 — 「規劃中，尚未實作。」
[Rule, not copy] for a planned platform, say it is not yet supported and stop. Each platform has its own flow and its own branch named `ci/deploy-<platform>` (e.g. `ci/deploy-github-pages`, `ci/deploy-vercel`).
```

## Build type

```
single-select · header: 「建置方式」
question: 「要用哪一種方式建置並部署？」
options:
  · 「Static（免建置）」 — 「直接部署靜態檔案，不經過建置步驟。」
  · 「Vite SPA」 — 「以 npm ci 與 npm run build 建置後再部署。」
[Rule, not copy] detect a hint from `package.json` first — a `vite` dependency or a `vite.config.*` → Vite, otherwise Static.
```

## Deploy branch

```
single-select · header: 「選擇部署分支」
question: 「要使用哪一條部署分支？」
options:
  · 「main」 — 「推送到 main 時即進行部署，維持最簡單的原本行為。」
  · 「develop」 — 「整合分支（integration branch）。」
  · 「preparing」 — 「測試環境分支（testing environment branch）。」
  · 「custom」 — 「使用其他任一分支，若不存在則從 main 開出並推送。」
[Rule, not copy] `main` is always offered. Include `develop` / `preparing` each only if it already exists (created by sk-project-initializer's deploy-branch option) — typically just one is present, presented by what it is, not by a flow label. For `custom`, ask for the name and, if it does not exist, create it from `main` and push it (proceed conversationally, the same shape as sk-repo-creator's `framework` option).
```
