# Environments

Environment-conditional execution rules. The body's flow assumes Claude Code; this file describes how to adapt when the host is something else, plus the path-handling rules for modifying an installed (often read-only) skill.

## Identifying the environment

Pick the matching section based on observable signals:

| Environment | Subagents? | Browser / display? | Heuristic |
| --- | --- | --- | --- |
| **Claude Code** | yes | yes | Default desktop / CLI session, can `open` URLs and HTML files. |
| **Claude.ai** | no | no | Web app, no `Bash` shell, no subagent spawning. |
| **Cowork** | yes | no | Has subagents, but `webbrowser.open()` is not available; you have a filesystem. |

If unsure, ask the user once at the start of the eval flow.

## Claude Code (default)

Everything in `references/evals.md` runs as written. Spawn subagents in parallel; let `generate_review.py` start its own server:

```bash
nohup python <skill-path>/eval-viewer/generate_review.py \
  <workspace>/iteration-N \
  --skill-name "my-skill" \
  --benchmark <workspace>/iteration-N/benchmark.json \
  > /dev/null 2>&1 &
VIEWER_PID=$!
```

Description-tuning (`scripts/run_loop.py`) and packaging (`scripts/package_skill.py`) work natively.

## Claude.ai (no subagents, no browser)

The core loop (draft → test → review → improve) is the same; mechanics change.

- **Running test cases**: no parallel subagents. For each test case, read the skill's `SKILL.md` yourself, then follow it to accomplish the test prompt. One at a time. This is less rigorous (the same agent that wrote the skill is also running it), but the human review step compensates. **Skip the baseline runs** — just use the skill to produce outputs.
- **Reviewing results**: no browser. Skip the eval viewer. Present results inline in the conversation: prompt + output for each test case. If the output is a file (e.g., `.docx`, `.xlsx`), save it to the filesystem and tell the user the path so they can download and inspect it. Ask for feedback inline: *"How does this look? Anything you'd change?"*
- **Benchmarking**: skip the quantitative aggregate. It depends on baseline runs that aren't possible without subagents. Lean on qualitative feedback.
- **Description optimization**: requires the `claude -p` CLI (only available in Claude Code). **Skip.**
- **Blind comparison**: requires subagents. **Skip.**
- **Iteration**: same as before — improve, re-run, ask for feedback — just without the viewer in the middle. Organize results into iteration directories on the filesystem if you have one.
- **Packaging**: `package_skill.py` works anywhere with Python and a filesystem. The user can download the resulting `.skill` file.

## Cowork (subagents available, no browser)

- The main eval workflow (parallel subagents, baselines, grading, aggregation) all works.
- **Eval viewer**: no display. Use `--static <output_path>` with `generate_review.py` to write a standalone HTML, then proffer the link to the user.
- **Feedback handoff**: no running server, so the viewer's *Submit All Reviews* button **downloads** `feedback.json`. Read it from the download path (you may need to request access first).
- **Always generate the eval viewer for human review *before* you self-evaluate outputs.** This is easy to forget on Cowork — get the human into the loop first, don't try to grade qualitatively yourself before they've looked.
- **Description optimization** (`scripts/run_loop.py` / `scripts/run_eval.py`): works fine, since it uses `claude -p` via subprocess, not a browser. Save it for after the skill is in good shape per the user's review.
- **Packaging**: works.
- If subagent timeouts are severe, fall back to running test prompts in series rather than parallel.

## Packaging (`O1`)

Run the packaging script only if the host has the `present_files` tool — that's how the user receives `.skill` files. Otherwise skip.

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

After packaging, tell the user the resulting `.skill` file path so they can install it.

## Modifying an existing skill — path handling (`O2`)

When the user is updating an installed skill (rather than creating a new one), the install path may be read-only. Workflow:

1. **Preserve the original name.** Note the directory name and the `name` field in the frontmatter — keep both unchanged. If the installed skill is `research-helper`, the output is `research-helper.skill` (not `research-helper-v2`).
2. **Copy to a writable location before editing.** Copy to `/tmp/<skill-name>/` and edit there.
3. **Package from the copy.** If packaging manually (without `package_skill.py`), stage the package in `/tmp/` first, then move it to the output directory — direct writes to the install path may fail due to permissions.

This pairs with the snapshot rule in `references/evals.md` (snapshotting the install path *before* edits, into `<workspace>/skill-snapshot/`, so the baseline run can use the unchanged version). The two snapshots have different purposes:

- `<workspace>/skill-snapshot/` — frozen baseline for evals comparison.
- `/tmp/<skill-name>/` — writable scratch space for the new version being authored.
