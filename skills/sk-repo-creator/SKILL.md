---
name: sk-repo-creator
description: Bootstraps a new repository. Use whenever creating a project or binding a remote is in play — starting a new project, spinning up a quick local repo, initializing version control, turning a folder into a git repo, creating or binding a GitHub remote, or scaffolding a meta-repo over sibling projects — regardless of exact wording or language. Lean toward consulting it the moment repo creation or remote-binding comes up.
---

# Repo Creator

Bootstrap a new repository — **built locally first, then optionally pushed to a remote**. This is the **create** stage of a two-stage project setup; the **initialize** stage (a separate skill) takes over the optional scaffolding afterwards — see *Hand-off*.

This skill covers only creating the repo. The follow-up once it exists — organizing the working tree into commits / branches / PRs — is handled separately by [sk-branch-creator](../sk-branch-creator/SKILL.md), [sk-commit-creator](../sk-commit-creator/SKILL.md), and [sk-pr-creator](../sk-pr-creator/SKILL.md).

## How it runs

Load on the intent — there is **no "should I use this" pre-gate**; just enter the skill and start with the template menu. From there everything is local and reversible until the very end, so it runs without confirmation. The **only** confirmation is the single *Execution gate* before anything touches a remote. Every menu and plain-text question this skill asks lives in `references/menus.md` — present each as written there.

**Pick a template** — present the **Template** menu, even when one template seems obvious; the user makes the call.

Per-template detail lives in the sections below ([meta-repo](references/meta-repo.md) carries its own reference). From there:

1. **Build it locally** — run the template's local steps (below) without confirmation.
2. **Push decision** — once the project stands up locally, the *Execution gate* asks whether to push it, and to which GitHub account. The owner directory is resolved before building (see *Where the repo lives*); the account is resolved at the gate. Every template passes through it.
3. **Hand off** to the initialize stage — for **all three templates**.

## Where the repo lives

Every repo lands at `~/Developer/<owner>/<repo>`. The root holds owner directories and nothing else. An owner directory is a local grouping only: it says nothing about the GitHub account the repo is pushed to, and the two often carry different names. The account is a separate decision at the *Execution gate*.

- **`<owner>`** — the owner directory the repo sits in. Default to the one named after the local username (`$USER`), so every template lands in `~/Developer/$USER/` unless told otherwise. Use another only when the user names one, or when the meta-repo interview resolves one.
- **`<repo>`** — the repo name, and also the directory name. The two never diverge, so `git clone` drops the directory where it belongs with no rename.
- **A local-only repo still lands under the default owner directory.** A repo without a remote is the common case that later gets one, and it almost always belongs beside the user's other repos. Parking it elsewhere buys a second move for nothing.
- **Placing the directory.** When the working directory already sits under an owner directory, build there. When it sits at the root, it has to move under the resolved owner before the first commit — but say so first, and say where it is going. The user asked for a repo, not for their directory layout to change, and the move pulls the ground out from under the shell they are standing in. Report the new path once it is done, so they can follow it.

**Resolving the owner directory.** When the user names one, use it and ask nothing. When the request names or calls for a GitHub organization instead, the directory is still a local choice: ask the **Owner directory** question. Never build the directory from the organization's name.

A meta repo resolves its directory in its own interview (see [meta-repo](references/meta-repo.md)), which also fixes the member names — the *Family naming* table lives there.

## 🚧 Execution gate

Local steps — `git init`, commits, scaffolding — run freely; they're local and reversible. The **only** gate is the outward-facing one — before creating a remote or pushing (`gh repo create`, `git push`, `git remote add`), render `assets/execution-gate.md` verbatim, resolve the GitHub account, show the exact commands below the table, and present the **Remote** menu. How the account is resolved, how 「換一個帳號」 loops back, and what each answer runs are in [`references/remote.md`](references/remote.md) — read it before the gate. A meta repo pushes the layer and its new members through one gate, with its own menu — see [meta-repo](references/meta-repo.md).

## blank

**Local (no confirmation):**

1. **Guard first.** If the working directory already has files but is *not* a git repo, flag it before writing anything more — don't wait for the user to notice.
2. `git init`.
3. The **initial commit contains a blank `README.md`** (an empty file) **and a standard `.gitignore`** (copied verbatim from `assets/blank/gitignore.txt` — macOS + editor/IDE + log artifacts), fixed message `chore: initialize repository` (verbatim — not via sk-commit-creator). The `.gitignore` is infrastructure rather than your work, so it belongs in the first commit — ignore rules should be in place *before* anything gets tracked.
4. Existing work stays **untracked** until the push decision; don't bundle it into the initial commit unless the user explicitly asks.
5. **Never overwrite a file that is already there.** When a `README.md` already exists, the initial commit still holds an empty one: stage an empty blob under that name and leave the file on disk as it is, so the user's content stays as an uncommitted change.

   ```sh
   empty=$(git hash-object -w --stdin </dev/null)
   git update-index --add --cacheinfo 100644,$empty,README.md
   ```

   Tell the user that `git status` now shows `README.md` as modified, and that discarding that change — `git restore`, `git stash`, `git reset --hard`, or VS Code's Discard Changes — replaces their content with the empty file. An existing `.gitignore` goes into the initial commit as it is, in place of the bundled one.

**Push decision (*Execution gate*)** — run the gate and act on the answer as [remote](references/remote.md) describes: push to the shown `<account>/<name>`, or stay local-only. Either way, continue to the *Hand-off*.

## framework

After 「框架專案 Framework」, pick **which template** — present the **Framework** menu. Only 「Vite + React」 has a fixed procedure; every other framework takes the conversational path. Both paths — the scaffold steps, the initial commit, and the deploy-stage boundary — are in [`references/framework.md`](references/framework.md); read it before building. Then the push decision and the hand-off, as for blank.

## meta-repo

A new family: a coordination layer plus the member repos listed for it, all created new, side by side in one owner directory. Its second-round interview resolves the owner directory, which fixes the member names; one push gate then covers the layer and every member.

**Full procedure — read it before running: [`references/meta-repo.md`](references/meta-repo.md).**

## Hand-off to the initialize stage

Applies to **all three templates** — for a meta repo, to the layer only. Once the repo is built (local, or local + remote), present the **Next step** menu.

- **進入 initialize 階段** → load the initialization skill (e.g. `sk-project-initializer`) if it is available; if it is not present, say so and stop.
- **不進入** → stop here and leave the next move to the user.

The initialize stage holds the optional scaffolding — a blank `.claude/CLAUDE.md`, a `LICENSE`, GitHub labels, and branch protection. `.gitignore` is the create stage's job (blank and meta-repo build it in; framework brings its own). Labels and branch protection need a remote, so they're skipped on a local-only repo. Never auto-enter it — it is always the user's choice.

## Related

- [sk-branch-creator](../sk-branch-creator/SKILL.md) / [sk-commit-creator](../sk-commit-creator/SKILL.md) / [sk-pr-creator](../sk-pr-creator/SKILL.md) — organizing the work that lands after the repo exists.
