# Section guidance

Deep-dive on what belongs in each of the three sections. See `SKILL.md` for the overall template and hard rules.

## 📝 Summary

What the PR does — **at least one bullet per commit on the branch**. The commit count is the floor, not a target: a commit that bundled several distinct changes expands into several bullets, so the bullet count is `≥` the number of commits, never fewer. Each bullet is one concrete change at the right level of abstraction.

Calibrate each bullet a notch more descriptively than its commit subject — clear enough that a reviewer grasps the change without opening the commit, but no more:

- ✅ `Install best-practices skill packages for the repo's primary stack`
- ❌ `Added some skills` — vague; says less than the commit subject
- ❌ `Created SKILL.md, rules/audio.md, rules/fonts.md, ...` — file-level, too granular
- ❌ `Install the skill packages, which register each rule file under rules/ and wire them into the loader so that …` — a paragraph; that detail belongs in the diff, not the bullet

Drop ceremonial words like "this PR" or "we now" — the GitHub context already says "this PR".

Bullet count:

- **Floor is the commit count** — every commit earns at least one bullet, so the Summary reads as the branch's commit list, expanded.
- A multi-concern commit splits into one bullet per concern (above the floor).
- Many commits → many bullets is expected: curated multi-commit branches are the norm here (the skill defaults to `--merge` and never squashes them — see `SKILL.md` *Merging*), so a long Summary is not in itself a reason to split the PR.
- This assumes each commit is one real change. Squash a fixup-heavy WIP branch first (`SKILL.md` *Merging*); the floor then follows the squashed commits.

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
