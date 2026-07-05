# Markdown-Style Rules

**Owner**: {{OWNER_TEAM}} maintainers | **Last Updated**: 2026-07-03 | **Review Cycle**: Quarterly

## No emojis in content

- **Applies to**: all `.md` files.
- **Rule**: never use emoji anywhere in content.
- **Rationale**: matches existing repo style and keeps diffs clean.

## Fence code with a language

- **Applies to**: all fenced code blocks.
- **Rule**: every fenced block declares a language (` ```bash `, ` ```jsonc `, ` ```markdown `, etc.).
- **Example**:
  Correct:
  ```bash
  echo hello
  ```
  Avoid:
  ```
  echo hello
  ```
- **Rationale**: enables syntax highlighting and satisfies markdownlint rule MD040.

## Use YAML frontmatter where opencode expects it

- **Applies to**: `.opencode/commands/*.md` and `.opencode/skills/*/SKILL.md`.
- **Rule**: frontmatter must include the required fields — `description` for commands; `name` and `description` for skills. See opencode-config.md for the field rules.
- **Rationale**: opencode parses frontmatter to register commands and skills.

## One sentence per line in lists, wrap prose ~120 cols

- **Applies to**: all `.md` files.
- **Rule**: keep each bullet item on a single line; avoid mid-sentence hard wraps in paragraphs.
- **Rationale**: cleaner diffs and easier editing.

## Prefer tables for mappings

- **Applies to**: reference and comparison content.
- **Rule**: when content is a key/value or feature-by-option mapping, use a markdown table instead of prose.
- **Rationale**: tables are scannable and agent-friendly.
