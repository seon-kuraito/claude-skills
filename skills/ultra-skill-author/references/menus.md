# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Capabilities

```
multiSelect · header: 「能力選用」
question: 「要為這個 skill 開啟哪些能力？（可複選／全部不選）」
options:
  · 「evals 測試」 — 「以 subagent 執行測試案例，依照 assertion 評分，並查看 benchmark 結果。」
  · 「description 調校」 — 「以自動化的 60/40 train-test 迴圈提升觸發準確度。」
[Rule, not copy] blind-A/B is not in this menu — it surfaces only when modifying an existing skill (see *After the skill is complete* in `SKILL.md`). Detail: evals → `evals.md`; description-tuning → `description-tuning.md`.
```
