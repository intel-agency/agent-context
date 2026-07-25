# Features

nam20485

The `agent-context` template ships three cross-cutting capabilities that downstream clones inherit and use immediately. Each one is self-contained, documented, and works without additional setup beyond the standard prerequisites (PowerShell 7+, GitHub CLI, environment variables).

## What is on this page

- [gh-issue-tracking-init](#gh-issue-tracking-init) - the skill that scaffolds a GitHub issue planning hierarchy from a plan document
- [Agent definitions](#agent-definitions) - eight OpenCode agent roles with a delegation hierarchy
- [AI instruction modules](#ai-instruction-modules) - local index files that resolve workflow shortIds to canonical remote instructions

## gh-issue-tracking-init

The flagship skill lives at `.agents/skills/gh-issue-tracking-init/`. It parses a development plan placed in `plan_docs/` and builds a full GitHub issue hierarchy: a Plan issue at the top, Epic sub-issues linked to it, Stories linked to each Epic, and Tasks linked to each Story. It also creates a Projects v2 board, milestones, and the 18 canonical labels. Every operation is driven by idempotent PowerShell scripts, so re-running the skill matches existing resources and skips or updates rather than duplicating.

The skill is self-contained: it vendors its own copies of the generic helpers and works unmodified when copied into any downstream clone. See the dedicated page for the full breakdown of its scripts, assets, and design.

[gh-issue-tracking-init](gh-issue-tracking-init/index.md)

## Agent definitions

The `.opencode/agents/` directory contains eight Markdown files, each defining a single agent role with frontmatter (model, permissions, mode) and a system prompt. They form a delegation hierarchy: two primary coordinators at the top (orchestrator and team-orchestrator), one workstream owner (team-lead), and five specialists (planner, developer, code-reviewer, qa-tester, researcher). The coordinators have `edit: deny` enforced in their frontmatter so they physically cannot implement changes; they must delegate. Specialists have scoped permissions matching their job.

[Agent definitions](agent-definitions.md)

## AI instruction modules

The `local_ai_instruction_modules/` directory at the repo root holds two index files: `ai-workflow-assignments.md` and `ai-dynamic-workflows.md`. Each file lists every shortId available in the remote canonical `nam20485/agent-instructions` repo, along with its GitHub UI URL, raw URL, and canonical file path. When a `/command` like `/orchestrate-dynamic-workflow` runs, it reads the local index to resolve the shortId, then fetches the remote `.md` via its raw URL. The script `scripts/update-remote-indices.ps1` regenerates both files from the remote directory listings and writes only if content changed.

[AI instruction modules](ai-instruction-modules.md)

## Key source files

| Path | What it contains |
| --- | --- |
| `.agents/skills/gh-issue-tracking-init/` | The flagship skill directory (scripts, assets, references) |
| `.opencode/agents/` | Eight agent definition Markdown files |
| `local_ai_instruction_modules/ai-workflow-assignments.md` | Workflow assignments index (shortId to URL mapping) |
| `local_ai_instruction_modules/ai-dynamic-workflows.md` | Dynamic workflows index (shortId to URL mapping) |
| `scripts/update-remote-indices.ps1` | Script that regenerates both index files from the remote repo |

## Related pages

- [agent-context overview](../overview/index.md)
- [Architecture](../overview/architecture.md)
- [Patterns and conventions](../how-to-contribute/patterns-and-conventions.md)
- [Memory and rules system](../systems/memory-and-rules.md)
- [Repository scripts](../systems/repo-scripts.md)
