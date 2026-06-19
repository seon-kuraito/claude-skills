# Testing

Optional but recommended for deterministic `command` hooks. Activate when the user opted into testing at the capability checkpoint, or asks to "test the hook", "does this hook work", and similar.

The mental model: a `command` hook is a pure function of (stdin JSON, environment) → (exit code, stdout, stderr, side effects). So you test it the way you test any script — feed it a fixture event payload, capture the outputs, and assert. No subagents, no grading model, no benchmark: the whole point of a hook is determinism, so the test is deterministic too. (`prompt` / `agent` hooks are non-deterministic — review them by hand and spot-check; don't assert exact output.)

## 1. Fixtures

A fixture is one sample event payload — the JSON Claude Code would deliver on stdin. Store them under the hook's `tests/fixtures/`:

```
hooks/ultra-task-notifier/
└── tests/fixtures/
    ├── stop.json
    └── stop-active.json     (stop_hook_active: true — the loop-guard case)
```

Build a fixture from `references/schemas.md` (common fields + the event's fields). Cover the cases that change behavior: the happy path, each branch (e.g. a protected path vs an allowed one for a `PreToolUse` guard), and edge cases (a missing field, the `stop_hook_active` re-entry for a blocking `Stop` hook).

**Confirm the shape against a real event — don't trust the schema doc blindly.** `references/schemas.md` is transcribed from the published reference and drifts across Claude Code versions (fields appear, vanish, or get renamed). Before relying on a field, capture what *your* runtime actually sends — temporarily log stdin, trigger the event once, read it back:

```bash
# top of hook.sh, right after INPUT=$(cat) — a throwaway line, removed once captured
echo "$INPUT" >> /tmp/hook-capture.jsonl
```

A `Stop` fires when Claude ends a turn; then `jq 'select(.hook_event_name=="Stop")' /tmp/hook-capture.jsonl` shows the live payload — author the fixture from *that*. (A real capture has caught the schema doc listing a field the runtime no longer sends, and missing several it does.)

Example `stop.json`:

```json
{ "session_id": "test", "transcript_path": "/tmp/t.jsonl", "cwd": "/tmp", "hook_event_name": "Stop", "stop_hook_active": false }
```

## 2. Run

Pipe a fixture into the hook and capture exit code + stdout + stderr:

```bash
scripts/run-hook-test.sh hooks/ultra-task-notifier/hook.sh hooks/ultra-task-notifier/tests/fixtures/stop.json
```

The runner prints the exit code, stdout, and stderr. By hand it is just:

```bash
cat fixture.json | ./hook.sh ; echo "exit: $?"
```

## 3. Assert

What to assert depends on the hook's output mode:

- **Exit code** — the load-bearing signal. A side-effect hook must `exit 0`; a `PreToolUse` guard must `exit 2` on a blocked input and `0` on an allowed one.
- **stdout JSON** — for structured hooks, pipe stdout to `jq` and check fields: `jq -e '.hookSpecificOutput.permissionDecision == "deny"'`.
- **stderr** — for blocking hooks, assert the reason text is present (it becomes Claude's feedback).
- **Side effects** — file created / appended, env file written. Notifications and sounds can't be asserted from a script — verify those once by hand.

Keep assertions objective and per-fixture. A good fixture set pairs each behavior branch with a fixture that should trigger it and one that shouldn't.

## 4. Iterate

When a test fails, read the hook against `references/writing-guide.md` (input read once? field defaulted? output mode single?), fix, and re-run the fixture. For the `Stop` block-cap loop, confirm `stop-active.json` (with `stop_hook_active: true`) makes the hook `exit 0`.

## When testing isn't worth it

- A one-line side-effect hook (`osascript … notification`) — a single by-hand run is enough; skip fixtures.
- `prompt` / `agent` hooks — non-deterministic; review the prompt and spot-check, don't assert exact output.

Reserve the fixture harness for hooks with real branching: guards, validators, formatters — anything that decides based on input.
