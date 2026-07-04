#!/usr/bin/env bash
# validation.sh
#
# Local validation gate for the agent-context repo.
#
# Mirrors CI. IMPORTANT: no CI pipeline (`.github/`) exists for this repo yet,
# so the steps below are the canonical checks. When CI is added, keep it in sync
# with this script (rule: "when adding a CI workflow check, add its equivalent
# to validation.sh").
#
# Runs three steps in order, fail-fast:
#   1. build  - for this markdown/config repo there is nothing to compile.
#   2. scan   - markdownlint (if installed) + gitleaks secret scan (if installed).
#               Missing optional tools WARN but do NOT fail the run.
#   3. test   - structural assertions in test/test-memory-system.sh (must pass).
#
# Usage:
#   ./validation.sh            # run all steps
#   ./validation.sh build      # run a single step: build|scan|test
#
# Exit status: non-zero if any required step fails.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Files considered "ours" for markdown linting (the memory + rules system).
MD_FILES=(
  ".opencode/memories.md"
  ".opencode/rules/rule-format.md"
  ".opencode/rules/markdown-style.md"
  ".opencode/rules/opencode-config.md"
  ".opencode/rules/memory-format.md"
  ".opencode/rules/validation.md"
  ".opencode/commands/remember.md"
  ".opencode/commands/review-memory.md"
  ".opencode/commands/setup-memory.md"
  ".opencode/skills/memory-capture/SKILL.md"
  ".opencode/skills/context-aware-implementation/SKILL.md"
  ".opencode/skills/apply-rules/SKILL.md"
  "docs/memory-system.md"
  "docs/rules-examples.md"
  "AGENTS.md"
)

step_build() {
  echo "=== build ==="
  # This repo is markdown + JSONC config + bash only; there is nothing to compile.
  echo "build: ok (nothing to compile)"
}

step_scan() {
  echo "=== scan ==="
  local rc=0

  # markdownlint (optional)
  if command -v markdownlint >/dev/null 2>&1; then
    echo "markdownlint: running"
    markdownlint "${MD_FILES[@]}" || rc=1
  else
    echo "markdownlint: not installed (skipped; advisory only)"
  fi

  # gitleaks secret scan (optional)
  if command -v gitleaks >/dev/null 2>&1; then
    echo "gitleaks: running"
    # --no-git: scan the working tree as-is, independent of git history/index.
    gitleaks detect --no-git --redact --source . --config .gitleaks.toml || rc=1
  else
    echo "gitleaks: not installed (skipped; advisory only)"
  fi

  if (( rc != 0 )); then
    echo "scan: FAILED"
    return 1
  fi
  echo "scan: ok"
}

step_test() {
  echo "=== test ==="
  bash test/test-memory-system.sh
}

main() {
  local target="${1:-all}"
  case "$target" in
    build) step_build ;;
    scan)  step_scan ;;
    test)  step_test ;;
    all)
      step_build
      step_scan
      step_test
      ;;
    *)
      echo "usage: $0 [build|scan|test|all]" >&2
      exit 2
      ;;
  esac
}

main "$@"
