# Meta Repo template

The **Meta Repo** template (from `ultra-repo-creator`'s *Pick a template* menu) roots a **new family**: a **coordination layer** plus the member repos listed for it, all created new, side by side in one owner directory. The layer **points at** the members (reached as `../<member>`) and holds shared norms; it never holds their files.

Its flow follows the other templates — build locally, then the push gate and the hand-off to the initialize stage — with two differences: the push gate covers the layer and every new member at once, and the hand-off covers the layer only. The layer's scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` is **not** scaffolded here — like every other project it comes from the initialize stage's `LICENSE` option (labels / branch protection also apply there once a remote is bound).

Run five steps in order: **interview → layer → members → workspace → push gate**.

## 1 · Second-round interview

Gather four things, in the order below. Never guess the family name or the owner — take each from the request, or ask. Judge from the whole `~/Developer` tree, never from the cwd: the answer must not change with the project the session happened to start in.

A family is a set of repos coordinated by one meta repo. Choosing this template means rooting a **new** family, so the first question is always its name. Ask the owner after it: the owner menu can then offer the real directory names, with the family name already filled in.

### Family name

Take the name from the request. When the request names none, ask the **Family name** question (`menus.md`, beside this file — every menu and question below is presented as written there).

**Refuse a duplicate family.** Once the name is known, look through `~/Developer` for a meta repo this family already has — `<family>-meta` under any owner directory, or `meta` inside `~/Developer/<family>/`. If one exists, stop and say where it is: a new meta repo is the root of a new family, never a second layer over an existing one.

### Owner

The owner here is a directory under `~/Developer`, never a GitHub account. Unless the request names or describes it, it is one of exactly two directories. Other owner directories are never candidates — a new family never sits under another family's owner directory.

- **`<family>`** — the family's own directory. Members drop the family name (`<token>`), and the layer is `meta`.
- **`<user>`** — the default directory named after the local username (`$USER`), shared by several families. Members keep the family name (`<family>-<token>`), and the layer is `<family>-meta`.

Present the **Owner** menu.

A described owner resolves by what it describes: the personal account ("my personal account") → `<user>`; the family's own organization → `<family>`. When the description fits neither, present the **Owner** menu after all. Resolve it from the description and `~/Developer` alone; do not call `gh` to interpret it.

The interview works with local directories only. The GitHub account is settled at the push gate (see *Resolving the GitHub account* in `SKILL.md`): a family's own organization is created by hand, may carry a different name from its directory, and is asked for there — the skill never looks it up, creates it, or builds it from the directory name.

Resolving the owner directory here rather than at the push gate is load-bearing: the names go into the layer's scaffold, the member repos, and their first commits, and all of that happens before the gate.

### Family type

This switches the framing of the generated `CLAUDE.md` / `README.md`. Present the **Family type** menu.

### Members

Ask for names only. Show `assets/meta-repo/members.md.tmpl` as an `md` code block for the user to copy, edit, and paste back, with `{{MEMBER_PREFIX}}` filled in: its lines read `` `<token>` `` under `<family>` and `` `<family>-<token>` `` (the real family name) under `<user>`. Ask nothing else about the members.

Read everything else from the pasted list:

- **Name** — each line holds one repo name, in the form the block showed. Under `<user>`, a line without the `<family>-` prefix gets it added.
- **Order** — the list order is the member order in every table, in the workspace, and at the push gate.
- **Description** — one line for the `CLAUDE.md` / `README.md` member tables, inferred from the name. List the descriptions in the report after the build, so the user can correct them in the files.

**Refuse a name that already exists.** Before creating anything, check each member path, `~/Developer/<owner>/<name>`. If any exists, stop and name them: every member of a new family is created new, and bringing an existing project into a family is a migration, not a create (see *Scope*).

## 2 · Layer

`git init` the layer, generate these files into it from `assets/meta-repo/`, substituting the interview answers (placeholder legend below the table), and make it **one commit** — no setup branch, no merge.

| File | Template | Filled with |
|---|---|---|
| `CLAUDE.md` | `CLAUDE.md.tmpl` | family · owner · family-type block · member table |
| `README.md` | `README.md.tmpl` | same, in Traditional Chinese |
| `.gitignore` | `gitignore.txt` | verbatim |

`CLAUDE.md.tmpl` carries **both** family-type blocks, marked `{{#同型}} … {{/同型}}` and `{{#混合}} … {{/混合}}`: keep the chosen one, delete the markers and the other block.

Placeholders (same set across templates):

- `{{FAMILY}}` — lowercase family name; `{{FAMILY_TITLE}}` — display form for the README heading.
- `{{OWNER}}` — the owner directory name resolved in the interview: a local folder under `~/Developer`, not a GitHub account. The templates never state which account the members push to; each member's own `origin` records that.
- `{{MEMBER_PREFIX}}` — the derived naming switch: **empty** when `{{OWNER}}` equals `{{FAMILY}}`, otherwise `{{FAMILY}}-`. Every member name in the templates is written `{{MEMBER_PREFIX}}<token>`, so one substitution covers both cases.
- `{{MEMBER_TABLE}}` — a `| repo | what it is | path |` markdown table, one row per member in the member list's order (path `../{{MEMBER_PREFIX}}<token>`), then a final self-row for the layer with path `.`. English in `CLAUDE.md`, Traditional Chinese in `README.md`.
- `{{MEMBER_WORKSPACE_FOLDERS}}` — one `{ "name": "{{MEMBER_PREFIX}}<token>", "path": "./{{MEMBER_PREFIX}}<token>" },` line per member, in the same order as `{{MEMBER_TABLE}}` (workspace).

The commit holds the three files at once, message `chore: scaffold {{FAMILY}} coordination layer`. The workspace is not in it — it lives outside the repo.

## 3 · Members

Create each member from the list, in list order, the way *blank* in `SKILL.md` builds a repo:

1. Create `~/Developer/{{OWNER}}/<name>` and `git init` it.
2. Add an empty `README.md` and a `.gitignore` copied verbatim from `assets/blank/gitignore.txt` — the blank template's file, not the layer's.
3. Commit both as one commit, fixed message `chore: initialize <name> repository` with the member's repo name for `<name>` (verbatim — not via ultra-commit-creator).

Each member is its own repo with its own history; the layer never tracks their files.

**Commit style** for the layer and the members: subject-only Conventional Commits — the harness default applies (including the `Co-Authored-By` trailer).

## 4 · Workspace

The VS Code workspace lists every member as a root, so the whole family opens as one window. It sits in the **owner directory**, beside the members rather than inside the meta repo:

```
~/Developer/{{OWNER}}/{{FAMILY}}.code-workspace
```

Write it from `code-workspace.tmpl`. It is **not version-controlled** — no repo owns the owner directory, and the meta repo cannot track a file above itself. That is the accepted trade: the workspace is local editor state, and it rebuilds from the member table in a minute.

Name this consequence to the user rather than leaving them to find it: the member list now lives in three places — `CLAUDE.md`, `README.md`, and the workspace — and only the first two carry git history. Adding a member means editing all three.

## 5 · Push gate

Every commit lands directly on each repo's `main` before the gate, so nothing bypasses a PR. Resolve the GitHub account once, as *Resolving the GitHub account* in `SKILL.md` describes; it applies to the layer and every member.

Unlike blank and framework, which are always public, a family's visibility is a choice. Settle it before the gate with the **Visibility** menu — one answer applies to the layer and every member.

Then render `assets/execution-gate.md` with each `<account>/<name>` and its command, and present the **Family remote** menu in place of the single-repo **Remote** menu.

- **建立遠端並 push** → for each repo in that order: `git -C <path> branch -M main`, then `gh repo create <account>/<name> --<visibility> --source <path> --remote origin --push`. Stop at the first failure and report which repos now have a remote and which stayed local.
- **先不綁遠端** → every repo stays local-only.

Then hand off the layer only: present the *Hand-off* menu once, for the meta repo. A member enters the initialize stage later, on its own.

## Scope

The Meta Repo template **creates a new family**: the coordination layer and the member repos listed for it. It does **not**:

- bring existing projects into a family — that is a migration, not a create. Move a folder with `ultra-project-migrator`, then add it to the member tables and the workspace by hand;
- write any memory cards. The generated `CLAUDE.md` *points at* the operating conventions (reach siblings at `../<member>`) but the template does not execute them.
