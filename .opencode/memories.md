# Project Memory

> Project memory — decisions, context, and history for this repo. Append with the /remember command. Loaded into every agent session via the opencode.jsonc instructions glob.

## Project Context

- **Name**: {{REPO_NAME}}
- **Type**: {{PROJECT_TYPE}}
- **Stack**: {{STACK}}
- **Started**: {{STARTED_YEAR}}
- **Remote**: {{REMOTE_FULL}}

## Architecture Decisions

### {{SPECIALIZED_DATE}}: Memory & Rules System Bootstrapped

- **Decision**: adopted the agent-context memory & rules architecture (4-layer: project memory `.opencode/memories.md`, rules `.opencode/rules/*.md`, skills, commands; plus the MCP memory-graph for atomic structured facts).
- **Reasoning**: gives every agent session eager-loaded conventions plus narrative context; capture is explicit via `/remember` and skills because opencode has no native auto-capture hooks.
- **Trade-offs**: capture relies on agent discipline (no auto-hook); markdown memory and the knowledge graph can drift if not kept complementary.

## Known Technical Debt

- [ ] `validation.sh` is the only gate; when CI is added keep the two in sync (see `.opencode/rules/validation.md`).

## Domain Knowledge

<!-- Repo-specific domain knowledge (business rules, glossary, architecture notes).
     Captured via /remember or the memory-capture skill. Empty by default. -->

## Environment & Preferences

<!-- Team-wide environment and workflow preferences for THIS repo.
     Personal preferences belong in ~/.config/opencode/memories.md (never committed). -->

## History

- [{{SPECIALIZED_DATE}}] Specialized memory & rules system from the agent-context template.
