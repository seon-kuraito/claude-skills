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
    │   └── menus.md — every AskUserQuestion menu and plain-text question the skill asks
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

- **Open with a single `# ` H1 in Title Case** — the skill name without the `sk-` prefix, as a readable title (`Repo Creator`), placed right after the frontmatter. Uppercase acronyms (`PR`, not `Pr`) and use the readable form of filename tokens (`CLAUDE.md`, not `Claudemd`). Every SKILL.md has exactly one.
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

This shapes how you write trigger cases (`references/verification.md`) — a trigger prompt must be substantive enough that the agent would actually benefit from consulting the skill.

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
- The content is a **menu or plain-text question** the skill asks the user — every one of them lives in `references/menus.md`, however often it runs (see *AskUserQuestion menus*).

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

An input with no enumerable option set — a name, a path, a free-form list — is a **plain-text question**: fixed the same way, but asked in prose rather than through the tool.

```
plain text
question: 「<verbatim question text, with <placeholders> where a value is filled in>」
[Rule, not copy] <what each placeholder is substituted with — English, never shown>
```

**Where they live — `references/menus.md`.** Every menu and plain-text question a skill asks sits in that one file, one per section, each under an English H2 that names it (`## Template`, `## Remote`, `## Account`). `SKILL.md` and the other references hold no menu blocks: they point at a menu by its section title — *present the **Remote** menu* — naming the file on the first mention in each file. This covers every menu, the entry menu a run always reaches as much as a branch-only one. Why one file: the 「」 strings are the skill's UI copy, the one place a second language lives in an English-authored skill, and one file makes every string findable and editable in one pass — the same reason a frontend keeps its strings in a locale file rather than inline in components. Why a section title rather than a number: inserting a menu never renumbers the pointers to the others, and *the Remote menu* says what it is at the call site. Why an English title: it is direction, like every other line outside 「」.

`menus.md` opens with the menu contract, once, so the rule sits with the content it governs — copy this opening verbatim:

```markdown
# Menus

Every menu and plain-text question this skill asks, one per section. Present each block exactly as written: everything in 「」 is the user-facing copy — reproduce it verbatim, in the given order, marking no option as recommended and adding no surrounding prose. Everything outside 「」 (the field labels, the `[Rule, not copy]` line) is English direction, never shown. A `single-select` / `multiSelect` block goes through the AskUserQuestion tool; a `plain text` block is asked in prose, word for word — fill in only the placeholders its `[Rule, not copy]` line names, and add nothing else, no examples and no suggested answers. Call the tool (or ask the question) and act on the answer; narration resumes only once every selection for the phase is in.
```

`SKILL.md` keeps one sentence where its flow begins — *Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there* — and points at each menu where the flow reaches it. What happens on each answer, the branch the flow takes, stays in the body beside that pointer: the menu file holds copy, not flow.

- **Verbatim & ordered** — question, header, labels, and order are copied exactly, never rephrased or reordered. The only line allowed to vary is a `[Rule, not copy]` entry that filters the option *set* by a deterministic condition (an existing branch, a bound remote, a detected `vite` dependency).
- **Copy vs. direction, split by language** — everything inside 「」 is user-facing copy, written in the user's language and reproduced verbatim; everything outside 「」 (the field labels, the section titles, the `[Rule, not copy]` line) is English direction to the agent and is never shown. A menu is UI, not config — the one deliberate exception to English-only authoring. The language split makes the two impossible to confuse.
- **Fully neutral** — no option is marked recommended and no surrounding prose nudges one; present the options as equals. If the skill asserts a default elsewhere, neutralize it so prose and menu agree.
- **Descriptions baked in** — the guidance for choosing lives in each option's description, not in conversational prose before the menu.
- **Silent collection** — emit no prose before, between, or after the menu calls of an input phase; call the tool and act on the answer. Narration resumes only once every selection for that phase is in. Stage-handoff gates ("enter the next stage?") follow the same no-prose-wrapping rule.

### Execution gate

Skills that run outward-facing or irreversible actions — anything touching a remote, repo settings, or another user's view — need a confirmation gate before those actions. SKILL.md carries a short `## Execution gate` section that states three things and nothing else: what triggers the gate, what the skill lists before anything runs, and that it waits for an explicit go. Write them in prose, and add the per-gate nuance there too — a gate that forks on the answer ("confirm = push, decline = stay local"), a gate that runs twice in one flow, a gate whose confirmation only covers the step in front of it.

Use the words *execution gate* verbatim. A user's own configuration may key on that term to supply the rendering, and a synonym never reaches it.

**A skill never specifies what the block looks like.** No heading emoji, no column headers, no row labels, no table, and no `assets/execution-gate.md`. The shape belongs to the user: one who has defined it gets it applied, one who has not gets whatever the agent renders at the time, and both are correct. Fixing the shape inside skills was the earlier design — every gate-emitting skill then carried its own copy of the rendered table, a change to the shape meant editing all of them, and the copies drifted apart.

### Locating paths on disk

A skill that needs a real location on the user's machine derives it at runtime instead of writing an absolute path into the skill. Decide by what the path points at:

- **The skill's own repo, or a sibling repo in its family** — resolve it from the install. A global skill sits in `~/.claude/skills/` as a symlink to `<repo>/skills/<name>/`, and the base directory Claude Code reports is that symlink: resolve it with `realpath`, go up two levels to reach `<repo>`, and reach a sibling at `<repo>/../<sibling>`. The sibling step assumes the family's repos share one parent directory; say so wherever the skill relies on it.
- **What the user is working on right now** — the working directory. That is all the cwd says; a session can start anywhere, so never read the skill's repo from it.
- **Where something new gets created** — a user convention, not a location to discover. Write it as a placeholder (`~/Developer/<owner>/<repo>`), never with a real account or project name.

**When the lookup fails** — the resolved directory is not a git checkout because the skill was copied rather than linked, it runs on another machine or a non-Claude-Code host, or a sibling lives somewhere else — fall back by what the skill does with the repo:

- **Publishes to it** (edits, commits) → work locally and skip the publishing steps.
- **Only reads it** → use a path the user gave; otherwise stop and ask for one. Never guess a location.

**Inside a bundled script**, count from the script, not from the skill directory. A script at `<repo>/skills/<name>/scripts/` resolves its own directory with `cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P` and goes up **three** levels to reach `<repo>` — copying "two levels" from the skill directory lands inside `skills/`. Accept an explicit path argument first, so the skill can pass along a path the user gave.

Why: an absolute path breaks the day the repo moves, and a real one leaks the maintainer's layout into a public skill. The link scripts already work this way — they find their repo through `BASH_SOURCE` — so a skill that resolves its own location stays true to however it was installed.

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
- [ ] No hard-coded machine path — the skill's own repo and its siblings are resolved from the install with `realpath` (three levels up from a bundled script), the cwd is read only for the user's current work, creation locations are placeholders, and a failed lookup falls back by what the skill does with the repo: skip publishing, or use the user's path or ask.
- [ ] Terminology is consistent throughout — same concept, same name everywhere.
- [ ] Concrete examples are included for non-trivial instructions.
- [ ] Reference depth is one level: `SKILL.md → references/<file>.md`, not `SKILL.md → ref → ref → ref`.
- [ ] Bundled scripts / agents / assets are referenced from the body so the agent knows they exist.
- [ ] Every `AskUserQuestion` menu and plain-text question lives in `references/menus.md` under an English H2, with the contract at its top; `SKILL.md` and the other references point at menus by section title and hold none inline.
