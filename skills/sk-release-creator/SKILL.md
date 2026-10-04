---
name: sk-release-creator
description: Runs a project's release flow on GitHub — starts a version, then publishes it through a release pull request, a version tag, and a GitHub Release. Use whenever a version or a release is in play — picking the next version number, cutting a release branch, opening or merging a release PR, tagging a version, publishing a GitHub Release, or asking how work reaches main in a repo that has a release flow — regardless of exact wording or language. Also the stage sk-project-initializer hands off to when a project opts into a release flow. Not an ordinary work-branch PR (that is sk-pr-creator), and not a deployment (that is sk-project-deployer).
---

# Release Creator

Run a project's release flow: start a version, let its work collect, and publish it into `main` with a release PR, a version tag, and a GitHub Release. Loading this skill means the project has a release flow — never ask whether it needs one; that question belongs to [sk-project-initializer](../sk-project-initializer/SKILL.md).

## Stage & entry

An **insertable stage**, entered at two moments: when a version starts, and when it is published. It works on one repository at a time.

**Entry precondition:** a GitHub remote — the release PR, the tag, and the Release live there. With no remote, point the user to [sk-repo-creator](../sk-repo-creator/SKILL.md) and stop.

Every menu and plain-text question this skill asks lives in `references/menus.md` — present each as written there.

## The two flows

Read the flow from the repo's branches (`git ls-remote --heads origin`); nothing is stored anywhere else:

| | Main flow | Develop flow |
| --- | --- | --- |
| The repo has | no `develop` | `develop` |
| `release/x.y.z` is cut | from `main`, when the version starts | from `develop`, when the version is published |
| A work branch | is cut from `main`, merges into `staging` first when the repo has one, then opens a PR into the release branch | is cut from `develop` and opens a PR into `develop` |
| The release branch receives | the work-branch PRs, and never a commit of its own | nothing — it is a snapshot of `develop` |

In both flows the release branch reaches `main` through one release PR, and the version is tagged and released from `main`. The commands for every step, and the reason behind each rule, are in `references/flows.md` — read it before running either flow.

The work-branch steps — the merge into `staging`, the PR base — are carried out by [sk-pr-creator](../sk-pr-creator/SKILL.md). This skill owns the start of a version and its publication.

## Start a version

1. Ask the **Version number** question. Offer the number `references/version-numbers.md` gives for the planned content, and take whatever the user answers.
2. **Main flow** — create `release/x.y.z` from `main`, then push it. Creating the branch is local and runs at once; the push waits at the execution gate. The branch comes before any work branch of the version, because every finished work branch opens its PR into it.
3. **Develop flow** — cut nothing. Say that work goes into `develop` and that the release branch is cut at publication.

In a repo with a version file (`package.json` and the like), the change of the number is a work branch of its own and the first change of the version — never a commit on the release branch.

## Publish a version

When the user says the version is complete:

1. **Develop flow only** — create `release/x.y.z` from `develop` and push it. It takes no commit.
2. **Build the list** — one bullet for each work-branch PR of the version: `- #<n>`. The list is the whole body of the release PR and the whole of the Release notes: no heading, no section, no written summary. A reader opens a PR for the details.
3. **Open the release PR** — title = the branch name, base `main`, label `release`, body = the list. It does not use sk-pr-creator's three-section body or its body check.
4. **Merge it** with a merge commit: `gh pr merge <n> --merge`.
5. **Tag and release** with one command: `gh release create vX.Y.Z --target main --title vX.Y.Z --notes-file <list-file>`. The tag is the lightweight tag this command makes.
6. **Delete the remote release branch**, and keep the local one.
7. **Compare the branches** — `git diff origin/main origin/staging --stat` in the main flow with `staging`, `git diff origin/main origin/develop --stat` in the develop flow. No output means the two hold the same content; report every file it lists.

## A coordination repo and its members

A family of repos that share a version releases its members first and its coordination repo (`meta` / `*-meta`) last. The coordination repo's two lists then carry one more bullet for each member that took part in the version: a reference to that member's release PR in the release PR, and a link to that member's Release in the Release notes. `references/flows.md` has the exact forms and the lookup commands.

## Execution gate

Before any command that writes to the remote — `git push`, `gh pr create`, `gh pr merge`, `gh release create`, `git push origin --delete` — stop at an execution gate, show the exact commands, and wait for an explicit go. Each step of *Publish a version* passes through its own gate: a go for the release PR is not a go for the merge, the Release, or the branch delete.

## References

- `references/menus.md` — the version-number question, with the menu contract at its top
- `references/flows.md` — both flows step by step, the list commands, the coordination-repo forms, and the reasons
- `references/version-numbers.md` — the default numbering: which event earns which number

## Related

- [sk-project-initializer](../sk-project-initializer/SKILL.md) — asks whether a project needs a release flow, and hands off here.
- [sk-pr-creator](../sk-pr-creator/SKILL.md) — every work-branch PR, with the base and the `staging` merge this flow needs.
- [sk-branch-creator](../sk-branch-creator/SKILL.md) — names the work branches; `release/x.y.z` is the one branch name this skill sets itself.
- [sk-project-deployer](../sk-project-deployer/SKILL.md) — deploys from `staging` or `develop`; in a repo with this flow its workflow lands as an ordinary change.
