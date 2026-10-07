---
name: sk-code-reviewer
description: Reviews a change along four separate axes — the repo's standards, the originating spec, security, and simplicity — each in its own subagent, and reports them side by side without merging or ranking. Make sure to use this skill whenever the user wants code reviewed: a branch, a pull request, work-in-progress changes, a diff since some point, or a second opinion on code — regardless of exact wording or language.
---

# Code Reviewer

Four-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the code follow this repo's documented standards and stay clear of the smell baseline?
- **Spec**: does the code implement what the originating spec asked for, no less and no more?
- **Security**: does the change introduce a vulnerability with a real exploit path?
- **Simplicity**: what in the change can be deleted, replaced by the standard library or the platform, reused, or shrunk?

Each axis runs in its own subagent, so that one axis cannot colour another, and this skill reports the four results side by side. It lists findings; it fixes nothing. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

## Process

### 1. Pin the fixed point

Whatever the user named is the fixed point: a commit, a branch, a tag, `main`, `HEAD~5`. When they named none, use the branch this work branch was cut from — `develop` when the repo has one, otherwise `main`; a branch stacked on another work branch uses that branch. When that cannot be told, ask the **Fixed point** question.

Capture the diff once, three-dot so that the comparison is against the merge-base — `git diff <fixed-point>...HEAD` — and the commit list: `git log <fixed-point>..HEAD --oneline`. Check that the ref resolves (`git rev-parse <fixed-point>`) and that the diff is not empty before anything else runs; a bad ref or an empty diff fails here, not inside four subagents.

### 2. Find the spec

Look in this order and take the first hit:

1. A path the user passed.
2. The version table in `DECISIONS.md` — in a family, the coordination repo's — and the spec whose name matches the branch.
3. A file under `specs/` whose name matches the branch or the feature.
4. Ask the user. When they say there is none, the Spec axis is skipped and the report says so.

### 3. Find the standards

Everything in the repo that says how code is written: `CLAUDE.md`, `CONTRIBUTING.md`, a coding-standards document, the conventions table of `DECISIONS.md`. On top of them, the Standards axis always carries the smell baseline in `references/smells.md`. A documented standard overrides the baseline; a smell is always a judgement call; anything tooling enforces is skipped.

### 4. Ask how to run

Say how many subagents the run takes — four, or three without a spec — then present the **Run mode** menu. Dispatch nothing before the answer.

### 5. Dispatch the subagents

One general-purpose subagent per axis, `model: opus`, in the background, in the mode the user chose. Every brief carries the same header, then its axis section.

**Header, in every brief.** The diff command and the commit list from step 1, and the list of files the diff touches. Then: "Read the diff first. Then read only the files it touches and what they import one hop away; grep before you read anything else. Report under 400 words. Quote the hunk for every finding. List findings only; change nothing."

**Standards.** The standards sources from step 3, and `references/smells.md` pasted in full — the subagent has no other access to it. "Report (a) every place the diff breaks a documented standard, citing the file and the rule, and (b) every baseline smell you see, named. A documented-standard breach can be a hard finding; a smell is always a judgement call, and a documented standard overrides the baseline."

**Spec.** The spec's path or its full text. "Report (a) requirements the spec asks for that are missing or partial, (b) behaviour the diff adds that the spec did not ask for, and (c) requirements that look implemented but wrong. Quote the spec line for each finding."

**Security.** `references/security.md` pasted in full. "Report only vulnerabilities this change introduces, with a real exploit path and the confidence the reference requires, in the reference's format. Nothing already in the codebase, nothing on the reference's exclusion list."

**Simplicity.** `references/simplicity.md` pasted in full. "Review the diff for what can be deleted, replaced, reused, or shrunk, one line per finding in the reference's format, and end with the net line count."

### 6. Aggregate

Present the four reports under `## Standards`, `## Spec`, `## Security`, `## Simplicity`, verbatim or lightly cleaned. Never merge the axes and never rerank across them: a change can pass one and fail another, and reporting them apart stops one from masking another. End with one line per axis — the number of findings and the worst one — and no winner across axes.

What gets fixed is the user's call, or the implementer's when this skill runs inside `sk-spec-implementer`. This skill applies no fix.

## References

- `references/menus.md` — the Fixed point question and the Run mode menu
- `references/smells.md` — the smell baseline the Standards axis carries
- `references/security.md` — the categories, the confidence bar, the exclusions, and the report format of the Security axis
- `references/simplicity.md` — the tags, the format, and the scoring of the Simplicity axis

## Related

- [sk-spec-planner](../sk-spec-planner/SKILL.md) — writes the spec the Spec axis reviews against, and the version table this skill reads to find it.
- [sk-spec-implementer](../sk-spec-implementer/SKILL.md) — loads this skill at the end of every implementation.
- [sk-code-tester](../sk-code-tester/SKILL.md) — leaves refactoring to this review.
