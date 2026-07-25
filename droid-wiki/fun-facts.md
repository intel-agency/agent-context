# Fun facts

A collection of interesting quirks and notable details about the `intel-agency/agent-context` repository.

## One month, zero to one hundred

The repository went from its first commit to its 120th in exactly 28 days. The first commit landed on June 26, 2026 at 01:20. The most recent commit landed on July 24, 2026 at 16:32. In that window the repo accumulated 100 tracked files, 13,400 lines of code and documentation, 190 Pester tests, and a CI pipeline.

To put that in perspective: the project averaged roughly 4.3 commits per day over its entire lifetime. If you count only the 12 days in July that saw commits, the daily average jumps to about 8 commits per active day. The single busiest day was June 26, which saw 18 commits in under 16 hours.

## The skill is bigger than the scripts it documents

The `gh-issue-tracking-init` skill definition file (`SKILL.md`) is 500 lines and 29 KB. That makes it the largest Markdown file in the repository and larger than all but two of the PowerShell scripts it documents. Only `test-github-permissions.ps1` at 301 lines and `query.ps1` at 284 lines come close among the repo-root scripts, and both are still smaller than the skill definition.

This is not accidental. The SKILL.md file contains the full orchestration logic for the skill: how to read a plan document, how to map plan levels to GitHub issue types, how to call each script, how to handle the body composition and filler detection spec, and how to compose the scripts into an idempotent pipeline. It is effectively the source code for the skill's behavior, written in prose for an AI agent to execute.

## SHA-256 boilerplate detection

The filler detector inside `gh-issue-tracking-init` uses SHA-256 hashing to catch copy-pasted boilerplate across sibling issues. When the skill generates a hierarchy of issues from a plan, each issue gets a body with sections like "Acceptance criteria" and "Validation plan." If multiple sibling issues end up with identical section text, that is a sign of filler rather than meaningful content.

The detector works by computing a SHA-256 hash of each section's body text, combining it with the heading and depth into a composite key, and then flagging any key that appears across multiple issues. The hash is truncated to 16 hex characters for the key, which is more than enough collision resistance for comparing a handful of issue bodies. This approach catches exact duplication. It will not catch paraphrased filler, but it reliably identifies the most common failure mode: a template that was applied without customization.

The filler detector was rewritten on July 21, 2026, when the original regex-based section parser was replaced with a robust line-by-line parser and the heading was added to the hash key to prevent false positives where the same body text legitimately appears under different headings.

## Zero TODO comments in PowerShell

There are zero `TODO`, `FIXME`, or `HACK` comments anywhere in the repository's 25 PowerShell scripts. The 9 occurrences of the word "TODO" in the codebase are all in Markdown documentation, where they refer to the `TodoWrite` tool for tracking work items, not to code debt.

This is a small but meaningful signal. The PowerShell scripts are either done or they are not written yet. When something is deferred, it is tracked in the memory system's "Remember To Do" section or in an archived plan document, not left as a comment in the code. The `readiness-gaps.md` document even proposes adding a `grep -rn "TODO|FIXME|HACK"` step to `validation.ps1` to keep this invariant enforced in CI.

## The spy-agency naming convention

The repository lives under the `intel-agency` GitHub organization. The naming is a deliberate theme: the agents are framed as members of an intelligence agency. The orchestrator dispatches missions, the team-lead runs operations, the developer executes in the field, and the planner briefs on objectives.

This convention extends into the code. The `gh-issue-tracking-init` skill produces a "forensic log" on every run: a timestamped file that records every GitHub API operation for post-execution analysis. The skill enforces a scratch workspace directory for isolation, so each mission's artifacts do not contaminate the repo. The permission verification script is called `test-github-permissions.ps1`, as if checking credentials before an operation.

The theme is playful but the infrastructure is serious. The forensic logging pattern means that when a skill run goes wrong, there is a complete trace of every API call, every parameter, and every response, ready for analysis.

---

See also: [agent-context overview](overview/index.md), [Architecture](overview/architecture.md), [Patterns and conventions](how-to-contribute/patterns-and-conventions.md), [gh-issue-tracking-init](features/gh-issue-tracking-init/index.md), [By the numbers](by-the-numbers.md), [Lore](lore.md).
