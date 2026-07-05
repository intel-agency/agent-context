#!/usr/bin/env bash
# test/test-memory-system.sh
#
# Structural validation tests for the opencode memory + rules system.
# Pure bash + coreutils (awk/grep/head/find) for the hard assertions.
# The emoji check is ADVISORY (best-effort) and never fails the suite.
#
# Run: bash test/test-memory-system.sh
# Exits non-zero if any hard assertion fails.
set -euo pipefail

# ----------------------------------------------------------------------------
# Locate repo root from this script's location so it runs from anywhere.
# ----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# ----------------------------------------------------------------------------
# Counters and reporting primitives.
# ----------------------------------------------------------------------------
PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  echo "  PASS: $1"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "  FAIL: $1${2:+ -- $2}"
}

# expect <description> <check-function> [args...]
# Runs the check function as the condition of `if`, so a non-zero return is
# captured as a failure rather than tripping `set -e`.
expect() {
  local desc="$1"
  shift
  if "$@"; then
    pass "$desc"
  else
    fail "$desc"
  fi
}

# ----------------------------------------------------------------------------
# Frontmatter helpers.
# ----------------------------------------------------------------------------

# Print the trimmed, unquoted value of a YAML frontmatter key, or empty.
get_frontmatter_value() {
  local file="$1" key="$2"
  awk -v k="$key" '
    /^---[[:space:]]*$/ { fm++; next }
    fm == 1 && $0 ~ ("^" k "[[:space:]]*:") {
      line = $0
      sub("^" k "[[:space:]]*:[[:space:]]*", "", line)
      gsub(/^["'\'']+|["'\'']+$/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      print line
      exit
    }
    fm >= 2 { exit }
  ' "$file"
}

# Returns 0 if the file's first line is the frontmatter delimiter "---".
starts_with_frontmatter() {
  local file="$1" first
  first="$(head -n1 "$file")"
  [[ "$first" == "---" ]]
}

# ----------------------------------------------------------------------------
# Assertion check functions (each returns 0 on success, 1 on failure).
# ----------------------------------------------------------------------------

# 1. Each command file: starts with --- frontmatter AND has a description:.
check_command_frontmatter() {
  local file="$1" desc
  starts_with_frontmatter "$file" || return 1
  desc="$(get_frontmatter_value "$file" "description")"
  [[ -n "$desc" ]]
}

# 2a. Skill file: starts with frontmatter and has BOTH name: and description:.
check_skill_has_name_and_description() {
  local file="$1" name desc
  starts_with_frontmatter "$file" || return 1
  name="$(get_frontmatter_value "$file" "name")"
  desc="$(get_frontmatter_value "$file" "description")"
  [[ -n "$name" && -n "$desc" ]]
}

# 2b. Skill name: equals the parent directory name.
check_skill_name_matches_dir() {
  local file="$1" name dir
  name="$(get_frontmatter_value "$file" "name")"
  dir="$(basename "$(dirname "$file")")"
  [[ "$name" == "$dir" ]]
}

# 2c. Skill name matches the lowercase-hyphen regex.
check_skill_name_regex() {
  local file="$1" name
  name="$(get_frontmatter_value "$file" "name")"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

# 3 & 4 & 5. File exists and is non-empty (>0 bytes).
check_file_nonempty() {
  local file="$1"
  [[ -s "$file" ]]
}

# 6a. opencode.jsonc instructions array contains the rules glob and memories.
check_jsonc_instructions() {
  local file=".opencode/opencode.jsonc"
  [[ -f "$file" ]] || return 1
  grep -qF '.opencode/rules/*.md' "$file" \
    && grep -qF '.opencode/memories.md' "$file"
}

# 6b. opencode.jsonc has a top-level "formatter" key (2-space indent = top
# level in this 2-space-indented JSONC file).
check_jsonc_formatter_toplevel() {
  local file=".opencode/opencode.jsonc"
  [[ -f "$file" ]] || return 1
  grep -Eq '^  "formatter"[[:space:]]*:' "$file"
}

# 7. AGENTS.md contains the Memory & Rules System heading.
check_agents_heading() {
  grep -qF '## Memory & Rules System' "AGENTS.md"
}

# ----------------------------------------------------------------------------
# Template placeholder integrity.
# ----------------------------------------------------------------------------
# Reads the `specialized` field of `.opencode/template.config.jsonc` and asserts
# the placeholder state matches:
#   specialized == false -> template is unspecialized, so at least one
#                            {{KEY}} placeholder MUST be present.
#   specialized == true  -> specialization complete, so ZERO {{KEY}}
#                            placeholders may remain anywhere in deliverables.
# Skipped (advisory) when the manifest is absent or the field is unset.
# Matched syntax: {{KEY}} where KEY is [A-Z][A-Z0-9_]* (no internal spaces).
# Docs/prose that need to SHOW the syntax without matching write {{ KEY }} (with
# spaces), which the regex rejects.
TEMPLATE_MANIFEST=".opencode/template.config.jsonc"

get_specialized() {
  [[ -f "$TEMPLATE_MANIFEST" ]] || { echo "missing"; return; }
  if grep -Eq '"specialized"[[:space:]]*:[[:space:]]*true' "$TEMPLATE_MANIFEST"; then
    echo "true"
  elif grep -Eq '"specialized"[[:space:]]*:[[:space:]]*false' "$TEMPLATE_MANIFEST"; then
    echo "false"
  else
    echo "unset"
  fi
}

# Print every {{KEY}} occurrence in the deliverable files. Excludes tooling that
# legitimately documents the mechanism (the manifest itself, this test, and the
# specialize skill/command). Empty output == none found.
scan_placeholders() {
  grep -rEo '[{][{][A-Z][A-Z0-9_]*[}][}]' . \
    --exclude-dir=node_modules --exclude-dir=.git \
    --exclude-dir=specialize-template \
    --exclude=template.config.jsonc \
    --exclude=test-memory-system.sh \
    --exclude=specialize.md 2>/dev/null || true
}

# ----------------------------------------------------------------------------
# Advisory emoji scan (best-effort; never fails the suite).
# Scans the new .md files under .opencode/ (excluding node_modules) plus the
# new docs for glyphs in U+1F000-1FAFF, U+2600-27BF, U+2B00-2BFF.
# ----------------------------------------------------------------------------
emoji_advisory() {
  echo "-- advisory: emoji scan (non-blocking) --"
  local files=()
  local f
  while IFS= read -r f; do
    [[ -f "$f" ]] && files+=("$f")
  done < <(find .opencode -type f -name '*.md' -not -path '*/node_modules/*' 2>/dev/null)
  while IFS= read -r f; do
    [[ -f "$f" ]] && files+=("$f")
  done < <(find docs -type f -name '*.md' 2>/dev/null)

  if ! command -v perl >/dev/null 2>&1; then
    echo "  skipped: perl not available (advisory only, no failure)"
    return 0
  fi

  local hits=0 hit
  for f in "${files[@]}"; do
    while IFS= read -r hit; do
      [[ -n "$hit" ]] || continue
      echo "  WARN emoji: $hit"
      hits=$((hits + 1))
    done < <(perl -Mopen=':std,:utf8' -C -ne '
      while (/([\x{1F000}-\x{1FAFF}\x{2600}-\x{27BF}\x{2B00}-\x{2BFF}])/g) {
        printf "%s:%d:U+%04X\n", $ARGV, $., ord($1);
      }
    ' "$f")
  done

  if (( hits == 0 )); then
    echo "  no emoji glyphs found in scanned files (advisory)"
  else
    echo "  $hits emoji glyph(s) found above (advisory only; suite not affected)"
  fi
}

# ----------------------------------------------------------------------------
# Test execution.
# ----------------------------------------------------------------------------
main() {
  echo "=== memory-system structural tests ==="

  echo "-- commands frontmatter (assertion 1) --"
  shopt -s nullglob
  local cmd_files=(.opencode/commands/*.md)
  shopt -u nullglob
  if (( ${#cmd_files[@]} == 0 )); then
    fail "command files exist" "no .opencode/commands/*.md found"
  else
    for f in "${cmd_files[@]}"; do
      expect "command frontmatter + description: $f" check_command_frontmatter "$f"
    done
  fi

  echo "-- skills frontmatter (assertion 2) --"
  shopt -s nullglob
  local skill_files=(.opencode/skills/*/SKILL.md)
  shopt -u nullglob
  if (( ${#skill_files[@]} == 0 )); then
    fail "skill files exist" "no .opencode/skills/*/SKILL.md found"
  else
    for f in "${skill_files[@]}"; do
      expect "skill has name + description: $f" check_skill_has_name_and_description "$f"
      expect "skill name equals directory: $f" check_skill_name_matches_dir "$f"
      expect "skill name matches lowercase-hyphen regex: $f" check_skill_name_regex "$f"
    done
  fi

  echo "-- memories.md non-empty (assertion 3) --"
  expect ".opencode/memories.md exists and non-empty" check_file_nonempty ".opencode/memories.md"

  echo "-- rules files non-empty (assertion 4) --"
  shopt -s nullglob
  local rule_files=(.opencode/rules/*.md)
  shopt -u nullglob
  if (( ${#rule_files[@]} == 0 )); then
    fail "rule files exist" "no .opencode/rules/*.md found"
  else
    for f in "${rule_files[@]}"; do
      expect "rule file non-empty: $f" check_file_nonempty "$f"
    done
  fi

  echo "-- docs non-empty (assertion 5) --"
  shopt -s nullglob
  local doc_files=(docs/*.md)
  shopt -u nullglob
  if (( ${#doc_files[@]} == 0 )); then
    fail "docs files exist" "no docs/*.md found"
  else
    for f in "${doc_files[@]}"; do
      expect "doc file non-empty: $f" check_file_nonempty "$f"
    done
  fi

  echo "-- opencode.jsonc config (assertion 6) --"
  expect "instructions array includes rules glob + memories" check_jsonc_instructions
  expect "top-level formatter key present" check_jsonc_formatter_toplevel

  echo "-- AGENTS.md heading (assertion 7) --"
  expect "AGENTS.md has '## Memory & Rules System'" check_agents_heading

  echo "-- template placeholder integrity (assertion 8) --"
  if [[ -f "$TEMPLATE_MANIFEST" ]]; then
    local ph_state ph_hits
    ph_state="$(get_specialized)"
    ph_hits="$(scan_placeholders)"
    case "$ph_state" in
      false)
        if [[ -n "$ph_hits" ]]; then
          pass "template mode (specialized=false): placeholders present"
        else
          fail "template mode (specialized=false): no placeholders found" \
               "expected at least one {{KEY}} while unspecialized"
        fi
        ;;
      true)
        if [[ -z "$ph_hits" ]]; then
          pass "specialized mode (specialized=true): no placeholders remaining"
        else
          fail "specialized mode (specialized=true): unresolved placeholders remain"
          printf '%s\n' "$ph_hits" | sed 's/^/    /'
        fi
        ;;
      *)
        echo "  SKIP: 'specialized' field unset in manifest (advisory)"
        ;;
    esac
  else
    echo "  SKIP: no template.config.jsonc (not a template repo; advisory)"
  fi

  echo "-- advisory emoji scan (assertion 9, non-blocking) --"
  emoji_advisory

  echo "=== summary ==="
  echo "Tests: $PASS passed, $FAIL failed"

  if (( FAIL > 0 )); then
    return 1
  fi
  return 0
}

main "$@"
