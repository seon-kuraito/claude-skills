---
name: ultra-branch-creator
description: Authors git branch names. Use whenever a git branch is in play — about to create, switch to, or name one (`git checkout -b`, `git switch -c`, branch creation via `gh`), or whenever new work warrants its own branch — regardless of exact wording or language. Lean toward consulting it the moment branching comes up, rather than naming a branch ad hoc or waiting for an explicit 'branch name' request.
---

# ultra-branch-creator

Author git branch names in `<type>/<kebab-description>` format. Reuses the Conventional Commits type vocabulary so branches and the commits that land on them share one consistent language.

## Quick start

Format: `<type>/<kebab-description>`

A correct example: `feat/00-blank-intro-animation`

## Format

- `<type>` — required, lowercase, exactly one of the 10 types listed below.
- `<kebab-description>` — required. Lowercase English, kebab-case, 2–5 words.

## Type vocabulary

Identical to Conventional Commits. See [ultra-commit-creator](../ultra-commit-creator/SKILL.md) for the full definition of each type.

| Type | Use for |
|---|---|
| `feat` | New feature or content |
| `fix` | Bug fix |
| `refactor` | Refactoring |
| `chore` | Tooling, deps, maintenance |
| `docs` | Documentation |
| `style` | Code formatting (NOT visual styling) |
| `perf` | Performance work |
| `build` | Build-system changes |
| `ci` | CI / CD changes |
| `test` | Tests |

## Description rules

- **English, kebab-case.** `add-intro-animation`, not `addIntroAnimation` or `add_intro_animation`.
- **2–5 words.** Long enough to be meaningful, short enough to type and recognize at a glance.
- **Lead with the scope when applicable.** A branch for `feat(00-blank): add intro fade-in` becomes `feat/00-blank-intro-fade-in` — related branches sort together in alphabetical listings.
- **Match the upcoming commit's intent.** The branch description should make the planned commit message obvious.

## Anti-patterns

Reject and rewrite. Each pattern, then why it fails:

- `feature/...` — Conventional Commits spec uses `feat`. Stay consistent across branches and commits.
- `bug/...` or `bugfix/...` — spec uses `fix`.
- `hotfix/...` — usually `fix` (or `chore` if it's a tooling tweak). `hotfix` implies release-process semantics this skill does not model.
- Personal names: `jian/my-work` — branches describe work, not people. If you need personal namespacing, fold it into the description (e.g. `feat/jian-experiment-x`) rather than replacing the type.
- camelCase or snake_case: `feat/addIntroAnimation` → `feat/add-intro-animation`. Kebab is the git / web convention.
- Excessive length: `feat/add-intro-fade-in-animation-with-bouncing-text-and-color-change` — split into smaller branches or shorten.
- Non-English: write English; use translation tools if needed.

## Examples

```
feat/00-blank-intro-animation
fix/audio-sync-issue
refactor/templates-folder-rename
chore/upgrade-remotion
docs/claude-md-restructure
perf/render-frame-caching
ci/add-typecheck-action
```

## Related

For commit message authoring using the same type vocabulary, see [ultra-commit-creator](../ultra-commit-creator/SKILL.md).
