---
name: sk-spec-implementer
description: Implements one spec end to end — the release branch, the work branch, tests first, the code, the review, the commit, and the PR — loading the sibling skill for each step and stopping where the user reads the work. Make sure to use this skill whenever the user asks to implement, build, or carry out a spec or a phase spec, or names a file under specs/ as the thing to do — regardless of exact wording or language.
---

# Spec Implementer

Implement one spec in this session: one spec, one work branch, one PR. The spec was settled by `sk-spec-planner`; this skill does not plan, it builds, and it loads a sibling skill for every step that has one. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

## 0. Get the spec

The spec is the path the user passed, or the file `sk-spec-planner` handed over. A spec is complete when it has the seven sections, its testing decisions name the seams, the version table of `DECISIONS.md` lists it, and `GLOSSARY.md` defines the terms it uses. With no spec, or an incomplete one, load `sk-spec-planner` to complete it, then come back here.

## 1. Read

Read the spec, `GLOSSARY.md`, and `DECISIONS.md` — in a family, the coordination repo's. Take from them:

- the **seams**, from the spec's testing decisions;
- the **version**, from the row of the version table that lists this spec;
- the **dependency**, from the spec's opening line: none, or the phase this spec is stacked on;
- the **member repo** the spec names, in a family; a single repo is its own target.

Read the code the spec touches the same way the planner did: the map first, then the area, grep before read, one hop at most.

## 2. The release branch

`git ls-remote --heads origin 'release/*'` in the target repo. When `release/<version>` is missing, load `sk-release-creator` to start the version, with the number from the version table; its version question becomes a confirmation. When the branch exists, go on.

## 3. The work branch

Load `sk-branch-creator`. A spec with no dependency is cut by its rules. A spec stacked on a phase is cut from that phase's work branch, and its PR is still based on the release branch: once the phase it depends on merges, the PR's diff shrinks to this spec alone.

## 4. Red

Load `sk-code-tester`. Write the failing tests at the seams, run them, show the failure. Then present the **Checkpoint** menu: the user reads the tests before any code is written.

## 5. Green

Write only enough code to pass. Run the type check and the single test files as you go, and the full suite once at the end. Present the **Checkpoint** menu: the user reads the code.

## 6. Review

Load `sk-code-reviewer` with the spec as the spec source and the work branch's base as the fixed point. Present the **Checkpoint** menu over its findings: the user decides what gets fixed. Fix what they name, return to step 5 for the green run, and come back here until nothing is left.

## 7. Land

Load `sk-commit-creator`: one slice is one commit, its tests and its code together. Then load `sk-pr-creator`: it merges into `staging` where the repo has one and opens the PR into the release branch. Both skills stop at their own gates; this skill adds none.

## Rules

- One spec per run. A phase spec is implemented alone; the next phase is a new run, usually in a fresh session.
- Never widen the spec. Behaviour the spec did not ask for is a finding for the review, not a feature.
- Stop at every Checkpoint. The user reads every line; the stops are where that happens.

## References

- `references/menus.md` — the Checkpoint menu

## Related

- [sk-spec-planner](../sk-spec-planner/SKILL.md) — writes the spec and hands over to this skill; this skill loads it when the spec is missing or incomplete.
- [sk-release-creator](../sk-release-creator/SKILL.md) — starts the version when the release branch is missing.
- [sk-branch-creator](../sk-branch-creator/SKILL.md) — names and cuts the work branch, stacked or not.
- [sk-code-tester](../sk-code-tester/SKILL.md) — the red → green discipline at the seams.
- [sk-code-reviewer](../sk-code-reviewer/SKILL.md) — the four-axis review before landing.
- [sk-commit-creator](../sk-commit-creator/SKILL.md) / [sk-pr-creator](../sk-pr-creator/SKILL.md) — the commit and the PR.
