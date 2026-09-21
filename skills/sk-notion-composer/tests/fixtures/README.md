# Fixture for the behavior case

This item's flow acts on a Notion workspace, which the tests cannot copy into a throwaway
directory. The fixture is a container the user set aside inside the real workspace, and it
stays there between rounds instead of being built and torn down.

## What the container holds

- A page that holds nothing but the fixture, referred to below as `<playground-page>`.
- One database under it, `Sandbox Base`, shaped like a real `<domain> Base`: a `Title`
  title property, a `Category` select whose options are gray, and a `Reviewed` checkbox.
  It carries no page template, because the tooling that creates a database cannot create
  one; a run that expects a `template_id` finds none and should say so.
- One row in that database, titled after the note the behavior case names, holding
  `draft-note.md` verbatim as its page content: plain paragraphs, no house style.

## The line the brief carries

The brief names the container in place of a `Sandbox:` block, and says what the flow may do
inside it. Keep it narrow — a line that names only the container invites the flow to read
everything under it:

> Notion scope: work inside `<playground-page>` and the `Sandbox Base` database under it.
> Read the one note this request names; do not list or read the other rows. Write nothing
> outside that database.

Substitute `<playground-page>` with the real address at run time. The address is not stored
here, the way a real path is not stored in a case prompt.

## Resetting between rounds

The container is permanent, so a round starts by putting the fixture row back the way it
was: replace its page content with `draft-note.md`, clear `Category`, and leave `Reviewed`
unchecked. Without the reset, the second round formats a page the first round already
formatted, and the asserts about structure pass for the wrong reason.
