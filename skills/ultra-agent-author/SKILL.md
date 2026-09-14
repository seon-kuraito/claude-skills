---
name: ultra-agent-author
description: Authors, refines, and evaluates Claude Code subagent definitions — the frontmatter-plus-system-prompt .md files, discovered recursively from ~/.claude/agents/ and each project's .claude/agents/, that run in an isolated context window. Use for ANY task touching a subagent — creating, editing, naming, classifying one as evaluator or worker, choosing its tools or model, writing its trigger description, or validating it — matched on intent rather than exact wording or language. Distinct from ultra-skill-author (skills load into the current session; agents run in a separate window) and ultra-hook-author (hooks are deterministic event scripts).
---

# Ultra Agent Author

Handle any work on a Claude Code subagent — creating, refining, classifying, naming, validating, and publishing. This file is the authoritative home of the family's agent positioning, taxonomy, and design norms; the `claude-agents` repo docs point here rather than restating them.

## Jurisdiction — every subagent the user works on

Third-party agents installed directly into `~/.claude/agents/` are out of scope — leave them alone. Agents the user authors split two ways:

- **Global (the default)** — born in the `claude-agents` repo (`agents/<name>/` holding the definition, `README.md`, `LICENSE`) and per-file symlinked into `~/.claude/agents/` by `scripts/link-agent.sh`, so companion files never enter the scanned directory.
- **Project-specific (the exception)** — a genuinely single-project agent lives in that project's version control at `.claude/agents/<name>/<name>.md` with its `README.md` beside it (discovery is recursive, and a `.md` without a `name` frontmatter field is treated as documentation by design). No symlink — the file already sits where Claude Code scans; no per-agent `LICENSE` — the project's license covers it.

Both layers follow the family linking principle — link what the runtime needs, nothing more: an agent's runtime need is the definition alone, because the scanned directory must hold only contracts. (Skill-bundled agents — `skills/*/agents/*.md`, frontmatter-less and spawned ad hoc through the Agent tool, never symlinked or scanned — are their skill's bundled resources, outside this jurisdiction.) Only *Publishing* below is conditional: it applies to repo-bound agents.

## Positioning & taxonomy

No predetermined roster — a definition file exists only once a real, recurring need has appeared (the recurrence gate below). Classify every agent by what the separate context window buys:

- **Thinking (evaluator)** — buys independence from anchoring. Read-only tools, `model: opus`, an adversarial mandate ("find why this fails from your angle"); the deliverable is the judgment itself: verdict, top risks, what evidence would change it.
- **Execution (worker)** — buys context economy and parallelism. Working tools, `model: sonnet` (`haiku` for trivial mechanical work); objective, checkable output.

Classifier question: "isolation to protect the judgment from anchoring (thinking), or to keep heavy work out of the main window (execution)?" Research-style agents are execution. When several thinking agents review the same input, synthesis produces a disagreement map, never a combined verdict — convergence stays with the user.

## The boundary rule — work units, not job titles

An agent's boundary is a work unit that can be completed and verified independently — never a profession or knowledge domain. The model already knows the domain; what it cannot know is your contract.

**Litmus test**: all five contract fields (scope, inputs, deliverable, verification, evaluation dimensions) must fill with *fixed* content. A deliverable that "depends on the task" means you are holding a domain, not a unit — split it or stop.

- ❌ `frontend-agent` — unbounded deliverable; a domain masquerading as a unit
- ✅ `accessibility-reviewer`, `test-generator`, `regression-investigator` — fixed I/O, independently checkable
- ✅ An evaluation panel = **one** work unit × several deliberately narrow lenses — one definition file per lens, sharing the skeleton in `assets/agent-body.md.tmpl` materialized at authoring time (never a runtime include: each definition must stand alone). Persona is legitimate only as an attention/evaluation policy, never as a knowledge container — a lens deliverable demands collectable evidence (what exists, how to test it in the real world), never simulated feelings standing in for data.
- Naming is the first smell test: a real unit yields a natural verber (`reviewer`, `checker`, `generator`); a domain does not (`ultra-frontend-…?`).

## Naming

All agents this user authors — global or project-specific — follow `ultra-<single-token>-<verber>` (authoritative: [ultra-skill-author](../ultra-skill-author/SKILL.md)); the `ultra-` prefix is the user's signature and travels with every agent they write. Verber families signal the taxonomy class: evaluator-family verbers for thinking agents, worker-family verbers (scanner, sweeper, generator, …) for execution agents.

## Step 1: Gather requirements

Identify the task type first — new agent or modifying an existing one. Then run two gates before any contract talk:

1. **Isolation cost-benefit** — "Why should this not stay in the main conversation?" Deterministic behavior → a hook or script; rules to load into the current session → a skill. For the rest, weigh what the separate window buys (independence for thinking agents; context economy and parallelism for execution agents) against what repackaging loses — the main conversation's history, constraints, and failed attempts don't come along for free. Main agent with full context doing it better = no agent.
2. **Recurrence** — a recurring ritual earns a definition file; a one-off does not. State that judgment and hand the delegation back to the main conversation — the flow stops there.

Record the surviving isolation rationale in the agent's `README.md` — it is an authoring decision, not runtime prompt content.

Then interview the user; each answer fills one contract field:

1. **Classification** — thinking or execution, per the classifier question above → derives the tool/model defaults.
2. **Scope / boundary** — what it is authorized to handle, and what it must never touch (thinking: which single lens, how deliberately narrow).
3. **Inputs** — what the main agent must package into the delegation; the subagent sees nothing else.
4. **Deliverable** — the fixed output shape (thinking: verdict / top risks / what evidence would change the verdict). *This question doubles as the boundary-rule gate.*
5. **Verification** — what evidence convinces the user it is done and right; require evidence-shaped output (cite the original material; no unsupported assertions).
6. **Evaluation framework** — when there is no pass/fail: which dimensions, anchored in the domain's real, citable frameworks — written as questions, never as invented personas.
7. **Provenance** — original or derived → licensing, same as [ultra-skill-author](../ultra-skill-author/SKILL.md) Step 1.

Ask these with the verbatim templates in `references/interview.md`. Cold start runs them as written, one at a time; when prior context already answers a field, present the inferred answer for confirmation instead of re-asking — fine-tune the template, never skip the sign-off.

**Capability checkpoint** — present this menu verbatim through the AskUserQuestion tool. Everything in 「」 is the user-facing copy, reproduced exactly with no option marked recommended and no surrounding prose; everything outside 「」 is English direction, never shown:

```
single-select · header: 「能力選用」
question: 「要為這個 agent 開啟驗證嗎？」
options:
  · 「開啟驗證」 — 「思考型執行鑑別力／分歧／可行動測試，執行型執行客觀檢查；沿用 skills 的 eval 套件。」
  · 「不開啟」 — 「不建立驗證，僅於審閱步驟做結構確認。」
[Rule, not copy] validation pays off when the agent's judgment will feed real decisions or its output is mechanically checkable; for a trivial delegation shim, skip this checkpoint entirely rather than posing it as if validation were always warranted. Detail: Step 3.
```

## Step 2: Draft the agent

Frontmatter — `name`, `description`, `tools`, `model` are the working set (Claude Code also supports `disallowedTools`, `permissionMode`, `skills`, `memory`, `background`, `maxTurns`, `mcpServers`, `hooks`, `isolation`). `tools` and `model` are the only hard constraints; body text is soft steering.

- **description = the delegation router.** Embed 3–5 `<example>` blocks (`Context / user / assistant / <commentary>`) demonstrating *when this work unit occurs* — input shape and deliverable shape, not profession. Open with `PROACTIVELY use this agent when/after …` for event-like auto-delegation (probabilistic; a guaranteed trigger is a hook's job).
- **tools / model** — start from the taxonomy defaults, trim to the contract.

Body — a work contract, not a résumé: materialize `assets/agent-body.md.tmpl` and fill each section from the interview. The body runs in a fresh context window — it sees nothing of the main conversation, so the contract must stand alone. Draft the agent's `README.md` (purpose, isolation rationale, provenance) alongside — plus `LICENSE` for repo-bound agents.

## Step 3: Review with user

Present the key decisions as bullets — name, classification, the five contract fields, tools/model — not the full file. After structural OK, write the files.

For a deeper pass, spawn `agents/agent-reviewer.md` to adversarially check boundary fit, contract self-sufficiency, and the hard-constraint trim.

**Confirm point** — if the user opted into validation, ask whether to run it now, by category:

- **Thinking** — discrimination: planted-flaw / known-outcome fixtures kept in the agent's own `fixtures/`, asserted as "the output catches flaw X"; divergence: sibling lenses must differ substantively (a comparative pass, kin of ultra-skill-author's blind comparison); actionability ("it stung a little" is a valid pass signal).
- **Execution** — objective checks per task: fixtures, dry runs, output verification — confirm it actually relieves the main window.

Reuse ultra-skill-author's eval machinery (`evals/evals.json`, the workspace layout, the grader) with the agent as the test subject.

## Publishing

Global agents are born in the `claude-agents` repo: one folder per agent (`agents/<name>/` holding the definition, `README.md`, `LICENSE`, and any `fixtures/`), linked per-file into `~/.claude/agents/` by `scripts/link-agent.sh`. Locate that repo from this skill's own install, never from the working directory: this skill is a symlink to `<skills-repo>/skills/ultra-agent-author/`, so resolve its base directory with `realpath`, go up two levels to `<skills-repo>`, and take the sibling `<skills-repo>/../claude-agents`. Provenance-to-license rules are the same as skills — follow [ultra-skill-author's publishing reference](../ultra-skill-author/references/publishing.md) with `claude-agents` as the destination repo, including its fallback when the resolved directory is not a git checkout.
