# Flows

Both release flows, step by step. `x.y.z` is the version, `<n>` a PR number, `<branch>` a work branch. Every command marked `# gate` writes to the remote and passes the SKILL.md *Execution gate* first.

## Which flow

```sh
git ls-remote --heads origin develop staging 'release/*'
```

- `develop` is listed → the develop flow.
- Otherwise → the main flow. When `staging` is listed, a work branch merges into it before its PR.

## Main flow

### Start a version

```sh
git fetch origin
git branch release/x.y.z origin/main
git push -u origin release/x.y.z          # gate
```

Cut the release branch as the first step of the version, once its content is settled and before any work branch.

### While the version is open

sk-pr-creator carries these out for each work branch; they are listed here so the whole flow reads in one place.

1. Cut the work branch from `main`.
2. When the repo has `staging`, merge the work branch into it and push, then confirm the change in the test environment or the CI run:

   ```sh
   git switch staging
   git merge --no-ff <branch>
   git push origin staging                # gate
   ```

3. Open a PR from the work branch into `release/x.y.z` and merge it with `--merge`. The work branch has then done its job: delete its remote branch and keep the local one.

Rules that hold the flow together:

- Never commit on the release branch directly, and never merge it into `staging`.
- Never open a PR from `staging`, and never merge `staging` into `main`.
- A change on `staging` that will not reach `main` is cleared with a revert of its merge commit: `git revert -m 1 <merge-commit>`.

### Publish

```sh
gh pr list --base release/x.y.z --state merged --json number \
  --jq 'sort_by(.number) | .[] | "- #\(.number)"' > <list-file>
```

Then the release PR, the merge, the Release, and the cleanup — see *The release PR and the Release* below.

## Develop flow

### Start a version

Nothing is cut. Work branches are cut from `develop` and open their PRs into `develop`, merged with `--merge`.

### Publish

```sh
git fetch origin
git branch release/x.y.z origin/develop
git push -u origin release/x.y.z          # gate
git log origin/main..origin/release/x.y.z --merges --first-parent --format=%s \
  | sed -n 's/^Merge pull request #\([0-9][0-9]*\) .*/- #\1/p' | sort -t'#' -k2 -n > <list-file>
```

The release branch is a snapshot: it takes no commit, so nothing has to merge back into `develop` after the release. A fix found before publication goes into `develop` through its own PR, and the release branch is cut again from the new `develop`.

Then the release PR, the merge, the Release, and the cleanup, as below.

## The release PR and the Release

The same in both flows.

`<list-file>` holds the list and nothing else. `<body-file>` holds the list, a blank line, and the attribution footer every PR of this skill family ends with: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

```sh
gh pr create --base main --head release/x.y.z --title "release/x.y.z" \
  --body-file <body-file> --assignee @me --label release                           # gate
gh pr merge <n> --merge                                                             # gate
gh release create vX.Y.Z --target main --title vX.Y.Z --notes-file <list-file>      # gate
git push origin --delete release/x.y.z                                              # gate
git fetch origin
git diff origin/main origin/staging --stat     # main flow with staging; expect no output
git diff origin/main origin/develop --stat     # develop flow; expect no output
```

- `--label release` needs the `release` label on the repo; sk-project-initializer creates it with the type labels. On a repo without it, drop the flag rather than let the command fail.
- Do not pass `--generate-notes`, and do not create an annotated tag first. The Release can be edited afterwards when a version needs more than the list.
- In the develop flow, a file the last diff lists is work that reached `develop` after the release branch was cut. It belongs to the next version; say so instead of treating it as an error.

## A coordination repo

A coordination repo (`meta` / `*-meta`) releases after its members, because its two documents point at theirs. It has no `staging`: it runs the main flow with no test-branch step.

| document | holds |
| --- | --- |
| its release PR | its own list, then one bullet for each member that took part: `- <owner>/<repo>#<n>`, that member's release PR |
| its Release | its own list, then one bullet for each such member: `- [<repo> vX.Y.Z](https://github.com/<owner>/<repo>/releases/tag/vX.Y.Z)` |

One list, with no heading between the two groups. Find the members in the coordination repo's own `CLAUDE.md` or `README.md`, then ask each one whether it took part:

```sh
gh pr list -R <owner>/<repo> --head release/x.y.z --state merged --json number --jq '.[].number'
gh release view vX.Y.Z -R <owner>/<repo> --json url --jq .url
```

A member with no release PR for the version took no part: leave it out. A gap in one member's tags is not a missing release.

## Why the rules are what they are

- **The release branch takes no commit of its own.** A commit made there would reach `main` without passing through the test branch. That is also why a version-number change is a work branch.
- **`--no-ff` into `staging`.** Every work branch leaves exactly one merge commit there, so one revert clears it. Within one version `main` does not move, so from the second work branch on a plain merge would create a merge commit anyway.
- **`--merge` for every PR.** Each commit of a work branch reaches `main` unchanged, and `staging` or `develop` holds the same commits.
- **A list, not prose.** The work-branch PRs already describe the changes; the release PR and the Release only say which ones the version holds.
- **The content check.** A work branch merges into `staging` and into the release branch separately, and two conflict resolutions can differ while the commit lists look the same. Merge commits differ between the branches by design, so compare content, not history.
