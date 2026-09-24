---
name: sk-skill-author
description: Authors, refines, and evaluates Claude agent skills (the `.claude/skills/*/SKILL.md` packages that extend agent capabilities). Use for ANY task touching a skill — creating, editing, refining, restructuring, naming, evaluating, licensing, or reasoning about one — matched on intent rather than exact wording or language. Reach for it whenever a request pairs an action with a skill, even briefly; prefer consulting it over handling skill work ad hoc.
---

# Skill Author

Handle any work on a Claude skill — creating, refining, restructuring, naming, licensing, and verifying. The flow is a lightweight interview / draft / review, closed by a verification pass that always runs: structure, script, and model tiers, per `references/verification.md`.

## Jurisdiction — every skill the user works on

Third-party skills installed directly into `~/.claude/skills/` are out of scope — leave them alone. Skills the user authors split two ways:

- **Global (the default)** — born in the `claude-skills` repo (`skills/<name>/` holding `SKILL.md`, `README.md`, `LICENSE`, and any bundled resources) and symlinked whole into `~/.claude/skills/` by `scripts/link-skill.sh`.
- **Project-specific (the exception)** — a genuinely single-project skill lives in that project's version control at `.claude/skills/<name>/`, same package shape with its `README.md` beside `SKILL.md`. No symlink — Claude Code scans the project directory directly; no per-skill `LICENSE` — the project's license covers it.

The family linking principle — link what the runtime needs, nothing more — is why the directory links whole: a skill's runtime need *is* the whole package (`SKILL.md` plus the resources it loads on demand). Only *Publishing & licensing* below is conditional: it applies to repo-bound skills.

## Naming convention

All skills this user authors — global or project-specific — follow the pattern **`sk-<single-token>-<verber>`**. Example: `sk-decision-griller`.

Rules:

- Always prefix with `sk-`
- Single-token domain — collapse multi-word concepts into one token (`claudemd`, not `claude-md`)
- Verb-er suffix matching the skill's action (`creator`, `composer`, `griller`, `publisher`, etc.). **`author` is reserved** for skills / hooks that author Claude Code *extensions* — `sk-skill-author`, `sk-hook-author`, and `sk-agent-author`; doc / content skills use `composer` / `formatter` / `curator` instead.

When **creating a new skill**: propose a name in this format during Step 1 and confirm with the user before drafting.

When **modifying an existing skill that doesn't match this pattern**: offer to rename as part of the change.

## Step 1: Gather requirements

**First, confirm a skill is the right extension.** Three shapes carry work, and only a skill is picked by the model's own judgement:

- **Skill** — a way of working, loaded when the model judges the request needs it.
- **Hook** — a rule the harness enforces on an event, whether the model agrees or not. Hand it to [sk-hook-author](../sk-hook-author/SKILL.md).
- **Agent** — a separate context with its own tools, for work that needs isolation or an independent read. Hand it to [sk-agent-author](../sk-agent-author/SKILL.md).

A request that says "every time" or "always" usually wants a hook, or a hook beside the skill. Say which shape you picked, and why, before drafting.

**Then identify task type: new skill or modifying existing.**

- **New skill** — proceed to the interview below.
- **Modifying existing skill** — also consult `references/environments.md` (read-only path handling, `/tmp` staging, name preservation).

Interview the user:

1. What task or domain does the skill cover?
2. What specific use cases should it handle?
3. Does it need executable scripts, or just instructions?
4. Any reference materials to bundle?
5. **Provenance** — is this original to the user, or derived from existing work (another skill, a library, copied code)? If derived, identify the upstream source and its license **before drafting** — provenance dictates licensing (see `references/publishing.md`), and a copyleft or unclear source may mean the skill cannot be published at all.

Then assess what the skill's `tests/` will hold. An objective output — file transforms, code generation, fixed workflow steps — earns script-tier checks and a behavior case. A subjective output — writing style, design quality, a conversation — carries a trigger case alone. Either way the skill gets verified; the assessment only decides what the cases can assert. Details in `references/verification.md`.

## Step 2: Draft the skill

Apply the writing rules in `references/writing-guide.md` — SKILL.md structure, description format, bundled-resources decisions, review checklist, interview depth, communication style. Each skill also carries a human-facing `README.md`; author it per `references/readme-guide.md`.

## Step 3: Review with user

Present key decisions in bullet form — frontmatter `name` / `description`, body section structure, scope guards, non-obvious choices. Show the drafted `description` word for word: it is the trigger, and the one line the user has to be able to judge before any file exists. Do NOT paste full SKILL.md / reference content unless the user explicitly asks; full-content paste floods the terminal and obscures the structural decisions worth confirming. After structural OK via bullets, write files; the user can read full content in their editor and request edits there. Iterate on feedback.

For a deeper pass, spawn `agents/skill-reviewer.md` to adversarially check trigger correctness, structural discipline, and companion-file compliance.

## Step 4: Verify

Runs on a new skill and on every later change. Never a menu, never a question of whether to verify — follow `references/verification.md`:

1. **structure and script tiers** — run `scripts/run-checks.sh <skill-name>` in the repo. Both are deterministic and cost no tokens. Fix what it reports, then run it again.
2. **model tier** — run the `default: true` cases in the skill's `tests/model.json`. One case is one general-purpose subagent with `model: opus`; propose the run — count, cost, batches, what the subagents can read — and wait for a go before the first case, then judge the assertions yourself from the subagent's report.

The model tier needs the skill linked into `~/.claude/skills/`, because a subagent can only pick an installed skill. For a repo skill this pass therefore happens as step 6 of `references/publishing.md` — after the link, before the commit gate. Run every case before fixing anything, then fix every finding together and re-run; only an all-clear moves the work on.

## Publishing & licensing

When a skill is destined for the user's `claude-skills` repo, follow `references/publishing.md` end to end: pick the license files by provenance (MIT for original; upstream `LICENSE` + `NOTICE` for derived; copyleft / unclear → don't publish), then run the git workflow — branch → create/edit → sync catalog → link → verify → gated commit, delegating to sk-branch-creator / sk-commit-creator. Read it before creating or modifying a repo skill.

## References

- `references/writing-guide.md` — SKILL.md writing / Description format / Bundled resources / Review checklist / Interview depth / Communication style
- `references/readme-guide.md` — per-skill README: sections / objective tone / heading spacers / two-level bullets
- `references/publishing.md` — provenance → license files + the repo git workflow (branch → create/edit → sync catalog → link → verify → gated commit)
- `references/verification.md` — the family verification contract: the three tiers, the runner interface, the shared rules, `tests/model.json`
- `references/environments.md` — Claude.ai / Cowork / Claude Code branches + packaging + modifying-existing path handling

## Related

- [sk-branch-creator](../sk-branch-creator/SKILL.md) / [sk-commit-creator](../sk-commit-creator/SKILL.md) — the branch and commit hand-offs used in `references/publishing.md`.
