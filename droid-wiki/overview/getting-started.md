# Getting started

## Prerequisites

- **PowerShell 7+** (`pwsh`) - all scripts in this repo are cross-platform PowerShell.
- **GitHub CLI** (`gh`) - authenticated with `repo`, `project`, and `user:email` scopes. Verify with `gh auth status`.
- **Node.js** (optional) - only needed for `markdownlint-cli2` markdown linting.
- **.NET SDK** (optional) - only needed for ReportGenerator HTML coverage reports.

## Setup

1. Create a new repository from this template (or clone it).
2. Set the required environment variables documented in [`docs/environment-variables.md`](../../docs/environment-variables.md). The minimum set:

   ```sh
   export EXA_API_KEY="..."
   export Z_AI_API_KEY="..."
   export GITHUB_AUTH_TOKEN="ghp_..."
   export GITHUB_USERNAME="..."
   ```

3. Read [`AGENTS.md`](../../AGENTS.md) - the operating manual for AI agents working in this repo.
4. Consult [`.agents/memory.md`](../../.agents/memory.md) for project history and current state.

## Running tests

The Pester test suite covers the `gh-issue-tracking-init` skill scripts:

```pwsh
Invoke-Pester -Path .agents/skills/gh-issue-tracking-init/scripts/tests -Output Detailed
```

Expected result: 190 tests passing across six test files.

## Running validation

The full validation pipeline (build, scan, test) runs via:

```pwsh
./validation.ps1
```

This mirrors the CI pipeline exactly. Individual steps:

```pwsh
./validation.ps1 -Step build
./validation.ps1 -Step scan
./validation.ps1 -Step test
```

## Linting

Markdown linting uses `markdownlint-cli2` with configuration in [`.markdownlint-cli2.jsonc`](../../.markdownlint-cli2.jsonc):

```sh
markdownlint-cli2
```

The scoped config lints 18 docs-of-record files and excludes plan/issue templates with intentional placeholder syntax.

## Coverage report

An HTML coverage report is generated at `coverage-html/` by the test step. Open `coverage-html/index.html` in a browser to browse coverage by file and line.

## Using the gh-issue-tracking-init skill

See [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) for details on scaffolding a GitHub issue hierarchy from a plan document.
