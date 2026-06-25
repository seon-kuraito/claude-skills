# Meta Repo template

The **Meta Repo** template (from `ultra-repo-creator`'s *Template dispatch*) scaffolds a **coordination layer** over several independent `<prefix>-*` sibling projects — the pattern behind `claude-meta` (over `claude-*`), `bootcamp-rocket-meta` (over the cohorts), and `personal-meta` (over the personal projects). The layer **points at** the siblings (reached via `../<prefix>-*` relative paths) and holds shared norms; it never holds their files.

Its flow is the **same as the other templates** — build locally, then the same remote gate and the same hand-off to the initialize stage. Its scaffold already includes `.gitignore` and a root `CLAUDE.md`; the `LICENSE` is **not** scaffolded here — like every other project it comes from the initialize stage's `LICENSE` option (labels / branch protection also apply there once a remote is bound).

Run three steps in order: **interview → scaffold → ceremony**.

## 1 · Second-round interview

Gather three things. For each, propose a guess but always let the user confirm or override.

### Family prefix

Resolve in order:

1. **cwd is `<X>-meta`** → prefix = `X` (strip `-meta`); the meta repo is created in the cwd.
2. **else scan `~/Developer`** for ungrouped projects (not already in a `*-meta` family) that share a leading `<prefix>-` stem; if **≥2** cluster, propose that `<prefix>`. The meta repo is created at `~/Developer/<prefix>-meta`.
3. **else ask** the user for the prefix directly.

The meta repo is always named `<prefix>-meta`.

### Family type

Ask which kind it is — this switches the generated `CLAUDE.md` / `README.md` framing:

- **同型家族 (typed family)** — every member is the same *kind* of thing (e.g. `claude-*` extension types, `bootcamp-rocket-*` cohorts). Framing: a clean 1:1 family table, uniform members.
- **混合家族 (mixed family)** — members are different things, united only by owner / theme (e.g. `personal-*`: billing, resume, terminal). Framing: heterogeneous, "don't assume symmetry," an app cluster.

### Members

Seed the list from the scan, then let the user edit it:

- **detected** — existing `<prefix>-*` siblings already in `~/Developer`.
- **adoptable** — ungrouped projects the user points at, recorded as *planned* members (e.g. `billing` → `<prefix>-billing`). **Do not rename or move them now** (see *Scope*) — just record the planned name + current path.
- **declared** — purely-future members the user types.

Each member needs a one-line description (it fills the `CLAUDE.md` / `README.md` member tables).

## 2 · Scaffold

Generate these into the meta repo from `assets/meta-repo/`, substituting the interview answers (placeholder legend below the table).

| File | Template | Filled with |
|---|---|---|
| `CLAUDE.md` | `CLAUDE.md.tmpl` | prefix · family-type block · member table |
| `README.md` | `README.md.tmpl` | same, in Traditional Chinese |
| `.gitignore` | `gitignore` | verbatim |
| `.vscode/{{PREFIX}}-meta.code-workspace` | `code-workspace.tmpl` | member folder list |

`CLAUDE.md.tmpl` carries **both** family-type blocks, marked `{{#同型}} … {{/同型}}` and `{{#混合}} … {{/混合}}`: keep the chosen one, delete the markers and the other block.

Placeholders (same set across templates):

- `{{PREFIX}}` — lowercase family prefix (e.g. `personal`); `{{PREFIX_TITLE}}` — display form for the README heading (e.g. `Personal`).
- `{{MEMBER_TABLE}}` — a `| repo | what it is | path |` markdown table, one row per member (path `../{{PREFIX}}-<token>`), then a final self-row for `{{PREFIX}}-meta` with path `.` — mirrors claude-meta. English in `CLAUDE.md`, Traditional Chinese in `README.md`; member names are `{{PREFIX}}-<token>`.
- `{{MEMBER_WORKSPACE_FOLDERS}}` — one `{ "name": "{{PREFIX}}-<token>", "path": "../../{{PREFIX}}-<token>" },` line per member (workspace).

Notes:

- **The workspace is committed; other `.vscode/` contents stay local** — `.gitignore` uses `.vscode/*` + `!.vscode/*.code-workspace`, so the `{{PREFIX}}-meta.code-workspace` file is part of the committed scaffold while `settings.json` and any other `.vscode/` file (editor settings, an extension's cache) stay untracked.

## 3 · Git ceremony

`git init`, write the whole scaffold, and make it **one commit** — no setup branch, no merge (like a framework scaffold's initial commit). Binding a remote is the generic end-gate every template passes through (the skill's Execution gate), applied after; the single commit then pushes cleanly, with nothing having bypassed a PR.

- **One commit** — all scaffold files at once (`README.md`, `CLAUDE.md`, `.gitignore`, `.vscode/{{PREFIX}}-meta.code-workspace`), message `chore: scaffold {{PREFIX}}-meta coordination layer`.
- **Commit style:** subject-only Conventional Commits — the harness default applies (including the `Co-Authored-By` trailer).

## Scope

The Meta Repo template **creates the coordination layer only**. It does **not**:

- rename or move sibling projects into the family — members are recorded as planned; renaming/adoption happens later;
- write any memory cards. The generated `CLAUDE.md` *points at* the operating conventions (reach siblings at `../<prefix>-*`) but the template does not execute them.
