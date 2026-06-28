# Applying the selection

How each option chosen in *Feature selection* (SKILL.md) is carried out. Read this before running any of it — the GitHub-side steps touch the remote and pass through the SKILL.md *Execution gate*.

The file options land on a dedicated branch; the labels, branch-protection, and deploy-branch options are GitHub-side effects with no commit (the deploy branch forks from `main`, so it carries no new commit of its own).

1. **File options** (`LICENSE`, `.claude/CLAUDE.md`) — if any is selected, create the branch `chore/initial-project-setup` (hand to ultra-branch-creator), then apply each selected one as its own commit, using these **fixed messages verbatim** (they do *not* go through ultra-commit-creator):
   - `LICENSE` → `chore: add <license> LICENSE` (the chosen id, e.g. `chore: add MIT LICENSE`)
   - `.claude/CLAUDE.md` → `chore: add CLAUDE.md`
2. **GitHub labels** — make the repo's labels *exactly* the type set, in two steps:
   - **Delete the defaults first.** A new GitHub repo ships nine default labels — `bug`, `documentation`, `duplicate`, `enhancement`, `good first issue`, `help wanted`, `invalid`, `question`, `wontfix`. Remove each that is present with `gh label delete <name> --yes`. Touch only these defaults — leave any custom labels alone.
   - **Then create the types.** For each entry in `../assets/type-labels.json`, run `gh label create <name> --color <color> --description <description>` (each entry carries `name`, `color`, and `description`); pass `--force` to overwrite a same-named label. This makes no commit.
3. **Branch protection** — apply the standard ruleset to the default branch so `main` requires a PR to merge and blocks deletion + force-push. A GitHub side-effect, no commit.
   - **Precondition (GitHub Free):** rulesets apply only to a **public** repo — a private repo returns `403 Upgrade to Pro`. If the repo has no remote or is private (and not on Pro / Team / Enterprise), explain that and **skip this item** rather than erroring.
   - **Pre-flight (read-only):**

     ```sh
     gh auth status                                          # logged in + repo admin scope
     gh api /repos/<owner>/<repo>/rulesets --jq '.[].name'   # avoid duplicating a ruleset
     ```

   - **Apply** (after the Execution gate). `owner` / `repo` live in the URL, so `../assets/main-protection-ruleset.json` is reused verbatim for any repo:

     ```sh
     gh api --method POST -H "Accept: application/vnd.github+json" \
       /repos/<owner>/<repo>/rulesets \
       --input <skill-dir>/assets/main-protection-ruleset.json
     ```

   - **Verify:**

     ```sh
     gh api /repos/<owner>/<repo>/rules/branches/main --jq '[.[].type]'
     # expect: ["deletion","non_fast_forward","pull_request"]
     ```

   - **Gotchas:**
     - **Solo repo → `required_approving_review_count` must be 0.** You cannot approve your own PR; any higher count deadlocks every PR. The bundled config uses 0 — raise it only for a collaborative repo.
     - **No admin bypass by default.** Rulesets ship with an empty bypass list, so the owner is also forced through PRs on `main` — that is the intent.
     - **`~DEFAULT_BRANCH`** tracks whichever branch is default, so renaming the default branch never breaks the rule.
4. **Deploy branch** — create the chosen branch (`develop` / `preparing`) from `main` and push it to `origin` (see *Deploy branch* in SKILL.md). A GitHub side-effect: needs a remote to push to, makes no commit. If the repo is local-only, explain and skip this item.

   ```sh
   git branch <name> main      # fork from main
   git push -u origin <name>   # push so the deployer can deploy from it
   ```
