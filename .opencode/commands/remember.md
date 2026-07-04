---
description: Save a memory to project (or personal with ## prefix) memories. Usage /remember <what to remember>
---

The user wants to persist the following text to memory. Append it as a new entry following the steps below.

$ARGUMENTS

## Routing

- If the text above starts with `##`, treat it as PERSONAL: target `~/.config/opencode/memories.md` and strip the leading `##` before saving.
- Otherwise target PROJECT: `.opencode/memories.md` (create the directory if missing).

## Steps

1. Read the target memories file first. If it does not exist, create it with the standard H1:
   - Project: `# Project Memory`
   - Personal: `# My Development Memory`
2. Decide the category of the memory: Decision, Context, Preference, History, or Tech Debt.
3. Append the entry under the most appropriate existing `##` section. If no section fits, create one. Use the dated format:
   `- [YYYY-MM-DD] <text>` (today's date: !`date +%F`)
   - For a Decision, use the ADR block instead:
     ```
     ### YYYY-MM-DD: <Title>
     **Decision:** ...
     **Reasoning:** ...
     **Trade-offs:** ...
     ```
4. Avoid duplicates: scan the file first. If a similar entry already exists, update it in place rather than adding a second copy.
5. Confirm to the user exactly what changed: the file path, the section, and the line(s) added or updated.

Note: Prefer the MCP memory-graph (`memory-graph_create_entities`) for atomic, structured facts and relations. Use this file for narrative, team-shared context that benefits from a human-readable timeline.
