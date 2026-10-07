# Decision record

The decision record of a project — `DECISIONS.md` — states the current state only: the decisions that hold now, the options that were rejected, and the version table. It carries no dated entries and no narrative of how a decision changed. When a decision changes, its entry is rewritten in place; the version history keeps the old state.

## What it holds

- Decisions and rejected options, and nothing else. The purpose of each repo stays in `CLAUDE.md`; measured facts and research stay under `docs/`; open questions and to-do items go to project memory; the how of a feature goes to its spec. The opening lines of the record point at those places.
- Each cell is a neutral statement in the written register: what the product does, and the reason. No second person, no slogan.

## Layout

`assets/decisions-template.md` is the skeleton; its Chinese strings are the literal headings, headers, and opening sentence.

- **Title.** The product name, then `決策紀錄`. A product with a name in another script gives the romanized name first and that name after it in full-width parentheses.
- **One H2 per repo.** In a family, each repo that has decisions gets an H2 named with its directory name; `meta` comes first and holds the product-level decisions. A single repo has one H2 named after the repo. A repo with no decision gets no section. One sentence under the H2 may say what the section covers.
- **Every table sits under an H3** that names its topic. No table hangs directly under an H2.
- **A decision table has three columns:** `決策`, `選擇`, `理由`, one row per decision.
- **Rejected options are the last H3 of their section:** `### 被否決的選項`, with the two columns `選項` and `否決理由`. A section with no rejected option leaves the heading out.
- **The product-level section opens with five topics, in this order:** `產品`, `定位`, `階段`, `產品機制`, `商業模式`; topics that only this product has come after them. `產品` starts with the rows `名稱`, `產品種類`, `一句話`; `定位` starts with `主要使用者`; `階段` has one row per version stage that has a definition, named with the stage and its version in full-width parentheses; `商業模式` holds the licence row `授權`. When the product has no fact for one of these rows, ask the user; never leave the row out and never invent it.
- **The version table** is the H3 `### 版本`, after the five topics and before the rejected options. Columns `版本`, `spec`, `狀態`: one row per version in progress or planned, its specs as links into `specs/`, and the state `進行中` or `已規劃`. A version that has shipped leaves the table; its tag and GitHub Release keep the history.
- **The section spacer.** Between two H2 sections, and between the opening pointers and the first H2: a blank line, a line holding one full-width space (U+3000), and a blank line.
- **Cross-references.** A cell that depends on another entry points at it by name: a row name in `「」`, a repo section in backticks.

## Before you draft or amend

- Open the record of another project with the same shape when one exists, and match its headings and row names.
- Read each entry you touch as a reader who knows nothing of the history: it must state what holds now, without dates or "changed on" notes.
- Draft in this layout from the first version; never hand over a record in another shape.
