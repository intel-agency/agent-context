# Memory & Rules System

This is the canonical guide to the memory and rules architecture used in this repo. It is adapted from Factory's "memory management" and "rules & conventions" guides, re-expressed in opencode-native primitives (no Factory/Droid runtime required). The whole system reduces to one distinction: **rules** say _how to write_ (prescriptive, enforceable); **memory** says _what and why_ (descriptive, narrative). Everything else is plumbing to load, capture, and enforce those two stores.

## Architecture

Four primary layers sit under `AGENTS.md`, with two cross-cutting mechanisms (commands and the formatter) wiring capture and enforcement back into them. All project-layer paths are relative to the repo root; personal-layer paths are under `~/.config/opencode/`.

```text
                          AGENTS.md  (build / test / run + orchestration)
                               |
   +---------------------------+---------------------------+-------------+
   |                           |                           |             |
 Rules                     Memory                       Skills        Commands
 (HOW to write)          (WHAT & WHY)               (task how-tos)   (capture)
 .opencode/rules/*.md    .opencode/memories.md      .opencode/       .opencode/
   |                       |                          skills/*/        commands/*.md
   |                       |                          SKILL.md           |
   +----------+------------+                          |                  |
              |                                       |                  |
   loaded eager via the `instructions` glob      apply-rules       /remember
   in opencode.jsonc                             context-aware-    /review-memory
   (AGENTS.md + memories.md + rules/*.md)        implementation    /setup-memory
                                                       |
                                            memory-capture -----> MCP memory-graph
                                                                (atomic/queryable,
                                                                 complementary)
              |
   enforcement: native `formatter` (auto-runs on write/edit) +
                 structural checks in validation.sh
```

## The four layers

| Layer         | Purpose                                                                       | Location                      | Loaded                         |
| ------------- | ----------------------------------------------------------------------------- | ----------------------------- | ------------------------------ |
| **Rules**     | Prescriptive conventions: _how to write_ code, config, and docs in this repo. | `.opencode/rules/*.md`        | Eager, via `instructions` glob |
| **Memory**    | Descriptive context: _what and why_ — decisions, history, domain knowledge.   | `.opencode/memories.md`       | Eager, via `instructions` glob |
| **AGENTS.md** | Build, test, run instructions plus orchestration and tool policy.             | `AGENTS.md`                   | Eager, via `instructions` glob |
| **Skills**    | Task how-tos that load on demand when a task matches.                         | `.opencode/skills/*/SKILL.md` | Lazy, on match                 |

Cross-cutting mechanisms (not context layers themselves, but how context is captured and enforced):

| Mechanism     | Role                                                                   | Location                           |
| ------------- | ---------------------------------------------------------------------- | ---------------------------------- |
| **Commands**  | Capture surfaces — user-invoked entry points that write to the layers. | `.opencode/commands/*.md`          |
| **Formatter** | Native auto-enforcement — reformats files on every write/edit.         | `opencode.jsonc` `formatter` block |

## Factory to opencode mapping

| Factory concept                      | opencode equivalent                          | Notes                                                                                          |
| ------------------------------------ | -------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `.factory/memories.md`               | `.opencode/memories.md`                      | Same role: project-wide narrative memory, dated entries.                                       |
| `.factory/rules/`                    | `.opencode/rules/*.md`                       | Loaded eager via the `instructions` glob (see `opencode-config.md`).                           |
| `~/.factory/` (personal layer)       | `~/.config/opencode/`                        | Outside the repo; bootstrapped by `/setup-memory`; never committed.                            |
| `UserPromptSubmit` auto-capture hook | `/remember` command + `memory-capture` skill | opencode has **no** native `UserPromptSubmit` hook, so capture is explicit and user-driven.    |
| `PostToolUse` lint hook              | Native `formatter` feature                   | opencode runs configured formatters automatically on write/edit; no separate lint hook needed. |
| `/remember` slash command            | `.opencode/commands/remember.md`             | Appends a dated entry; `##` prefix routes to personal memory.                                  |
| Memory-aware implementation skill    | `context-aware-implementation` skill         | Loads memory + rules + graph before implementing a non-trivial change.                         |

## Markdown memory vs knowledge graph

This repo runs both a markdown memory file and an MCP knowledge-graph server. They are **complementary**, not competing — pick the store that plays to its strength and never duplicate the same fact in both.

| Use markdown memory (`.opencode/memories.md`) when...    | Use the MCP memory-graph when...                                                                    |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| The content is narrative, with reasoning and trade-offs. | The content is an atomic, structured fact (entity attribute, relationship, stable ID/path/version). |
| It is team-shared and should be always in context.       | It should be queryable (`search_nodes`, `read_graph`) and agent-managed.                            |
| A human-readable timeline matters.                       | You need de-duplication and cross-entity relations.                                                 |

Two rules keep them from drifting:

- **`/remember` writes markdown only.** It never touches the graph. Use the `memory-capture` skill (or call `memory-graph_create_entities` / `add_observations` directly) when a fact belongs in the graph.
- **Don't duplicate.** If a fact is in the graph, do not also narrate it in markdown; reference the graph entity instead. See `memory-format.md` "Markdown vs knowledge-graph split".

For the full graph usage guide (primitives, search-before-create, active-voice relations, no-secrets), see [docs/tool-memory.md](tool-memory.md).

## Rule format

Every rule entry uses the standard template below. Full details and the deprecation format live in [`.opencode/rules/rule-format.md`](../.opencode/rules/rule-format.md).

```markdown
## [Rule Name]

- **Applies to**: <concrete file types or contexts, e.g. *.md, opencode.jsonc, bash scripts>
- **Rule**: <one-sentence prescriptive statement>
- **Example**:
  Correct:
  <fenced example>
  Avoid:
  <fenced example>
- **Rationale**: <why this rule exists>
```

Each rules file starts with an ownership header directly under its H1:

```markdown
# <Domain> Rules

**Owner**: <team> | **Last Updated**: <YYYY-MM-DD> | **Review Cycle**: Quarterly
```

To retire a rule, strike the heading through, append `(DEPRECATED)`, and add `**Reason**:` + `**Replacement**:` lines — never delete silently, because agents may have cached the old rule.

## Memory format

Memory entries are either a dated bullet (most categories) or an ADR block (decisions where reasoning matters). Full rules live in [`.opencode/rules/memory-format.md`](../.opencode/rules/memory-format.md).

Dated bullet:

```markdown
- [2026-07-03] (Context) The memory-graph path is devcontainer-only.
```

ADR block:

```markdown
### 2026-07-03: <Title>

- **Decision**: <what was decided>
- **Reasoning**: <why>
- **Trade-offs**: <what was given up>
```

Every entry is prefixed `[YYYY-MM-DD]` and holds one atomic fact or decision. Search the target file before adding to avoid duplicates.

## Capture surfaces

Three user-invoked commands and three on-demand skills move information into the layers.

| Surface                        | Kind    | Purpose                                                                                                            |
| ------------------------------ | ------- | ------------------------------------------------------------------------------------------------------------------ |
| `/remember <text>`             | Command | Append a dated entry to project memory (`## <text>` routes to personal memory). Writes markdown only.              |
| `/review-memory`               | Command | Maintenance review of project + personal memory, rules, and the graph; reports proposed edits, never applies them. |
| `/setup-memory`                | Command | Bootstrap the personal layer in `~/.config/opencode/` (idempotent, never overwrites).                              |
| `memory-capture`               | Skill   | Interactively capture a memory: pick category + scope, write in standard format, offer the graph for atomic facts. |
| `context-aware-implementation` | Skill   | Load memory + rules + graph _before_ implementing a non-trivial change; flag conflicts rather than overriding.     |
| `apply-rules`                  | Skill   | Surface the rules that apply to a file type _before_ editing it, so output conforms on the first try.              |

## Enforcement

Two mechanisms keep the layers consistent, with different scope:

- **Native formatter (auto, on edit).** opencode's `formatter` feature runs configured formatters automatically whenever a file is written or edited. In this repo prettier is configured for `.md` and `.json`, so style is enforced without an agent having to remember it. This replaces Factory's `PostToolUse` lint hook.
- **Structural validation (gate, on demand).** `validation.sh` runs the build/scan/test chain required by `AGENTS.md`. Its test step additionally asserts structural integrity: every command and skill has valid frontmatter, the `instructions` glob resolves to files that exist, and `memories.md` plus each rules file is non-empty. See [`.opencode/rules/validation.md`](../.opencode/rules/validation.md).

There is **no** native markdown-lint hook in opencode; `markdownlint` (if installed) runs as part of the scan step of `validation.sh`, not automatically on edit.

## Setup

The project layer is committed to the repo, so collaborators get rules + memory automatically. The personal layer is yours alone.

1. **Project layer** — nothing to do; it loads via the `instructions` glob the first time you open a session.
2. **Personal layer** — run `/setup-memory`. It creates `~/.config/opencode/memories.md`, `~/.config/opencode/rules/{style,tools}.md`, and `~/.config/opencode/AGENTS.md` (idempotent; never overwrites existing files). These live outside the repo and are never committed.
3. **Start capturing** — use `/remember <text>` for project facts, `/remember ## <text>` for personal facts, or invoke the `memory-capture` skill for guided categorization.

## Maintenance

Each layer has a review cadence. Run `/review-memory` to perform all of them; it reports proposed edits and waits for approval before applying anything.

| Layer                     | Cadence   | Focus                                                                                      |
| ------------------------- | --------- | ------------------------------------------------------------------------------------------ |
| Project + personal memory | Monthly   | Overturned decisions, resolved tech debt, missing domain knowledge.                        |
| Rules                     | Quarterly | Rules now auto-enforced by formatting (removal candidates), stale examples, wording drift. |
| Knowledge graph           | Monthly   | Stale, duplicated, or contradicted observations; prune or update in place.                 |

## Known limitations

- **No native auto-capture or lint hooks.** opencode exposes neither `UserPromptSubmit` nor `PostToolUse` hooks, so capture is explicit (`/remember`, `memory-capture`) and lint is replaced by the native `formatter`. This relies on agent discipline.
- **Memory-graph store is repo-local by default.** `MEMORY_FILE_PATH` points at `.opencode/.memory/memory.jsonl` (gitignored). A devcontainer may override it to `/app/.memory/memory.jsonl`; if so, keep the two in sync.
- **CI may be absent.** If `.github/workflows/` does not exist, `validation.sh` is the only (local) gate; when CI is added, keep it in sync with `validation.sh`.
- **Eager glob loading may not scale.** Loading `AGENTS.md` + `memories.md` + every rule eagerly is fine for this repo's rule count. For very large rule sets, switch to the lazy `@file` read-on-demand pattern (taught via `AGENTS.md`) instead of globbing every rule into context.

## Quick reference

File locations:

| What                                                | Where                                                     |
| --------------------------------------------------- | --------------------------------------------------------- |
| Project memory                                      | `.opencode/memories.md`                                   |
| Project rules                                       | `.opencode/rules/*.md`                                    |
| Commands                                            | `.opencode/commands/*.md`                                 |
| Skills                                              | `.opencode/skills/*/SKILL.md`                             |
| opencode config (instructions glob, formatter, MCP) | `.opencode/opencode.jsonc`                                |
| Build/test/run + orchestration                      | `AGENTS.md`                                               |
| Personal memory                                     | `~/.config/opencode/memories.md`                          |
| Personal rules                                      | `~/.config/opencode/rules/`                               |
| Knowledge graph store                               | `.opencode/.memory/memory.jsonl` (repo-local, gitignored) |
| Graph usage guide                                   | `docs/tool-memory.md`                                     |

When to add:

| Event                                 | Record what                           | Where                                             |
| ------------------------------------- | ------------------------------------- | ------------------------------------------------- |
| Made an architecture decision         | decision + reasoning + trade-offs     | project memory (ADR block)                        |
| Discovered a user/machine preference  | the preference                        | personal memory                                   |
| Learned a repo convention             | the convention as a prescriptive rule | `.opencode/rules/` (+ add to `instructions` glob) |
| Resolved a tricky issue               | solution + context                    | project memory                                    |
| Captured a stable entity/relationship | atomic structured fact                | MCP memory-graph                                  |
