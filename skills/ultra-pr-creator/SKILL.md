---
name: ultra-pr-creator
description: Authors GitHub pull request descriptions and titles. Use whenever a pull request is in play — writing or editing a PR body, running or planning `gh pr create`, opening a branch as a PR, or asked how to phrase one — regardless of exact wording or language. Lean toward consulting it the moment a PR comes up, even when 'PR description' is never said.
---

# Ultra PR Creator

Authors a GitHub pull request body in a fixed three-section format, populated from the branch's commits and diff against its base.

## Quick start

Always author the PR body into a temporary staging file (e.g. `/tmp/pr-<branch>.md`), passed to `gh pr create --body-file` — never print the full body into the terminal. The file follows the template bundled at `assets/pr-body.md.tmpl`.

Four things to notice:

1. Each H2 is prefixed with an emoji: 📝 Summary, 🎯 Scope, ✅ Test plan.
2. A single full-width space `　` (U+3000) on its own line separates each section — renders as visual breathing room on GitHub, unlike an empty line which collapses.
3. The file holds the raw markdown body — no outer code fence. The user reviews the PR by opening the file, not by reading it in the terminal.
4. The body ends with the attribution footer `🤖 Generated with [Claude Code](https://claude.com/claude-code)`, set off from the Test plan by a single blank line (not a `　` spacer).

For per-section guidance (what belongs in each, ✅/❌ bullets, `N/A` handling) see `references/sections.md`. For full canonical PR examples see `references/examples.md`.

## PR title

The PR title is the branch name, verbatim — e.g. branch `chore/initial-project-setup` → title `chore/initial-project-setup`. Do not compose an imperative sentence for the title; branch names follow [ultra-branch-creator](../ultra-branch-creator/SKILL.md), so title quality is already enforced upstream.

## Assignees and labels

On `gh pr create`, default to two flags:

- **`--assignee @me`** — self-assign every PR (resolves to the repo owner, `seon-kuraito`), so open PRs are easy to track.
- **`--label <type>`** — tag the PR with its type, taken verbatim from the branch prefix (`feat/add-x` → `feat`). The repo carries one label per Conventional Commits type — the same vocabulary as [ultra-branch-creator](../ultra-branch-creator/SKILL.md) and [ultra-commit-creator](../ultra-commit-creator/SKILL.md): `feat` `fix` `improve` `perf` `refactor` `style` `test` `docs` `build` `ci` `chore` (lowercase, matching the branch / commit type).

Both are behavior-affecting — include them in the Execution gate preview. `--label` only adds an already-existing label; the eleven type labels are set up in this repo, so for a *different* repo that lacks them, drop `--label` rather than letting the command error.

## The `gh pr create` command

Push the branch, then create the PR. Title is the branch name, body is the file you wrote, plus the two default flags:

```sh
git push -u origin <branch>
gh pr create --base main --head <branch> \
  --title "<branch>" --body-file <body-file> \
  --assignee @me --label <type>
```

`<type>` is the branch prefix (`feat/add-x` → `feat`). Fill every placeholder in and show this exact command at the Execution gate before running it.

## 🚧 Execution gate

- **Triggers on** — any `gh` command (`pr create`, `pr edit`, `pr merge`, `pr close`, …) or the post-merge remote-branch prune (`git push origin --delete`).
- **Stop & show** — surface the title, the body as a clickable editor link (e.g. `[/tmp/pr-<branch>.md](vscode://file/tmp/pr-<branch>.md)`, opened in the editor to review rather than pasted inline), and any behavior-affecting flags (merge method, `--delete-branch`, `--assignee`, `--label`). Present the block as a callout — above and below it, place a `---` rule, each padded by a full-width `　` spacer line on its inner side only (the side facing the block; the same `　` used between PR body sections), with blank lines between every line so `　` + `---` doesn't parse as a setext heading.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold creation and merging into a single uninterrupted step.

## Merging

Default to `--merge` without `--delete-branch` (`gh pr merge <n> --merge`): it creates a merge commit and preserves the branch's individual commits, keeping a deliberately-organized history intact on the base branch — and leaves the local branch in place as a historical label (this user keeps merged branch labels locally). After merging, run the default cleanup: prune the now-stale remote branch and delete the temp body file (see the points below).

- **Do not `--squash`** a branch whose commits were intentionally curated — squashing collapses them into one and discards that structure. Reserve `--squash` for genuinely messy WIP branches where a single clean commit is the goal.
- `--rebase` replays the commits onto the base without a merge commit, but loses the "this was one PR" grouping.
- **Keep the local branch, prune the remote.** Don't pass `--delete-branch` — it removes the local branch too, and this user keeps merged branch labels. Instead, after every merge, delete only the *remote* branch by default: `git push origin --delete <branch>`. This clears the stale remote PR branch while the local label stays — a standard post-merge step, not an optional afterthought (show it at the Execution gate like any remote-touching command).
- **Delete the temp body file.** Once the merge is confirmed, remove the staging file written for `--body-file` (e.g. `rm /tmp/pr-<branch>.md`). Keep it while the PR is open — a `gh pr edit --body-file` may still need it — and delete it only after merge.

## Populating from the branch

Before drafting, read:

1. `git log <base>..HEAD --oneline` — the commits on the branch
2. `git diff <base>...HEAD --stat` — files changed and rough size
3. Specific file contents for any commit whose subject is not self-explanatory

Then map the commits into Summary bullets — **at least one bullet per commit**: the commit count is the floor, never fewer. Each bullet corresponds to a commit, or to one distinct change within it — a commit that bundled several changes expands into several bullets, so the bullet count is `≥` the number of commits. Write each bullet a notch more descriptively than its commit subject: clear enough that a reviewer grasps the change without opening the commit, but no more. This assumes a curated branch where every commit is one real change (this family's commits already are); squash a fixup-heavy WIP branch first (see *Merging*), then the floor follows the squashed commits.

Default base branch: `main`. If the repo uses `master` / `develop` / a feature trunk, infer from `git remote show origin` or ask the user once.

## Test precondition

Before the Execution gate, the Test plan must be **verified, not just asserted** — run the change's relevant automated checks and only reach the gate once they pass.

1. **Find what changed has logic.** From `git diff <base>...HEAD`, identify components with **logic** changes, not docs-only. In `claude-skills` that means a skill whose `SKILL.md` / scripts / `evals/` / references / assets changed — a README-only change is docs and needs no test. (In another repo, the equivalent is whatever automated checks cover the changed code.)
2. **Fold their checks into the Test plan.** Add each such component's deterministic checks (e.g. `skills/<name>/evals/check-*.py`) as Test plan items, alongside the change-specific items you write anyway.
3. **Run the runnable items.** Execute every Test plan item that runs without the user — the check scripts and any command-style items. Items only the user can confirm (e.g. "open the app, confirm X") are skipped and stay `[ ]`.
4. **Block on failure.** If anything fails, **stop — do not open the PR.** Surface the failure; it must be resolved (fix the code or correct the test) before the precondition passes, then re-run. This is a gate, not a place to wave a red check through — and not a debugging loop the skill owns: fixing is ordinary work that happens because the gate blocks.
5. **Tick what passed.** Mark verified items `[x]`; leave user-only items `[ ]`.

**Scope — deterministic only.** Run the token-free `check-*.py` scripts and runnable Test plan items; do **not** auto-run an LLM eval loop — its token cost is why it stays opt-in under [ultra-skill-author](../ultra-skill-author/SKILL.md). A change with no relevant automated checks (e.g. a pure-docs PR) has nothing to run — go straight to the gate.

## Conventions

- **English only — the entire body.** Every section and every bullet is English, regardless of the language of the conversation, the branch, the commits, or the issue it closes. PR descriptions live alongside commits in tools (changelog generators, release-note writers, AI summarizers) that assume English; a single non-English bullet breaks them.
- **Body in a file, not the terminal.** Author the body into a file for `--body-file` and never print the full body into the terminal — show only its path, as a clickable editor link (`vscode://file/<abs-path>`) the user can open. The user reviews and edits in the file (the same principle as ultra-skill-author: don't flood the terminal with full content). The file holds raw markdown with no outer code fence.
- **Full-width spacer line.** Before each heading that has content above it, insert a three-line spacer: a blank line, a line containing a single `　` (U+3000), then a blank line. Renders as vertical breathing room on GitHub; a lone blank line collapses too tightly.
- **Always three sections.** Do not omit Scope or Test plan even for tiny PRs — use `- N/A — <reason>` if truly nothing to say. The shape of the PR should be predictable.
- **No nesting.** Top-level bullets only. If you reach for sub-bullets, the bullet is doing too much — split it.

## Anti-patterns

Reject and rewrite. Each pattern, then why it fails:

- Multi-paragraph prose body — defeats the bullet format; reviewers scan, they don't read.
- Missing Test plan — leaves the reviewer with no entry point for verification. Even `[ ] Type-check passes` is better than nothing.
- Headers without the emoji decoration — the emojis are part of the template's visual rhythm; omitting them produces an off-template PR.
- Restating the PR title in Summary's first bullet — the title is already on the PR; don't waste a bullet.
- Fewer Summary bullets than commits — collapsing commits below the commit count; the floor is one bullet per commit (see *Populating from the branch*).
- Imperative-sentence PR titles (`chore: set up project scaffolding`) — the title is the branch name verbatim; see *PR title*.
- Squashing a branch with deliberately-organized commits — collapses the curated history into one; default to `--merge` (see *Merging*).
- `This PR …` / `We now …` lead-ins — start each bullet with the verb.
- Printing the full PR body into the terminal — write it to a file and show only the path; a full dump floods the terminal and buries the decisions (see Conventions).
- Writing prose into Scope explaining the codebase — Scope is boundary-setting, not architecture explanation.

## References

- `references/sections.md` — per-section deep guidance (Summary / Scope / Test plan)
- `references/examples.md` — full PR body examples

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) — authors the branch name, which doubles as the PR title.
- [ultra-commit-creator](../ultra-commit-creator/SKILL.md) — authors per-commit messages in imperative-mood, single-sentence style.
