# Project Memory

> Project memory — decisions, context, and history for this repo. Append with the /remember command. Loaded into every agent session via the opencode.jsonc instructions glob.

## Project Context

- **Name**: agent-context
- **Type**: opencode agent-context/memory reference repo
- **Stack**: opencode CLI, markdown, JSONC, bash, MCP servers (sequential-thinking, memory-graph)
- **Started**: 2026
- **Remote**: intel-agency/agent-context

## Architecture Decisions

### 2026-07-03: Memory & Rules Architecture

- **Decision**: adopted a 4-layer Factory-derived architecture adapted to opencode (memories.md, rules/, skills, commands) loaded via the `instructions` glob in opencode.jsonc.
- **Reasoning**: opencode has no native UserPromptSubmit/PostToolUse hooks, so capture is wired through native commands, skills, and formatters instead.
- **Trade-offs**: capture is manual (`/remember`) rather than automatic; it relies on agent discipline.

### 2026-07-03: Markdown Memory vs Knowledge-Graph

- **Decision**: keep markdown memory and the MCP memory-graph complementary, not competing.
- **Reasoning**: markdown is human-editable, team-shared, narrative, and always-in-context; the MCP memory-graph is agent-managed, atomic, and queryable.
- **Trade-offs**: `/remember` writes markdown only; the same fact could land in both stores if the team is not disciplined.

## Known Technical Debt

- [ ] memory-graph MCP path `/app/.memory/memory.jsonl` in opencode.jsonc is devcontainer-only and won't exist locally.
- [ ] no CI (`.github/` absent) yet.
- [ ] validation.sh is new and minimal.

## Domain Knowledge

- This repo also hosts `ai-new-workflow-app-template/`, a separate, more elaborate opencode GitHub-Actions template, used as a reference (not the active project).

## Environment & Preferences

- **opencode ACP permission prompts are suppressed on the opencode side, NOT Zed.** Zed has NO `always_allow_external_agent_tools` setting — zed-industries/zed PRs #56722 and #57356 were both **closed without merging**, and tracking issue #57355 was closed (verified 2026-07-03). So cards are silenced by setting tool permissions to `allow` in opencode.jsonc (`websearch`, `bash`): opencode then never sends `session/request_permission` to Zed. `deny` rules still apply.

## History

- [2026-07-03] Switched ACP auto-approve from (non-existent) Zed `always_allow_external_agent_tools` to opencode-side `permission.bash: allow` after confirming zed PRs #56722/#57356 were never merged.
- [2026-07-03] Initialized memory & rules system (Factory guide adapted to opencode).
