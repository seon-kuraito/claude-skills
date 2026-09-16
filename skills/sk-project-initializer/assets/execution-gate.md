
　

---

　

## 🚧 Execution gate

- **Triggers on** — any command that writes to the remote or the repo's settings: `gh label delete`, `gh label create`, the ruleset `gh api --method POST`, `git push`.
- **Stop & show** — surface exactly what will run before running it.
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold the whole selection into one uninterrupted run.

　

---

　
