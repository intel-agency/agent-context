# Patterns and conventions

## Scripting language

All scripts are written in cross-platform PowerShell 7+ (`pwsh`) unless a task specifically requires another language. This is documented in [`.agents/rules/coding-style.md`](../../.agents/rules/coding-style.md) and applies to repo-root scripts, CI/CD steps, and skill scripts alike.

## PowerShell conventions

- `$ErrorActionPreference = 'Stop'` is active in all scripts. Use `throw` for fatal errors, not `Write-Error` + `exit 1`.
- `Set-StrictMode -Version Latest` is active in auth-aware scripts. Access properties via `$obj.PSObject.Properties` (not direct member access) to handle nulls gracefully.
- Use comma-guard (`return ,$value`) when returning arrays to prevent PowerShell from unwrapping single-element arrays.
- `-Repo` parameters validate the `owner/repo` form with regex `^[^/]+/[^/]+$`.

## Error handling

Scripts fail fast. Each validation step in `validation.ps1` throws on the first error and halts the pipeline. Operation scripts in the skill throw on missing fields, broken links, or failed API calls rather than silently continuing.

## Idempotency

All GitHub-mutating scripts match existing resources before creating:

- Labels: matched by name, updated if color/description differs
- Milestones: matched by title, skipped if existing
- Issues: matched by numbered title, skipped if existing
- Sub-issue links: matched by parent/child pair, skipped if existing
- Board fields: set on every run (idempotent update)

This means re-running the skill after editing a plan syncs additions and changes without duplicating existing resources.

## Determinism

Skills prefer scripts over prose steps. The `gh-issue-tracking-init` skill encodes its operations as 11 PowerShell scripts rather than narrative instructions, so every run produces the same output regardless of the agent model or session context.

## Self-contained skills

The `gh-issue-tracking-init` skill vendors its dependencies (`common-auth.ps1`, `import-labels.ps1`, `create-milestones.ps1`) inside its own `scripts/` directory. Copy the skill directory into another repo and it works unmodified. No dependencies on files outside the skill directory.

## Version pinning

GitHub Actions in CI use SHA-pinned references (full 40-character commit SHA with a `# vX.Y.Z` comment). Tag refs like `@v4` or `@main` are prohibited. This is documented in [`.agents/rules/ci-cd.md`](../../.agents/rules/ci-cd.md).

## Validation discipline

All non-trivial changes must pass `./validation.ps1` before committing. The script runs three steps:

1. **Build** - markdownlint + relative link validation
2. **Scan** - PSScriptAnalyzer (error severity) + gitleaks
3. **Test** - Pester with 85% coverage gate + HTML report

The CI pipeline (`.github/workflows/ci.yml`) runs the same script on every push and PR.

## Branch naming

Branches use the form `<prefix>/<name>` (e.g. `mn/new-feature`, `dev/fix-bug`). Pull requests must have a milestone and project set. See [`.agents/rules/source-control.md`](../../.agents/rules/source-control.md) for full details.

## Scratch workspaces

Per-run scratch files (composed drivers, rendered bodies, trace logs) go under `/tmp/kilo/<repo-slug>/`, not loose in `/tmp/kilo/`. This isolates one repo's run from another's. Durable artifacts go under `docs/plans/`, not scratch.
