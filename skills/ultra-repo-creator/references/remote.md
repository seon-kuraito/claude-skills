# Remote

How the *Execution gate* in `SKILL.md` resolves the GitHub account and acts on the push decision. Every template passes through it — blank and framework with the **Remote** menu, a meta repo with its own **Family remote** menu (`meta-repo.md`). The menus and questions named below are in `menus.md`, beside this file; present each as written there.

## Resolving the GitHub account

Settle it right before the gate, in this order, and never build it from the owner directory's name:

1. The request names the account or organization → use it.
2. The request calls for an organization without naming which one → present the **Account** menu, leaving out the personal account.
3. The repo sits in a family's own directory (`~/Developer/<family>/`) → ask the **Family organization** question. That organization is created by hand and may not exist yet.
4. Otherwise → the authenticated account from `gh api user --jq .login`.

The gate shows the full destination, so a wrong default is corrected there instead of discovered after the push.

## Changing the account

On 「換一個帳號」, present the **Account** menu, then show the gate again with the chosen account. When that menu would need more than four options, ask the **Account (free text)** question instead.

## Acting on the answer

- **建立遠端並 push** → ensure the branch is `main` (`git branch -M main`), then:

  ```sh
  gh repo create <account>/<name> --public --source . --remote origin --push
  ```

  Always write the account explicitly: a bare `<name>` creates under the personal account without saying so, which silently sends an org's repo to the wrong home.

  Always **public** for blank and framework — no visibility question (a deliberate personal-fit default; create a private repo by hand if ever needed). The meta-repo template is the exception: it asks for the visibility before its gate (`meta-repo.md`). If `gh` is unavailable, fall back to `git remote add origin <url>` → `git branch -M main` → `git push -u origin main`.
- **先不綁遠端** → stay local-only; stop here (still offer the *Hand-off* in `SKILL.md`).
