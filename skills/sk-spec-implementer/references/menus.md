# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Checkpoint

```
single-select · header: 「檢查點」
question: 「<stage>已完成，請先檢視並選擇下一步。」
options:
  · 「繼續」 — 「進入下一步」
  · 「需要修改」 — 「先說明需要修改的內容，完成後返回此步驟」
[Rule, not copy] substitute <stage> with 「測試」 after step 4, 「程式碼」 after step 5, and 「審查」 after step 6. On 「需要修改」, take the user's instructions, apply them, and present the same menu again.
```
