# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.

The interview sections (*Classification* through *Provenance*) run in the order and modes `interview.md` describes; each answer's mapping to contract fields lives there.

## Classification

```
single-select · header: 「分類」
question: 「把工作交給獨立 context window，主要是為了換到什麼？」
options:
  · 「獨立判斷」 — 「避免判斷被主對話錨定；歸類為思考型（evaluator）。」
  · 「分擔工作」 — 「避免工作佔用主對話空間；歸類為執行型（worker）。」
[Rule, not copy] research-style agents are execution. If neither buyer can be named, return to the isolation gate — the agent may not deserve to exist.
```

## Scope

```
plain text
question: 「這個 agent 可以處理什麼？哪些事絕對不碰？」
[Thinking only, ask as follow-up] 「它只從哪個單一視角判斷？這個視角要刻意窄到什麼程度？」
```

## Inputs

```
plain text
question: 「委派時，主對話必須把哪些材料一起交給它？（沒有打包的內容，它都看不到）」
```

## Deliverable (thinking)

```
single-select · header: 「交付形狀」
question: 「輸出要採用預設三段式，還是改用自訂形狀？」
options:
  · 「預設三段式」 — 「採用固定三段：明確結論、主要風險、什麼證據會改變判斷。」
  · 「自訂形狀」 — 「改用自訂格式：自行描述固定輸出；仍需通過五欄 litmus test。」
```

## Deliverable (execution)

```
plain text
question: 「它固定要交付什麼輸出？」
```

## Verification

```
plain text
question: 「哪些證據能讓你確認它已經做完，而且做對？」
```

## Framework

```
plain text
question: 「評估維度要錨定在該領域哪個既有、可查證的框架上？」
[Rule, not copy] dimensions are written as questions anchored in that framework — never as invented personas. If the user can't name one, research candidates and present them; don't invent a framework wholesale.
```

## Provenance

```
single-select · header: 「出處」
question: 「這個 agent 是全新原創，還是從既有作品衍生？」
options:
  · 「原創」 — 「未沿用他人內容；採 MIT 授權。」
  · 「衍生」 — 「以既有 agent 或範本為基礎；先確認上游授權，copyleft 或來源不明者不能發佈。」
```

