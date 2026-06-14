# Description Tuning

Optional automated optimization of the `description` field's trigger accuracy. Activate when the user opted into description-tuning at the capability checkpoint, or asks to "optimize the description", "improve trigger accuracy", "make sure this skill fires when it should", etc.

The mental model: build a small eval set of realistic queries (some that *should* trigger the skill, some that *shouldn't*); have an automated loop propose description rewrites; evaluate each candidate against the eval set across multiple runs; pick the candidate that wins on a held-out test split.

## How skill triggering actually works

Background that shapes everything below: skills appear in the agent's `available_skills` list with name + description, and the agent decides whether to consult one based on that description. Two important facts:

- **Simple, one-step queries don't trigger skills.** "Read this PDF" may not trigger a PDF skill even with a perfect description, because the agent can handle it directly with basic tools.
- **Substantive, multi-step, specialized queries reliably trigger** when the description matches.

This means **eval queries must be substantive enough that the agent would actually benefit from consulting the skill.** Simple queries like `"read file X"` are poor test cases — they won't trigger skills regardless of description quality, so they don't measure anything.

## 1. Generate trigger eval queries

Create ~20 queries — a mix of should-trigger and should-not-trigger.

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

### Query realism

Queries must be the kind of thing a real Claude Code or Claude.ai user would actually type. Include:

- **File paths** — "the xlsx is in my downloads, called something like 'Q4 sales final FINAL v2.xlsx'"
- **Personal context** — what the user's job is, what the situation is
- **Specific values** — column names, table names, company names, URLs
- **A bit of backstory** — why they're doing this
- **Casual register variations** — lowercase, abbreviations, typos, conversational phrasing
- **Length variation** — some short, some longer

**Bad:** `"Format this data"`, `"Extract text from PDF"`, `"Create a chart"` — too clean, too abstract, none of these would trigger a skill in practice anyway.

**Good:** *"ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think"*

### Coverage strategy

**Should-trigger queries (8–10):** different phrasings of the same intent — formal, casual, doesn't mention the skill name explicitly, doesn't mention the file type explicitly but clearly needs it. Throw in some uncommon use cases. Include cases where this skill competes with another skill but should win.

**Should-not-trigger queries (8–10):** the most valuable ones are **near-misses** — queries that share keywords or concepts with the skill but actually need something different. Adjacent domains, ambiguous phrasing where a naive keyword match would trigger but shouldn't, contexts where another tool is more appropriate.

> **Avoid:** obviously irrelevant queries. *"Write a fibonacci function"* as a negative test for a PDF skill is too easy — it doesn't measure anything because no description would ever match it.

## 2. Review with user before optimizing

Bad eval queries lead to bad descriptions. Get user sign-off on the set before running the optimization loop.

Use the HTML template in `assets/eval_review.html`:

1. Read the template.
2. Replace placeholders:
   - `__EVAL_DATA_PLACEHOLDER__` → the JSON array of eval items (no quotes — it's a JS variable assignment).
   - `__SKILL_NAME_PLACEHOLDER__` → the skill's name.
   - `__SKILL_DESCRIPTION_PLACEHOLDER__` → the skill's current description.
3. Write to `/tmp/eval_review_<skill-name>.html` and `open` it.
4. The user can edit queries, toggle `should_trigger`, add or remove entries, then click *Export Eval Set*.
5. The file downloads to `~/Downloads/eval_set.json`. Check Downloads for the most recent (`eval_set (1).json`, etc., if there are multiples).

Save the approved eval set to the workspace.

## 3. Run the optimization loop

Tell the user: *"This will take some time — I'll run the optimization loop in the background and check on it periodically."*

Background:

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

Use the model ID from your system prompt (the same model running this session) so the triggering test matches what the user actually experiences.

While it runs, periodically tail the output to give the user updates on which iteration it's on and the scores.

### What the loop does

The script handles the full optimization flow:

1. Splits the eval set 60% train / 40% held-out test.
2. Evaluates the current description by running each query 3 times (averaged for a reliable trigger rate).
3. Calls Claude to propose improved descriptions based on what failed.
4. Re-evaluates each candidate on both train and test.
5. Iterates up to 5 times.
6. Returns `best_description` — selected by **test** score (not train) to avoid overfitting.

When done, it opens an HTML report showing per-iteration results and emits JSON containing `best_description`.

## 4. Apply the result

Take `best_description` from the JSON output and update the skill's `SKILL.md` frontmatter. Show the user the before / after along with the train and test scores so they can see the improvement.

If the new score is worse on test (rare but possible), keep the original description and report that — overfitting to the train split sometimes wins on train but loses on test.
