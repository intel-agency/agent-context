# agent-context overview

`intel-agency/agent-context` is a GitHub template repository that provides the substrate for AI agent development workflows. Each downstream instance is cloned from this template to house a unique application plan and develop it using a structured, agent-driven process.

The repo ships three main things:

1. **An operating manual** (`AGENTS.md`) that tells AI agents how to work in any clone of this repo: coding guidelines, validation rules, source control conventions, delegation patterns, and tool usage.
2. **A memory and rules system** (`.agents/`) with durable project context (`memory.md`), subject-specific rules files (one per topic), and agent skills.
3. **The `gh-issue-tracking-init` skill** that scaffolds a GitHub issue-based planning hierarchy (plan to epic to story to task) with linked sub-issues, a Projects v2 board, milestones, and labels, all driven by idempotent PowerShell scripts.

All scripts are written in cross-platform PowerShell 7+ and use the GitHub CLI (`gh`) for API operations. The repo has 100 tracked files across 120 commits, with 190 Pester tests at 93.91% coverage.

## Quick links

- [Architecture](architecture.md) - system architecture and component relationships
- [Getting started](getting-started.md) - prerequisites, setup, testing
- [Glossary](glossary.md) - project-specific terms
- [How to contribute](../how-to-contribute/index.md) - development workflow and conventions
- [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) - the main skill
- [Memory and rules system](../systems/memory-and-rules.md) - the .agents/ directory
- [Validation pipeline](../systems/validation-pipeline.md) - build, scan, test
