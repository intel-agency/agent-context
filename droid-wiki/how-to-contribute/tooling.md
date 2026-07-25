# Tooling

The repo's tooling spans three layers: a local validation script that mirrors CI, linters and scanners that enforce quality, and MCP tools that give agents structured reasoning and research capabilities. The tool policy lives in `.agents/rules/tools.md` and the CI standards live in `.agents/rules/ci-cd.md`.

## Build system

`validation.ps1` at the repo root is the single entry point for local validation. It runs three steps in order and fails fast on the first error:

```pwsh
./validation.ps1              # all steps (default)
./validation.ps1 -Step build  # build only
./validation.ps1 -Step scan   # scan only
./validation.ps1 -Step test   # test only
```

The script mirrors the CI pipeline in `.github/workflows/ci.yml` exactly. When you change one, update the other to keep them in sync. See [Validation pipeline](../systems/validation-pipeline.md) for the full breakdown of each step.

## Linters

### markdownlint-cli2

Markdown linting uses `markdownlint-cli2` (pinned at version 0.22.1 in CI). Configuration lives in `.markdownlint-cli2.jsonc` at the repo root. The scoped config lints 18 docs-of-record files and excludes plan and issue templates that contain intentional placeholder syntax.

The build step in `validation.ps1` also validates relative Markdown links in `README.md` and `AGENTS.md`, throwing on any broken link.

### PSScriptAnalyzer

PowerShell static analysis uses [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) (minimum version 1.20.0). The scan step runs it against two directories:

- `.agents/skills/gh-issue-tracking-init/scripts/`
- `scripts/`

Errors are blocking: any `Error`-severity finding throws and halts validation. `Warning`-severity findings are reported but non-blocking.

## Secret scanner

[gitleaks](https://github.com/gitleaks/gitleaks) (version 8.21.2 in CI) scans the entire repo for secrets on every run. Configuration lives in `.gitleaks.toml`, which extends the default rule set and allowlists the test fixture file `AssertNoSecrets.Tests.ps1` because it contains intentional fake secrets for testing the scanner itself.

The scan step runs gitleaks with `--redact` so any detected secret is masked in the output rather than printed in full.

See [Security](../security.md) for the full secret-management picture.

## Coverage tools

The test step in `validation.ps1` uses Pester's built-in CodeCoverage to measure how much of the skill's `scripts/` directory is exercised:

1. **Pester CodeCoverage** instruments the run and collects executed-command counts.
2. **JaCoCo XML** output is written to `coverage.xml` at the repo root.
3. **ReportGenerator** (dotnet global tool, version 5.5.10) converts the JaCoCo XML into an HTML report at `coverage-html/`.

The 85% coverage gate is enforced after the report is generated. If coverage is below the threshold, `validation.ps1` throws with a message showing how many more commands need to be executed.

See [Testing](testing.md) for how to run tests and interpret coverage results.

## CI

GitHub Actions runs the pipeline on every push to `development` or `main` and on every pull request. The workflow file is `.github/workflows/ci.yml`.

Two things make the CI supply-chain safe:

- **SHA-pinned actions**: every `uses:` line references a full 40-character commit SHA with a trailing `# vX.Y.Z` comment. Tag refs like `@v4` or `@main` are prohibited because mutable tags are a supply-chain attack vector.
- **Pinned tool versions**: `markdownlint-cli2` is installed at 0.22.1 and gitleaks at 8.21.2, so the CI environment is reproducible.

The pipeline uploads the `coverage-html/` directory as an artifact on every run, even on failure, so coverage reports are always available for download.

See [Deployment](../deployment.md) for the full CI configuration and branch protection setup.

## MCP tools

The agent runtime config in `.opencode/opencode.jsonc` wires up several MCP servers that give agents structured capabilities beyond file editing:

### Sequential-thinking

`@modelcontextprotocol/server-sequential-thinking` externalizes reasoning into discrete, numbered thought steps that can build linearly or be revised and branched mid-stream. Use it for non-trivial, multi-step problems: planning, root-cause analysis, and problems with unclear scope. Do not use it for trivial single-step tasks.

### Memory graph

`@modelcontextprotocol/server-memory` is a persistent knowledge-graph store with three primitives: entities (typed nodes), observations (atomic facts), and relations (directed edges). Use it for durable, reusable context across sessions. Never store secrets or PII because the store is a plaintext local file.

### Z.AI web research

Three remote MCP servers authenticate via the `Authorization: {env:Z_AI_API_KEY}` header:

- **`webSearchPrime`** - web search returning titles, URLs, and summaries. Use for best-practice surveys and factual questions.
- **`webReader`** - fetches a URL and converts it to markdown. Use to read API docs and articles.
- **`zread`** - reads public GitHub repos without cloning. Use for dependency evaluation and "how does library X work?" questions.

### Exa search

A remote MCP server authenticated via `exaApiKey={env:EXA_API_KEY}`. It provides neural web search, code-context lookup, and site crawling as a complement to Z.AI. Use it when Z.AI is rate-limited or when its neural search fits better.

See [Configuration](../reference/configuration.md) for the full config reference and [Dependencies](../reference/dependencies.md) for version details.

## Related pages

- [Testing](testing.md) - running tests and interpreting coverage
- [Validation pipeline](../systems/validation-pipeline.md) - build, scan, test in detail
- [Deployment](../deployment.md) - CI workflow and branch protection
- [Security](../security.md) - secret scanning and branch protection
