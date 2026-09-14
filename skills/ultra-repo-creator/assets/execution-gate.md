
　

---

　

## 🚧 Execution gate

Local steps — `git init`, commits, scaffolding — run freely; they're local and reversible. The **only** gate is the outward-facing one, and it **is** the remote decision:

- **Triggers on** — binding a remote or pushing: `gh repo create`, `git push`, `git remote add`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for the remote decision: confirming creates the public remote at the shown `<account>/<name>` and pushes; changing the account shows the gate again with the selected account; declining keeps the repo local-only.
- **Never bypass** — never reach a remote without passing this gate.

　

---

　
