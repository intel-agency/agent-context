# Glossary

## Template and clone

- **Template repo** - This repository (`intel-agency/agent-context`). The substrate from which downstream instances are cloned.
- **Clone instance** - A repository created from this template, seeded with a unique application plan. Any repo other than `agent-context` is a clone instance.
- **Downstream clone** - Same as clone instance. Used when describing the cloning pipeline.

## Planning hierarchy

- **Plan** - The top-level issue in the hierarchy. One per project. Title format: `Plan: <Name>`.
- **Epic** - A major work group within a plan. Often maps to a "Phase" in the source plan document. Title format: `Epic <N>: <Name>`.
- **Story** - An atomic, independently-completable work item within an epic. Title format: `Story <N>.<M>: <Name>`.
- **Task** - An optional sub-tier beneath stories, only when the plan nests a sub-tier. Title format: `Task <N>.<M>.<K>: <Name>`.
- **Sub-issue** - GitHub's mechanism for parent/child issue linking. The hierarchy uses sub-issues exclusively, never issue-linked task lists.

## Memory and rules system

- **Memory** - Durable project context stored at `.agents/memory.md`. Four sections: Current Activity, Completed Work Items, Decisions, Remember To Do.
- **Rules** - Subject-specific convention files under `.agents/rules/`. One file per topic (tools, validation, source control, etc.).
- **Skill** - A self-contained agent capability following the Agent Skills specification. Lives under `.agents/skills/` with `SKILL.md`, `scripts/`, `references/`, and `assets/`.

## Validation

- **Build step** - Markdown linting and relative link validation.
- **Scan step** - PSScriptAnalyzer static analysis (error severity) and gitleaks secret scanning.
- **Test step** - Pester test suite with code coverage and an 85% threshold gate.
- **JaCoCo** - Coverage output format (XML) produced by Pester's code coverage feature.
- **ReportGenerator** - Tool that converts JaCoCo XML into browsable HTML coverage reports.

## Agent infrastructure

- **OpenCode** - The agent runtime that reads `opencode.jsonc` for model providers, MCP servers, and agent definitions.
- **Agent definitions** - YAML-like markdown files under `.opencode/agents/` defining agent roles (orchestrator, team-lead, developer, etc.).
- **MCP servers** - Model Context Protocol servers configured in `opencode.jsonc` for tools like sequential-thinking, memory-graph, web search, and code reading.
- **Workflow assignments** - ShortId-to-URL mappings in `local_ai_instruction_modules/ai-workflow-assignments.md` that resolve `/commands` to canonical instruction files.
- **Dynamic workflows** - ShortId-to-URL mappings in `local_ai_instruction_modules/ai-dynamic-workflows.md` for parameterized workflow templates.

## gh-issue-tracking-init specific

- **Forensic log** - Per-run log file (`gh-init-<slug>-<timestamp>.log`) recording every GitHub API call and operation outcome for post-execution analysis.
- **DryRun** - Preview mode for all operation scripts. Shows what would be created without making any API calls.
- **Filler detection** - Automated check that flags body sections byte-identical across 3+ sibling issues, indicating template boilerplate was pasted instead of plan-derived content.
- **Orchestration signal label** - `gh-issue-tracking:init-success` label applied to the Plan issue on a successful apply run. A downstream orchestrator matches it to know the hierarchy is ready.

## App stacks

- **App stack** - A pre-defined language and tech stack profile in `.agents/rules/app-stacks/`, referenced from app development plans to specify the language, tools, and packages to use. Named by slug ID (e.g. `dotnet-aspire-aspnet-blazor`).
