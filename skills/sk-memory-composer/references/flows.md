# Flows

Every flow starts by reading the user's preferences (`SKILL.md`, *Read the user's preferences first*). `<base>` is this skill's resolved directory.

## Init

1. Check for the user-level CLAUDE.md, `~/.claude/CLAUDE.md`. When it does not exist, load `sk-claudemd-composer` and ask it for a blank user-level CLAUDE.md; it creates the file and hands back. When that skill is not installed, create an empty file yourself and say so.
2. Create `~/.claude/global-memory/`. Create no case yet: a case appears with its first rule (Case flow).
3. Add the section in `assets/claude-md-memory-section.txt` to the end of CLAUDE.md, showing the diff first. When a `## Memory` section already exists, add only its line to that section.
4. Run `uv run <base>/scripts/check.py`.
5. When project memory folders exist, offer an Audit: rules that follow the user everywhere are often sitting in one project's folder.

## Write

1. Route with the test in `references/architecture.md`. When the answer is unclear, present the **Route** menu in `references/menus.md`.
2. For global memory, read the CLAUDE.md sections and pick the case whose lookup line names the moment the rule applies. When none does, run the Case flow first.
3. Look for a memory on the same subject — in the target folder, and for a global rule in every project folder too. Update it instead of writing a second one; a copy in a project folder moves through the Restructure flow.
4. Write the file. `name` equals the file name; a global file name leaves out the case; a link to a global file is `[[<case>/<name>]]`.
5. For project memory, add the file's line to `MEMORY.md`.
6. For global memory, ask the **CLAUDE.md rule line** question in `references/menus.md`. When the answer is yes, add the rule itself as one imperative line above the lookup line, showing the diff first.
7. Run the check.

A save decided mid-task takes the same steps. Route first; never write to the project folder and move the file later.

## Case

### Add

1. Read every CLAUDE.md section that ends with a lookup line, and confirm no case covers the rule.
2. Propose a name by the rules in `references/architecture.md`, then ask the **Case name** question in `references/menus.md`.
3. Create the folder.
4. Give it a section, or a line in the closest section, that ends with `assets/lookup-line.tmpl`: `{{TRIGGER}}` is the moment, `{{CASE}}` the name. Show the diff first.
5. Write the first rule into it (Write flow, step 4 on).

### Rename

1. Find every reference to the old name — `global-memory/<old>/` and `[[<old>/` — in the user-level CLAUDE.md, `~/.claude/global-memory/`, and every project memory folder.
2. Pass the Execution gate with that list.
3. Back up the case, CLAUDE.md, and every file from step 1 with `uv run <base>/scripts/backup.py --dest <dir> <path>...`.
4. Move the folder, then rewrite the lookup line and every link and path from step 1.
5. Run the check, and search for the old name again. Both must come back clean.

## Audit

### Evidence rules

Each rule answers a way an audit has reached a wrong conclusion:

- **List from disk, never from a sample.** Build the inventory from every memory folder and every case. A claim about all projects drawn from three of them is a guess.
- **Confirm which folder is current.** A renamed or retired project leaves its folder behind, and path encoding can map two projects to one folder. Ask when a folder's project is unclear.
- **Say what a count counts.** Name the folders behind a number, and keep retired projects out of claims about current ones.
- **Check links and paths separately.** `[[links]]` and backtick paths go stale on their own schedules; the check covers both.
- **Report every judgment call as a finding.** A merge, a split, or a move you are unsure of goes into the report table, not a remark beside it.

### Steps

1. Run `uv run <base>/scripts/check.py --inventory` and keep the output. Its inventory is the list of folders and cases the audit covers, and every failure it reports is a finding; quote the result in the report. The order you read the memories in is yours.
2. Read every memory and compare it with those preferences.
3. Look for:
   - the same rule in more than one project folder → global memory
   - a rule about the user in a project folder → global memory
   - a project fact in a case → that project's folder
   - memories that repeat each other → one memory
   - a preference file that restates `references/architecture.md` → remove the restated part
4. Report every finding before changing anything, naming the memory and the change you propose. How a report is laid out is the user's preference, not this skill's.
5. Apply what the user approves through the Restructure flow.

## Restructure

1. List every change: the files to split, merge, move, or delete, the index lines and links each change touches, and any CLAUDE.md line.
2. Pass the Execution gate.
3. Back up every file on the list with `uv run <base>/scripts/backup.py --dest <dir> <path>...`.
4. Apply the changes. A moved memory leaves its old folder and its old index line; every link to it is rewritten.
5. Run the check. Report the backup folder, and that it does not outlive the session.
