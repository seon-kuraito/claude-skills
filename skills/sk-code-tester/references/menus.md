# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Seams

```
plain text
question: 「預計透過以下 seam 驗證此功能：<seams>。這樣的劃分是否符合你的預期？」
[Rule, not copy] substitute <seams> with the seams you intend to test, one line each: the seam, whether it exists or is new, and the level (end-to-end, integration, unit) with the reason. Wait for the answer before writing any test. Skip the question when a spec already names the seams.
```
