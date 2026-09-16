# Environments

Environment-conditional execution rules. The body's flow assumes Claude Code; this file describes how to adapt when the host is something else, plus the path-handling rules for modifying an installed (often read-only) skill.

## Identifying the environment

Pick the matching section based on observable signals:

| Environment | Shell? | Subagents? | Heuristic |
| --- | --- | --- | --- |
| **Claude Code** | yes | yes | Default desktop / CLI session, has `Bash`. |
| **Claude.ai** | no | no | Web app, no `Bash` shell, no subagent spawning. |
| **Cowork** | yes | yes | Has a filesystem and subagents; no browser. |

Only Step 4 depends on this. The structure and script tiers need a shell to run `scripts/run-checks.sh`; the model tier needs subagents.

## Claude Code (default)

Everything runs as written. `scripts/run-checks.sh` runs on the system shell; the Python scripts declare their dependencies inline (PEP 723) and run through `uv run`.

## Claude.ai (no shell, no subagents)

The core flow — interview, draft, review — is unchanged. Verification cannot run here: there is no shell for the deterministic tiers and no subagent for the model tier.

Say so plainly rather than skipping it silently: the skill is unverified until someone runs `scripts/run-checks.sh` and the `model.json` cases in an environment that has both. Never hand-simulate a tier and report it as passed.

Packaging works anywhere with Python and a filesystem; the user can download the resulting `.skill` file.

## Cowork (shell and subagents, no browser)

All three tiers run as written — nothing in verification needs a browser. Packaging works.

If subagent timeouts are severe, run the model cases one at a time rather than together.

## Packaging (`O1`)

Run the packaging script only if the host has the `present_files` tool — that's how the user receives `.skill` files. Otherwise skip.

```bash
uv run --with pyyaml python -m scripts.package_skill <path/to/skill-folder>
```

After packaging, tell the user the resulting `.skill` file path so they can install it.

## Modifying an existing skill — path handling (`O2`)

When the user is updating an installed skill (rather than creating a new one), the install path may be read-only. Workflow:

1. **Preserve the original name.** Note the directory name and the `name` field in the frontmatter — keep both unchanged. If the installed skill is `research-helper`, the output is `research-helper.skill` (not `research-helper-v2`).
2. **Copy to a writable location before editing.** Copy to `/tmp/<skill-name>/` and edit there.
3. **Package from the copy.** If packaging manually (without `package_skill.py`), stage the package in `/tmp/` first, then move it to the output directory — direct writes to the install path may fail due to permissions.

A repo skill is the opposite case: the repo is the source of truth and `~/.claude/skills/` only holds a symlink, so edit the repo copy directly.
