# Systems

nam20485

The `agent-context` template is built from four internal systems that work together to keep AI agents productive and consistent across downstream clones. Each system is a set of files and conventions, not a running service, and each is documented on its own page.

## What is on this page

- [Memory and rules system](#memory-and-rules-system) - durable project context and subject-specific conventions under `.agents/`
- [Validation pipeline](#validation-pipeline) - the build, scan, test steps enforced locally and in CI
- [Repository scripts](#repository-scripts) - seven GitHub CLI helper scripts under `scripts/`
- [App stacks](#app-stacks) - three pre-defined tech stack profiles referenced by app development plans

## Memory and rules system

The `.agents/` directory is the single source of truth for project-specific decisions, conventions, and history. It has three parts: `memory.md` (durable context with four sections: Current Activity, Completed Work Items, Decisions, Remember To Do), `rules/` (ten files, one per subject, covering tools, validation, source control, delegation, practices, coding style, skills, scripts, CI/CD, and AI instruction modules), and `skills/` (the `gh-issue-tracking-init` skill). The discipline is to update as you go, never wait until the end. When content is relocated from `AGENTS.md` into a rules file, the `AGENTS.md` section becomes a brief with a link rather than disappearing.

[Memory and rules system](memory-and-rules.md)

## Validation pipeline

The root `validation.ps1` script runs three steps in sequence: build (markdownlint plus relative-link checking), scan (PSScriptAnalyzer for static analysis plus gitleaks for secret scanning), and test (Pester with an 85% coverage gate, JaCoCo XML output, and ReportGenerator HTML report). The GitHub Actions workflow at `.github/workflows/ci.yml` mirrors this exactly: it installs the same tools, runs `validation.ps1`, and uploads the HTML coverage report as an artifact. All actions are SHA-pinned. The CI run completes in about 32 seconds.

[Validation pipeline](validation-pipeline.md)

## Repository scripts

The `scripts/` directory holds seven cross-platform PowerShell 7+ scripts that wrap the GitHub CLI for common operations: authentication bootstrap, label synchronization, PR review-thread management, permission verification, dispatch-issue creation, and remote-instruction-module index regeneration. They share conventions: `Set-StrictMode -Version Latest`, `$ErrorActionPreference = 'Stop'`, dot-sourcing `common-auth.ps1` for auth, `-Repo` validation against the `owner/repo` pattern, and a `-DryRun` switch for previewing actions without mutation.

[Repository scripts](repo-scripts.md)

## App stacks

The `.agents/rules/app-stacks/` directory contains three pre-defined tech stack profiles, each named by a slug ID: `dotnet-aspire-aspnet-blazor` (.NET Aspire web stack), `dotnet-avalonia-xplatform-desktop` (.NET Avalonia cross-platform desktop), and `python-uv-fastapi-vite` (Python FastAPI web stack). App development and implementation plans reference these by slug ID to specify the language, tech stack, tools, and packages to use, so the choice of stack is declared once and resolved consistently.

[App stacks](app-stacks.md)

## Key source files

| Path | What it contains |
| --- | --- |
| `.agents/memory.md` | Project memory (Current Activity, Completed Work Items, Decisions, Remember To Do) |
| `.agents/rules/` | Ten rules files, one per subject |
| `validation.ps1` | Root validation script (build, scan, test) |
| `.github/workflows/ci.yml` | CI pipeline that mirrors `validation.ps1` |
| `scripts/` | Seven repo-root utility scripts |
| `.agents/rules/app-stacks/` | Three tech stack profile files |

## Related pages

- [agent-context overview](../overview/index.md)
- [Architecture](../overview/architecture.md)
- [Getting started](../overview/getting-started.md)
- [Features](../features/index.md)
- [Patterns and conventions](../how-to-contribute/patterns-and-conventions.md)
