---
name: ultra-claudemd-composer
description: Create, refine, and trim CLAUDE.md / AGENTS.md files (the per-project agent-onboarding doc loaded into every session by Claude Code / OpenCode / Cursor / Codex / Zed). Use whenever the user wants to scaffold one from scratch, is writing / editing / restructuring an existing CLAUDE.md (or AGENTS.md), asking what belongs in one, reviewing it for length / quality, deciding whether to split content out, or comparing CLAUDE.md across projects — regardless of exact wording or language. Do NOT trigger for general markdown docs, READMEs, design docs, or unrelated docs work.
---

# Ultra CLAUDE.md Composer

CLAUDE.md (and the open-equivalent AGENTS.md) is the file an agent harness loads into every session by default. It's the single highest-leverage onboarding lever in a project — every line affects every plan, every implementation, every review the agent ever produces in that repo. That leverage cuts both ways: a bad line is a bad line in every artifact, not just one.

These principles are distilled from Kyle Mistele's ["Writing a good CLAUDE.md"](https://www.humanlayer.dev/blog/writing-a-good-claude-md) (HumanLayer, Nov 25, 2025). Read the source for the underlying reasoning, especially when a user pushes back on a recommendation here. The principles below are the actionable distillation.

## Step 0: New file or existing?

**Identify the task type before doing anything else:**

- **No CLAUDE.md exists** — invoke `/init` to generate a starting scaffold from the codebase, then apply every principle below. `/init`'s output is a *first draft*, not a finished file — treat it like a junior engineer's first PR: keep what earns its place, cut or rewrite the rest against the *Common pitfalls* checklist below before shipping.
- **CLAUDE.md exists** — proceed straight to review / refine / trim against the principles below.

`/init` breaks the blank page; this skill makes the result good. Don't ship `/init`'s output as-is, and don't skip `/init` for a brand-new file unless the project is small enough that you'd rather hand-write from a blank page.

## The frame: WHY / WHAT / HOW

A good CLAUDE.md onboards the agent to the codebase by covering three things and little else:

- **WHAT** — the stack, the project structure, where things live. Especially load-bearing in monorepos (apps vs. shared packages, what each is for).
- **WHY** — the purpose of the project and the role of each part. Helps the agent make judgment calls instead of pattern-matching blindly.
- **HOW** — how to actually work on it: package manager, how to run tests / typecheck / build, how to verify changes.

If a line doesn't clearly serve WHY, WHAT, or HOW, it probably shouldn't be there. Especially watch out for content that's really "things that annoyed the user once" disguised as universal guidance.

## Less is more — the instruction budget is real

Frontier thinking models attend to ~150–200 instructions reliably; smaller and non-thinking models, fewer. Claude Code's system prompt already burns ~50, and rules / skills / user messages take more. Every line of CLAUDE.md eats into what's left.

Worse, the harness wraps CLAUDE.md with a system reminder telling the model "this context may or may not be relevant... should not respond to this context unless highly relevant." Irrelevant content isn't merely inert — it actively trains the model to discount the whole file. **Bloat doesn't just waste tokens; it lowers the signal-to-noise of every line you actually care about.**

So treat each line as load-bearing or cuttable. "Universally applicable to most sessions in this repo" is the bar.

## Length

- Target **< 300 lines**; shorter is significantly better. HumanLayer's root is < 60 lines.
- Many good CLAUDE.md files fit on one screen.
- If you're approaching 300, the answer is almost never "tighten the prose" — it's "this content belongs elsewhere via progressive disclosure."

## Progressive disclosure

When you have more context than the file can hold, don't try to fit it. Park it in separate markdown files (`docs/`, `agent_docs/`, etc.) with self-descriptive filenames, and have CLAUDE.md describe **the convention** so the agent can find them on demand:

> "`docs/` holds area-specific notes; filenames are prefix-tagged (`cms-`, `issue-`, `style-`...). Run `ls docs/` and read the relevant file before touching that area."

**Prefer pointers to copies.** Don't inline code snippets — they go stale. Use `path/to/file:line` references so the agent reads the current source.

**Avoid filesystem-mirror lists.** Enumerating every file in `docs/` with a one-line summary creates a maintenance trap: every time a doc is added/renamed/removed, the index needs syncing, and stale entries quietly mislead. Describe the directory and the naming convention instead, and let the agent `ls`. Same logic for any list that mirrors enumerable filesystem state (scripts, routes, etc.).

The exception is true *load-bearing* pointers — files whose presence (or absence) genuinely changes how an agent should work. A short list of those is fine.

## Don't use CLAUDE.md as a style guide

Code style, formatting, and lint rules belong in linters and formatters — not in CLAUDE.md.

- Linters are deterministic, fast, and free; LLMs are slow, expensive, and inconsistent at this.
- Style rules pull a lot of mostly-irrelevant text into every session, lowering signal density.
- LLMs are in-context learners — given existing code patterns plus a couple of grep / read calls, they imitate conventions without being told.

If you have rules a linter can't enforce, consider a Stop hook that runs the linter and surfaces errors back to Claude, or a slash command that targets changed files. Don't make Claude do the linter's job.

## Common pitfalls — what to cut

The patterns below are what to cut or move, whether reviewing an existing CLAUDE.md or cleaning up a fresh `/init` scaffold — both produce the same offenders:

- **Hotfix accretion** — lines appended to "fix" past misbehavior, not actually broadly applicable. Almost always cut.
- **Style / formatting rules** — belongs in the linter.
- **Code snippets** — will go stale. Replace with `path:line` pointers.
- **Filesystem-mirror lists** — replace with directory + naming convention.
- **Task-specific instructions** — relevant on some sessions, distracting on all. Move to a slash command, a skill, or a `docs/` file the agent will load on demand.
- **WHAT-only descriptions** with no WHY or HOW. Either add the missing dimension or trim.
- **Length > ~300 lines** — split aggressively via progressive disclosure.
- **Repeated content across multiple CLAUDE.md files** in nested dirs — consolidate at the highest common ancestor; per-project files keep only deltas.

## Multi-CLAUDE.md / monorepo considerations

Claude Code (and similar harnesses) load CLAUDE.md by walking up the directory tree, so a session in a subdir sees the parent's CLAUDE.md *together with* its own. This means:

- Shared baseline → put in the parent CLAUDE.md.
- Per-project deltas → put in the project's CLAUDE.md (or absorb into the parent under a "Per-project notes" section if the deltas are small).
- Anything truly universal across all the user's projects → consider a global CLAUDE.md or a skill instead.

Don't duplicate the same content at multiple levels — duplication is the enemy of trust in the file. If you find yourself writing the same paragraph in two CLAUDE.md files, hoist it.

## When applying these principles to a real edit

1. Read the file end to end. Identify which lines serve WHY, WHAT, or HOW.
2. Mark anything that fails "universally applicable to most sessions in this repo" — those are candidates for cut, slash command, hook, skill, or `docs/`.
3. Replace inlined details with pointers wherever the source can drift.
4. Verify the file is short enough that an instruction-following budget isn't being burned on it (target < 300, aim much lower).
5. Before you add "always do X", check whether a hook, linter, or slash command can enforce it deterministically. Prefer the deterministic option.

When in doubt, read [the source article](https://www.humanlayer.dev/blog/writing-a-good-claude-md) for the full reasoning behind these calls.
