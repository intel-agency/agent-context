# AGENTS.md

## Validation

All changes must be validated.

- Changes should be validated as they are implemented.
- All changes must be validated before committing.

### Steps

The follwing steps must be run as part of validation:

- build
- scan
- test

A validation script must be maintained to run these steps automatically (i.e. `validation.sh`, `validation.ps1`, etc.).
- It should be mirror what is run in the CI/CD pipeline.

### Testing

An automated test suite must be maintained. 

- Test results and coverage reports should be generated automatically.
- Test Coverage levels must be maintained as new code is added.

#### Test Driven Development (TDD)

When implementing new features, TDD should be used.

- Implement failing tests to cover the required functionality.
- Implemment changes to make the tests pass.
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
- Prefer to delegate work if you are the top-level agent, esp. if you're agent type is not relevant to the current task.
- Delegate to parallel agents to speed up work and reduce implementation time.

## Making Chnages

- Always make the smallest most surgical change possible.
- Only make changes that are necessary to fix the issue at hand.
- Ignore areas that are not relevant to the current task.

## Investigation 

- Never guess at the cause of an issue. 
- Always invesitage the issue by using first hand sources,i.e. logs, code, output.
- Do not make or report assertins withoutspecific details, i.e. line numbers, files, log messages, etc. toi backup your claims.
- Do not determine or start implementing a solution until you have decesively found the root cause.

## Planning

- Always create a plan before starting any non-trivial task (e.g. >= 3 steps or >= 5 minutes of work)
- Present plans for approval before starting any non-trivial task.
- Always use TODO lists to track work to be done. 
- Mark TODO items as complete when they are done.
- Present summary after completing all plans/tasks.

## Tool Usage

### Sequential-Thinking

Sequential-Thinking (`sequentialthinking`) externalizes reasoning into discrete, numbered thought steps that can build linearly *or* be revised, branched, and extended mid-stream. It is for dynamic, reflective problem-solving — not for generating one-shot answers.

**When to use it**

- Use it for problems that benefit from structured reasoning: breaking down complex problems into steps, planning/design with room for revision, analysis that may need course correction, problems whose full scope is not clear initially, multi-step solutions, tasks needing context maintained over many steps, and filtering out irrelevant information.
- Do **not** use it for trivial, single-step tasks where a one-shot answer suffices.

**How to use it well**

- Start with an initial `totalThoughts` estimate, but treat it as adjustable — you can revise it up or down as you progress.
- Let each thought build on the previous ones, but you are not locked into a linear path.
- Generate a hypothesis, then verify it within the chain; repeat until you reach a satisfactory answer.
- Express uncertainty explicitly when present, and ignore information irrelevant to the current step.

**Revision and branching**

- **Revise** (`isRevision: true`, `revisesThought: <n>`) when questioning, course-correcting, or changing a previous decision. Feel free to question or revise previous thoughts.
- **Branch** (`branchFromThought: <n>`, `branchId: "<id>"`) to explore an alternative approach or assumption non-linearly while leaving the original line of reasoning intact.

**Adjusting and terminating**

- Use `needsMoreThoughts: true` if you reach the planned end but realize more reasoning is required — don't hesitate to add more thoughts even at the "end".
- Only set `nextThoughtNeeded: false` when truly done and a satisfactory answer has been reached; provide a single, ideally correct answer as the final output.
- Control flow with `nextThoughtNeeded` — don't rely on the thought count alone (if `thoughtNumber` exceeds `totalThoughts`, the server auto-bumps `totalThoughts` to match).

### Memory

Memory is a persistent knowledge-graph store (`@modelcontextprotocol/server-memory`) that survives across sessions and chats. Its data model is three primitives:

- **Entities** — typed nodes with a unique `name`, a specific `entityType`, and a list of `observations`.
- **Observations** — discrete string facts attached to an entity. **One fact per observation.**
- **Relations** — directed edges (`from` → `to`) with a `relationType`, always stored in **active voice**.

Use Memory for **durable, reusable context**, not transient scratch state (which belongs in TODO lists/chat).

**When to store**

- Store durable facts: entity attributes, project/repository structure, decisions **and their rationale**, cross-component relationships, ownership, locations/paths/URLs/IDs, stable conventions.
- Do **not** store secrets, credentials, tokens, or PII — the store is a plaintext local file.
- Do **not** store large blobs, logs, or full file contents — store a reference (path/URL) instead.
- Do **not** dump chat transcripts or transient task progress — keep the graph high-signal.

**Search before create (de-duplicate)**

- Before creating any entity, call `search_nodes` (fuzzy match) and/or `open_nodes` (exact name) to find existing matches.
- Prefer adding observations to an existing entity (`add_observations`) over creating a duplicate — `create_entities` silently ignores names that already exist, so a duplicate create loses the new observations.
- Before creating a relation, confirm both endpoints exist; `create_relations` skips exact duplicates automatically.

**Writing good observations and relations**

- Make each observation **atomic and self-contained** — it should make sense read in isolation.
- Be **specific and concrete**: include values, IDs, versions, paths, URLs (e.g. `"uses PostgreSQL 16, host db.internal:5432"` beats `"uses a database"`).
- Avoid vague judgements like `"is important"` — state the constraint or reason instead.
- Use **active voice** for `relationType` (`"ServiceA calls ServiceB"`, not `"ServiceB is called by ServiceA"`) and reuse consistent verb phrases across the graph.

**Entity naming and types**

- Use **unique, stable entity names** (the name is the identifier; renaming is not supported — delete and recreate).
- Use **specific, consistent `entityType` values** (e.g. `microservice`, `cli-tool`, `adr`, `team`) rather than a generic `thing`.

**Maintenance**

- When a fact changes or is contradicted, **delete the stale observation** (`delete_observations`) and add the corrected one.
- Remove obsolete entities (`delete_entities` cascades to their relations) and obsolete edges (`delete_relations`).
- Keep the graph tidy; don't let it bloat with low-value noise.
