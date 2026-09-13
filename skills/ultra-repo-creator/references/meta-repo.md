# Meta Repo template

The **Meta Repo** template (from `ultra-repo-creator`'s *Pick a template* menu) scaffolds a **coordination layer** over several independent sibling repos that share one owner directory. The layer **points at** the siblings (reached as `../<member>`) and holds shared norms; it never holds their files.

Its flow is the **same as the other templates** — build locally, then the same push gate and the same hand-off to the initialize stage. Its scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` is **not** scaffolded here — like every other project it comes from the initialize stage's `LICENSE` option (labels / branch protection also apply there once a remote is bound).

Run four steps in order: **interview → scaffold → workspace → ceremony**.

## 1 · Second-round interview

Gather four things. Never guess the family name or the owner — take each from the request, or ask. Judge from the whole `~/Developer` tree, never from the cwd: the answer must not change with the project the session happened to start in.

### Family name

A family is a set of repos coordinated by one meta repo. Take its name from the request. When the request names none, ask — present this menu verbatim:

```
single-select · header: 「家族名稱」
question: 「這個家族要叫什麼名稱？」
options:
  · 「放在 <user> 底下」 — 「owner 先定為 <user>，再輸入家族名稱。」
  · 「自行輸入」 — 「先輸入家族名稱，owner 下一步再決定。」
[Rule, not copy] <user> is the local username (`$USER`). When the request already names or describes the owner (see *Owner*), skip the menu and ask for the name in plain text — the first option would contradict that owner. Either way the name is what the user types — never propose one from the cwd, directory names, or repo prefixes.
```

**Refuse a duplicate family.** Before going further, look through `~/Developer` for a meta repo this family already has — `<family>-meta` under any owner directory, or `meta` inside `~/Developer/<family>/`. If one exists, stop and say where it is: a new meta repo is the root of a new family, never a second layer over an existing one.

### Owner

Unless the request names or describes the owner, it is one of exactly two directories. Other owner directories are never candidates — a new meta repo roots a new family, so it never sits under another family's owner.

A described owner (for example "my personal account") resolves to the owner directory that already holds this family's repos — `<family>-<token>` repos under it, or `~/Developer/<family>/` itself. When no directory or several directories hold them, ask for the owner in plain text. Resolve it from `~/Developer` alone; do not call `gh` to interpret the description.

- **`<family>`** — the family's own directory. Members drop the family name (`<token>`), and the layer is `meta`.
- **`<user>`** — the default directory named after the local username (`$USER`), shared by several families. Members keep the family name (`<family>-<token>`), and the layer is `<family>-meta`.

Present this menu verbatim:

```
single-select · header: 「擁有者」
question: 「這個家族要放在哪一個 owner 底下？」
options:
  · 「<family>」 — 「建在 <family> 底下，本機路徑是 ~/Developer/<family>/meta。」
  · 「<user>」 — 「建在 <user> 底下，本機路徑是 ~/Developer/<user>/<family>-meta。」
[Rule, not copy] both paths follow *Family naming* in `SKILL.md`.
```

The interview works with local directories only. A family's own GitHub organization is created by hand and may carry a different name from its directory — the skill never looks it up or creates it; the push gate asks for it.

Resolving the owner here rather than at the push gate is load-bearing: the names go into the scaffold and the first commit, and both happen before the gate.

### Family type

This switches the framing of the generated `CLAUDE.md` / `README.md`. Present this menu verbatim:

```
single-select · header: 「家族類型」
question: 「這個家族是哪一種？」
options:
  · 「同型家族 Typed」 — 「每個成員都是同一種東西，對應同一種角色；產出的成員表是整齊的 1:1 對應。」
  · 「混合家族 Mixed」 — 「成員類型不同，靠擁有者或主題放在同一層協調；產出的說明不假設成員對稱。」
[Rule, not copy] the answer decides which block survives in the templates — keep the chosen one, delete the markers and the other block.
```

### Members

Seed the list from the scan, then let the user edit it:

- **detected** — repos already sitting in the owner directory.
- **adoptable** — ungrouped repos the user points at, recorded as *planned* members. **Do not rename or move them now** (see *Scope*) — just record the planned name + current path.
- **declared** — purely-future members the user types.

Each member needs a one-line description (it fills the `CLAUDE.md` / `README.md` member tables).

## 2 · Scaffold

Generate these into the meta repo from `assets/meta-repo/`, substituting the interview answers (placeholder legend below the table).

| File | Template | Filled with |
|---|---|---|
| `CLAUDE.md` | `CLAUDE.md.tmpl` | family · owner · family-type block · member table |
| `README.md` | `README.md.tmpl` | same, in Traditional Chinese |
| `.gitignore` | `gitignore.txt` | verbatim |

`CLAUDE.md.tmpl` carries **both** family-type blocks, marked `{{#同型}} … {{/同型}}` and `{{#混合}} … {{/混合}}`: keep the chosen one, delete the markers and the other block.

Placeholders (same set across templates):

- `{{FAMILY}}` — lowercase family name; `{{FAMILY_TITLE}}` — display form for the README heading.
- `{{OWNER}}` — the account or organization resolved in the interview.
- `{{MEMBER_PREFIX}}` — the derived naming switch: **empty** when `{{OWNER}}` equals `{{FAMILY}}`, otherwise `{{FAMILY}}-`. Every member name in the templates is written `{{MEMBER_PREFIX}}<token>`, so one substitution covers both cases.
- `{{MEMBER_TABLE}}` — a `| repo | what it is | path |` markdown table, one row per member sorted by repo name (path `../{{MEMBER_PREFIX}}<token>`), then a final self-row for the layer with path `.`. English in `CLAUDE.md`, Traditional Chinese in `README.md`.
- `{{MEMBER_WORKSPACE_FOLDERS}}` — one `{ "name": "{{MEMBER_PREFIX}}<token>", "path": "./{{MEMBER_PREFIX}}<token>" },` line per member, in the same order as `{{MEMBER_TABLE}}` (workspace).

## 3 · Workspace

The VS Code workspace lists every member as a root, so the whole family opens as one window. It sits in the **owner directory**, beside the members rather than inside the meta repo:

```
~/Developer/{{OWNER}}/{{FAMILY}}.code-workspace
```

Write it from `code-workspace.tmpl`. It is **not version-controlled** — no repo owns the owner directory, and the meta repo cannot track a file above itself. That is the accepted trade: the workspace is local editor state, and it rebuilds from the member table in a minute.

Name this consequence to the user rather than leaving them to find it: the member list now lives in three places — `CLAUDE.md`, `README.md`, and the workspace — and only the first two carry git history. Adding a member means editing all three.

## 4 · Git ceremony

`git init`, write the whole scaffold, and make it **one commit** — no setup branch, no merge (like a framework scaffold's initial commit). The push gate is the generic end-gate every template passes through, applied after; the single commit then pushes cleanly, with nothing having bypassed a PR.

- **One commit** — all scaffold files at once (`README.md`, `CLAUDE.md`, `.gitignore`), message `chore: scaffold {{FAMILY}} coordination layer`. The workspace is not in it — it lives outside the repo.
- **Commit style:** subject-only Conventional Commits — the harness default applies (including the `Co-Authored-By` trailer).

## Scope

The Meta Repo template **creates the coordination layer only**. It does **not**:

- rename or move sibling repos into the owner directory — members are recorded as planned; adoption happens later;
- write any memory cards. The generated `CLAUDE.md` *points at* the operating conventions (reach siblings at `../<member>`) but the template does not execute them.
