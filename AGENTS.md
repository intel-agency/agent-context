# AGENTS.md

## Memory and Rules

This codebase uses a dynamic memory and rules system to capture and provide agents with information, preferences, and other details specific to this project.

- It is represented as a directory structure of markdown files under `.agents/` directory in the root of the repository.

- Consult this before you plan, make changes, or perform work in this project.
- Update it as you work and learn about this project.

### Memory

Memory is for past decisions, choices, and history.

#### Examples

- design decisions
- trade-off choices
- reasons for choosing one approach over another.
- resolution to questions during planning or implementation

#### Files

Memory is a single file is located at `.agents/memory.md`.

### Rules

Rules dictate coding style, tools, source control, validation.

#### Examples

- tools
- coding conventions
- frameworks
- languages
- CI
- testing
- merging
- branching
- validation

#### Files

Rules files are located under the `.agents/rules/` directory, with each file named by the subject it applies to.

**IMPORTANT** When working on a file, performing actions or implementation, check the relevant rules files first.

Follow the conventions documented in `.factory/rules/`:

- **TypeScript**: `.factory/rules/typescript.md`
- **React**: `.factory/rules/react.md`
- **Testing**: `.factory/rules/testing.md`
- **API Design**: `.factory/rules/api.md`
- **Security**: `.factory/rules/security.md`

---

## Validation

All changes must be validated.

- Changes should be validated as they are implemented.
- All changes must be validated before committing.

### Steps

The following steps must be run as part of validation:

- build
- scan
- test

A validation script must be maintained to run these steps automatically (i.e. `validation.sh`, `validation.ps1`, etc.).

- It should mirror exactly what is run in the CI/CD pipeline.
- Update the local and CI/CD copies to keep them in sync with any changes.

### Missing Validation Script

If an agent needs to run validation and the expected script (e.g. `validation.ps1`, `validation.sh`) does not exist:

1. **Create the script** before proceeding with any validation. Write it at the repository root with the platform-appropriate extension (`.ps1` for Windows, `.sh` for Unix).
2. **Implement the three steps** — `build`, `scan`, `test` — in the order listed. Each step must fail fast (non-zero exit) on error so the script stops immediately.
3. **Make it executable** (`chmod +x validation.sh` on Unix; on Windows ensure the execution policy allows it).
4. **Commit the script** as its own change before running it, so CI/CD picks it up on the same branch.
5. **Mirror CI/CD** — inspect any existing pipeline configuration (e.g. `.github/workflows/`, `azure-pipelines.yml`) and ensure the script commands match what CI runs. If no CI config exists, choose sensible defaults for the project's language/framework and document the choices in a comment at the top of the script.

### Testing

An automated test suite must be maintained.

- Test results and coverage reports should be generated automatically.
- Test Coverage levels must be maintained as new code is added.
- Test coverage level must be > 85% at all times.

#### Test Driven Development (TDD)

When implementing new features, TDD should be used.

- Implement failing tests to cover the required functionality.
- Implement changes to make the tests pass.
- Iterate creating tests and implementing changes to make them pass until the required functionality is implemented.

## Committing

### Safe Commit

- Always run the `/safe-commit` skill before committing.

### Monitor Workflows

- After pushing, monitor the workflows to ensure they are running as expected.
- If a workflow fails, investigate and fix the issue before proceeding.
- Repeat the process until all workflows are running as expected.

### Branching

- Create a new branch for each feature or bug fix.
- Use a descriptive branch name that reflects the work being done.
- Use the form `<base-branch-prefix>/<branch-name>`, i.e. `mn/new-feature` or `dev/<branch-name>`.

### Pull Requests

- Create a pull request for each branch.
- Use a descriptive title and description that reflects the work being done.
- Request a review from the appropriate team member before merging.
- Once reviews have left comments, address all comments before merging.
- For each comment that is addressed, leave a comment explaining the resolution and mark the thread as RESOLVED state.
- ADDRESS ALL COMMENTS BEFORE MERGING.

## Delegation

- Delegate work to the appropriate subagent type when possible.
- Prefer to delegate work if you are the top-level agent, esp. if your agent type is not relevant to the current task.
- Delegate to parallel agents to speed up work and reduce implementation time.

## Orchestration

Use orchestration agents to **decompose and delegate** work instead of implementing it all yourself. Pick the **smallest layer** that fits the scope — do not spawn a higher layer for work a lower one (or you directly) can handle.

- `orchestrator` — top-level coordinator for multi-step, multi-agent tasks. Breaks the work into a dependency graph and dispatches units to specialists (`planner`, `developer`, `code-reviewer`, `qa-tester`, `researcher`) in parallel batches. Use as the default for non-trivial, multi-part work.
- `team-lead` — owns a **single workstream** (one feature/epic/fix) end-to-end: reviews the plan, assigns specialists, and enforces the definition of done. Use when the work fits within one accountable owner.
- `team-orchestrator` — runs a **program of multiple parallel workstreams** by delegating each to a `team-lead` and managing cross-team dependencies. Use only for efforts too large for one `team-lead`; otherwise delegate straight to a `team-lead`.

## Making Changes

- Always make the smallest most surgical change possible.
- Only make changes that are necessary to fix the issue at hand.
- Ignore areas that are not relevant to the current task.

## Investigation

- Never guess at the cause of an issue.
- Always investigate the issue using first-hand sources, i.e. logs, code, output.
- Do not make or report assertions without specific details, i.e. line numbers, files, log messages, etc., to back up your claims.
- Do not determine or start implementing a solution until you have decisively found the root cause.

## Planning

- Always create a plan before starting any non-trivial task (e.g. >= 3 steps or >= 5 minutes of work)
- Present plans for approval before starting any non-trivial task.
- Always use TODO lists to track work to be done.
- Mark TODO items as complete when they are done.
- Present summary after completing all plans/tasks.

## Tool Usage

Detailed guidance for each tool lives in [`docs/`](docs/); the rules below are the project-specific decision points.

Always use your sequential-thinking and Memory knowledge-graph for all non-trivial tasks.

### Sequential-Thinking

Use `sequentialthinking` for non-trivial, multi-step problems (planning, root-cause analysis, problems with unclear scope). Do **not** use it for trivial single-step tasks. Full usage guide: [`docs/tool-sequential-thinking.md`](docs/tool-sequential-thinking.md).

### Memory

Use the Memory knowledge-graph (`@modelcontextprotocol/server-memory`) for **durable, reusable context only** — never transient scratch state or secrets/PII (the store is plaintext). Search before creating to avoid duplicates; keep observations atomic, specific, and active-voiced. Full usage guide: [`docs/tool-memory.md`](docs/tool-memory.md).

### Semantic Search (Codebase Indexing)

The `semantic_search` tool (powered by Kilo Code's codebase indexing) finds code by **meaning**, not by exact text. It uses AI embeddings to rank semantic code blocks (functions, classes, methods, markdown sections) against a natural-language query, returning ranked matches with file paths and line ranges.

**Prerequisite:** Codebase indexing is enabled and available for this project. The tool errors only if the index is disabled or empty; otherwise assume it is ready.

**When to use `semantic_search` — prefer it as the first probe when you:**

- Are exploring an **unfamiliar** code area before you know exact identifiers.
- Are looking for a feature, behavior, or **intent** ("authentication logic", "database connection setup", "error handling patterns", "API endpoint definitions", "rate limiting").
- Want to locate **conceptually related** implementations or similar code patterns spread across the codebase.
- Need to **narrow a large codebase** before following up with `Grep` / `Glob` / `Read`.

**When NOT to use it — pick the specialized tool instead:**

- Exact symbol, regex, or keyword lookups → `Grep`.
- Finding files by name or extension (e.g. `**/*.ts`, `*.config.js`) → `Glob`.
- Reading a file whose path you already know → `Read`.
- Exploring files **outside** the current workspace → `Grep` / `Glob` / `Read` (`semantic_search` is workspace-scoped).

**How to query:**

- Write the query in **natural language, in English** (e.g. "where are user sessions validated before API access?").
- Prefer **specific, descriptive** phrasing over vague nouns. "Redis retry/backoff handling" beats "redis".
- To restrict results to a subdirectory, pass the `path` argument (relative to the workspace root). Leave it empty for a whole-workspace search.
- After getting ranked matches, follow up with `Read` (to inspect the returned line ranges) or `Grep` (to enumerate exact occurrences of an identifier you discovered).

**Tuning (optional, set in `indexing` under `kilo.jsonc`):**

- `searchMaxResults` (default `50`) — lower for faster, more focused results; raise for broader context.
- `searchMinScore` (default `0.4`) — raise to require closer matches; lower to surface tangentially related code.

Full guide: [Codebase Indexing](https://github.com/Kilo-Org/kilocode/blob/main/packages/kilo-docs/pages/customize/context/codebase-indexing.md).

### Web & Repository Research (Z.AI MCP)

These three **remote** Z.AI MCP servers authenticate via the `Authorization: {env:Z_AI_API_KEY}` header and require no local install. Use them for reliable, structured external information retrieval instead of ad-hoc fetching.

- **`web-search-prime`** → `webSearchPrime` — Web search returning titles, URLs, summaries, site names, and icons. Use for best-practice surveys, competitive analysis, dependency/API research, and factual questions needing current external info. Key params: `content_size` (`medium` default, `high` for comprehensive), `location` (`cn` / `us`), `search_domain_filter` (whitelist a domain), `search_recency_filter` (`oneDay` / `oneWeek` / `oneMonth` / `oneYear` / `noLimit`). Keep queries ≤ 70 chars.
- **`web-reader`** → `webReader` — Fetches a URL and converts it to large-model-friendly input (markdown/text/html). Returns page title, main content, metadata, and optional link/image summaries. Use to read API docs, articles, release notes, and reference pages. Prefer this over generic `webfetch` when available.
- **`zread`** — Reads **public** GitHub repositories without cloning: `search_doc` (search docs/issues/commits/PRs/contributors), `get_repo_structure` (directory tree + file list), and `read_file` (full file contents). Use for dependency evaluation, "how does library X work?" questions, and issue/commit history lookups. Requires `owner/repo` names; only public repos are supported.

Decision points:

- Need current facts from the open web → `webSearchPrime`, then `webReader` to drill into a specific result.
- Need to understand an open-source repo → `zread` first (`get_repo_structure` + `search_doc`), then `read_file` for implementation details.
- For broad, multi-source surveys, delegate to the `researcher` subagent; use these tools directly for quick, single-shot lookups.

### Exa Search (MCP)

The **remote** Exa MCP server authenticates via `exaApiKey={env:EXA_API_KEY}` and requires no local install. Use it as a complement to Z.AI when its neural search, code-context, or crawling fits better.

- **`web_search_exa`** — Keyword/neural web search. Fallback when Z.AI `webSearchPrime` is rate-limited.
- **`web_search_advanced_exa`** — Filtered search (date, domain, text-match, count). Scoped queries.
- **`web_fetch_exa`** — Fetch a URL to clean markdown/text. Alternative to Z.AI `webReader`.
- **`get_code_context_exa`** — Code context (functions, types, usage) for "how is X used?" before `zread` for full files.
- **`crawling_exa`** — Crawl multiple pages of a site; collect a doc subsite in one call.

Prefer Z.AI `webSearchPrime`/`webReader` as the default for single-shot lookups; reach for Exa when its neural search, code-context, or crawling fits better.
