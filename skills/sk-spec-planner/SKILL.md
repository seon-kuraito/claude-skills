---
name: sk-spec-planner
description: Turns settled decisions into a specification and its records — the spec file, the decision record, and the glossary — and splits large work into phase specs sized to one context window. Make sure to use this skill whenever the user wants a spec, a specification, an SDD document, a feature written up so that it can be implemented, or decisions landed as documents — even when the word spec is never said, and regardless of exact wording or language.
---

# Spec Planner

Turn what the conversation has settled into three files: a spec under `specs/`, the decision record `DECISIONS.md`, and the glossary `GLOSSARY.md`. Synthesize; do not interview again. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

## Where the files live

- A **family** — the repo's `CLAUDE.md` describes a coordination layer (`meta` / `*-meta`) over member repos — keeps all three at the root of that coordination repo. A spec for one member lives there too and names the member.
- A **single repo** keeps them at its own root.
- A file that does not exist yet is created from its template in `assets/`.

## Before you start

The spec is a synthesis of decisions already made. When the goal is unclear, or the context does not hold enough to fill the template — the actors, the behaviour, the seams — load `sk-decision-griller` once, run the interview, and come back here. Never fill a gap with a guess.

## Process

### 1. Read the map, then the area

Read `CLAUDE.md`, `DECISIONS.md`, `GLOSSARY.md`, and, in a family, the `README.md` of each member the work touches. Then read only the area the change touches: grep for the symbols and names the decisions mention, read the hits, and go one hop further at most. Use the glossary's terms and identifiers throughout; respect every decision the record lists, and never propose again an option it lists as rejected. A whole-repo read is for a family's first spec or a wide refactor only, and what it finds goes back into the glossary and the record. A repo that holds no code yet has nothing to explore: derive everything from the behaviour the conversation settled.

### 2. Agree the seams

Sketch the seams at which the feature will be tested. Prefer seams that exist; take the highest one; the fewer the better, and the ideal is one. When a new seam is needed, propose it at the highest point you can. Ask the **Seams** question. `sk-code-tester` and `sk-code-reviewer` rely on the agreed seams later, so nothing is written before the user confirms them.

### 3. Split into phases when the work is too big

One spec is sized to one fresh context window of implementation: one work branch, one PR. When the work is larger, split it into phase specs — `<name>-phase-1.md`, `<name>-phase-2.md`, … — with the rules from to-tickets:

- Each phase is a tracer bullet: a narrow but complete path through every layer, demoable or verifiable on its own.
- Each phase names the phases that block it. Prefactoring goes first.
- A wide refactor — one mechanical change whose blast radius spans the codebase — is sequenced expand, migrate in batches, contract, each step its own phase.

Ask the **Breakdown** question and iterate until the user approves. A phase that cannot ship on its own stays in the same version as the phase it depends on; whether a phase becomes a version of its own is decided by what can ship, in step 5.

### 4. Write the spec

Copy `assets/spec-template.md` to `specs/<name>.md` and fill its seven sections. The spec is written in Traditional Chinese; the glossary's identifiers stay in English.

- The user stories are a long numbered list. For a refactor, write developer stories whose benefit a developer can observe, and keep the mechanism out of the story.
- The implementation decisions name modules, interfaces, contracts, and schemas, never file paths or code; a snippet a prototype produced may be inlined, trimmed to the decision it encodes.
- The testing decisions hold the agreed seams, what makes a good test, and the prior art in the codebase. For a refactor they state that the existing tests at the seams stay green.
- No version field: the version lives in the record (step 5).

### 5. Update the decision record

`references/decision-record.md` holds the layout and the rules. Add or rewrite the rows the spec decides; move every option the spec rejects into the rejected-options table; add the spec to the version table. Pick the version number by the rule in `sk-release-creator`'s `references/version-numbers.md` when that skill is installed — read it at `../sk-release-creator/references/version-numbers.md` relative to this skill's directory — and ask the **Version** question. The record states the current state only: rewrite an entry in place, never append a dated line.

### 6. Update the glossary

Every term the spec introduces or sharpens gets a row in `GLOSSARY.md` — the term, its identifier in code, one line of definition — written while the spec is written, not after. A term the record already uses without a definition gets one now.

### 7. Hand over

Present the **Next step** menu.

- Implement now → load `sk-spec-implementer` in this session; when it is not installed, say so and stop.
- Later → name the spec file and stop. A fresh session runs the implementer with that path.

## Rules

- A spec is a snapshot. While its version is open it is edited; once the version ships it is frozen, and only the record changes afterwards.
- The record is the current state; the spec is the how. Agents read `specs/` only when the record points them there.
- Never publish an issue, a ticket, or a Release from here; every artifact is a local markdown file.

## References

- `references/menus.md` — the four questions this skill asks
- `references/decision-record.md` — the layout and the rules of `DECISIONS.md`, with the version table
- `assets/spec-template.md`, `assets/decisions-template.md`, `assets/glossary-template.md` — the skeletons of the three files

## Related

- [sk-decision-griller](../sk-decision-griller/SKILL.md) — the interview that settles the decisions; this skill loads it when the context is too thin, and it loads this skill to land its result.
- [sk-spec-implementer](../sk-spec-implementer/SKILL.md) — implements one spec; this skill hands over to it.
- [sk-release-creator](../sk-release-creator/SKILL.md) — owns the version-number rule this skill reads.
