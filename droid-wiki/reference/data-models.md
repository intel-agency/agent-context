# Data models

The repository defines several structured data formats that flow through the skill scripts and the planning hierarchy. This page documents the canonical node schema, the label taxonomy, the issue body templates, and the app stack definition format.

## Canonical node schema

When the `gh-issue-tracking-init` skill parses a plan document, it produces a tree of nodes. Each node conforms to this schema, documented in `.agents/skills/gh-issue-tracking-init/SKILL.md`. The skill asserts the presence of required fields before rendering so that omissions fail loudly in preview rather than creating empty-titled issues.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Level` | string | yes | One of `plan`, `epic`, `story`, `task` |
| `Title` | string | yes | Full numbered title (e.g. `Story 1.1: Bootstrap`) or the parts to build it (`N`/`M`/`K`, `Name`) |
| `Labels` | string[] | yes | Level label plus priority and area labels |
| `Milestone` | string | yes for epic/story | Conceptual work group name (e.g. `MVP`, `UI`) |
| `Priority` | string | no | One of `P0`, `P1`, `P2`, `P3` |
| `Phase` | string | no | Cross-cutting phase value, only if the plan uses phases |
| `BodyFile` | string | after rendering | Path to the rendered template body file, passed to `ensure-issue.ps1 -BodyFile` |
| `Prereqs` | string[] | no | Array of sibling keys for blocking dependencies (story/task level) |

Title numbering follows a strict convention:

| Level | Format |
|-------|--------|
| Plan | `Plan: <Name>` |
| Epic | `Epic <N>: <Name>` |
| Story | `Story <N>.<M>: <Name>` |
| Task | `Task <N>.<M>.<K>: <Name>` |

See [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) for how these nodes are created and linked.

## Label taxonomy

The canonical label set ships in `.agents/skills/gh-issue-tracking-init/assets/labels.json` as a JSON array of 18 labels. Each entry has a `name`, `color` (hex), and `description`. The `ensure-labels.ps1` script imports them into the target repo.

| Label | Color | Category | Description |
|-------|-------|----------|-------------|
| `plan` | `5319e7` | Level | Top-level application plan issue |
| `epic` | `1d76db` | Level | Epic (project/component) |
| `story` | `0e8a16` | Level | Story |
| `task` | `fbca04` | Level | Atomic task |
| `P0` | `b60205` | Priority | Critical |
| `P1` | `d93f0b` | Priority | High |
| `P2` | `fbca04` | Priority | Medium |
| `P3` | `c2e0c6` | Priority | Low |
| `area/ai` | `5319e7` | Area | AI / inference |
| `area/ui` | `1d76db` | Area | UI |
| `area/core` | `0052cc` | Area | Core |
| `area/infra` | `006b75` | Area | Infrastructure / DevOps |
| `area/docs` | `bfdadc` | Area | Documentation |
| `blocked` | `b60205` | Status | Blocked by another issue |
| `needs-review` | `fbca04` | Status | Awaiting review |
| `wontfix` | `ffffff` | Status | Will not be worked on |
| `gh-issue-tracking:direct-body` | `6f42c1` | Trigger | Dispatch the issue body verbatim as a prompt |
| `gh-issue-tracking:init-success` | `1a7f37` | Signal | Skill completed successfully; hierarchy initialized |

The four categories are Level, Priority, Area, and Status/Signal. Workflow state lives in the Project `Status` field, not in labels. The `gh-issue-tracking:init-success` label is the orchestration hand-off signal: a downstream orchestrator matches it to learn the hierarchy is ready.

## Issue body templates

The skill fills templates from `.agents/skills/gh-issue-tracking-init/assets/templates/` to produce issue bodies. Each template is a Markdown skeleton with placeholders that must be filled with plan-derived content, not boilerplate.

| Template | Target issue | Key sections |
|----------|-------------|--------------|
| `application-plan.md` | Plan (top-level) | Implementation Plan, Development Standards, Exact package versions, Repository layout |
| `epic.md` | Epic | Epic Stories, Implementation Plan, Brief Technology Stack, Risk Mitigation Strategies |
| `story.md` | Story | Objective, Scope, Plan, Acceptance Criteria, Validation Plan, Dependencies, Test Strategy |
| `task.md` | Task | Task-specific implementation details |

The `story.md` template illustrates the structure. Its sections include Objective, Scope (In Scope / Out of Scope), Plan (Implementation approach with a `Reference` fenced block for verbatim plan snippets, plus a Tasks list), Acceptance Criteria, Validation Plan, Validation Commands, Dependencies, Risks and Mitigations, Test Strategy, Rollback, and Implementation Notes.

The skill enforces a filler prohibition: no two sibling issues may share a body section whose text is byte-identical unless that section is genuinely common cross-cutting content placed canonically on the Plan body. A DryRun filler detector flags section bodies byte-identical across 3 or more sibling issues. See [Pitfalls and danger zones](../background/pitfalls.md) for the runtime quirks that affect template rendering.

## App stack definitions

Pre-defined language and tech stack profiles live in `.agents/rules/app-stacks/`, one file per stack, named by slug ID. Development plans reference a stack by slug to specify the language, tools, and packages to use.

Three stacks are available:

| Slug ID | Language | Stack summary |
|---------|----------|---------------|
| `dotnet-aspire-aspnet-blazor` | .NET C# | .NET Aspire + ASP.NET Core + Blazor WebAssembly + PostgreSQL (EF Core) |
| `dotnet-avalonia-xplatform-desktop` | .NET C# | .NET Avalonia cross-platform desktop |
| `python-uv-fastapi-vite` | Python | uv + FastAPI + Vite frontend + PostgreSQL (SQLAlchemy) |

Each stack file follows a consistent section structure. The `dotnet-aspire-aspnet-blazor.md` file demonstrates the format:

| Section | Content |
|---------|---------|
| Platform | `web` (or `desktop`) |
| OS | List of supported operating systems (Windows, Linux, macOS) |
| Language | Primary language (e.g. `.NET C#`, `Python`) |
| Stack | Stack name or template description |
| Package Management | Package manager (e.g. `nuget`, `uv`) |
| Backend | Backend frameworks (e.g. ASP.NET Core, FastAPI) |
| Frontend | Frontend technology (e.g. Blazor WebAssembly, Vite + React/Vue/Svelte) |
| Database | Database and ORM (e.g. PostgreSQL with EF Core or SQLAlchemy) |
| Packages | List of additional packages |
| Containerization | Container tools (e.g. Docker, Docker Compose) |
| Testing | Test frameworks (e.g. xUnit, Pytest) |
| Linting | Linter/formatter (e.g. dotnet format, ruff) |
| CI | CI system (e.g. GHA workflows) |

Some stacks include additional sections. The `python-uv-fastapi-vite` stack adds a Type Checking section (`basedpyright`) that the .NET stacks do not need.

## Related reading

- [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) for how these data models flow through the skill
- [Glossary](../overview/glossary.md) for definitions of plan, epic, story, and task
- [Memory and rules system](../systems/memory-and-rules.md) for how app stacks are referenced from AGENTS.md
