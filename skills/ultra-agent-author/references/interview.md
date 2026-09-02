# Interview

Run the Step 1 interview with the fixed copy below — the 「」 strings are the user-facing copy, shown exactly; everything outside 「」 is English direction, never shown. **Present every menu block through the AskUserQuestion tool** — `single-select` maps to one question, `header` / `question` / `options` map to the tool's fields verbatim (discipline: [ultra-skill-author's writing guide](../../ultra-skill-author/references/writing-guide.md)). Questions marked *(open)* have no enumerable option set — ask them as plain prose questions, copy verbatim, not through the tool.

Two starting modes:

- **Cold start** — nothing is known yet: run the questions as written, in order, one at a time.
- **Warm start** — prior conversation already answers some fields: don't re-ask from zero. Present the inferred answer and ask only for confirmation or correction — fine-tune the copy, keep its vocabulary. Never silently assume: every contract field still gets an explicit user sign-off.

Each answer fills contract fields and template placeholders in `../assets/agent-body.md.tmpl`; the mapping table follows each question, and the full placeholder map is at the end.

## Q1 — Classification

```
single-select · header: 「分類」
question: 「把工作交給獨立 context window，主要是為了換到什麼？」
options:
  · 「獨立判斷」 — 「避免判斷被主對話錨定；歸類為思考型（evaluator）。」
  · 「分擔工作」 — 「避免工作佔用主對話空間；歸類為執行型（worker）。」
[Rule, not copy] research-style agents are execution. If neither buyer can be named, return to the isolation gate — the agent may not deserve to exist.
```

The answer derives the defaults (trim to the contract in Step 2, never widen silently):

| classification | `tools` default | `model` default | template blocks | extras |
| --- | --- | --- | --- | --- |
| 思考型（evaluator） | read-only（Read, Grep, Glob） | `opus` | `{{#thinking}}` | adversarial mandate 段落固定進入內文 |
| 執行型（worker） | working set（加上任務需要的 Write／Edit／Bash） | `sonnet`（瑣碎機械工作可降 `haiku`） | `{{#execution}}` | — |

## Q2 — Scope / boundary *(open)*

```
question: 「這個 agent 可以處理什麼？哪些事絕對不碰？」
[Thinking only, ask as follow-up] 「它只從哪個單一視角判斷？這個視角要刻意窄到什麼程度？」
```

| answer part | fills |
| --- | --- |
| 授權處理 | `{{SCOPE_HANDLE}}` |
| 絕對不碰 | `{{SCOPE_NEVER}}` |
| 視角（思考型） | `{{LENS}}`；其錨定框架由 Q6 補上 `{{CITABLE_FRAMEWORK}}` |

## Q3 — Inputs *(open)*

```
question: 「委派時，主對話必須把哪些材料一起交給它？（沒有打包的內容，它都看不到）」
```

Fills `{{INPUTS}}`. If the user lists something the agent "can just go read", probe once: the definition runs in a fresh window — anything not in the delegation prompt or reachable by its own tools does not exist for it.

## Q4 — Deliverable

Thinking:

```
single-select · header: 「交付形狀」
question: 「輸出要採用預設三段式，還是改用自訂形狀？」
options:
  · 「預設三段式」 — 「採用固定三段：明確結論、主要風險、什麼證據會改變判斷。」
  · 「自訂形狀」 — 「改用自訂格式：自行描述固定輸出；仍需通過五欄 litmus test。」
```

Execution *(open)*:

```
question: 「它固定要交付什麼輸出？」
```

| classification | fills |
| --- | --- |
| 思考型・預設三段式 | `{{VERDICT_SHAPE}}` 只需補結論的量尺（例如：做／不做／補證據再議） |
| 思考型・自訂 | 以自訂形狀取代模板的三段式區塊 |
| 執行型 | `{{DELIVERABLE_SHAPE}}` |

**[Rule, not copy]** "depends on the task" fails the boundary rule — this question doubles as that gate: split the unit or stop the flow.

## Q5 — Verification *(open)*

```
question: 「哪些證據能讓你確認它已經做完，而且做對？」
```

Fills `{{VERIFICATION_EVIDENCE}}`. The template already fixes the first bullet (cite the delegated material; no unsupported assertions) — this answer adds the task-specific evidence on top, it does not replace that bullet.

## Q6 — Evaluation framework *(only when the deliverable has no pass/fail; open)*

```
question: 「評估維度要錨定在該領域哪個既有、可查證的框架上？」
[Rule, not copy] dimensions are written as questions anchored in that framework — never as invented personas. If the user can't name one, research candidates and present them; don't invent a framework wholesale.
```

Fills `{{DIMENSIONS_AS_QUESTIONS}}` and `{{CITABLE_FRAMEWORK}}`; skip entirely when Q5's evidence is already pass/fail (then drop the `{{#no_pass_fail}}` block).

## Q7 — Provenance

```
single-select · header: 「出處」
question: 「這個 agent 是全新原創，還是從既有作品衍生？」
options:
  · 「原創」 — 「未沿用他人內容；採 MIT 授權。」
  · 「衍生」 — 「以既有 agent 或範本為基礎；先確認上游授權，copyleft 或來源不明者不能發佈。」
```

License files follow [ultra-skill-author's publishing reference](../../ultra-skill-author/references/publishing.md) — MIT for original, upstream `LICENSE` + `NOTICE` for derived, copyleft / unclear → not publishable. Project-specific agents (the jurisdiction exception) carry no per-agent license regardless.

## Placeholder map

| placeholder | source |
| --- | --- |
| `{{AGENT_NAME}}` / `{{AGENT_TITLE}}` | naming step（`ultra-<single-token>-<verber>`，Step 1 提案、用戶確認） |
| `{{ROUTER_DESCRIPTION}}` ＋ `<example>` 區塊 | Step 2 起草，取材自 Q2–Q4（輸入形狀與交付形狀，不寫職業） |
| `{{TOOLS}}` / `{{MODEL}}` | Q1 預設 → Step 2 裁剪 |
| `{{ONE_LINE_MISSION}}` | Q2 範圍的一句話濃縮 |
| `{{SCOPE_HANDLE}}` / `{{SCOPE_NEVER}}` / `{{LENS}}` | Q2 |
| `{{INPUTS}}` | Q3 |
| `{{VERDICT_SHAPE}}` / `{{DELIVERABLE_SHAPE}}` | Q4 |
| `{{VERIFICATION_EVIDENCE}}` | Q5 |
| `{{DIMENSIONS_AS_QUESTIONS}}` / `{{CITABLE_FRAMEWORK}}` | Q6（無 pass/fail 時） |

The capability checkpoint menu that follows the interview stays in `SKILL.md`; isolation-rationale wording gathered along the way lands in the agent's `README.md`, not in the definition.
