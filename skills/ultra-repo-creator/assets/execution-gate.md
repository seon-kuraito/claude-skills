
　

---

　

## 🚧 Execution gate

Local steps — `git init`, commits, scaffolding — run freely; they're local and reversible. The **only** gate is the outward-facing one, and it **is** the remote decision:

- **Triggers on** — binding a remote or pushing: `gh repo create`, `git push`, `git remote add`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; confirming means "create the public remote and push," declining means "stay local-only."
- **Never bypass** — never reach a remote without passing this gate.

　

---

　
