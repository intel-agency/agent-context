---
description: Run a maintenance review of project memory, personal memory, and rules
---

Perform a maintenance review of the memory and rules layers. Do NOT apply any edits; only report and propose changes for the user to confirm.

## Read the following

- `.opencode/memories.md` (project memory)
- `~/.config/opencode/memories.md` (personal memory, if it exists)
- List every file under `.opencode/rules/*.md`

## Produce a checklist report

Organize findings under these sections. For each item, propose the specific edit as `file` + `old text` + `new text`.

### `## Project Memory`
- Decisions that have been overturned or superseded by later work?
- Tech-debt items that have since been resolved (candidates for removal)?
- New domain knowledge or conventions established recently that are not yet captured?

### `## Personal Memory`
- Are recorded tool preferences and communication-style notes still accurate?
- Any preferences that no longer reflect current habits?

### `## Rules`
- Any rule that is now enforced automatically by linting/formatting (candidate for removal to reduce noise)?
- Any rule whose wording or intent has changed?
- Are code examples in the rules still valid against the current codebase?
- Does each rule still reference AGENTS.md correctly and is that reference current?
  (Review this section quarterly.)

### `## Knowledge Graph`
- Optionally run `memory-graph_read_graph` (and `memory-graph_search_nodes` as needed) and flag observations that are stale, duplicated, or contradicted by the memory files above.

## Cadence

- Memory (project + personal): review monthly.
- Rules: review quarterly.

Present the report and wait for the user to approve any edits before applying them.
