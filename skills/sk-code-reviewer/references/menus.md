# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Fixed point

```
plain text
question: 「此次 review 應以哪個版本點為比較基準？請提供 commit、branch 或 tag。」
[Rule, not copy] ask only when the default of step 1 cannot be told. Accept any ref that resolves.
```

## Run mode

```
single-select · header: 「執行方式」
question: 「此次 review 將使用 <count> 個 subagent，請選擇執行方式。」
options:
  · 「平行執行」 — 「同時執行，所需時間較短；完成前不顯示花費」
  · 「循序執行」 — 「依序執行，完成一個後再開始下一個」
[Rule, not copy] substitute <count> with 4, or 3 when the Spec axis is skipped.
```
