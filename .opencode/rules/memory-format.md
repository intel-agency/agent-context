# Memory-Format Rules

**Owner**: {{OWNER_TEAM}} maintainers | **Last Updated**: 2026-07-03 | **Review Cycle**: Quarterly

## Date every memory entry

- **Applies to**: `.opencode/memories.md` and personal `~/.config/opencode/memories.md`.
- **Rule**: prefix every entry with `[YYYY-MM-DD]` so the timeline is reconstructable.
- **Example**: `- [2026-07-03] Initialized memory & rules system.`

## One atomic fact/decision per entry

- **Applies to**: all memory entries.
- **Rule**: keep each bullet or ADR self-contained — one fact or one decision per entry.
- **Rationale**: atomic entries are easier to search, cite, and deprecate.

## Use ADR format for decisions

- **Applies to**: architecture and design decisions.
- **Rule**: use `### YYYY-MM-DD: Title` followed by `**Decision**`, `**Reasoning**`, and `**Trade-offs**`.
- **Example**:
  ```markdown
  ### 2026-07-03: Markdown Memory vs Knowledge-Graph

  - **Decision**: keep them complementary.
  - **Reasoning**: markdown is narrative and shared; the graph is atomic and queryable.
  - **Trade-offs**: possible duplication if not disciplined.
  ```

## Markdown vs knowledge-graph split

- **Applies to**: all memory writes.
- **Rule**: write NARRATIVE, team-shared, always-relevant context to markdown; write ATOMIC, queryable, structured facts to the MCP memory-graph (`create_entities` / `add_observations`). Do not duplicate the same fact in both. See the AGENTS.md Memory section.
- **Rationale**: each store plays to its strength and avoids drift.

## Search before create

- **Applies to**: all memory writes.
- **Rule**: before adding, read the target file to check for duplicates; prefer editing an existing entry over appending a new one.
- **Rationale**: duplicate facts fragment context and erode trust.
