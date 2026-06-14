# Evals

Optional rigorous evaluation loop for a skill. Activate when the user opted into evals at the capability checkpoint, or when the user explicitly asks to "test the skill", "run evals", "benchmark this", "is this skill any good", etc.

The mental model: spawn the skill on test prompts, capture outputs and timing, grade against assertions, aggregate into a benchmark, surface results to the user, read their feedback, iterate. The same loop works for new skills (compared against `without_skill`) and for modified skills (compared against a snapshot of the previous version).

JSON schemas for every artifact below are in `references/schemas.md` — consult that file when generating any of these files manually.

## 1. Test cases

### Drafting prompts

After the skill draft exists, write 2–3 realistic test prompts — the kind of thing a real user would actually say. Share them with the user before running anything: *"Here are a few test cases I'd like to try. Do these look right, or do you want to add more?"*

Save them to `evals/evals.json` inside the skill directory. **Don't write assertions yet** — just the prompts. Assertions get drafted in the next step while the test runs are in progress (free time).

### Schema

See `references/schemas.md` § *evals.json* for the full structure.

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

### When to write assertions vs. not

Skills with **objectively verifiable** outputs benefit from assertions: file transforms, data extraction, code generation, fixed workflow steps. Skills with **subjective** outputs (writing style, design quality, art) usually don't — human judgment in the review step is the right tool.

## 2. Workspace and execution

### Workspace layout

Put runs in `<skill-name>-workspace/` as a sibling of the skill directory. Within it, organize by iteration; within each iteration, each test case gets its own directory:

```
<skill>-workspace/
└── iteration-1/
    ├── eval-<descriptive-name>/
    │   ├── with_skill/outputs/
    │   ├── without_skill/outputs/   ← new-skill baseline
    │   │   (or old_skill/outputs/   ← modify-skill baseline)
    │   ├── eval_metadata.json
    │   ├── timing.json
    │   └── grading.json
    └── benchmark.json
```

Don't pre-create the whole tree — make directories as you go. Give each eval a descriptive name based on what it tests, not just `eval-0`. Reuse the name for the directory.

### Spawn with-skill + baseline in the same turn

For each test case, spawn **two subagents in the same turn** — one with the skill, one without. Don't spawn the with-skill runs first and come back for baselines later; launch everything at once so they finish around the same time.

**With-skill subagent prompt:**

```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<name>/with_skill/outputs/
- Outputs to save: <what the user cares about — e.g., "the .docx file", "the final CSV">
```

**Baseline subagent** depends on the task type:

- **New skill** — same prompt, no skill path. Save to `without_skill/outputs/`. The baseline is "what would Claude do without this skill at all."
- **Modifying an existing skill** — snapshot the previous version *before editing* (`cp -r <skill-path> <workspace>/skill-snapshot/`), then point the baseline subagent at the snapshot. Save to `old_skill/outputs/`.

### eval_metadata.json (per eval)

Write `eval_metadata.json` for each test case. Assertions can be empty for now — they get filled in step 3.

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

If this iteration introduces new or modified eval prompts, write fresh metadata files — don't assume they carry over from previous iterations.

### timing.json — capture immediately

When a subagent task completes, the notification includes `total_tokens` and `duration_ms`. **Save these immediately** to `timing.json` in the run directory:

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

This is the only opportunity. The values aren't persisted anywhere else — process each notification as it arrives rather than batching.

## 3. Drafting assertions while runs are in progress

Don't waste the wait. While the subagent runs are executing, draft assertions for each test case and explain them to the user. (If `evals/evals.json` already has assertions, review them and explain what each one checks.)

Good assertions are:

- **Objectively verifiable** — pass/fail can be decided without subjective judgment.
- **Descriptively named** — they should read clearly in the benchmark viewer so a glance tells you what each one is checking.
- **Programmatic where possible** — assertions that can be checked by a script (file exists, JSON has key X, output contains Y) should be checked by script, not eyeballed. Scripts are faster, more reliable, and reusable across iterations.

Subjective skills (writing style, design quality) are evaluated qualitatively in the human review step — don't force assertions onto judgment calls.

Update `eval_metadata.json` and `evals/evals.json` with assertions once drafted. Tell the user what they'll see in the viewer (qualitative outputs + quantitative benchmark).

## 4. Grading

Spawn a grader subagent (or grade inline). The grader reads `agents/grader.md` for its contract, evaluates each assertion against the outputs, and writes `grading.json` in each run directory.

**Field convention** — `grading.json` must use exactly:

- `text` — the assertion text
- `passed` — boolean
- `evidence` — short explanation referencing the output / transcript

The viewer depends on these exact field names. Don't substitute `name` / `met` / `details` or other variants.

For programmatic assertions, write a Python script that checks them and emit the same `grading.json` shape — don't have the grader subagent eyeball things a script can verify.

Full schema: `references/schemas.md` § *grading.json*.

## 5. Aggregation, analyst pass, and viewer

### aggregate_benchmark

Run the aggregation script:

```bash
python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
```

This produces `benchmark.json` and `benchmark.md` in the iteration directory. The benchmark contains pass-rate, time, and tokens for each configuration with mean ± stddev plus a delta column. **Put each `with_skill` row before its baseline counterpart** so the diff reads top-down.

If you generate `benchmark.json` manually, follow `references/schemas.md` § *benchmark.json* exactly — the viewer reads field names like `configuration`, `pass_rate`, `run_summary` literally and will show empty / zero values if you use synonyms.

### Analyst pass

Read the benchmark and surface what aggregate stats might hide. See `agents/analyzer.md` § *Analyzing Benchmark Results* for the checklist:

- **Non-discriminating assertions** — pass 100% in both configurations; not actually testing skill value.
- **High-variance evals** — large stddev relative to mean; possibly flaky or model-dependent.
- **Time / token trade-offs** — the skill might add latency or token cost; flag that explicitly so the user can weigh it against pass-rate gains.

### Launch the viewer

```bash
nohup python <skill-path>/eval-viewer/generate_review.py \
  <workspace>/iteration-N \
  --skill-name "my-skill" \
  --benchmark <workspace>/iteration-N/benchmark.json \
  > /dev/null 2>&1 &
VIEWER_PID=$!
```

For iteration 2+, also pass `--previous-workspace <workspace>/iteration-<N-1>` so the viewer can show last iteration's outputs and feedback alongside the new ones.

For Cowork / headless environments (no display), use `--static <output_path>` to write a standalone HTML file instead of starting a server. See `references/environments.md` for environment-specific viewer handling.

Use `generate_review.py` — don't write custom HTML.

### What the user sees

The viewer has two tabs:

- **Outputs** — one test case at a time. Shows the prompt, the files the skill produced (rendered inline where possible), the previous iteration's output (if any), formal grades (collapsed), and a feedback textbox that auto-saves as the user types. Navigation via prev/next or arrow keys.
- **Benchmark** — pass rates, timing, token usage per configuration; per-eval breakdowns; analyst observations.

Tell the user roughly: *"I've opened the results in your browser. There are two tabs — 'Outputs' lets you click through each test case and leave feedback, 'Benchmark' shows the quantitative comparison. When you're done, come back here."*

## 6. Read feedback and iterate

When the user says they're done, read `feedback.json`:

```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "the chart is missing axis labels", "timestamp": "..."},
    {"run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..."},
    {"run_id": "eval-2-with_skill", "feedback": "perfect, love this", "timestamp": "..."}
  ],
  "status": "complete"
}
```

**Empty feedback means the user thought it was fine.** Focus improvements on test cases with specific complaints.

Kill the viewer when you're done with this iteration:

```bash
kill $VIEWER_PID 2>/dev/null
```

### How to think about improvements

1. **Generalize from the feedback.** Skills get used across many prompts, but you and the user are iterating on a handful. Don't make fiddly overfit changes that only fix the specific examples — try metaphors, different patterns, different framings. It's cheap to try.
2. **Keep the prompt lean.** Read the *transcripts*, not just the final outputs. If the skill is making the model waste effort on unproductive steps, cut the parts of the skill that produced that detour and see what happens.
3. **Explain the why.** Today's models have strong theory of mind. Even when feedback is terse or frustrated, try to understand *what* the user actually wants and *why* — then transmit that understanding into the instructions. ALL CAPS RULES are a yellow flag; reframe them as reasoning when you can.
4. **Look for repeated work across test cases.** If all three runs independently wrote a similar `create_docx.py` or `build_chart.py`, that's a strong signal: write it once, put it in `scripts/`, and have the skill point at it. Saves every future invocation from reinventing the wheel.

### The iteration loop

1. Apply improvements to the skill.
2. Re-run all test cases into a new `iteration-<N+1>/` directory, including baseline runs. (For new skills the baseline is always `without_skill`. For modify-skill flows, decide whether the baseline is the original version or the previous iteration — usually the original, occasionally the previous if you're doing fine-grained tuning.)
3. Launch the viewer with `--previous-workspace` pointing at the previous iteration.
4. Wait for user review.
5. Read new feedback. Improve again.

### Termination

Stop when one of these is true:

- The user says they're happy.
- Feedback is all empty.
- You're not making meaningful progress (changes aren't moving the metrics or the qualitative reads).
