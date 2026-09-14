---
　
## 🚧 Execution gate

- **Triggers on** — handing `apply.sh` to the user: it deletes the session folders, config entries, and editor state selected in the manifest.
- **Stop & show** — the selected items grouped by project path, the sessions and memory cards that would be lost, the manifest path, and the exact Terminal command.
- **Confirm** — wait for explicit confirmation; only then give the quit-and-run instructions.
- **Never chain** — keep the backup until the user has checked the result; deleting it is a separate step.
　
---
