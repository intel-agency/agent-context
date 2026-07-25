# Configuration

The repository ships a set of configuration files that control linting, secret scanning, CI, issue tracking, and the agent runtime. This page catalogues each one and its key parameters.

## Config file inventory

| File | Purpose | Format |
|------|---------|--------|
| `.opencode/opencode.jsonc` | Agent runtime: MCP servers, model providers, default agent | JSONC |
| `.markdownlint.json` | Markdown linting rules (base config) | JSON |
| `.markdownlint-cli2.jsonc` | Markdownlint-cli2 globs and override config | JSONC |
| `.gitleaks.toml` | Secret scanning allowlist | TOML |
| `.gitignore` | Git ignore patterns | gitignore |
| `validation.ps1` | Build, scan, test pipeline (parameters below) | PowerShell |
| `.github/workflows/ci.yml` | CI pipeline definition | YAML |
| `.github/CODEOWNERS` | File ownership rules | CODEOWNERS |
| `.github/ISSUE_TEMPLATE/config.yml` | Issue form behavior config | YAML |

## `.opencode/opencode.jsonc`

The OpenCode agent runtime configuration. It defines:

- **Default agent:** `orchestrator`
- **Default model:** `zai-coding-plan/glm-5.2`
- **Small model:** `zai-coding-plan/glm-4.5-air`
- **Instructions:** reads `AGENTS.md`
- **LSP:** enabled
- **Web search permission:** `allow`

MCP servers are configured under the `mcp` key (see [Dependencies](dependencies.md) for the full list). Model providers are configured under the `provider` key with credential resolution from `auth.json` first, then environment variable fallbacks.

## `.markdownlint.json` and `.markdownlint-cli2.jsonc`

Two files work together to control markdown linting:

`.markdownlint.json` is the base rule set:

| Rule | Setting | Effect |
|------|---------|--------|
| MD013 | `false` | Line length not enforced |
| MD024 | `siblings_only: true` | Duplicate headings allowed if not in the same parent |
| MD060 | `false` | No maximum heading count per document |

`.markdownlint-cli2.jsonc` scopes which files get linted. It defines an explicit glob list so intentional placeholder syntax in plan and issue templates is excluded from linting:

- `README.md`
- `AGENTS.md`
- `.agents/memory.md`
- `.agents/rules/**/*.md`
- `docs/*.md`

The same rule overrides (MD013, MD024, MD060) are repeated in the `config` block so the scoped files inherit them.

## `.gitleaks.toml`

Secret scanning configuration for the gitleaks binary. It extends the default gitleaks rule set and adds an allowlist for the one test file that contains intentional fake-secret fixtures:

```toml
[extend]
useDefault = true

[allowlist]
description = "Test fixtures with intentional fake secrets for AssertNoSecrets"
paths = [
    '''\.agents/skills/gh-issue-tracking-init/scripts/tests/AssertNoSecrets\.Tests\.ps1$''',
]
```

This exists because `AssertNoSecrets.Tests.ps1` must contain fake secret-like strings to test that the secret detector catches them. Without the allowlist, gitleaks would flag the test fixtures as real leaks. See [Design decisions](../background/design-decisions.md) for why the binary is used instead of the action.

## `.gitignore`

Standard ignore patterns plus repo-specific entries:

| Category | Patterns |
|----------|----------|
| Agent state | `.kilo/` |
| Forensic logs | `gh-init-*.log` |
| Test artifacts | `testResults.xml`, `coverage/`, `coverage.xml`, `coverage-html/` |
| Scratch files | `scripts/tmp-*.txt` |
| Environment | `.env`, `.env.*`, `!.env.example` |
| Dependencies | `node_modules/` |
| Build artifacts | `bin/`, `obj/`, `dist/`, `build/`, `out/` |
| IDE | `.idea/`, `.vs/`, `*.swp` |
| OS | `.DS_Store`, `Thumbs.db`, `desktop.ini` |
| Local notes | `docs/gpg-non-interactive-signing.md` |

The `!.env.example` negation ensures the example environment file is tracked while real `.env` files are ignored.

## `validation.ps1` parameters

The root validation script mirrors the CI pipeline. It accepts three parameters:

| Parameter | Type | Default | Valid values | Description |
|-----------|------|---------|--------------|-------------|
| `-Step` | string | `all` | `build`, `scan`, `test`, `all` | Which step(s) to run |
| `-CoverageThreshold` | int | `85` | any integer | Minimum coverage percentage; run fails below this |
| `-SkipHtml` | switch | (not set) | (flag) | Skip HTML coverage report generation |

Examples:

```pwsh
./validation.ps1                              # run all steps
./validation.ps1 -Step test                  # run tests only
./validation.ps1 -CoverageThreshold 90       # require 90% coverage
./validation.ps1 -Step all -SkipHtml         # all steps, no HTML report
```

See [Validation pipeline](../systems/validation-pipeline.md) for the full step-by-step breakdown.

## `.github/workflows/ci.yml`

The CI pipeline runs on `ubuntu-24.04` and triggers on push to `development` or `main`, and on all pull requests. It has `permissions: contents: read`.

Steps in order:

1. Checkout (SHA-pinned `actions/checkout@` commit `3d3c42e5...`, tagged `v7.0.1`)
2. Install `markdownlint-cli2@0.22.1` via npm
3. Install gitleaks 8.21.2 (binary download, not the action)
4. Run `./validation.ps1` in `pwsh`
5. Upload `coverage-html/` as an artifact (runs even on failure via `if: always()`)

The artifact upload step uses SHA-pinned `actions/upload-artifact@` commit `043fb46d...`, tagged `v7.0.1`. SHA pinning is mandated by `.agents/rules/ci-cd.md`.

## `.github/CODEOWNERS`

A single line:

```
* @nam20485
```

Every file in the repository is owned by `nam20485`. GitHub will automatically request review from `nam20485` on any pull request. See [Maintainers](../maintainers.md) for the ownership table.

## `.github/ISSUE_TEMPLATE/config.yml`

Controls issue form behavior:

```yaml
blank_issues_enabled: false
contact_links: []
```

Blank issues are disabled, so contributors must use one of the three issue form templates (`bug_report.yml`, `feature_request.yml`, `task.yml`). No contact links are configured. See [Data models](data-models.md) for the issue body templates that the skill uses.

## Related reading

- [Dependencies](dependencies.md) for the tools and packages referenced by these config files
- [Patterns and conventions](../how-to-contribute/patterns-and-conventions.md) for the rules these configs enforce
- [Security](../security.md) for how gitleaks and CODEOWNERS fit into the security posture
