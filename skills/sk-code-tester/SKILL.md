---
name: sk-code-tester
description: Drives test-first implementation — tests at pre-agreed seams, red before green, end-to-end or integration tests first with unit tests only to fill gaps, and assertions that state the intention without restating what the test already implies. Make sure to use this skill whenever the user wants TDD, test-first work, tests written for a feature or a bug fix, or asks what to test and at which level — regardless of exact wording or language.
---

# Code Tester

TDD is the red → green loop. This skill is the reference that makes the loop produce tests worth keeping: where tests go, at which level, what they assert, and the rules of the loop. Every section applies on every cycle; consult them before and during the loop, not after. Every menu and plain-text question this skill asks lives in `references/menus.md`; present each as written there.

Before the first test, read `GLOSSARY.md` when it exists, so that test names and interface vocabulary match the project's terms, and read `DECISIONS.md` for the decisions that hold in the area you touch.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behaviour without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** When the work comes from a spec, its testing decisions name the seams: use those. Otherwise write down the seams you intend to test and ask the **Seams** question. No test is written at an unconfirmed seam: you cannot test everything, so agreeing the seams up front puts the effort on the critical paths and the complex logic instead of every edge case. Prefer seams that exist; take the highest one; the fewer the better.

## Which level to test at

Test from the outside in. An end-to-end or integration test through the real interface comes first: it checks what a user or a caller observes, and it survives refactors. A unit test is for what the higher level cannot reach — a parser, a pure calculation, a boundary case too expensive to drive from the outside — or for a gap the higher test leaves. Mock only at system boundaries; `references/mocking.md` says where and how.

## What a test asserts

- Every action and every equality check already asserts something: rendering a component asserts that it renders, and `expect(data).toEqual({ id: 1 })` asserts that `data` is an object. Do not add an explicit assertion for what the test already implies, and delete one when you find it.
- Each assertion states the intention of the test. A diff of the whole value says more on failure than a count or a type check.
- Expected values come from an independent source — a known-good literal, a worked example, the spec — never from the computation under test.
- A check on the test setup itself — a fixture that must exist, a helper that must be ready — is a plain `if` and `throw`, not an assertion: it reports a broken setup, not a broken system.

`references/assertions.md` holds the examples; `references/tests.md` shows a good and a bad test side by side.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor and behaviour has not changed.
- **Tautological**: the expected value is recomputed the way the code computes it, so the test passes by construction.
- **Horizontal slicing**: all tests first, then all implementation. Bulk tests verify imagined behaviour. Work in vertical slices: one test, one implementation, repeat.
- **Overcautious**: an existence check on an element the next line clicks, a length check before an equality on the same array. Such assertions add noise and a false sense of cover.

## Rules of the loop

- **Red before green.** Write the failing test, run it, and show the failure before any implementation. Then write only enough code to pass it: no speculative features, no anticipating later tests.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to review — `sk-code-reviewer` — not to the red → green cycle.
- **The slice's test and code land together**, in one commit; neither waits for the other.
- **Throwaway tests stay out of the repo.** A probe written to learn how something behaves goes to the session scratchpad and is deleted with it.

## References

- `references/menus.md` — the Seams question
- `references/tests.md` — a good and a bad test, side by side
- `references/mocking.md` — where to mock, and how to design for it
- `references/assertions.md` — implicit assertions: what to keep and what to delete

## Related

- [sk-spec-planner](../sk-spec-planner/SKILL.md) — writes the testing decisions this skill takes its seams from.
- [sk-spec-implementer](../sk-spec-implementer/SKILL.md) — loads this skill at the start of every implementation.
- [sk-code-reviewer](../sk-code-reviewer/SKILL.md) — where refactoring and the review of the tests happen.
