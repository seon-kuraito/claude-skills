---
name: sk-decision-griller
description: Interview the user relentlessly to resolve each decision in a plan or design, walking the decision tree one branch at a time until reaching shared understanding. Use when the user wants to stress-test a plan or design, asks to be grilled on it, or otherwise wants their decisions pressure-tested — regardless of exact wording or language.
---

# Decision Griller

Interview me relentlessly to resolve every decision in this plan or design until we reach shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

## How to ask

- **One branch at a time.** Don't bundle questions: asking several at once is bewildering, and the answers blur into each other. Pick the most upstream unresolved decision, ask, then move to the next once it's settled.
- **Use `AskUserQuestion` whenever the branch has 2–4 plausible answers.** Multi-choice converges faster than open-ended prose. Reserve plain-text questions for genuinely open inputs (names, numbers, free-form design).
- **Facts are yours to find; decisions are mine.** If a question can be answered by exploring the codebase, explore the codebase instead. The same goes for any other fact in the environment — a file, a tool's output — found with a grep, a read, or a subagent. Don't make me look up something the repo can tell us. Put only the decisions to me.
- **Answer a question inside my answer before the next branch.** When my reply to a question dialog carries a question of its own, or shows I did not follow, reply with the explanation only and end the turn; open the next dialog after I answer. A dialog covers the screen while it is open, so a question put beside it goes unanswered.

## How to recommend

I answer first; you respond after.

- If you agree, say so briefly and move on — don't pad.
- If you disagree, push back with the strongest counter-argument you can. Steel-man before steering.
- If I missed an angle, raise it as the *next* branch rather than retroactively rewriting the one we just closed.

Leading with your recommendation anchors me to it. Letting me commit first surfaces real disagreements instead of agreeable nods.

## When to stop

Stop when every branch you can think of has a settled answer, *and* I haven't surfaced new branches in the last 1–2 turns. Do not act on the plan until I confirm we have reached a shared understanding; the three steps below are that confirmation.

1. **Restate the goal in one sentence.** In your own words, say what you believe my real goal is and what problem I am trying to solve. Wait for my confirmation; a correction reopens the branch it touches.
2. **Summarize the decisions** as concise bullets — branch → decision → one-line rationale.
3. **Ask only whether to land it** — present the **Landing** menu. How it lands — the file, its name, its content — is not this skill's call:
   - Yes → load `sk-spec-planner`; it decides the files and writes them. When that skill is not installed, ask me where to write the summary and write it there.
   - No → the summary stays in the conversation, and the session is done.

## Related

- [sk-spec-planner](../sk-spec-planner/SKILL.md) — lands the settled decisions as a spec and its records; it also loads this skill when a plan is too thin to specify.
