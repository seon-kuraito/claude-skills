# Blind Comparison

Optional rigorous A/B comparison between two versions of a skill — when assertion-based evals don't fully capture quality differences and the user wants an independent answer to *"is the new version actually better?"*.

This surfaces only on the **modifying-existing-skill** pathway. For new skills there's no "old version" to compare against — assertion-based evals against `without_skill` (in `references/evals.md`) is the right pattern.

## When to offer this

In the `SKILL.md` post-completion confirm step, if `task type = modifying existing`, offer blind A/B proactively. Typical user phrasings that also surface it directly:

- *"Is the new version actually better than the old one?"*
- *"Did my rewrite improve things?"*
- *"Compare the old and new skill on these prompts"*

It's complementary to assertion-based evals — assertions check *did the output have property X*, blind A/B captures *which output is qualitatively better and why* (style, depth, completeness, judgment), which is what assertions struggle with.

## Mechanics

The basic idea: give two outputs to an independent agent **without telling it which is which**, let it judge quality, then analyze why the winner won.

1. **Run both versions on the same eval prompts** (the same eval set used in `references/evals.md`).
2. **Spawn the comparator subagent** — see `agents/comparator.md` for its full contract. It receives two outputs labeled only "A" and "B" (no skill identity, no version info), evaluates them on a content/structure rubric, and returns a winner with reasoning. Schema: `references/schemas.md` § *comparison.json*.
3. **Aggregate verdicts across the eval set.** A single win could be noise; consistent wins across multiple prompts indicate systematic improvement.

## Analysis — explain *why* the winner won

After the comparator picks winners, spawn the analyzer subagent (`agents/analyzer.md`). It reads the comparator results plus the underlying outputs and produces a structured explanation:

- **Winner strengths** — concrete patterns that helped (clear instructions, validation script bundled, explicit step ordering).
- **Loser weaknesses** — concrete patterns that hurt (vague language, missing scripts, ambiguous decision points).
- **Instruction-following scores** — did the executor actually use the skill, or improvise around it?
- **Improvement suggestions** — prioritized changes that would close the gap (or, if the new version *lost*, what regressions to revert).
- **Transcript insights** — execution patterns observable in the transcripts (e.g., *winner read skill → followed 5 steps → used validation script*; *loser read skill → unclear → tried 3 different approaches*).

Schema: `references/schemas.md` § *analysis.json*.

## Cross-iteration tracking

If the user is iterating across multiple versions (v0 → v1 → v2 → …), keep `history.json` in the workspace root tracking each version's `expectation_pass_rate` and the comparator verdict (`won` / `lost` / `tie`) against its parent. The current best is whichever version is `is_current_best: true`.

Schema: `references/schemas.md` § *history.json*.

## What to report to the user

After the comparison run, surface:

- **Verdict** — version X won on N of M prompts (with verdict per prompt).
- **Why** — the analyzer's top strengths and weaknesses.
- **Suggestions** — the prioritized improvement list.

If the new version lost, **say so plainly** and suggest reverting the regressions or scoping the changes more narrowly. The point of running this is to know.
