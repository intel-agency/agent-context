#!/usr/bin/env bash
# validation.sh
#
# Local validation gate. Mirrors CI: when this template is specialized onto a
# repo with CI (`.github/workflows/`), keep this script and CI in sync (rule:
# "when adding a CI workflow check, add its equivalent to validation.sh").
#
# Runs three steps in order, fail-fast:
#   1. build  - no-op by default (this template ships markdown + config only);
#               add real build commands (npm run build, dotnet build, etc.) after
#               specialization if the repo has something to compile.
#   2. scan   - markdownlint (if installed) + gitleaks secret scan (if installed).
#               Missing optional tools WARN but do NOT fail the run.
#   3. test   - structural assertions in test/test-memory-system.sh (must pass),
#               including template placeholder integrity.
#
# Usage:
#   ./validation.sh            # run all steps
#   ./validation.sh build      # run a single step: build|scan|test
#
# Exit status: non-zero if any required step fails.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Markdown files "owned" by this system, discovered dynamically so newly added
# rules/commands/skills/docs are linted without editing this list. Agent
# definitions (.opencode/agents/) are excluded: their frontmatter schema
# (mode/permission blocks) is not markdownlint-friendly.
MD_FILES=()
while IFS= read -r f; do
  MD_FILES+=("$f")
done < <(find .opencode docs -type f -name '*.md' \
           -not -path '*/node_modules/*' \
           -not -path './.opencode/agents/*' 2>/dev/null)
[[ -f AGENTS.md ]] && MD_FILES+=("AGENTS.md")

step_build() {
  echo "=== build ==="
  # No-op by default: this template ships markdown + JSONC config + bash only.
  # After specialization, replace with the repo's real build (npm run build, etc.).
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
