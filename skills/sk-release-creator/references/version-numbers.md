# Version numbers

The default numbering this skill suggests. It is a default: the number the user answers always wins.

A number is defined by an event, never by the name a project gives a stage:

| number | event |
| --- | --- |
| `0.0.z` | every version before the prototype, whatever it holds |
| `0.1.0` | the prototype: the product runs end to end for the first time and is not yet delivered to users |
| `0.y.0`, y above 1 | a version after the prototype that adds a capability |
| `0.y.z`, z above 0 | a version after the prototype that only fixes |
| `1.0.0` | the MVP: the first version delivered into users' hands |
| above `1.0.0` | standard SemVer |

## Picking the suggestion

Read the repo's version tags (`git ls-remote --tags origin 'v*'`) and the planned content of the version, then:

- no tag yet, or only `0.0.z` tags and no prototype → the next `0.0.z`;
- the version that first runs end to end → `0.1.0`;
- after the prototype → the next minor with the patch at 0 when the version adds a capability, the next patch when it only fixes;
- the first version delivered to users → `1.0.0`.

Never suggest `0.1.0` or `1.0.0` because a document calls a version a milestone — check it against the event in the table.

## In a family of repos

The number belongs to the family, not to one repo. Every repo that takes part in version x.y.z gets its own `release/x.y.z`, tag, and Release with that number, and a repo that takes no part gets none — so the tags of one repo can skip numbers. Before suggesting a number in a family member, read the tags of the family's other repos, the coordination repo included.
