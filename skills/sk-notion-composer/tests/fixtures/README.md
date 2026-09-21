# Fixture for the behavior case

This item's flow acts on a Notion workspace, which the tests cannot copy into a throwaway
directory. The fixture lives under a page the user set aside inside the real workspace. The
page stays; the database under it is built before a round and removed after it, so nothing
from one round is left for the next one to trip over.

## What a round builds

- The page itself is not built: it holds nothing but the fixture, and is referred to below
  as `<playground-page>`.
- One database under it, `Sandbox Base`, shaped like a real `<domain> Base`: a `Title`
  title property, a `Category` select whose options are gray and include `CSS` — the one
  the draft note belongs to — and a `Reviewed` checkbox. It carries no page template,
  because the tooling that creates a database cannot create one; a run that expects a
  `template_id` finds none and should say so.
- One row in that database, titled after the note the behavior case names, holding
  `draft-note.md` verbatim as its page content: plain paragraphs, no house style. `Category`
  is empty and `Reviewed` is unchecked.

Build both with the same tooling the flow uses — create the database under
`<playground-page>`, then create the row in it — and read the new addresses off the
results.

## The line the brief carries

The brief names the container in place of a `Sandbox:` block, and says what the flow may do
inside it. Keep it narrow — a line that names only the container invites the flow to read
everything under it:

> Notion scope: work inside `<playground-page>` and the `Sandbox Base` database under it.
> Read the one note this request names; do not list or read the other rows. Write nothing
> outside that database.

Substitute `<playground-page>` with the real address at run time. No address is stored
here, the way a real path is not stored in a case prompt — and the database's address
changes every round anyway.

## Removing it after a round

The tooling that builds the fixture cannot remove it: it has no delete or trash action. Once
the round is judged, the user deletes the database by hand, and the page is empty again.

Never run a round on a database left over from an earlier one. Its row holds the last
round's output, so the second round formats a page the first round already formatted, and
the asserts about structure pass for the wrong reason. When one is found, delete it and
build a fresh one; or, to keep it, put the row back first: replace its page content with
`draft-note.md`, clear `Category`, and uncheck `Reviewed`.
