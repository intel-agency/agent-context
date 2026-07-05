---
description: Specialize this repo from the agent-context template (detect identity, replace placeholders, validate). Pass --force to skip the re-run warning.
---

The caller wants to specialize this cloned template into a concrete repository. Invoke the `specialize-template` skill and follow it end to end.

$ARGUMENTS

## Routing

- If the arguments contain `--force`, pass that through so the skill skips the already-specialized re-run warning.
- Otherwise run the skill normally; it will warn and ask for confirmation if `specialized` is already `true`.

## Steps

1. Load and follow `.opencode/skills/specialize-template/SKILL.md` exactly.
2. When the skill completes, echo its final report to the caller (variables filled, files changed, validation result, next steps).
3. Do not commit or push; tell the caller to run `/safe-commit` when ready.
