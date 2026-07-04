---
name: apply-rules
description: Check the applicable project rules before writing or editing a file. Use right before creating/editing markdown, opencode config (jsonc), or bash scripts to ensure the output conforms to repo conventions.
---

## What I do

Surface the repo rules that apply to a given file type **before** editing, so the output conforms to conventions on the first try.

## When to use me

Use me immediately before writing or editing any file in this repo — especially markdown (`.md`), opencode config (`opencode.jsonc`), and bash scripts (`validation.sh`, `test/*.sh`).

## Process

1. **Identify the target file type** (e.g. `.md`, `.jsonc`, `.sh`, `.json`) and the specific file path. The path often implies the relevant rule (e.g. `validation.sh` -> validation rules).
2. **Read `.opencode/rules/*.md`** and select the entries whose `Applies to` field matches the file type. Each rule file declares what it applies to; match on file extension and on path/location hints.
3. **Creating a NEW rule?** Read `.opencode/rules/rule-format.md` first so the new rule follows the rule schema itself (frontmatter, `Applies to`, sections).
4. **List the active rules** to satisfy, then write/edit the file accordingly. When several rules apply, satisfy all of them; if two conflict, prefer the more specific one and flag the conflict to the user.
5. **Flag conflicts.** If a rule conflicts with the user's request, surface the conflict and ask rather than silently ignoring the rule.

## Worked example

Editing `validation.sh`: the file type is `.sh` and the path is the repo validation script.

1. Identify: `.sh`, path `validation.sh`.
2. Read rules; `validation.md` declares `Applies to: validation.sh, test/*.sh`.
3. List active rules from `validation.md` (e.g. "must run build, scan, test in order; fail fast on error").
4. Edit `validation.sh` to match; confirm the three steps are present and ordered.
5. If the user asks to drop the `scan` step, flag that `validation.md` requires it and ask before changing.

## Rule quick-map

| File type / target | Most relevant rules file |
| --- | --- |
| `*.md` (docs, memory, skills) | `.opencode/rules/markdown-style.md` |
| `opencode.jsonc` | `.opencode/rules/opencode-config.md` |
| new rule file | `.opencode/rules/rule-format.md` |
| memory file (`memories.md`) | `.opencode/rules/memory-format.md` |
| `validation.sh`, `test/*.sh` | `.opencode/rules/validation.md` |

If a referenced rules file does not yet exist, note that to the user and proceed with sensible defaults; do not invent rule content.
