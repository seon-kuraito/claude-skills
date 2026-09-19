# Architecture

What makes the two memory layers work for any user. Everything here is structure. How a particular user wants memories written — body language, extra frontmatter, body shapes, how finely to split, when to delete, how to hand off — lives in that user's global memory and is never restated here.

## Two layers

| | Project memory | Global memory |
| --- | --- | --- |
| Location | `~/.claude/projects/<encoded-path>/memory/` | `~/.claude/global-memory/<case>/` |
| Loaded | The harness loads `MEMORY.md` into every session started in that project | Never on its own; a CLAUDE.md lookup line sends a session in |
| Index | `MEMORY.md`, one line per file | The lookup lines in the user-level CLAUDE.md |
| Holds | Facts useless outside the project: its state, pending work, file coupling, repo conventions | Rules that follow the user into every project |

**Routing test:** would this still be true in a different repo? Yes → global memory. No → project memory.

Why two layers: a project folder loads only for sessions started in that project. A rule about how the user works, saved there, is missing from every other project — and gets saved again elsewhere, in different words.

## Path encoding

The harness names a project's memory folder after the project's absolute path, with every `/` replaced by `-`. A nested path and a hyphenated one can map to the same folder: `~/work/a/b` and `~/work/a-b` both become `…-work-a-b`. A renamed or retired project also leaves its folder behind under the old name. When a folder could belong to more than one project, ask which one before reading it as current.

Every folder name starts with `-`, so a command that takes one as a bare argument reads it as an option. Pass the name as a path (`./-Users-…`, or the full `~/.claude/projects/-Users-…`), or after `--`.

## Lookup lines

A lookup line is the only way a session reaches a case. Every case has a section in the user-level CLAUDE.md — or a line in the closest section — that ends with:

```
Before you <trigger>, `ls ~/.claude/global-memory/<case>/` and read the file that matches.
```

- `<trigger>` names the moment the case's rules apply, as an action: "explain an unfamiliar topic", "touch agent config".
- One line may name several cases that share a moment.
- A session follows the line only at the moment it names.

## Rule lines

Above its lookup line, a section states the rules that apply at a moment the lookup line does not cover. Write the rule itself as an imperative, never a pointer to its file. A rule whose moment matches the lookup line needs no line: the lookup already brings the session to it.

Why: the lookup line fires only at its own moment. A rule for another moment — before a push, while a background agent runs — is never looked up in time unless CLAUDE.md states it.

## The write entry

The `## Memory` section carries one fixed line, from `assets/claude-md-memory-section.txt`: before writing any memory, check whether it belongs in global memory. It is not a rule line, and the rule-line test above never removes it.

Why: lookup lines only bring a session in to read. A session that has not loaded this skill follows the harness's own memory instructions, which point at the project folder; this line is what makes it consider global memory at all. The line states the rule; how to decide stays in this skill.

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

Belongs here: what the layers need in order to work for every user — the layout, loading, lookup lines, rule lines, the write entry, case and file naming, links, indexes, and the check.

Belongs in the user's global memory: how that user wants memories written and kept.

A preference file that restates a rule from this document is a duplicate. The audit reports it, so each rule lives in one place.
