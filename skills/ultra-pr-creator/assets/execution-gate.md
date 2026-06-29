---
　
## 🚧 Execution gate

- **Triggers on** — any `gh` command (`pr create`, `pr edit`, `pr merge`, `pr close`, …) or the post-merge remote-branch prune (`git push origin --delete`).
- **Stop & show** — surface the title, the body as a clickable editor link (e.g. `[/tmp/pr-<branch>.md](vscode://file/tmp/pr-<branch>.md)`, opened in the editor to review rather than pasted inline), and any behavior-affecting flags (merge method, `--delete-branch`, `--assignee`, `--label`).
- **Confirm** — wait for explicit confirmation; proceed only after.
- **Never chain** — don't fold creation and merging into a single uninterrupted step.
　
---
