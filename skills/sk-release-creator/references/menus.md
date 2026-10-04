# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Version number

```
plain text
question: 「請輸入這個版本的版本號。依預設規則建議使用 <suggested>。」
[Rule, not copy] substitute <suggested> with the number `version-numbers.md` gives for the planned content. Accept any `x.y.z` the user answers, whether or not it matches the suggestion.
```
