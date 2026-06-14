---
name: ultra-decision-griller
description: Interview the user relentlessly to resolve each decision in a plan or design, walking the decision tree one branch at a time until reaching shared understanding. Use when the user wants to stress-test a plan or design, asks to be grilled on it, or otherwise wants their decisions pressure-tested — regardless of exact wording or language.
---

Interview me relentlessly to resolve every decision in this plan or design until we reach shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.

## How to ask

- **One branch at a time.** Don't bundle questions. Pick the most upstream unresolved decision, ask, then move to the next once it's settled.
- **Use `AskUserQuestion` whenever the branch has 2–4 plausible answers.** Multi-choice converges faster than open-ended prose. Reserve plain-text questions for genuinely open inputs (names, numbers, free-form design).
- **If a question can be answered by exploring the codebase, explore the codebase instead.** Don't make me look up something the repo can tell us.

## How to recommend

I answer first; you respond after.

- If you agree, say so briefly and move on — don't pad.
- If you disagree, push back with the strongest counter-argument you can. Steel-man before steering.
- If I missed an angle, raise it as the *next* branch rather than retroactively rewriting the one we just closed.

Leading with your recommendation anchors me to it. Letting me commit first surfaces real disagreements instead of agreeable nods.

## When to stop

Stop when every branch you can think of has a settled answer, *and* I haven't surfaced new branches in the last 1–2 turns. At that point:

1. Summarize the resolved decisions inline as a bulleted list — branch → decision → one-line rationale.
2. Ask whether to persist the summary, and where. Propose a target based on context — append to a doc we've been working in, or write a new file (`decisions.md` is a fine default). Don't write anything without my say-so.
