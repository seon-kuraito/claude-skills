# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Seams

```
plain text
question: 「預計透過以下 seam 驗證此功能：<seams>。這樣的劃分是否符合你的預期？」
[Rule, not copy] substitute <seams> with the proposed seams, one line each: the seam, whether it exists or is new, and why it is the highest usable one. Wait for the answer before writing anything.
```

## Breakdown

```
plain text
question: 「phase 拆分如下：<list>。顆粒度與 blocking 關係是否合適？是否需要合併或進一步拆分？」
[Rule, not copy] substitute <list> with a numbered list, one phase per item: its title, the phases that block it or 「無」, and the end-to-end behaviour it delivers. Repeat the question after each change until the user approves.
```

## Version

```
plain text
question: 「此 spec 應納入哪個版本？依規則建議使用 <suggested>。」
[Rule, not copy] substitute <suggested> with the number the version-number rule gives for the planned content. When the rule is not available, drop the second sentence and ask the first alone. Accept any `x.y.z` the user answers.
```

## Next step

```
single-select · header: 「下一步」
question: 「spec 已定案，請選擇下一步。」
options:
  · 「現在實作」 — 「在目前的 session 載入實作流程」
  · 「稍後實作」 — 「在新的 session 執行，以保留 context window」
```
