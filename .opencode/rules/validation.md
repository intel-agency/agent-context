# Validation Rules

**Owner**: agent-context maintainers  |  **Last Updated**: 2026-07-03  |  **Review Cycle**: Quarterly

This file governs `validation.sh` and the local validation workflow that every change must pass before commit, mirroring the build/scan/test steps required by AGENTS.md.

## Mirror CI in validation.sh

- **Applies to**: `validation.sh`.
- **Rule**: the script runs build, scan, and test in order, fail-fast on the first error; it mirrors what CI runs. Note: no CI exists yet — when one is added, keep the two in sync.
- **Example**:
  ```bash
  ./build.sh   || exit 1
  ./scan.sh    || exit 1
  ./test.sh    || exit 1
  ```
- **Rationale**: local validation must predict CI outcomes.

## Scan for secrets and markdown issues

- **Applies to**: the scan step of `validation.sh`.
- **Rule**: run gitleaks (if available) and markdownlint (if available); missing tools warn but do not fail the chain unless installed.
- **Rationale**: surface issues without blocking environments that lack the tools.

## Structure tests are mandatory

- **Applies to**: the test step of `validation.sh`.
- **Rule**: the test step asserts that every command and skill has valid frontmatter, the `instructions` glob resolves to existing files, and `memories.md` plus each rules file is non-empty.
- **Rationale**: structural breakage silently breaks agent context loading.

## No failing validation before commit

- **Applies to**: every commit.
- **Rule**: never commit while `validation.sh` exits non-zero; fix or revert first.
- **Rationale**: a red validation gate must never reach the remote.
