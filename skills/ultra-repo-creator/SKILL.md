---
name: ultra-repo-creator
description: Bootstraps a new repository. Use whenever creating a project or binding a remote is in play — starting a new project, spinning up a quick local repo, initializing version control, turning a folder into a git repo, creating or binding a GitHub remote, or scaffolding a meta-repo over sibling projects — regardless of exact wording or language. Lean toward consulting it the moment repo creation or remote-binding comes up.
---

# Ultra Repo Creator

Bootstrap a new repository — **built locally first, then optionally pushed to a remote**. This is the **create** stage of a two-stage project setup; the **initialize** stage (a separate skill) takes over the optional scaffolding afterwards — see *Hand-off*.

This skill covers only creating the repo. The follow-up once it exists — organizing the working tree into commits / branches / PRs — is handled separately by [ultra-branch-creator](../ultra-branch-creator/SKILL.md), [ultra-commit-creator](../ultra-commit-creator/SKILL.md), and [ultra-pr-creator](../ultra-pr-creator/SKILL.md).

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

A meta repo resolves its directory in its own interview (see [meta-repo](references/meta-repo.md)).

**Family naming.** A family is a set of repos coordinated by one meta repo. Whether a member carries the family name depends on whether the owner directory already carries it:

| Condition | Members | Meta repo |
|---|---|---|
| `<owner>` == `<family>` | `<token>` | `meta` |
| `<owner>` != `<family>` | `<family>-<token>` | `<family>-meta` |

In the first case the owner directory *is* the family container, so repeating the name inside every member buys nothing. In the second, one owner holds several families — the family name has to live in the repo name, or two families both claim `meta`.

## 🚧 Execution gate

Local steps — `git init`, commits, scaffolding — run freely; they're local and reversible. The **only** gate is the outward-facing one — before creating a remote or pushing (`gh repo create`, `git push`, `git remote add`), render `assets/execution-gate.md` (the framed gate), then present the **Remote** menu and act on the answer.

**Resolving the GitHub account.** Settle it right before the gate, in this order, and never build it from the owner directory's name:

1. The request names the account or organization → use it.
2. The request calls for an organization without naming which one → present the **Account** menu, leaving out the personal account.
3. The repo sits in a family's own directory (`~/Developer/<family>/`) → ask the **Family organization** question. That organization is created by hand and may not exist yet.
4. Otherwise → the authenticated account from `gh api user --jq .login`.

The gate shows the full destination, so a wrong default is corrected there instead of discovered after the push.

On 「換一個帳號」, present the **Account** menu, then show the gate again with the chosen account.

When the account menu would need more than four options, ask the **Account (free text)** question instead.

A meta repo pushes the layer and its new members through one gate, with its own menu — see [meta-repo](references/meta-repo.md).

## blank

**Local (no confirmation):**

1. **Guard first.** If the working directory already has files but is *not* a git repo, flag it before writing anything more — don't wait for the user to notice.
2. `git init`.
3. The **initial commit contains a blank `README.md`** (an empty file) **and a standard `.gitignore`** (copied verbatim from `assets/blank/gitignore.txt` — macOS + editor/IDE + log artifacts), fixed message `chore: initialize repository` (verbatim — not via ultra-commit-creator). The `.gitignore` is infrastructure rather than your work, so it belongs in the first commit — ignore rules should be in place *before* anything gets tracked.
4. Existing work stays **untracked** until the push decision; don't bundle it into the initial commit unless the user explicitly asks.

**Push decision (*Execution gate*)** — run the gate above, then:

- **建立遠端並 push** → ensure the branch is `main` (`git branch -M main`), then:

  ```sh
  gh repo create <account>/<name> --public --source . --remote origin --push
  ```

  Always write the account explicitly: a bare `<name>` creates under the personal account without saying so, which silently sends an org's repo to the wrong home.

  Always **public** for blank and framework — no visibility question (a deliberate personal-fit default; create a private repo by hand if ever needed). The meta-repo template is the exception: it asks for the visibility before its gate (see [meta-repo](references/meta-repo.md)). If `gh` is unavailable, fall back to `git remote add origin <url>` → `git branch -M main` → `git push -u origin main`.
- **先不綁遠端** → stay local-only; stop here (still offer the *Hand-off*).

## framework

After 「框架專案 Framework」, pick **which template** — present the **Framework** menu.

**Vite + React — local (no confirmation):**

1. **Scaffold.** From the parent directory: `npm create "vite@~9.1" <name> -- --template react-compiler-ts --eslint` — Vite's React Compiler + TypeScript starter (minor pinned, patch floats). `--eslint` selects ESLint over create-vite's default linter (Oxlint); it is **required, not optional** — a non-interactive (no-TTY) run silently takes the default, so the linter prompt never appears to be answered. It creates `<name>/` with its own `.gitignore`.
2. **Install.** `cd <name>`, then `npm install` — `npm create vite` produces no lockfile, so this generates `package-lock.json` (`node_modules` is already gitignored). Commit the lockfile so a later `npm ci` (the standard CI / deploy install) has one to work from.
3. **Initial commit.** `git init`, then commit the whole scaffold — **including `package-lock.json`** — as one commit, fixed message `chore: scaffold vite react app` (verbatim — not via ultra-commit-creator). `npm create vite` does not init git, so this `git init` is load-bearing.
4. **Push decision (*Execution gate*)** — same as blank.
5. **Hand off** to the initialize stage.

Deploy-time concerns — Vite's `base` path and a routing `404.html` — are **not** set here; they belong to the deploy stage ([ultra-project-deployer](../ultra-project-deployer/SKILL.md)'s Vite caveat).

**Conversational — local (no confirmation):**

1. Ask which framework / template the user wants.
2. Run its own init locally, commit as you go. Framework scaffolds normally generate their own `.gitignore`; only if one didn't, offer the standard `assets/blank/gitignore.txt`.
3. **Push decision (*Execution gate*)** — same as blank.
4. **Hand off** to the initialize stage.

## meta-repo

A new family: a coordination layer plus the member repos listed for it, all created new, side by side in one owner directory. Built locally — the layer with its own scaffold, each member the way *blank* builds a repo — then through one push gate that covers the layer and every member, and a hand-off for the layer only. Its second-round interview resolves the owner directory, which fixes the member names through the *Family naming* table above; the GitHub account waits for the gate like every other template. The layer's scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` comes from the initialize stage's `LICENSE` option like every other project, and labels / branch protection apply there once a remote is bound. Bringing existing projects into a family is a migration, not part of this skill.

**Full procedure — read it before running: [`references/meta-repo.md`](references/meta-repo.md).**

## Hand-off to the initialize stage

Applies to **all three templates** — for a meta repo, to the layer only. Once the repo is built (local, or local + remote), present the **Next step** menu.

- **進入 initialize 階段** → load the initialization skill (e.g. `ultra-project-initializer`) if it is available; if it is not present, say so and stop.
- **不進入** → stop here and leave the next move to the user.

The initialize stage holds the optional scaffolding — a blank `.claude/CLAUDE.md`, a `LICENSE`, GitHub labels, and branch protection. `.gitignore` is no longer one of them: the create stage now lays a standard one (blank and meta-repo build it in; framework brings its own). Labels and branch protection need a remote, so they're skipped on a local-only repo. Never auto-enter it — it is always the user's choice.

## Related

- [ultra-branch-creator](../ultra-branch-creator/SKILL.md) / [ultra-commit-creator](../ultra-commit-creator/SKILL.md) / [ultra-pr-creator](../ultra-pr-creator/SKILL.md) — organizing the work that lands after the repo exists.
