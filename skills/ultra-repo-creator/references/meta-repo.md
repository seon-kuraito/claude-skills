# Meta Repo template

The **Meta Repo** template (from `ultra-repo-creator`'s *Pick a template* menu) scaffolds a **coordination layer** over several independent sibling repos that share one owner directory. The layer **points at** the siblings (reached as `../<member>`) and holds shared norms; it never holds their files.

Its flow is the **same as the other templates** — build locally, then the same push gate and the same hand-off to the initialize stage. Its scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` is **not** scaffolded here — like every other project it comes from the initialize stage's `LICENSE` option (labels / branch protection also apply there once a remote is bound).

Run four steps in order: **interview → scaffold → workspace → ceremony**.

## 1 · Second-round interview

Gather four things. For each, propose a guess but always let the user confirm or override.

### Family name

A family is a set of repos coordinated by one meta repo. Resolve its name in order:

1. **cwd is `<X>/meta` or `<X>-meta`** → family = `X`; the meta repo is created in the cwd.
2. **else cwd is an owner directory** already holding ≥2 repos → propose that directory's name.
3. **else scan `~/Developer`** for ungrouped repos sharing a leading `<stem>-`; if ≥2 cluster, propose that `<stem>`.
4. **else ask** the user for the family name directly.

### Owner

Ask which account or organization owns the family — always ask here, never fall back to the default. The menu is the 「擁有者」 block in `SKILL.md`'s *Resolving the owner*; present it verbatim from there.

This answer decides the member names through *Family naming* in `SKILL.md`:

- **an organization named the same as the family** → members drop the family name (`<token>`), the layer is `meta`;
- **any other owner** → members keep it (`<family>-<token>`), the layer is `<family>-meta`.

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
- `{{MEMBER_TABLE}}` — a `| repo | what it is | path |` markdown table, one row per member (path `../{{MEMBER_PREFIX}}<token>`), then a final self-row for the layer with path `.`. English in `CLAUDE.md`, Traditional Chinese in `README.md`.
- `{{MEMBER_WORKSPACE_FOLDERS}}` — one `{ "name": "{{MEMBER_PREFIX}}<token>", "path": "./{{MEMBER_PREFIX}}<token>" },` line per member (workspace).

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
