# AGENTS.md

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
