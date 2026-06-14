---
name: ultra-notion-formatter
description: Formats note content into a Notion page in the user's fixed house style. Use when the user asks to write, format, or tidy up a Notion note, hands over a Notion note page, or wants note formatting / layout applied — regardless of exact wording or language. Do NOT trigger for non-note Notion work like database queries, dashboards, or view / schema engineering.
---

# Ultra Notion Formatter

Formats a note into a Notion page following the user's fixed house style. The rules below are the contract — apply all of them, every time. A related family of notes (e.g. a tutorial series) shares this exact structure — Type／Tag properties, Good-to-know callouts, glossary table, and code marking — so keep it consistent across the whole set, whether you format one page or create a batch.

## Before you start

- **Identify the target.** Two paths:
  - **Format an existing page** — ask the user for the page (URL or ID) and operate on it.
  - **Create new page(s) from a database template** — when the user wants fresh notes, create them under the note database using its page template (`template_id`). This is now allowed: the template carries the house icon and default properties, so a created page is not an orphan. Batch creation is fine — one call can produce many pages.
- **Fetch first.** For an existing page, fetch it to read its title, properties, and the draft / source content. For creation, fetch the parent **database** to get its data-source schema (exact property names) and the `<templates>` section (template IDs). Why: property names and the title property may differ from defaults — rely on the fetched schema, never guess.
- Content is written in **Notion-flavored Markdown**. The syntax used below (block color, inline span color, Quote block, callout, `<details>` toggle, `<empty-block/>`) is verified against the spec. If you hit anything not covered here, read the MCP resource `notion://docs/enhanced-markdown-spec` rather than guessing.

## Page properties

Every note lives in a Notion database, so it always carries these properties — the icon represents the topic, the title carries only the note's own headline, and category and stack live in their own properties:

- **Title** — the placeholder is filler. Replace it with **only the note's real subject** — the headline derived from its content. Strip out the category label and any language／tool name; those move to the properties below. Example: a note on Ruby variable assignment → title `變數與賦值`, not `Ruby 變數（Concept）`.
- **`Type`** — a select with exactly one of: `Concept`／`How-to`／`Overview`／`Setup`. Pick the one matching the note's intent.
- **`Tag`** — the language／tool(s) the note is about (e.g. `Ruby`、`Notion`、`Bash`). Not the category.
- **Icon** — inherited from the template's default when creating; it stands in for the old leading-image role of signaling the topic. Only override it if the user asks.

## Page structure, in order

The body always opens with the gray summary — there is **no leading-image requirement** (the icon signals the topic instead).

1. **Summary** — the first content block: a Quote block summarizing the note's key point in 1–2 sentences, the **whole block gray**. Inline code inside it must be **individually wrapped in a gray span** too — block color does not carry into inline code:
   `> 用 <span color="gray">\`puts\`</span> 輸出文字。 {color="gray"}`
2. **Spacer** — exactly one `<empty-block/>` on its own line after the summary, before the main content.
3. **Main content** — numbered h2 sections (see below). An optional `零、` preamble (e.g. `零、相關筆記`) may come before `一、`.
4. **Glossary** — the note always closes with a `詞彙表` section as its final h2 (see below).

## Formatting rules for the body

### Headings

- Start at **h2** (`##`); never put an h1 in the body. The page title is the only h1.
- Every **h2 begins with a Chinese-numeral index + 、**: 一、二、三、四… Never use bracket-number style like 【1】.
  Example: `## 一、種類（Type）欄位`
- A **`零、` section is allowed for a preamble** such as `零、相關筆記`, placed before `一、`.
- For **tutorial / step-by-step notes, number the sections in actual operation order**; the glossary is always last.
- **No standalone 練習／Recap section.** Fold the key takeaways into the relevant section's Good-to-know callout, or drop them. Don't give recap its own h2.
- **h3** (`###`) numbering is optional — add sub-numbering only when the section structure genuinely benefits; otherwise leave h3 headings unnumbered. Don't force it.

### Full-width punctuation everywhere

Use full-width punctuation throughout — 。，、；：？！（）「」『』 — **including in and around English**. Never use half-width `.` `,` `;` `:` `?` `!` `(` `)` `"` `'`.

Example: `我們採用 TypeScript，並搭配 ESLint。` — not `…，並搭配 ESLint.`

**Code is exempt.** Inline code and code blocks keep literal syntax — write `` `v=spf1` `` and `-all`, never full-width versions, or the value stops being valid.

### Full-width slash for "or"

Use the full-width slash ／ for alternatives or pairings: `root／apex`、`none／quarantine／reject`、`SPF／DKIM`. This applies even inside otherwise-plain parentheses (e.g. a glossary cell or summary title).

### Inline code

Mark technical tokens as inline code `` `code` `` — record types (`TXT`), commands, config values (`v=spf1`, `-all`, `p=reject`), filenames (`my-test-key.pem`), subdomains / symbols (`_dmarc`, `@`), instance IDs, and similar literals. Why: it visually separates machine syntax from prose and keeps it from being "corrected" into full-width.

- **Also wrap any token Notion would auto-linkify** — method chains, dotted calls, or anything that reads like a URL (e.g. `gets.chomp.to_f`). Left bare, Notion turns it into a link; inline code keeps it literal.

### Code blocks

Use ` ```bash ` fenced blocks for terminal commands, and let the surrounding prose flow naturally into the block (introduce it with a sentence, don't drop it in cold).

### Gray parentheses — body text only

Parentheses are gray **only in body / prose text**. Wrap the parentheses and everything inside them in an inline color span:

`這是一個函式庫<span color="gray">（可重用的程式碼集合）</span>。`

**Everywhere else, parentheses stay plain** (white, no span) — h2 headings, callout `<summary>` titles, and glossary table cells:

- Heading: `## 一、種類（Type）欄位`
- Summary / cell: `**根域（root／apex，@）**`

Why: the gray is a reading-rhythm cue for asides in running prose; in a heading or a label it just looks broken.

> **Known quirk:** when a gray-parenthesis span contains inline code (e.g. `（用 `puts` 輸出）`), Notion splits the one gray span into several on save. It **displays correctly**, but the raw Markdown comes back fragmented — that's expected, don't try to "repair" it on a later fetch.

### Cross-references

Refer to another section of the **same note** by its heading label in brackets — 「四、建立金鑰對」 — matching the section's actual numeral + title exactly. For a **separate topic**, point to the companion note instead of duplicating it. Keep this 「X、章節名」 format consistent wherever the prose names another section.

## Good-to-know callouts — one per content h2 (required)

**Every content h2 must close with a 💡 Good-to-know callout** (the 詞彙表 is the only exception). It holds supplementary knowledge — points worth knowing but not core to the section — and is where folded-in recap takeaways live (see the headings rule). Put the detail inside a `<details>` toggle so it stays collapsed by default:

```
<callout icon="💡">
    **Good to know**：
    <details>
    <summary>**標題**</summary>
        說明文字。
    </details>
</callout>
```

Parentheses in the `<summary>` title stay plain (see the gray-parentheses rule). Why it's required: the mandate is a deliberate nudge to make you actively reach for a related, non-obvious knowledge point — an extension, a common pitfall, why something works under the hood, or a folded-in recap takeaway — rather than restating the section. Aim for a point the reader would genuinely be glad to learn; don't pad with filler just to satisfy the count.

## Glossary — always the final h2

Every note closes with a glossary as its last h2:

`## X、詞彙表（Glossary）`

- Name it **詞彙表**, never 名詞解釋.
- Render it as a **Markdown table**, not a Notion database, with three fixed columns: 名詞 ｜ 英文 ｜ 說明.
- Parentheses in cells stay plain (no gray span); use ／ for English alternatives.
- No Good-to-know callout here — the glossary is exempt.

```
| 名詞 | 英文 | 說明 |
| --- | --- | --- |
| 根域 | root／apex | 網域最上層的 `@` 節點。 |
```

## Applying the changes

**Formatting an existing page:**

1. Set the properties with the `update_properties` command — `title`, `Type`, and `Tag`.
2. Write the body with the update tool (`replace_content`), summary block first.
3. Briefly tell the user what changed — title／Type／Tag set, gray summary added, h2 headings renumbered, Good-to-know callouts added, glossary table added — so they can verify at a glance.

**Creating new page(s) from a template:**

1. Create each page with `notion-create-pages`: `parent` = the note `data_source_id`, `template_id` = the house template (inherits icon + default properties), and `properties` = the title plus `Type`／`Tag`. Don't pass `content` — the template provides the starting content.
2. Write the formatted body into each new page with `update_page` (`replace_content`), summary block first.
3. For a batch, repeat per note (one `create-pages` call takes up to 100 pages). Report the list of created pages and what each got.

## Out of scope

This skill is for formatting note pages in the house style — single or batch. It does **not** cover unrelated Notion work like database queries, dashboards, or view/schema engineering. Creating note pages (including batches) from the note database's template is in scope; arbitrary page creation outside that flow is not.
