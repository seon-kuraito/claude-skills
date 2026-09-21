# Interview

Run the Step 1 interview with the fixed copy in `menus.md` — the sections *Classification* through *Provenance*, one per question below; present each as written there (the menu contract is at the top of that file). Questions marked *(open)* are `plain text` blocks — asked as prose, copy verbatim, not through the tool.

Two starting modes:

- **Cold start** — nothing is known yet: run the questions as written, in order, one at a time.
- **Warm start** — prior conversation already answers some fields: don't re-ask from zero. Present the inferred answer and ask only for confirmation or correction — fine-tune the copy, keep its vocabulary. Never silently assume: every contract field still gets an explicit user sign-off.

Each answer fills contract fields and template placeholders in `../assets/agent-body.md.tmpl`; the mapping table follows each question, and the full placeholder map is at the end.

## Q1 — Classification

Ask the **Classification** menu.

The answer derives the defaults (trim to the contract in Step 2, never widen silently):

| classification | `tools` default | `model` default | template blocks | extras |
| --- | --- | --- | --- | --- |
| 思考型（evaluator） | read-only（Read, Grep, Glob） | `opus` | `{{#thinking}}` | adversarial mandate 段落固定進入內文 |
| 執行型（worker） | `Read, Grep, Glob` 起步，再加上交付物需要的 `Write`／`Edit`／`Bash` | `sonnet`（瑣碎機械工作可降 `haiku`） | `{{#execution}}` | — |

## Q2 — Scope / boundary *(open)*

Ask the **Scope** question — for a thinking agent, its follow-up line as well.

| answer part | fills |
| --- | --- |
| 授權處理 | `{{SCOPE_HANDLE}}` |
| 絕對不碰 | `{{SCOPE_NEVER}}` |
| 視角（思考型） | `{{LENS}}`；其錨定框架由 Q6 補上 `{{CITABLE_FRAMEWORK}}` |

## Q3 — Inputs *(open)*

Ask the **Inputs** question.

Fills `{{INPUTS}}`. If the user lists something the agent "can just go read", probe once: the definition runs in a fresh window — anything not in the delegation prompt or reachable by its own tools does not exist for it.

## Q4 — Deliverable

Thinking: ask the **Deliverable (thinking)** menu. Execution *(open)*: ask the **Deliverable (execution)** question.

| classification | fills |
| --- | --- |
| 思考型・預設三段式 | `{{VERDICT_SHAPE}}` 只需補結論的量尺（例如：做／不做／補證據再議） |
| 思考型・自訂 | 以自訂形狀取代模板的三段式區塊 |
| 執行型 | `{{DELIVERABLE_SHAPE}}` |

**[Rule, not copy]** "depends on the task" fails the boundary rule — this question doubles as that gate: split the unit or stop the flow.

## Q5 — Verification *(open)*

Ask the **Verification** question.

Fills `{{VERIFICATION_EVIDENCE}}`. The template already fixes the first bullet (cite the delegated material; no unsupported assertions) — this answer adds the task-specific evidence on top, it does not replace that bullet.

## Q6 — Evaluation framework *(only when the deliverable has no pass/fail; open)*

Ask the **Framework** question.

Fills `{{DIMENSIONS_AS_QUESTIONS}}` and `{{CITABLE_FRAMEWORK}}`; skip entirely when Q5's evidence is already pass/fail (then drop the `{{#no_pass_fail}}` block).

## Q7 — Provenance

Ask the **Provenance** menu.

License files follow [sk-skill-author's publishing reference](../../sk-skill-author/references/publishing.md) — MIT for original, upstream `LICENSE` + `NOTICE` for derived, copyleft / unclear → not publishable. Project-specific agents (the jurisdiction exception) carry no per-agent license regardless.

## Placeholder map

| placeholder | source |
| --- | --- |
| `{{AGENT_NAME}}` / `{{AGENT_TITLE}}` | naming step（`sk-<single-token>-<verber>`，Step 1 提案、用戶確認；title 是去掉 `sk-` 前綴的 Title Case） |
| `{{ROUTER_DESCRIPTION}}` ＋ `<example>` 區塊 | Step 2 起草，取材自 Q2–Q4（輸入形狀與交付形狀，不寫職業） |
| `{{TOOLS}}` / `{{MODEL}}` | Q1 預設 → Step 2 裁剪 |
| `{{ONE_LINE_MISSION}}` | Q2 範圍的一句話濃縮 |
| `{{SCOPE_HANDLE}}` / `{{SCOPE_NEVER}}` / `{{LENS}}` | Q2 |
| `{{INPUTS}}` | Q3 |
| `{{VERDICT_SHAPE}}` / `{{DELIVERABLE_SHAPE}}` | Q4 |
| `{{VERIFICATION_EVIDENCE}}` | Q5 |
| `{{DIMENSIONS_AS_QUESTIONS}}` / `{{CITABLE_FRAMEWORK}}` | Q6（無 pass/fail 時） |

Verification follows the interview on its own, with nothing to opt into — see *Verify* in `SKILL.md`. Isolation-rationale wording gathered along the way lands in the agent's `README.md`, not in the definition.
