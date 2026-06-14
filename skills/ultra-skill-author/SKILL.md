---
name: ultra-skill-author
description: Authors, refines, and evaluates Claude agent skills (the `.claude/skills/<name>/SKILL.md` packages that extend agent capabilities). Use for ANY task touching a skill — creating, editing, refining, restructuring, naming, evaluating, licensing, or reasoning about one — matched on intent rather than exact wording or language. Reach for it whenever a request pairs an action with a skill, even briefly; prefer consulting it over handling skill work ad hoc.
---

# Ultra Skill Creator

Handle any work on a Claude skill — creating, refining, restructuring, naming, licensing, and evaluating. The default flow is a lightweight three-step interview / draft / review; heavier machinery — eval loops, blind A/B, description-tuning — is available behind a capability checkpoint when the user opts in.

## Naming convention

All skills in this user's `~/.claude/skills/` follow the pattern **`ultra-<single-token>-<verber>`**. Example: `ultra-claudemd-author`.

Rules:

- Always prefix with `ultra-`
- Single-token domain — collapse multi-word concepts into one token (`claudemd`, not `claude-md`)
- Verb-er suffix (`author`, `creator`, `formatter`, `griller`, `polisher`, etc.)

When **creating a new skill**: propose a name in this format during Step 1 and confirm with the user before drafting.

When **modifying an existing skill that doesn't match this pattern**: offer to rename as part of the change.

## Step 1: Gather requirements

**First, identify task type: new skill or modifying existing.**

- **New skill** — proceed to the interview below.
- **Modifying existing skill** — also consult `references/environments.md` (read-only path handling, `/tmp` staging, name preservation), `references/evals.md` (snapshot the existing skill as baseline), and `references/blind-comparison.md` (rigorous A/B between old and new versions).

Interview the user:

1. What task or domain does the skill cover?
2. What specific use cases should it handle?
3. Does it need executable scripts, or just instructions?
4. Any reference materials to bundle?
5. **Provenance** — is this original to the user, or derived from existing work (another skill, a library, copied code)? If derived, identify the upstream source and its license **before drafting** — provenance dictates licensing (see `references/publishing.md`), and a copyleft or unclear source may mean the skill cannot be published at all.

Then assess whether test cases are warranted — objective outputs (file transforms, code generation, fixed workflow steps) benefit from them; subjective outputs (writing style, design quality) usually don't. Details in `references/evals.md`.

**Capability checkpoint** — use `AskUserQuestion` (multi-select) to let the user opt into:

- **evals** — run test cases via subagents, grade outputs against assertions, see benchmarks. See `references/evals.md`.
- **description-tuning** — automated 60/40 train-test loop to improve trigger accuracy. See `references/description-tuning.md`.

(blind-A/B is not in this menu — it surfaces only when modifying an existing skill, see *After the skill is complete* below.)

## Step 2: Draft the skill

Apply the writing rules in `references/writing-guide.md` — SKILL.md structure, description format, bundled-resources decisions, review checklist, interview depth, communication style. Each skill also carries a human-facing `README.md`; author it per `references/readme-guide.md`.

## Step 3: Review with user

Present key decisions in bullet form — frontmatter `name` / `description`, body section structure, scope guards, non-obvious choices. Do NOT paste full SKILL.md / reference content unless the user explicitly asks; full-content paste floods the terminal and obscures the structural decisions worth confirming. After structural OK via bullets, write files; the user can read full content in their editor and request edits there. Iterate on feedback.

**Confirm point** — if the user opted into evals at the capability checkpoint, ask whether to proceed into the eval loop now. If yes, follow `references/evals.md`.

## Publishing & licensing

When a skill is destined for the user's `claude-skills` repo, follow `references/publishing.md` end to end: pick the license files by provenance (MIT for original; upstream `LICENSE` + `NOTICE` for derived; copyleft / unclear → don't publish), then run the git workflow — branch → create/edit → link → verify → gated commit, delegating to ultra-branch-creator / ultra-commit-creator. Read it before creating or modifying a repo skill.

## After the skill is complete

**Confirm point** — if the user opted into description-tuning, ask whether to run the optimization loop now. If yes, follow `references/description-tuning.md`.

**Modifying existing skill only** — proactively offer blind A/B comparison between old and new versions. If the user accepts, follow `references/blind-comparison.md`.

## References

- `references/writing-guide.md` — SKILL.md writing / Description format / Bundled resources / Review checklist / Interview depth / Communication style
- `references/readme-guide.md` — per-skill README: sections / objective tone / heading spacers / two-level bullets
- `references/publishing.md` — provenance → license files + the repo git workflow (branch → create/edit → link → verify → gated commit)
- `references/evals.md` — Test cases / Workspace / Grading / Aggregation / Iteration (opt-in)
- `references/description-tuning.md` — Trigger optimization loop (opt-in)
- `references/blind-comparison.md` — Blind A/B between two skill versions (opt-in; surfaces only when modifying existing)
- `references/environments.md` — Claude.ai / Cowork / Claude Code branches + packaging + modifying-existing path handling

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — the branch and commit hand-offs used in `references/publishing.md`.
