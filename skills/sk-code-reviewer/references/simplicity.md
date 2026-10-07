# Simplicity axis

Review the diff for unnecessary complexity. One line per finding: location, what to cut, what replaces it. The diff's best outcome is getting shorter.

## Format

`<N>. L<line>: <tag> <what>. <replacement>.`, or `<N>. <file>:L<line>: …` for a multi-file diff. Number the findings `1.`, `2.`, … across the whole report, so that the user can say "fix 2 and 5".

Tags:

- `delete:` dead code, unused flexibility, a speculative feature. Replacement: nothing.
- `stdlib:` a hand-rolled thing the standard library ships. Name the function.
- `native:` a dependency or code doing what the platform already does. Name the feature.
- `reuse:` an equivalent helper, util, or pattern already in this repo. Name the path.
- `yagni:` an abstraction with one implementation, config nobody sets, a layer with one caller.
- `shrink:` the same logic in fewer lines. Show the shorter form.

## Examples

❌ "This EmailValidator class might be more complex than necessary, have you considered whether all these validation rules are needed at this stage?"

✅ `1. L12-38: stdlib: 27-line validator class. "@" in email, 1 line, real validation is the confirmation mail.`

✅ `2. L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

✅ `3. L18-29: reuse: slugify helper duplicates src/lib/slug.ts slugify. Delete it, import the existing one.`

✅ `4. repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`

✅ `5. L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Scoring

End with the only metric that matters: `net: -<N> lines possible.`

If there is nothing to cut, say `Lean already. Ship.` and stop.

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes, and performance belong to the other axes, not to this one. A single smoke test or `assert`-based self-check is the minimum, not bloat: never flag it for deletion. This axis lists; it applies nothing.
