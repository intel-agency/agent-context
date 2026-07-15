# Project Memory

## Current Activity

Current project and its sub-work items that we are working on actively. This section is a placeholder for the current project and its work items, which will be updated as we progress. Once completed, the work items will be moved to the "Completed Work Items" section below.

### Project

#### Work Items

## Completed Work Items

### Project: Rules and Memory Consolidation

- **Tool rules consolidation** (2026-07-10): Moved all tool-related information (Sequential-Thinking, Memory, Semantic Search, Z.AI MCP, Exa MCP) from `AGENTS.md` and the two `docs/tool-*.md` guides into a single new `.agents/rules/tools.md`. AGENTS.md `## Tool Usage` section is now a 2-line pointer; `docs/tool-memory.md` and `docs/tool-sequential-thinking.md` were deleted (content merged, not lost). AGENTS.md rules list now includes a `Tools` entry.
- **Additional rules file extraction** (2026-07-10): Created three more rules files from AGENTS.md content — `.agents/rules/delegation.md` (Delegation + Orchestration), `.agents/rules/validation.md` (Validation + Testing + TDD), `.agents/rules/source-control.md` (Committing/Safe Commit/Monitor/Branching/PRs). Each AGENTS.md section slimmed to a brief pointer. Rules list updated: added `Delegation` entry, removed `Testing` entry (merged into validation.md). CI and Scripts entries remain stub references (files not yet created).
- **Practices rules file + relocation directive** (2026-07-10): Combined the remaining three AGENTS.md sections (Planning, Investigation, Making Changes) into `.agents/rules/practices.md`, framed as the 3-stage engineering lifecycle. Added a written directive to AGENTS.md `#### Files` section: when relocating content to a rules file, the section brief's heading/summary must describe what the reader finds, not just name the subject. All AGENTS.md content sections now follow the brief-with-link pattern.
- **Memory and Rules section cleanup** (2026-07-10): Condensed the AGENTS.md `## Memory and Rules` section from 75 to 32 lines. Removed redundant "consult before starting" (was 3×) and "update as you go" (was 3×) restatements. Removed stale Rules#Examples list (had duplicate "validation" entry) and Memory#Examples subsection. Removed non-existent `ci.md` and `scripts.md` from rules file list. Fixed typos ("informatin", "assumptions-", double "is"). Concentrated uppercase/bold emphasis on 3 distinct critical directives. Full file is now 60 lines.

## Decisions

## Remember To Do

Things to plan, add, or change when we are done with the current activity.
