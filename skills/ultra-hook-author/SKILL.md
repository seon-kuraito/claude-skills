---
name: ultra-hook-author
description: Authors, refines, and reviews Claude Code hooks — the shell commands registered in settings.json that fire on lifecycle events (PreToolUse, PostToolUse, Stop, Notification, SessionStart, and the rest). Use for ANY task touching a hook: picking an event, writing or debugging a hook script, registering one in settings, choosing exit-code vs JSON output, matchers or the `if` filter, or publishing one to the hooks repo — matched on intent, not exact wording or language. Reach for it the moment hooks come up, even briefly, rather than hand-writing a hook ad hoc. Distinct from ultra-skill-author: skills are LLM-triggered packages, hooks are deterministic event scripts.
---

# Ultra Hook Author

Handle any work on a Claude Code hook — choosing the event, writing the script, registering it in settings, testing it, licensing it, and publishing it to the hooks repo. The default flow is a lightweight three-step interview → draft → review; deterministic fixture testing is available behind a capability checkpoint when the user opts in.

## What a hook is (and is not)

A hook is **a command registered in `settings.json` that fires deterministically when a lifecycle event occurs** — not a package the model chooses to load. This is the load-bearing distinction from a skill (see [ultra-skill-author](../ultra-skill-author/SKILL.md)): a skill is selected by the model from its `description`; a hook always runs when its event fires and its matcher matches. So there is no "trigger description" to tune — correctness lives in the event choice, the matcher / `if` filter, and the script's input / output contract.

## Naming convention

All hooks in this user's `claude-hooks` repo follow the pattern **`ultra-<single-token>-<verber>`** — the same convention as skills. Example: `ultra-attention-reminder`.

Rules:

- Always prefix with `ultra-`
- Single-token domain — collapse multi-word concepts into one token (`claudemd`, not `claude-md`)
- Verb-er suffix (`author`, `creator`, `formatter`, `griller`, `polisher`, etc.)

Each hook lives one directory per hook under `hooks/<name>/`, holding a `hook.sh` entry point plus its own `README.md` and license files.

When **creating a new hook**: propose a name in this format during Step 1 and confirm with the user before drafting.

When **modifying an existing hook that doesn't match this pattern**: offer to rename as part of the change.

## Step 1: Gather requirements

Identify the task type first — new hook or modifying an existing one. Then interview the user:

1. **Trigger** — which lifecycle event fires it? Work from the goal when unsure: "notify when the turn ends" → `Stop`; "before a risky command" → `PreToolUse`; "format after an edit" → `PostToolUse`. The full event list is in `references/schemas.md`.
2. **Action** — what does it do, and is it a pure side-effect (notify, log, format) or a decision (block / allow / inject context)?
3. **Cadence** — every occurrence, or only under a condition? Events fire unconditionally (`Stop` every turn, not only when you're away), so "only when I'm away" or "only on `main`" is a gate the hook applies itself — see `references/writing-guide.md` § *Gate the side-effect*.
4. **Type** — a deterministic `command` script, or a judgment call better served by a `prompt` / `agent` hook? Most hooks are `command`.
5. **Scope & matcher** — user / project / local settings? Does the event take a matcher, or the `if` filter, to narrow it?
6. **Provenance** — original to the user, or derived from existing work? Provenance dictates licensing (see `references/publishing.md`); a copyleft or unclear source cannot be published.

Apply `references/writing-guide.md` (event selection, the five hook types, input parsing, output, security) and `references/schemas.md` (the JSON I/O contract) while drafting.

**Capability checkpoint** — use `AskUserQuestion` to let the user opt into:

- **testing** — feed fixture event JSON to the hook and assert on its exit code / stdout JSON / side effects. See `references/testing.md`. Most valuable for deterministic `command` hooks with real branching; `prompt` / `agent` hooks are non-deterministic and reviewed by hand. For a trivial one-line side-effect hook (a single `osascript` notification), skip fixtures — one manual run is enough — rather than posing the checkpoint as if testing were always warranted.

## Step 2: Draft the hook

Write `hook.sh` (or the chosen type) plus its `README.md` and license, per `references/writing-guide.md`. Keep the script idempotent, fast, and safe: read input with `jq`, use absolute paths, quote every variable, and `exit 0` for pure side-effects so the hook never blocks or loops Claude. Author the per-hook `README.md` per `references/readme-guide.md`.

## Step 3: Review with user

Present the key decisions in bullets — event, matcher / `if`, type, the output contract (exit code vs JSON), the settings registration block, and any security choices. The `hook.sh` is usually short and is the central artifact — show it in the review; just don't dump the long references into the terminal (the user reads those in their editor). Iterate on feedback.

For a deeper pass, spawn `agents/hook-reviewer.md` to adversarially check event-fit, the I/O contract, blocking semantics, and security.

**Confirm point** — if the user opted into testing, ask whether to run the fixture tests now (see `references/testing.md`).

## Registration & publishing

A hook only takes effect once it is **registered in `settings.json`** — the step skills don't have. Follow `references/registration.md` for the settings scopes, the matcher / event contract, and the `claude-hooks` repo's declare-and-compare mechanism (`settings.hooks.json` + `scripts/link-hook.sh`). Then follow `references/publishing.md` end to end: license by provenance, then the git workflow — branch → create → link → register → verify → gated commit, delegating to ultra-branch-creator / ultra-commit-creator.

## References

- `references/writing-guide.md` — choosing the event, the five hook types, input parsing, output (exit codes vs JSON), matchers / `if`, async / timeout, security, review checklist
- `references/schemas.md` — the hook JSON I/O contract: events, input fields, settings config, output / `hookSpecificOutput`, matchers, environment variables
- `references/testing.md` — deterministic fixture testing: payloads in, assert exit code / stdout / side effects (opt-in)
- `references/registration.md` — settings scopes & precedence, the repo's link-hook + declare-and-compare, matcher correctness, OS notes, `/hooks` + debugging
- `references/publishing.md` — provenance → license files + the repo git / registration workflow
- `references/readme-guide.md` — per-hook README house-style

## Related

- [ultra-skill-author](../ultra-skill-author/SKILL.md) — the sibling for **skills**, sharing the interview → draft → review shape. Hooks are not skills: deterministic event scripts, not LLM-triggered packages.
- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commit hand-offs used in `references/publishing.md`.
