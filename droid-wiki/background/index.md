# Background

This section captures the reasoning behind the repository's shape and the traps that shaped it. The `agent-context` template did not arrive at its current form by accident: every constraint, from branch protection rules to coverage scope, was a deliberate choice made under real conditions, often after a downstream clone exposed a flaw in the previous approach.

The pages here are for anyone who needs to understand not just *what* the repo does but *why* it does it that way, and *where* the sharp edges are.

- [Design decisions](design-decisions.md) - the six load-bearing choices documented in `.agents/memory.md`, with rationale and alternatives considered
- [Pitfalls and danger zones](pitfalls.md) - known limitations, platform quirks, and gotchas that affect how the skill scripts run

For the system-level view of how these decisions manifest in code, see [Architecture](../overview/architecture.md). For the conventions that follow from them, see [Patterns and conventions](../how-to-contribute/patterns-and-conventions.md).
