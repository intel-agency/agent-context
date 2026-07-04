---
name: context-aware-implementation
description: Implement a feature or change using project memory, rules, and the knowledge graph for context. Use before implementing any non-trivial feature so prior decisions, conventions, and constraints are respected.
---

## What I do

Load all relevant context **before** writing code, so the change respects prior decisions, conventions, and constraints instead of contradicting them.

## When to use me

Use me before implementing any feature, refactor, or non-trivial change (roughly: more than a one-line edit or anything touching architecture, conventions, or multiple files).

## Process

1. **Read project memory** — `/home/nam20485/src/github/intel-agency/agent-context/.opencode/memories.md`. Look for applicable architecture decisions, constraints, conventions, and known tech debt related to the area you'll touch. Note any ADR blocks whose scope overlaps the change.
2. **Read the applicable rules** — scan `.opencode/rules/*.md` and pick entries whose `Applies to` matches the file types you will edit. Hand the detailed per-file rule lookup to the `apply-rules` skill when you actually start writing files.
3. **Query the knowledge graph** — use the MCP memory-graph `search_nodes` (fuzzy) and/or `read_graph` to find prior decisions, entities, and relationships about the components involved. Use `open_nodes` for exact entity names you already know. Look for ownership edges, dependency relations, and prior ADR entities.
4. **Read personal memory** — `~/.config/opencode/memories.md` — for the user's style/tooling preferences that bear on the change (skip if clearly irrelevant).
5. **Summarize, then implement.** Briefly state the discovered constraints and conventions to the user (e.g. "memory says X, rule Y applies, graph entity Z depends on this"), THEN implement following them. If a constraint conflicts with the request, flag it rather than silently overriding — propose an alternative or ask for a decision.
6. **Capture new context.** After implementing, if a new decision, constraint, or learning emerged, persist it via the `memory-capture` skill (or `/remember`) so the next session stays in sync. Update a stale memory/graph fact in place rather than appending a contradiction.

## What to look for

- **Decisions/ADRs** that govern the component, module, or pattern you are changing.
- **Conventions** (naming, structure, formatting) enforced by rules for the file types involved.
- **Tech debt** entries that the change might resolve or must avoid worsening.
- **Relationships** in the graph (dependencies, callers, ownership) that the change could ripple into.

## Example summary to give the user

Before coding, produce a short summary in this shape so the user can confirm the context is right:

- **Memory:** `<applicable decision/tech-debt entry from memories.md>`
- **Rules:** `<rule files whose Applies to matches the files I'll edit>`
- **Graph:** `<relevant entities/relations, e.g. "ModuleA depends-on ModuleB">`
- **Plan:** `<one or two lines on how I'll follow these while implementing>`

If any layer is empty or silent for this change, say so explicitly (e.g. "no graph entities found for ModuleA") — silence is a finding, not a green light.

## Note

The system is a 4-layer taxonomy of context: (1) project memory `.opencode/memories.md` (narrative/team-shared), (2) `.opencode/rules/*.md` (file-type conventions), (3) MCP memory-graph (atomic structured facts), and (4) personal memory `~/.config/opencode/memories.md` (individual preferences). Load layers 1-3 for every non-trivial change; layer 4 when style/tooling matters.
