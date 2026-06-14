# Section guidance

Deep-dive on what belongs in each of the three sections. See `SKILL.md` for the overall template and hard rules.

## 📝 Summary

What the PR does, in 2–5 bullets. Each bullet is one concrete change at the right level of abstraction.

- ✅ `Install best-practices skill packages for the repo's primary stack`
- ❌ `Added some skills` — vague
- ❌ `Created SKILL.md, rules/audio.md, rules/fonts.md, ...` — file-level, too granular

Aim for "what changed, in one line." Drop ceremonial words like "this PR" or "we now" — the GitHub context already says "this PR".

Sizing:

- 1 bullet — fine for a single-fix or single-feature PR
- 2–4 bullets — typical
- 5+ bullets — likely too big a PR; consider splitting before writing the description

## 🎯 Scope

What is and is not touched. 1–3 bullets. Helps the reviewer set expectations and reduces the surface they feel they need to audit.

Common bullet shapes:

- Boundaries — `Tooling-only — no application code touched`
- Confinement — `All changes confined to `.claude/` and root-level config`
- Out-of-scope callouts — `Does not migrate existing X — see follow-up issue`
- Non-changes that look like changes — `Renames a file but its imports and behavior are unchanged`

If the change genuinely spans the whole project and there is nothing useful to say, write:

```
- N/A — broad change spanning the whole codebase
```

Do not omit the section. The shape of the PR should be predictable so reviewers can scan PRs in this repo the same way every time.

Anti-pattern: writing prose into Scope explaining the architecture. Scope is boundary-setting, not codebase tutorial.

## ✅ Test plan

A markdown checklist of how a reviewer (or future-you) can verify the change. 2–4 items.

- Use open checkboxes `[ ]` — never `[x]` in the template — so reviewers can tick them as they verify.
- Each item is an action the reviewer can run, not an assertion about the code. `Open the app, confirm the empty state renders` is better than `Empty state renders correctly`.
- Order from cheap to expensive — type-check / lint first, manual UI verification last.

For pure-config or pure-docs PRs that don't need active testing, list passive checks rather than omitting:

```
- [ ] Lint still passes
- [ ] No runtime references to the removed module
- [ ] Docs render correctly on GitHub
```

Anti-pattern: a single item that says `[ ] Tested locally`. That is unverifiable for the reviewer — they want to know *what* you tested so they can repeat or extend it.
