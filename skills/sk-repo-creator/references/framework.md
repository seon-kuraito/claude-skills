# Framework template

The **Framework** template (from `SKILL.md`'s *Pick a template* menu) scaffolds a framework project. After 「框架專案 Framework」, `SKILL.md` presents the **Framework** menu (`menus.md`): only 「Vite + React」 has a fixed procedure; every other framework takes the conversational path. As a framework gets its own procedure, add it as a section here and as an option in that menu.

## Vite + React — local (no confirmation)

1. **Scaffold.** From the parent directory: `npm create "vite@~9.1" <name> -- --template react-compiler-ts --eslint` — Vite's React Compiler + TypeScript starter (minor pinned, patch floats). `--eslint` selects ESLint over create-vite's default linter (Oxlint); it is **required, not optional** — a non-interactive (no-TTY) run silently takes the default, so the linter prompt never appears to be answered. It creates `<name>/` with its own `.gitignore`.
2. **Install.** `cd <name>`, then `npm install` — `npm create vite` produces no lockfile, so this generates `package-lock.json` (`node_modules` is already gitignored). Commit the lockfile so a later `npm ci` (the standard CI / deploy install) has one to work from.
3. **Initial commit.** `git init`, then commit the whole scaffold — **including `package-lock.json`** — as one commit, fixed message `chore: scaffold vite react app` (verbatim — not via sk-commit-creator). `npm create vite` does not init git, so this `git init` is load-bearing.
4. **Push decision (*Execution gate*)** — same as blank (`remote.md`).
5. **Hand off** to the initialize stage (`SKILL.md`).

Deploy-time concerns — Vite's `base` path and a routing `404.html` — are **not** set here; they belong to the deploy stage ([sk-project-deployer](../../sk-project-deployer/SKILL.md)'s Vite caveat).

## Conversational — local (no confirmation)

1. Ask which framework / template the user wants.
2. Run its own init locally, commit as you go. Framework scaffolds normally generate their own `.gitignore`; only if one didn't, offer the standard `assets/blank/gitignore.txt`.
3. **Push decision (*Execution gate*)** — same as blank (`remote.md`).
4. **Hand off** to the initialize stage (`SKILL.md`).
