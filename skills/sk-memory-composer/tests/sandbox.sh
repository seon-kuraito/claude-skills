#!/usr/bin/env bash
#
# sandbox.sh — build a throwaway Claude Code folder so a model-tier case can
# read and write memory for real without touching the machine.
#
# Usage: sandbox.sh [dir]     (default: a fresh mktemp -d)
# Prints the environment lines the case runs with. Three model-tier cases use
# it (the fixture's own memory cases are a different thing, listed below):
#
#   mid-task-save  — the Write flow's own first step writes a file, so a case
#                    that forbids writing measures a description, not the flow.
#   behavior core  — the Audit flow reads every memory it can reach. Pointed at
#                    the real folder it audits the user's own machine, and every
#                    run produces a fresh batch of judgement calls about content
#                    this skill does not own. Here its findings are the two the
#                    fixture plants.
#   trigger core   — a request that can be answered by reading every real memory
#                    pulls the model into doing the work by hand, and it then
#                    reads this skill as a file instead of loading it. The
#                    fixture keeps that inventory small.
#
# The fixture carries what the architecture needs — a CLAUDE.md with lookup
# lines and the write entry, four cases (gate, maintain, output, talk), two
# project folders with their indexes — plus two planted problems for the Audit
# flow to find:
#
#   1. the same rule sits in both project folders, so it belongs in global memory
#   2. a project fact sits in a case, so it belongs in that project's folder
#   3. a rule body carries a date, which the fixture's own preference file
#      forbids — only a reader who read that preference catches it
#
# scripts/check.py reads the fixture through --claude-dir and treats the folder
# above it as home. It warns on the first planted problem, because one memory
# sitting byte for byte in two project folders is mechanical; the second is a
# judgement about placement, which only a reader catches.
#
# UV_CACHE_DIR points inside the sandbox as well. Without it a case that forbids
# every write has no way to run the scripts: `uv run` writes a cache, and the
# user's own default is uv rather than bare python3. Pass the line to the case,
# and say that writes under the sandbox are what the sandbox is for.
set -euo pipefail

sb="${1:-$(mktemp -d)}"
claude="$sb/.claude"
demo="$sb/dev/demo"
other="$sb/dev/other"
demo_key="$(printf '%s' "$demo" | sed 's/[^A-Za-z0-9]/-/g')"
other_key="$(printf '%s' "$other" | sed 's/[^A-Za-z0-9]/-/g')"

mkdir -p "$claude/global-memory/gate" "$claude/global-memory/talk" "$claude/global-memory/output" "$claude/global-memory/maintain" \
         "$claude/projects/$demo_key/memory" "$claude/projects/$other_key/memory" "$demo" "$other" "$sb/.uv-cache"

cat > "$claude/CLAUDE.md" <<'MD'
# Global Instructions

## Talking and Deciding

- Before you explain an unfamiliar topic or put a decision to the user, `ls ~/.claude/global-memory/talk/` and read the file that matches.

## Gates

- Stop and wait for an explicit go before any outward git action: push, `gh pr create`, merge.
- Before any action above, `ls ~/.claude/global-memory/gate/` and read the file that matches.

## Language and Output

- Before you report finished work, `ls ~/.claude/global-memory/output/` and read the file that matches.

## Memory

- Before writing any memory, check whether it belongs in a skill or in `~/.claude/global-memory/<case>` instead. A rule for a step of an installed skill's flow goes into that skill. A rule that follows the user across projects goes to global memory. Only a fact that is useless outside the current project goes to that project's `MEMORY.md`.
- Before you write, delete, hand off, or audit a memory, `ls ~/.claude/global-memory/maintain/` and read the file that matches.
MD

cat > "$claude/global-memory/gate/outward-git-actions.md" <<'MD'
---
name: outward-git-actions
description: Wait for an explicit go before push, pull request, or merge
metadata:
  type: feedback
  established: 2026-01-01
---

Wait for an explicit go before any outward git action.

**Why:** The user asked to hold every outward action until they say go.

**How to apply:** State what the action would do, then stop and wait.
MD

cat > "$claude/global-memory/talk/explain-the-mechanism-first.md" <<'MD'
---
name: explain-the-mechanism-first
description: Explain how a thing works before offering options to choose between
metadata:
  type: feedback
  established: 2026-01-01
---

Explain the mechanism before you offer options.

**Why:** The user asked for the mechanism first, then the choice.

**How to apply:** Describe how the thing works in a few lines, then list the options with their costs.
MD

# Planted problem 2: a fact about one project, sitting in a case.
cat > "$claude/global-memory/talk/demo-ships-on-fridays.md" <<'MD'
---
name: demo-ships-on-fridays
description: The demo project ships on Fridays
metadata:
  type: project
  established: 2026-01-01
---

The demo project ships on Fridays.

**Why:** The user said the demo project ships every Friday.

**How to apply:** Name the next Friday when you plan work that has to ship.
MD

cat > "$claude/global-memory/maintain/keep-bodies-factual.md" <<'MD'
---
name: keep-bodies-factual
description: A memory body records what happened and what the user said, with no inference and no dates in the body
metadata:
  type: feedback
  established: 2026-01-01
---

Write a memory body from facts: what happened, and what the user said.

**Why:** The user asked for bodies that stay true as projects change.

**How to apply:** Leave out inference and prediction. Put a date in the frontmatter, never in the body of a memory.
MD

cat > "$claude/global-memory/output/finished-work-in-a-table.md" <<'MD'
---
name: finished-work-in-a-table
description: Report finished work under a delivery summary heading with a table as the body
metadata:
  type: feedback
  established: 2026-01-01
---

Report finished work under a `## ✅ Delivery summary` heading, with a table as the body.

**Why:** The user asked for finished work in a table rather than prose.

**How to apply:** Key each row by the item, and keep each cell to one short phrase.
MD

cat > "$claude/projects/$demo_key/memory/MEMORY.md" <<'MD'
# Memory Index

- [Demo build command](demo-build-command.md) — the project builds with `make demo`
- [Ask before adding a dependency](ask-before-adding-a-dependency.md) — the user decides every new dependency
MD

cat > "$claude/projects/$demo_key/memory/demo-build-command.md" <<'MD'
---
name: demo-build-command
description: The demo project builds with `make demo`
metadata:
  type: project
  established: 2026-03-04
---

Since 2026-03-04 this project builds with `make demo`.

**Why:** The user said `make demo` replaced the old build script.

**How to apply:** Run `make demo` before you claim the project builds.
MD

cat > "$claude/projects/$other_key/memory/MEMORY.md" <<'MD'
# Memory Index

- [Other test command](other-test-command.md) — the project tests with `make check`
- [Ask before adding a dependency](ask-before-adding-a-dependency.md) — the user decides every new dependency
MD

cat > "$claude/projects/$other_key/memory/other-test-command.md" <<'MD'
---
name: other-test-command
description: The other project tests with `make check`
metadata:
  type: project
  established: 2026-01-01
---

This project tests with `make check`.

**Why:** The user said this project's tests run with `make check`.

**How to apply:** Run `make check` before you claim the tests pass.
MD

# Planted problem 1: one rule about the user, copied into both project folders.
for key in "$demo_key" "$other_key"; do
  cat > "$claude/projects/$key/memory/ask-before-adding-a-dependency.md" <<'MD'
---
name: ask-before-adding-a-dependency
description: Ask the user before adding any new dependency, in every project
metadata:
  type: feedback
  established: 2026-01-01
---

Ask the user before you add a new dependency.

**Why:** The user said a new dependency is their decision, whatever the project.

**How to apply:** Name the dependency and what it costs, then wait for an answer.
MD
done

cat <<ENV
CLAUDE_DIR=$claude
HOME_DIR=$sb
PROJECT=$demo
UV_CACHE_DIR=$sb/.uv-cache
ENV
