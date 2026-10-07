# CLAUDE.md — records-cli

A zero-dependency Node CLI that lists records. Modules live in `src/` as ES modules; tests live in `test/` and run with `npm test` (the built-in `node --test` runner). The specs under `specs/` describe the features in progress; `DECISIONS.md` holds the current decisions.

Conventions: a function is named for what it returns or does; no abstraction with a single implementation; no shelling out from library code.
