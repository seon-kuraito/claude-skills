---
name: ultra-commit-creator
description: Authors git commit messages. Use whenever a commit is in play — about to run `git commit`, finishing a discrete unit of work, or asked how to phrase one — regardless of exact wording or language. Lean toward consulting it whenever a commit is being written or planned, even when 'Conventional Commits' is never said, rather than hand-writing a message ad hoc.
---

# Ultra Commit Creator

Author git commit messages strictly conforming to the Conventional Commits spec, with one extra rule: the description must be a single concise English sentence in imperative mood.

## Quick start

The output format is always:

```
<type>(<scope>): <description>

[BREAKING CHANGE: <what changed and how to migrate>]
```

A correct example: `feat(00-blank): add intro fade-in animation`

## Format

- `<type>` — required, lowercase, exactly one of the 10 types below.
- `<scope>` — optional, lowercase, kebab-case. Omit when no single scope fits.
- `<description>` — required. Single concise English sentence, imperative mood, lowercase first letter, no trailing period, ideally under 50 chars.
- BREAKING CHANGE footer — required by the spec when the change breaks API or user-facing behavior. Footer is also one English sentence.
- **No prose body.** The message is the subject line only (plus a `BREAKING CHANGE` footer and standard trailers like `Co-Authored-By` when applicable). A coherent, single-purpose change stays one commit even when it touches many files — its extended context goes in the PR description, not a commit body. Don't split a unified change just to avoid writing a body; genuinely separate changes still split (see Anti-patterns).

## Type vocabulary

| Type | Use for |
|---|---|
| `feat` | New feature or new user-facing content |
| `fix` | Bug fix |
| `refactor` | Code change that neither adds a feature nor fixes a bug |
| `chore` | Tooling, dependencies, maintenance |
| `docs` | Documentation changes |
| `style` | Code formatting (whitespace, semicolons) — NOT visual / CSS styling |
| `perf` | Performance improvement |
| `build` | Build system or external dependency changes |
| `ci` | CI / CD configuration changes |
| `test` | Adding or modifying tests |

If a change spans types, pick the dominant one. If two changes are clearly distinct, split into two commits — easier to read in `git log` and safer to revert.

## Scope determination

Check in order:

1. **Project CLAUDE.md** — if it defines a scope vocabulary (e.g. "use `00-blank`, `01-intro`, `shared`"), use those exact tokens.
2. **Changed file path** — if changes are confined to one subdirectory, use that directory's leaf name (e.g. `src/templates/00-blank/` → `00-blank`).
3. **Logical module** — if changes span files within one logical unit, name that unit (e.g. `auth`, `api`, `render`).
4. **Omit scope** — for cross-cutting changes, top-level config, or when no single scope applies.

Scope is always lowercase, kebab-case.

## Description rules

The single-sentence description is the load-bearing part. Why one sentence: anything longer is either two commits, or detail that belongs in code or PR description.

- **English, imperative mood.** "add intro animation", not "added" / "adding".
- **Lowercase first letter.** Convention across the spec ecosystem.
- **No trailing period.**
- **Under ~50 characters when possible.** Git tooling truncates beyond ~72.
- **Concrete over vague.** "fix audio sync on intro scene" beats "fix audio".
- **One sentence only.** If you cannot say the change in one sentence, the commit is too big — split it.

## BREAKING CHANGE footer

Include when the change breaks an existing API, contract, or user-facing behavior:

```
feat(api): switch response envelope to camelCase

BREAKING CHANGE: response keys are now camelCase; clients reading snake_case must be updated.
```

Footer text is also a single concise English sentence (extended slightly for migration guidance if needed).

## Anti-patterns

Reject and rewrite. Each pattern, then why it fails:

- `wip: try something` — empty information. If truly WIP, don't commit; use `git stash` or a feature branch.
- `update X` — no commitment to what kind of update. Pick `feat` / `fix` / `refactor` / etc.
- `fix stuff` — too vague to be useful in `git log`. Name what was broken.
- Non-English description or body — the spec ecosystem expects English; tools that parse commits (changelog generators, AI release-note writers) assume English.
- Multi-paragraph body — if the change has multiple narratives, split into multiple commits.
- `style: refactor parser logic` — wrong type. `style` is whitespace/formatting only; this is `refactor`.
- Multiple unrelated changes in one commit — split.

## Examples

```
feat(00-blank): add intro fade-in animation
fix: incorrect duration on title scene
refactor: rename templates folder to videos
chore: bump remotion to 4.0.500
docs(claude): update structure section
perf(render): cache frames to reduce render time
ci: add github action for typecheck
```

Breaking example:

```
refactor(config): rename Config.setOutputLocation to Config.setOutputPath

BREAKING CHANGE: setOutputLocation removed; use setOutputPath instead.
```

## Related

For matching branch names that use the same type vocabulary, see [ultra-branch-creator](../ultra-branch-creator/SKILL.md).
