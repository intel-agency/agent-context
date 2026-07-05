# OpenCode-Config Rules

**Owner**: {{OWNER_TEAM}} maintainers | **Last Updated**: 2026-07-03 | **Review Cycle**: Quarterly

## Keep instructions glob in sync with memory/rules files

- **Applies to**: `.opencode/opencode.jsonc`.
- **Rule**: the `instructions` array must list `AGENTS.md`, `.opencode/memories.md`, and the `.opencode/rules/*.md` glob; when a new always-on memory/rules file is added, add it here too.
- **Rationale**: this is what eager-loads the layers into every agent session.

## Skill frontmatter: name matches directory

- **Applies to**: `.opencode/skills/<name>/SKILL.md`.
- **Rule**: `name` must be lowercase-hyphenated and equal the `<name>` directory; `description` must be 1-1024 chars. Allowed pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`.
- **Rationale**: opencode uses the directory name to route skill loads; a mismatch silently breaks discovery.

## Command frontmatter: include description

- **Applies to**: `.opencode/commands/*.md`.
- **Rule**: frontmatter must include `description`. In the body, use `$ARGUMENTS` for command arguments and an exclamation-mark-prefixed backtick command (e.g. `` !`cmd` ``) for shell-output injection.
- **Rationale**: `description` drives command discovery and listing.

## Validate JSONC before commit

- **Applies to**: `.opencode/opencode.jsonc`.
- **Rule**: ensure the file parses as JSONC (trailing commas are allowed); never commit a broken config. validation.sh covers this.
- **Rationale**: a broken config breaks every agent session.

## Do not commit personal-layer paths

- **Applies to**: this repository.
- **Rule**: anything under `~/.config/opencode/` is personal and must NOT be committed; only the project `.opencode/` directory is committed.
- **Rationale**: personal settings leak secrets and machine-specific paths.
