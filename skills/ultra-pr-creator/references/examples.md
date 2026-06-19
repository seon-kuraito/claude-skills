# Examples

Canonical PR body files. Each is the exact markdown the skill writes to the body file (for `gh pr create --body-file`) for the scenario described — the emoji-prefixed H2s, the `　` (U+3000) full-width spacer lines, and the footer. The body file holds this raw markdown with no outer code fence; the fences below are only to display each example here.

## CI / repo-policy PR

Scenario: a branch that adds a GitHub Actions workflow, pins the Node version, and updates contributing docs.

````
## 📝 Summary

- Add GitHub Actions workflow running lint and typecheck on every PR
- Pin Node version to 20 via `.nvmrc`
- Document the new branch-protection rules in CONTRIBUTING.md

　

## 🎯 Scope

- CI and repo-policy only — no application code touched

　

## ✅ Test plan

- [ ] CI runs on this PR and both jobs pass
- [ ] Cloning fresh and running `nvm use` picks Node 20
- [ ] `CONTRIBUTING.md` renders correctly on GitHub
````

## Single bug-fix PR

Scenario: a one-commit branch that fixes an off-by-one error in a helper.

````
## 📝 Summary

- Fix off-by-one error in pagination that hid the last record on every page

　

## 🎯 Scope

- Single helper changed; no API contract or schema modified

　

## ✅ Test plan

- [ ] Unit tests pass, including the new regression case
- [ ] Manually paginate a 100-row dataset — last row is visible on the final page
````

## Pure-config / pure-docs PR

Scenario: a branch that only adjusts editor and tooling config — no runtime impact.

````
## 📝 Summary

- Add shared `.editorconfig` so all contributors get consistent indentation
- Enable Prettier's `singleQuote` and `trailingComma: all` to match the existing codebase

　

## 🎯 Scope

- Editor / formatter config only — no source code reformatted in this PR

　

## ✅ Test plan

- [ ] Lint still passes
- [ ] Opening a source file in an EditorConfig-aware editor uses the new defaults
````

Note the Test plan still has actionable items even though nothing executable changed — passive checks are better than omitting the section.

## Broad-change PR using `N/A`

Scenario: a sweeping rename that touches almost every file — no meaningful Scope to narrow.

````
## 📝 Summary

- Rename the `legacy` namespace to `core` across the codebase ahead of the v2 cut

　

## 🎯 Scope

- N/A — broad rename spanning the whole codebase

　

## ✅ Test plan

- [ ] `grep -r legacy src/` returns no results
- [ ] Full test suite passes
- [ ] App boots and renders the dashboard without errors
````

`N/A` with a one-line reason is correct here. Do not omit the Scope section.
