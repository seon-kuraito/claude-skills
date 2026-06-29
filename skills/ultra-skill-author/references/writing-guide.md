# Writing Guide

The static rules for authoring a skill. Read this when drafting `SKILL.md` content, choosing a description, deciding what to bundle, or running a self-review.

## Anatomy of a skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled resources (optional)
    ├── scripts/    — executable code for deterministic / repetitive tasks
    ├── references/ — docs loaded into context as needed
    └── assets/     — files used in output (templates, icons, fonts)
```

A `compatibility` frontmatter field exists for declaring required tools / dependencies but is rarely needed.

## SKILL.md structure

Use this skeleton as the starting point:

```md
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---

# Skill Name

## Quick start

[Minimal working example]

## Workflows

[Step-by-step processes with checklists for complex tasks]

## Advanced features

[Link to separate files: See REFERENCE.md]
```

### Title and frontmatter

- **Open with a single `# ` H1 in Title Case** — the skill name as a readable title (`Ultra Repo Creator`), placed right after the frontmatter. Uppercase acronyms (`PR`, not `Pr`) and use the readable form of filename tokens (`CLAUDE.md`, not `Claudemd`). Every SKILL.md has exactly one.
- **Keep frontmatter to `name` + `description`** — plus a real behavior field (e.g. `allowed-tools`) only when actually needed. Don't add inert keys like `metadata: type: skill`; Claude Code's skill loader ignores them, so they are pure noise.

### Progressive disclosure (three-tier)

Skills load in three tiers:

1. **Metadata** (name + description) — always in context, ~100 words.
2. **SKILL.md body** — in context whenever the skill triggers. Aim for under 100 lines if you can; under 500 is acceptable. Push detail behind references.
3. **Bundled resources** — loaded on demand (unlimited size; scripts execute without being read into context).

If `SKILL.md` body grows past ~100 lines, add another layer of hierarchy: pull the long sections into `references/<topic>.md` and leave a clear pointer about when to read them.

### Multi-domain organization

When a skill supports multiple frameworks / variants / domains, organize by variant under `references/`:

```
cloud-deploy/
├── SKILL.md (workflow + variant selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

The agent reads only the relevant variant — keeps each context lean.

### Large reference files

For any reference file longer than ~300 lines, include a table of contents at the top so the agent can navigate without reading the whole file.

## Description format

The `description` field is **the only thing the agent sees** when deciding which skill to load. It surfaces in the system prompt alongside every other installed skill. Get this wrong and the skill never triggers.

### Format rules

- **≤1024 characters.**
- **Third person**, present tense.
- **First sentence**: what the skill does (the capability).
- **Second sentence**: `Use when [specific triggers]` — name the keywords, contexts, file types, or user phrasings that should activate it.

### Keep it trigger-only — spec belongs in the body

The description loads into *every* session for *every* installed skill, and it exists for one job: helping the agent decide whether to trigger. Carry only trigger-relevant content — the capability as one short phrase, plus the activation conditions. Keep out everything the agent needs only *after* the skill fires:

- Output templates or format strings (`<type>/<kebab>`, a section layout) → body.
- Exhaustive coverage lists (all 11 types, the 24 patterns) → body.
- Output-style rules (imperative mood, kebab-case, full-width spacers) → body.
- Execution mechanics (how it reads the diff, that it pauses for confirmation) → body.

Why: spec in the description doesn't improve triggering, and it carries an ongoing cost — every other skill's trigger decision now reads past your template noise, and a long low-signal description trains the agent to discount the whole field. The body loads only once the skill triggers, which is exactly when that detail is needed.

```
Before: "Authors git commit messages in strict Conventional Commits format —
         `<type>(<scope>): <description>` ... Covers all 11 types (feat, fix, ...),
         BREAKING CHANGE footer, scope inference ..., rejects `wip` / `update X` ..."

After:  "Authors git commit messages. Use whenever Claude is about to write a commit
         message, the user runs `git commit`, asks how to phrase a commit, or finishes
         a discrete unit of work — even if they don't say 'Conventional Commits'."
```

### Good vs. bad

```
Good: "Extract text and tables from PDF files, fill forms, merge documents.
       Use when working with PDF files or when user mentions PDFs, forms,
       or document extraction."

Bad:  "Helps with documents."
```

The bad example gives the agent no way to distinguish this skill from any other document-related skill.

### Pushy phrasing combats undertrigger

The agent has a tendency to *under*-trigger skills — to skip them when they would have helped. Combat this by writing descriptions that are slightly pushy. Instead of:

> *How to build a simple fast dashboard to display internal Anthropic data.*

write:

> *How to build a simple fast dashboard to display internal Anthropic data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'*

### How triggering actually works

Skills appear in `available_skills` with their name + description. The agent decides whether to consult one based on that description. Two important nuances:

- **Simple, one-step queries don't trigger skills.** "Read this PDF" may not trigger a PDF skill even with a perfect description, because the agent can handle it directly.
- **Substantive, multi-step, specialized queries reliably trigger** when the description matches.

This shapes how you write evals for description-tuning (`references/description-tuning.md`) — eval queries must be substantive enough that the agent would actually benefit from consulting the skill.

## Bundled resources — what goes where

### Scripts (`scripts/`)

Add a script when:

- The operation is **deterministic** (validation, formatting, fixed transforms).
- The same code would otherwise be generated repeatedly across invocations.
- Errors need explicit handling that the agent shouldn't reinvent each time.

Scripts save tokens and improve reliability versus letting the agent regenerate code.

### References (`references/`)

Split content into a separate reference file when:

- `SKILL.md` body is approaching the line ceiling.
- The content has **distinct domains** the agent only needs one of at a time (finance vs. sales schemas; AWS vs. GCP).
- The content is **advanced or rarely needed** — gate it behind a pointer rather than burdening every invocation.

### Assets (`assets/`)

Files the skill emits or templates from — HTML mockups, icon sets, fonts, sample documents. Distinct from scripts (executable) and references (docs).

**Naming an emitted-template asset.** A source asset's filename never reaches the file it produces (the skill writes to a fixed destination name), so name it for clarity, not to match the output:

- **Structural template** — multiple named placeholders, conditional blocks, or generated sections → `<destination-filename>.tmpl` (`CLAUDE.md.tmpl`, `NOTICE.tmpl`, `pr-body.md.tmpl`). The `.tmpl` says "don't copy raw — fill the placeholders."
- **Plain text copied verbatim or with a single-token swap** (e.g. only `{{YEAR}}`) → its content type, `.txt` (`MIT.txt`, `gitignore.txt`, `license-mit.txt`). Keeps it legible as source text and avoids an extensionless `Apache-2.0` reading as a `.0` file.
- **A typed file copied verbatim** keeps its real extension — a workflow stays `pages-static.yml`, not `.txt`.

Assets the skill reads but does not emit (a JSON config applied via a CLI, an HTML viewer for tooling) aren't templates — they keep their natural extension and sit outside this rule.

**Placeholder syntax.** One syntax everywhere: `{{UPPER_SNAKE}}` for substitutions, `{{#cond}} … {{/cond}}` for conditional blocks. One convention keeps templates greppable and dodges collisions — `[…]` reads as a Markdown link, `<…>` as HTML, while GitHub Actions' `${{ }}` stays distinct by its leading `$`.

## Writing patterns

### Imperative form

Write instructions in the imperative (`Apply the rules…`, `Read X…`) rather than describing them in the third person (`The agent should…`). Imperative prose reads more directly as commands.

### Explain *why*, not just *what*

Today's models have strong theory of mind. When you ask them to do something, explaining the reason almost always produces better behavior than a bare directive — especially in edge cases the directive didn't anticipate. If you find yourself writing `ALWAYS` or `NEVER` in all caps, or building rigid rule structures, that's a yellow flag: try reframing as "here's what we want, here's why" and let the model's judgment do the rest.

### Defining output formats

Use an explicit template rather than describing the format prose-style:

```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

### AskUserQuestion menus

A skill that collects choices through `AskUserQuestion` writes each menu as a **fixed verbatim block** — the *Defining output formats* discipline applied to an interactive menu. Spell the menu out in full so the agent copies it rather than composing one fresh each run: identical copy every time, no wasted deliberation, a CLI-scaffold feel.

```
single-select · header: 「<≤12-char label>」          # or: multiSelect (questions render as tabs)
question: 「<verbatim question text>」
options:
  · 「<label>」 — 「<the guidance the user needs to choose, baked in>」
  · …
[Rule, not copy] <deterministic filter on which options appear — English, never shown>
```

Each question takes **2–4 options**; a `header` is **≤12 characters**. A `multiSelect` can bundle up to two questions, rendered as tabs — give each its own header:

```
multiSelect · two questions, rendered as tabs
Q1 · header: 「<≤12-char label>」
  question: 「<verbatim question text>」
  options:
    · 「<label>」 — 「<baked-in guidance>」
Q2 · header: 「<≤12-char label>」
  question: 「…」
  options:
    · …
```

- **Verbatim & ordered** — question, header, labels, and order are copied exactly, never rephrased or reordered. The only line allowed to vary is a `[Rule, not copy]` entry that filters the option *set* by a deterministic condition (an existing branch, a bound remote, a detected `vite` dependency).
- **Copy vs. direction, split by language** — everything inside 「」 is user-facing copy, written in the user's language and reproduced verbatim; everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction to the agent and is never shown. A menu is UI, not config — the one deliberate exception to English-only authoring. The language split makes the two impossible to confuse.
- **Fully neutral** — no option is marked recommended and no surrounding prose nudges one; present the options as equals. If the skill asserts a default elsewhere, neutralize it so prose and menu agree.
- **Descriptions baked in** — the guidance for choosing lives in each option's description, not in conversational prose before the menu.
- **Silent collection** — emit no prose before, between, or after the menu calls of an input phase; call the tool and act on the answer. Narration resumes only once every selection for that phase is in. Stage-handoff gates ("enter the next stage?") follow the same no-prose-wrapping rule.

### Execution gate

Skills that run outward-facing or irreversible actions — anything touching a remote, repo settings, or another user's view — need a confirmation gate before those actions. Standardize it as a fixed-title bullet block, `## 🚧 Execution gate`, one sentence per bullet, **rendered as a framed callout** — a `---` rule above and below the block, each with a full-width `　` (U+3000) spacer line tight against it on the inner side (no blank-line padding, for a denser frame):

```markdown
---
　
## 🚧 Execution gate

- **Triggers on** — <which outward-facing commands>: `cmd`, `cmd`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold the steps into one uninterrupted run.
　
---
```

The four bullets are the spine; the `---`/`　` frame is part of the standard rendering, not optional decoration — reproduce both, every time. This guide isn't loaded at skill runtime, so each gate-emitting skill keeps the framed gate above in its own `assets/execution-gate.md`, and in SKILL.md keeps a short `## 🚧 Execution gate` pointer that names what triggers it and says to render that asset before proceeding. Extracting the frame to a file keeps the format syncable across skills; the bespoke `Triggers on` line stays per-skill. When a gate carries extra meaning, fold it into the relevant bullet rather than adding noise — e.g. a gate that *is* a fork in the flow ("confirm = push, decline = stay local") says so on **Confirm**; what to show (title, body-as-link, flags) rides on **Stop & show**. Don't flatten that nuance away for the sake of uniformity.

### Examples pattern

Concrete Input/Output pairs beat abstract descriptions:

```markdown
## Commit message format
**Example 1:**
Input:  Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### Lack-of-surprise / safety

Skills must not contain malware, exploit code, or content that would compromise system security. The skill's contents shouldn't surprise the user given the skill's stated intent. Don't go along with requests to build misleading skills, skills that facilitate unauthorized access, or skills designed for data exfiltration. ("Roleplay as X" skills are fine.)

## Interview depth

The four basic questions in `SKILL.md` Step 1 are the floor, not the ceiling. Probe further when warranted:

- **Edge cases** — what happens when input is empty / malformed / very large / multilingual?
- **Input/output format** — is there a sample file? What field names? What encoding?
- **Success criteria** — what makes an output "right" vs. "wrong"? Subjective vs. objective?
- **Dependencies** — does this rely on a specific library, API, environment variable, or external service?

Use available MCPs and parallel subagents to research relevant docs / similar skills / best practices before drafting, so the user isn't burdened with explaining things you could look up.

## Communication style

Skills can be invoked by anyone — domain experts, beginners trying coding for the first time, plumbers, parents, grandparents. Calibrate jargon to context cues:

- "evaluation" / "benchmark" — borderline, usually fine.
- "JSON" / "assertion" / "schema" — use only when the user has already shown familiarity. Briefly define on first use otherwise.

Show intermediate artifacts and reasoning when it helps the user follow along, especially during multi-step workflows. The user shouldn't have to guess what the agent is doing.

## Review checklist

After drafting, verify:

- [ ] Description includes triggers (`Use when…`).
- [ ] Description is in third person, ≤1024 chars, two-sentence shape.
- [ ] Description is trigger-only — no output template, format strings, coverage lists, or execution mechanics (those live in the body).
- [ ] Description scope agrees with the human-facing summaries — the body's opening line and the README Summary are not narrower than what the description triggers on.
- [ ] `SKILL.md` body is under the line ceiling (under 100 ideal, under 500 acceptable).
- [ ] No time-sensitive information (dates, "currently", "as of last quarter").
- [ ] Terminology is consistent throughout — same concept, same name everywhere.
- [ ] Concrete examples are included for non-trivial instructions.
- [ ] Reference depth is one level: `SKILL.md → references/<file>.md`, not `SKILL.md → ref → ref → ref`.
- [ ] Bundled scripts / agents / assets are referenced from the body so the agent knows they exist.
