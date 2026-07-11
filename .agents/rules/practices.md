# Orientation, Planning, Investigation, and Making Changes

The disciplined engineering lifecycle: orient to context before starting, plan before acting, investigate root causes using first-hand sources, and make the smallest surgical changes possible.

## Orientation

When starting a new project, session, task, or answering questions, always orient yourself to the project's history and current state first.

**Do not perform any work or proceed with any tasks without understanding the history and context.**

Inspect the following to orient yourself:

- **Memory Tools** — query the Memory knowledge-graph: `memory_search_nodes` to find relevant entities by keyword, `memory_read_graph` to browse the whole graph, and `memory_open_nodes` to open specific entities.
- **Memory Context File** — read `.agents/memory.md` (Current Activity, Completed Work Items, Decisions, Remember To Do) for the project's current state and history.
- **Plans** — glob and read `plan_docs/`, `docs/plans/`, and `docs/` for existing plans, specs, and design docs relevant to the task.
- **Uncommitted changes** — run `git status` and `git diff` to see pending work in the working directory.
- **Recent commits** — run `git log --oneline -10` to see the latest work and conventions in the current branch.

## Planning

- Always create a plan before starting any non-trivial task (e.g. >= 3 steps or >= 5 minutes of work).
- Present plans for approval before starting any non-trivial task.
- Always use TODO lists to track work to be done.
- Mark TODO items as complete when they are done.
- Present summary after completing all plans/tasks.

## Investigation

- Never guess at the cause of an issue.
- Always investigate the issue using first-hand sources, i.e. logs, code, output.
- Do not make or report assertions without specific details, i.e. line numbers, files, log messages, etc., to back up your claims.
- Do not determine or start implementing a solution until you have decisively found the root cause.

## Making Changes

- Always make the smallest most surgical change possible.
- Only make changes that are necessary to fix the issue at hand.
- Ignore areas that are not relevant to the current task.
