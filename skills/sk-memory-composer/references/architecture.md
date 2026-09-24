# Architecture

What makes the two memory layers work for any user. Everything here is structure. How a particular user wants memories written — body language, extra frontmatter, body shapes, how finely to split, when to delete, how to hand off — lives in that user's global memory and is never restated here.

## Two layers

| | Project memory | Global memory |
| --- | --- | --- |
| Location | `~/.claude/projects/<encoded-path>/memory/` | `~/.claude/global-memory/<case>/` |
| Loaded | The harness loads `MEMORY.md` into every session started in that project | Never on its own; a CLAUDE.md lookup line sends a session in |
| Index | `MEMORY.md`, one line per file | The lookup lines in the user-level CLAUDE.md |
| Holds | Facts useless outside the project: its state, pending work, file coupling, repo conventions | Rules that follow the user into every project |

**Routing test** (step 2 of *Memory or skill* below): would this still be true in a different repo? Yes → global memory. No → project memory.

Why two layers: a project folder loads only for sessions started in that project. A rule about how the user works, saved there, is missing from every other project — and gets saved again elsewhere, in different words.

## Memory or skill

Before the two layers, one more destination: a skill. A rule whose moment sits inside an installed skill's flow, and whose content is a rule for that flow — when to stop, what to list, what to read or write — belongs in that skill, not in a memory. How a block renders, how the user wants to be addressed, and a gate the user set for themselves stay in memory, whatever flow they touch.

**Routing test, in order:**

1. Does the rule govern a step of an installed skill's flow, and is it a flow rule rather than rendering, tone, or a personal gate? Yes → that skill: hand the rule to `sk-skill-author` — or to `sk-hook-author` when the harness should enforce it on an event — and write no memory. When that authoring skill is not installed, say so and go on to step 2.
2. Would this still be true in a different repo? Yes → global memory. No → project memory.

Why: a memory loads for one user at the moment a lookup line names, while a skill loads for every session that runs it — peers, subagents, other users. A flow rule kept only in memory is missing for every other reader, and a copy in both places drifts. The same boundary, seen from the skill's side, is in `sk-skill-author`'s writing guide.

## Path encoding

The harness names a project's memory folder after the project's absolute path, with every `/` replaced by `-`. A nested path and a hyphenated one can map to the same folder: `~/work/a/b` and `~/work/a-b` both become `…-work-a-b`. A renamed or retired project also leaves its folder behind under the old name. When a folder could belong to more than one project, ask which one before reading it as current.

Every folder name starts with `-`, so a command that takes one as a bare argument reads it as an option. Pass the name as a path (`./-Users-…`, or the full `~/.claude/projects/-Users-…`), or after `--`.

A project's folder holds more than `memory/`: the harness keeps that project's session transcripts beside it. Search `~/.claude/projects/*/memory`, never `~/.claude/projects/` as a whole — a transcript quotes every memory its session read, so a wider search returns the same text many times over.

## Lookup lines

A lookup line is the only way a session reaches a case. Every case has a section in the user-level CLAUDE.md — or a line in the closest section — that ends with:

```
Before you <trigger>, `ls ~/.claude/global-memory/<case>/` and read the file that matches.
```

- `<trigger>` names every moment the case's rules apply, as actions: "explain a topic", "put a decision to him", "touch agent config". When a new rule's moment is missing, widen the trigger.
- One line may name several cases that share a moment.
- A session follows the line only at the moment it names.

## Always-loaded lines

A memory section carries its lookup line and nothing else. The rule's text lives in its file, and the lookup line names its moment. When a rule's moment is missing from the trigger, widen the trigger; never add the rule as a line of its own. A line that restates a rule from a file is a copy: it drifts from the file, and the audit reports it.

Two kinds of line stay in CLAUDE.md outside this rule:

- Content with no moment — who the user is, the language they speak — cannot be looked up, because a lookup line needs a moment. It sits in a section of its own, which belongs to `sk-claudemd-composer`.
- A rule that applies on nearly every tool call — a package manager, a shell's traps, where scratch files go — stays as an always-loaded line above its section's lookup line. A lookup before every call is impractical. The user names the section that holds these lines; the audit reports an always-loaded line anywhere else.

Why: every line of CLAUDE.md loads into every session, and a copy of a rule outside its file drifts. Widening a trigger costs a few words and keeps the rule in one place.

## The write entry

The `## Memory` section carries one fixed line, from `assets/claude-md-memory-section.txt`: before writing any memory, check whether it belongs in a skill or in global memory. It is not a copy of any file, and the rule above never removes it.

Why: lookup lines only bring a session in to read. A session that has not loaded this skill follows the harness's own memory instructions, which point at the project folder; this line is what makes it consider a skill or global memory at all. The line states the rule; how to decide stays in this skill.

## Cases

- Add a case only when a rule fits none of the existing ones. Read the CLAUDE.md sections to see what each case covers — a name alone does not say.
- Name a case after the situation that sends a session to it: an action (`talk`, `shell`) or the thing being touched (`workspace`).
- The name says the same thing as its lookup line's `<trigger>`.
- The name repeats no word of its parent path — not `claude`, `global`, or `memory`.
- Use lowercase full words joined by hyphens. A standard code, such as a locale tag, is a word.
- Never keep a list of cases in a memory or a document. Say how to find them: `ls ~/.claude/global-memory/`.

Why: a session picks a case by the moment it is in, so a name that states the moment routes both the reader and the writer. A name that repeats its parent says nothing the path did not.

## Files

- A memory's frontmatter `name` equals its file name without `.md`, in both layers.
- A global file name does not repeat its case: `gate/outward-git-actions.md`, not `gate/gate-outward-git-actions.md`.
- Nothing sits directly in `~/.claude/global-memory/`, and no folder sits inside a case.
- Everything else about a file — its other frontmatter fields, body, and language — follows the harness's memory instructions and the user's preferences.

## Links

- Link to a global file as `[[<case>/<name>]]`, from either layer — never as a backtick path. Such a link must resolve: a broken one means a case or file moved without its links. A backtick path to a global file is a warning: it breaks the same way, and the link check cannot follow it.
- A bare `[[name]]` links within the same folder. The harness allows one that points at a memory not written yet, so a bare link to nothing is a warning, not a failure.
- A path in backticks (`~/…`) should exist. A note about history may name a path that is gone on purpose, so the check warns and the audit decides.

## Indexes

- Every memory file in a project folder has one line in that folder's `MEMORY.md`, and every line links to a file that exists.
- Global memory has no index file. The lookup lines are its index.

## Architecture or preference

Belongs here: what the layers need in order to work for every user — the routing between a skill and the two layers, the layout, loading, lookup lines, always-loaded lines, the write entry, case and file naming, links, indexes, and the check.

Belongs in the user's global memory: how that user wants memories written and kept.

A preference file that restates a rule from this document is a duplicate. The audit reports it, so each rule lives in one place.
