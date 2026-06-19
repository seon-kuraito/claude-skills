# GitHub Pages deployment

Deploy a project to **GitHub Pages** via **GitHub Actions** (the modern publishing source). The bundled templates in `../assets/` mirror the official workflow shapes — keep them in step with the official starters and the pinned action versions.

## Build type

Pick with a single-select `AskUserQuestion`; detect a hint from `package.json` first — a `vite` dependency or a `vite.config.*` → Vite, otherwise static:

| build type | template | structure | upload | `cancel-in-progress` | source |
| --- | --- | --- | --- | --- | --- |
| Static (no build) | `../assets/pages-static.yml` | single job | `path: '.'` (narrow to a subfolder if the site lives in one) | `false` | [GitHub starter](https://github.com/actions/starter-workflows/blob/main/pages/static.yml) |
| Vite SPA | `../assets/pages-vite.yml` | single job (`npm ci` + `npm run build`) | `./dist` | `true` | [Vite official guide](https://vite.dev/guide/static-deploy#github-pages) |

Shared action versions (version tags, not SHA pins): `actions/checkout@v6`, `actions/setup-node@v6`, `actions/configure-pages@v6`, `actions/upload-pages-artifact@v5`, `actions/deploy-pages@v5`. The Vite template runs Node `lts/*`.

## Steps

1. **Add the workflow** — copy the chosen template to `.github/workflows/deploy-pages.yml`.
2. **Enable Pages** — set the publishing source to Actions: `gh api --method POST /repos/<owner>/<repo>/pages -f build_type=workflow` (if Pages already exists, use `--method PUT`).
3. **Commit** on `ci/deploy-github-pages` (hand to ultra-branch-creator) with the fixed message `ci: add github pages deploy workflow` — verbatim; it does *not* go through ultra-commit-creator.

The PR prompt and the Execution gate are handled by the general flow in `SKILL.md`.

## Vite project-page caveat

A project site served at `https://<user>.github.io/<repo>/` needs Vite's `base` set to `/<repo>/` in `vite.config.*`, and client-side routing needs a `404.html` fallback. Surface this to the user — do not silently edit their `vite.config`.

## Version choices

- **Normalized to the newest set.** The GitHub starter and the Vite guide pin different majors; both templates use the newest versions for consistency — so the static template is not verbatim the starter's pins.
- **Version tags, not SHA pins.** The Vite guide SHA-pins (with `# v6` comments); these templates use the matching version tags for readability. Switch to SHA pins for stricter supply-chain hardening.
- **`cancel-in-progress` per source.** Static keeps the starter's `false` (let a production deploy finish); Vite keeps the guide's `true`.
