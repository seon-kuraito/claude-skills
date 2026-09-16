# Verification

The verification contract for the whole extension family — `claude-skills`, `claude-hooks`, `claude-agents`. This file is the authority; `ultra-hook-author` and `ultra-agent-author` cite it rather than restating it.

Three tiers, named by what they inspect:

| Tier | Inspects | Cost | Lives in |
| --- | --- | --- | --- |
| **structure** | the shape of the files | 0 tokens | the repo's `scripts/runner/` |
| **script** | what the item's own scripts do | 0 tokens | the item's `tests/` |
| **model** | what a model does after reading the item | tokens per case | the item's `tests/model.json` |

## When it runs

Always. This is not a menu and not an opt-in: a new item and every later change both run all three tiers, as the last step before the confirmation gate — step 6 of `references/publishing.md`.

The model tier needs the item linked into `~/.claude/`, because a subagent can only pick a skill that is installed. That is why verification sits after the link step, not before it.

A finding sends the flow back to fix the item, then re-runs. Only an all-clear allows the work to move on to the commit gate and to `ultra-pr-creator`.

Never ask whether to run the structure and script tiers; they cost nothing. Always state the model tier's call count before running it.

## Runner contract

Identical interface in all three repos, so one instruction fits all of them:

```bash
scripts/run-checks.sh            # every item in the repo
scripts/run-checks.sh <item>     # one item
```

- Exit `0` passes, exit `1` fails.
- One line per rule, a summary line last.
- Rules land as code, one file per rule: `scripts/runner/<rule-id>.*`. The file name stem is the rule id; the extension is whatever suits that repo (`.sh` beside a shell hook, `.py` where frontmatter has to be parsed). A leading underscore marks a helper, never a rule.
- Each repo writes its own runner against its own architecture. No shared code, so no copy can drift.
- The runner covers the structure and script tiers only. It is a plain script; it cannot spawn a subagent, so the model tier stays a step the author skill performs.

## Shared rules

Every repo implements these five, under these exact file names. Each repo judges its own targets — `claude-skills` reads `SKILL.md` frontmatter, `claude-hooks` reads `hooks/<name>/`, and so on.

| Rule id | Intent |
| --- | --- |
| `naming` | `ultra-<single-token>-<verber>`; `author` is reserved for extension-authoring tools |
| `no-real-paths` | no hard-coded machine paths, no real account or project names — placeholders only |
| `readme-catalog` | the repo README lists this item, sorted alphabetically |
| `license` | the item carries `LICENSE`, plus `NOTICE` when it is derived |

## Routed-item rules

These two apply only where a model *chooses* the item — `claude-skills` and `claude-agents` implement them, `claude-hooks` does not, because a hook fires on an event and is never routed to:

| Rule id | Intent |
| --- | --- |
| `description` | trigger-only wording, within the length the writing guide sets |
| `model-cases` | the item has `tests/model.json` with at least one `default: true` trigger case |

Repo-specific rules simply get their own file beside them (for example `registration.sh` in `claude-hooks`).

**Drift check.** A runner compares the shared list — and, where it is a routed-item repo, the routed-item list — against its own `scripts/runner/` and fails when a rule has no file. Reaching the list means reading this file at `<repo>/../claude-skills/skills/ultra-skill-author/references/verification.md`; when that sibling is absent — someone cloned one repo alone — the runner skips the comparison and says so. The check catches a newly added rule that a repo never picked up. It does not catch a changed judgement inside a rule that already exists.

## Model tier

This tier exists only for items a model selects — skills and agents. A hook has no model tier: it fires on an event, so there is no routing decision and no reading of its text to measure. Its verification ends at the structure and script tiers.

Two case types, both driven by the single most representative task:

- **trigger** — does a real request reach this item? `expect` names the item that should win, which may be a *different* item: that is how a request that must go to a sibling gets pinned down.
- **behavior** — after reading the item, does the model do what it says? `assert` lists objectively checkable statements.

Rules that keep the cost countable:

- One case is one subagent. Never a `claude -p` probe loop.
- A subagent does load the installed skills and triggers on its own — verified 2026-09-16, one probe, 40,550 tokens.
- Judge the assertions yourself from the subagent's report. Never spawn a grader.
- Every item needs at least one `default: true` trigger case. One exception: a command-only item — `disable-model-invocation: true`, reached by the user typing its name — has no routing decision to measure, so it carries no `model.json` at all. The `description` and `model-cases` rules skip it. Behavior cases are optional; an item whose output is a conversation has nothing objective to assert.
- `default: true` cases run on every change. `default: false` cases run only when the user asks for a deeper pass, so a growing case list never raises the routine cost.
- State the count first: N default cases means N calls, roughly 40k tokens each.
- No subagents in this host? Skip the tier and say so.

### A case that touches real state

An item whose flow writes outside its own repo — it moves a project, clears saved state, calls a remote — cannot be verified by forbidding change. Its first step already writes something (a manifest, a backup folder), so a subagent told to change nothing can only describe the step it was not allowed to take, and the case measures a description.

Such an item ships `tests/sandbox.sh`: it builds a throwaway copy of the state the flow acts on and prints the environment lines that point the scripts at it. The behavior case then runs the real flow inside the sandbox, and the harness instruction changes to: work only inside this sandbox, change nothing outside it.

Two rules for the sandbox itself:

- **Build the fixture from the real shape, never from a document.** A fixture of `githubRepoPaths` that mapped a repo name to a path *string* passed straight through both scripts and tested nothing; the real file maps a repo name to an *array* of paths. Read one real record before writing the fixture.
- **Point every override at the sandbox, including the ones for sibling items.** `ultra-project-migrator` finds the cleaner under `CLAUDE_DIR`, which the sandbox redirects, so the sandbox prints `CLEANER_DIR` too. An override the sandbox forgets turns into a silent "not installed".

A prompt stored with a placeholder (`~/Developer/<user>/…`) has it substituted at run time; the stored case stays free of real paths, which is what the `no-real-paths` rule requires.

### `tests/model.json`

```json
{
  "trigger": [
    {
      "id": "core",
      "default": true,
      "prompt": "what a real user would say",
      "expect": "ultra-example-verber"
    }
  ],
  "behavior": [
    {
      "id": "plan-first",
      "default": true,
      "prompt": "the single most representative task",
      "assert": ["writes a plan file instead of deleting", "every listed path exists"]
    }
  ]
}
```

| Field | Applies to | Meaning |
| --- | --- | --- |
| `id` | both | short kebab-case label, unique within its array |
| `default` | both | `true` runs on every change; `false` runs only on request |
| `prompt` | both | the request as a real user would phrase it — never a description of the trap |
| `expect` | trigger | the item that must win the request |
| `assert` | behavior | objectively checkable statements about the run |

Keep the prompt neutral. A prompt that names the pitfall lets any model reason around it, so the case stops measuring anything.

**Running a trigger case.** Hand the `prompt` to one subagent verbatim, followed by this constraint: say what you plan to do, change no file and no state, reading is fine. Reading has to stay allowed — loading a skill *is* a read, and a blanket "touch nothing" makes the subagent describe the skill it would have loaded instead of loading it, which measures intent rather than routing. Name no skill in the prompt: the point is which one the subagent reaches for on its own. The subagent's tool-use count tells you whether a skill was actually loaded; read its report to see which one, and ask it once if that stays unclear.

### `tests/` layout

```
<item>/tests/
├── fixtures/      inputs for the script tier      (optional)
├── checks/        deterministic check scripts     (optional)
├── run.sh         script-tier entry, called by scripts/run-checks.sh
└── model.json     model-tier cases
```

An item with no executable output carries `model.json` alone.
