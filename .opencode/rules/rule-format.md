# Rule-Format Rules

**Owner**: agent-context maintainers  |  **Last Updated**: 2026-07-03  |  **Review Cycle**: Quarterly

## Use the standard rule format

- **Applies to**: every entry in `.opencode/rules/*.md`.
- **Rule**: each rule uses a `## [Rule Name]` heading followed by `**Applies to**:`, `**Rule**:`, `**Example**:`, and an optional `**Rationale**:`.
- **Example**:
  ````markdown
  ## Fence code with a language

  - **Applies to**: all fenced code blocks.
  - **Rule**: every fenced block declares a language.
  - **Rationale**: enables syntax highlighting and linting.
  ````
- **Rationale**: consistency aids agent retrieval and human scanning.

## State applicability explicitly

- **Applies to**: every rule.
- **Rule**: always fill `**Applies to**:` with concrete file types or contexts (e.g. `*.md`, `opencode.jsonc`, `bash scripts`).
- **Rationale**: agents must know precisely when a rule fires.

## Include correct/incorrect examples

- **Applies to**: rules that govern formatting or syntax.
- **Rule**: pair a Correct example with an Avoid example using fenced code blocks.
- **Example**:
  Correct:
  ````jsonc
  { "name": "value", }
  ````
  Avoid:
  ````
  { name: "value" }
  ````
- **Rationale**: contrast is faster to learn than description alone.

## Add ownership & review cycle

- **Applies to**: every rules file.
- **Rule**: start each file with the `**Owner** | **Last Updated** | **Review Cycle**` header line directly under the H1.
- **Rationale**: makes stewardship and staleness visible at a glance.

## Deprecate, don't delete silently

- **Applies to**: any rule that becomes obsolete.
- **Rule**: strike the heading through, append `(DEPRECATED)`, and add `**Reason**:` and `**Replacement**:` lines.
- **Example**:
  ````markdown
  ## ~~Old rule name~~ (DEPRECATED)
  - **Reason**: superseded by the opencode.jsonc schema.
  - **Replacement**: see opencode-config.md "Keep instructions glob in sync".
  ````
- **Rationale**: preserves history for agents that may have cached the old rule.
