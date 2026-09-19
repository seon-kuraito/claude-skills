# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

## Route

```
single-select · header: 「放哪一層」
question: 「這則記憶要放在哪一層？」
options:
  · 「全域記憶」 — 「適用於多個專案的規則，存放於 global-memory 下的 case」
  · 「專案記憶」 — 「僅適用於目前專案的資訊，存放於此專案的記憶資料夾」
```

## CLAUDE.md rule line

```
plain text
question: 「這條規則已寫入 `<case>`，目前會在『<trigger>』時查詢。若其他時機也需要套用，是否要在 CLAUDE.md 加入這條規則？」
[Rule, not copy] <case> is the case the memory was written to; <trigger> is the moment that case's lookup line names, in the user's language.
```

## Case name

```
plain text
question: 「新 case 的查詢時機是『<trigger>』，建議名稱為 `<name>`。要採用這個名稱，或指定其他名稱？」
[Rule, not copy] <trigger> is the moment the lookup line will name, in the user's language; <name> is the name proposed by the case rules in references/architecture.md.
```
