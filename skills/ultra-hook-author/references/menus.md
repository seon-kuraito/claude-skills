# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Capabilities

```
single-select · header: 「能力選用」
question: 「要為這個 hook 開啟 testing 嗎？」
options:
  · 「開啟 testing」 — 「使用 fixture 事件 JSON 執行 hook，檢查 exit code、stdout JSON 與副作用。」
  · 「不開啟」 — 「不建立 fixture 測試。」
[Rule, not copy] testing is most valuable for deterministic `command` hooks with real branching; `prompt` / `agent` hooks are non-deterministic and reviewed by hand. For a trivial one-line side-effect hook (a single `osascript` notification), skip this checkpoint entirely — one manual run is enough — rather than posing it as if testing were always warranted. Detail: `testing.md`.
```
