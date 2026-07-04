---
name: memory-capture
description: Interactively capture a memory with categorization. Use when the user wants to remember, record, or persist a decision, preference, context, or learning. Chooses category and target file (project vs personal) and writes dated entries in the standard format.
---

## What I do

Capture a memory with the right category, scope, and format, so future sessions and teammates can find and trust it.

## When to use me

Use me when the user says "remember / record / note / save / log this", or after a significant decision, agreement, constraint discovery, or learning worth keeping. Also use me when an atomic structured fact (entity attribute, relationship, stable ID/path) should land in the knowledge graph.

## Process

1. **Determine category.** Ask or infer one of: `Decision`, `Context`, `Preference`, `History`, `Tech Debt`. If unclear, ask the user rather than guessing.
2. **Determine scope.** Project (`/home/nam20485/src/github/intel-agency/agent-context/.opencode/memories.md`) for things the whole team/project needs, or Personal (`~/.config/opencode/memories.md`) for the individual's style/tool preferences. Default to **Project**.
3. **Read the target file first** and check for a duplicate or related entry. Prefer editing/augmenting an existing entry over creating a near-duplicate.
4. **Write using the standard dated format.**
   - Most categories: a dated bullet — `- [YYYY-MM-DD] (Category) ...`
   - Decisions: an ADR block when the reasoning matters.
5. **Offer the knowledge graph for atomic facts.** If the fact is a discrete, structured, reusable attribute (entity attribute, relationship, stable path/URL/ID/version), ALSO offer to store it via the MCP memory-graph `create_entities` / `add_observations` / `create_relations`. Do NOT duplicate narrative prose into the graph. Follow `docs/tool-memory.md`:
   - Search before create — call `search_nodes` / `open_nodes` to find existing entities; prefer `add_observations` over a duplicate `create_entities` (duplicate names are silently ignored, losing new observations).
   - One atomic, self-contained fact per observation; include concrete values (versions, paths, IDs).
   - Active-voice `relationType`; confirm both endpoints exist before `create_relations`.
   - Never store secrets, credentials, tokens, or PII — the store is plaintext.
6. **Confirm.** Report what was saved and where (file path and/or graph entity names), and the category chosen.

## Format reminder

Dated bullet (Project memory):

```
- [2026-07-03] (Preference) Use Conventional Commits for all commit messages on this repo.
```

ADR block (Decision):

```
### 2026-07-03: Use MCP memory-graph for atomic structured facts

**Decision:** Store entity attributes and relationships in the knowledge graph; keep narrative/team-shared context in .opencode/memories.md.

**Reasoning:** The graph de-duplicates and queries atomic facts well; markdown carries rationale and team-shared narrative.

**Trade-offs:** Two stores to keep in sync; mitigated by treating them as complementary (graph = facts, markdown = narrative).
```
