# Interview templates

Fixed verbatim phrasings for the Step 1 interview, per the AskUserQuestion menu discipline in [ultra-skill-author's writing guide](../../ultra-skill-author/references/writing-guide.md): menus for discrete choices, fixed question copy for open fields. Everything in 「」 is user-facing copy, reproduced exactly, no option marked recommended, no surrounding prose; everything outside 「」 is English direction, never shown.

Two starting modes:

- **Cold start** — nothing is known yet: run the templates as written, in order, one at a time.
- **Warm start** — prior conversation already answers some fields: don't re-ask from zero. Present the inferred answer and ask only for confirmation or correction — fine-tune the template's wording, keep its vocabulary. Never silently assume: every contract field still gets an explicit user sign-off.

Questions marked *(open)* are asked as plain questions in prose, verbatim; they have no enumerable option set, so AskUserQuestion is not used for them.

## Q1 — Classification (menu)

```
single-select · header: 「分類」
question: 「開一個獨立 context window，主要想換到什麼？」
options:
  · 「獨立判斷」 — 「隔離用來保護判斷不被主對話錨定；歸類為思考型（evaluator），預設唯讀工具與 opus。」
  · 「分擔工作」 — 「隔離用來把繁瑣工作留在主對話之外；歸類為執行型（worker），預設工作型工具與 sonnet。」
[Rule, not copy] research-style agents are execution. If neither buyer can be named, return to the isolation gate — the agent may not deserve to exist.
```

## Q2 — Scope / boundary *(open)*

```
question: 「這個 agent 授權處理什麼？什麼絕對不碰？」
[Thinking only, ask as follow-up] 「它的單一視角是什麼？刻意窄化到什麼程度？」
```

## Q3 — Inputs *(open)*

```
question: 「委派時，主對話必須打包哪些材料給它？（打包以外的任何東西它都看不到）」
```

## Q4 — Deliverable

Thinking (menu):

```
single-select · header: 「交付形狀」
question: 「輸出要用預設的三段式，還是自訂形狀？」
options:
  · 「預設三段式」 — 「明確結論、主要風險、什麼證據會改變判斷。」
  · 「自訂形狀」 — 「另行描述固定的輸出形狀；仍需通過五欄 litmus test。」
```

Execution *(open)*:

```
question: 「固定的輸出形狀是什麼？」
[Rule, not copy] "depends on the task" fails the boundary rule — split the unit or stop; this question doubles as that gate.
```

## Q5 — Verification *(open)*

```
question: 「什麼證據能說服你它做完了、而且做對了？」
```

## Q6 — Evaluation framework *(open; only when the deliverable has no pass/fail)*

```
question: 「評估維度要錨定在該領域哪個既有、可查證的框架？」
[Rule, not copy] dimensions are written as questions anchored in that framework — never as invented personas.
```

## Q7 — Provenance (menu)

```
single-select · header: 「出處」
question: 「這個 agent 是原創，還是衍生自既有作品？」
options:
  · 「原創」 — 「未沿用他人內容；採 MIT 授權。」
  · 「衍生」 — 「延伸自既有 agent 或範本；先確認上游授權，copyleft 或來源不明者不能發佈。」
```

The capability checkpoint menu that follows the interview stays in `SKILL.md`.
