---
name: specialize-template
description: Specialize this repo after cloning the agent-context template. Detects git identity + stack, asks for the rest, replaces every {{VARIABLE}} placeholder, renames the workspace file, flips the template marker, and runs validation. Use on first run after cloning this template into a real repo.
---

## What I do

Turn the generic agent-context template into a repo-specific setup in one pass: detect what can be detected, ask for what cannot, substitute every placeholder, then prove it with `validation.sh`.

## When to use me

Run me **once, right after cloning** this template into a real repository (before doing any real work in it). Also re-runnable later if the repo is renamed or the team/stack changes — I will warn and ask for confirmation first because re-running overwrites customizations that originated from placeholders.

## Inputs

- `.opencode/template.config.jsonc` — the manifest. It declares each variable (description, detection method, whether to ask) and the `specialized` flag that I flip at the end.
- If `specialized` is already `true`, this is a RE-run: warn the caller that re-specializing will overwrite any hand-edits made inside placeholder values, and require explicit confirmation before proceeding (unless the caller passed `--force`).

## Process

### 1. Guard

Read `.opencode/template.config.jsonc`. If `"specialized"` is `true`, tell the caller this repo has already been specialized and that re-running may overwrite local edits to formerly-placeholder text. Stop unless they confirm (or supplied `--force`). If the manifest is missing entirely, this is not a template repo — stop and say so.

### 2. Detect (do not ask)

Run the auto-detections below. Record each value. If a detection fails (e.g. no `origin` remote, no commits), leave that variable empty and fall back to asking.

| Variable           | Detection                                                            |
| ------------------ | -------------------------------------------------------------------- |
| `REPO_NAME`        | `basename "$(git rev-parse --show-toplevel)"`                        |
| `REPO_OWNER`       | from origin remote (see parsing note)                                |
| `REMOTE_FULL`      | `REPO_OWNER/REPO_NAME` derived from the origin remote                |
| `STARTED_YEAR`     | `git log --reverse --format=%cs \| head -1 \| cut -d- -f1`           |
| `SPECIALIZED_DATE` | `date +%F` (today)                                                   |
| `HAS_CI`           | `true` if `.github/workflows/` exists and is non-empty, else `false` |

Origin-remote parsing (handles SSH and HTTPS, with or without trailing `.git`):

```bash
remote="$(git remote get-url origin 2>/dev/null)"
slug="$(printf '%s' "$remote" | sed -E -e 's#\.git$##' -e 's#^[a-zA-Z][a-zA-Z0-9+.-]*://[^/]+/##' -e 's#^[^:]+:##')"   # -> owner/repo
# slug is now owner/repo
owner="${slug%%/*}"
repo="${slug#*/}"
```

### 3. Infer, then ask

Infer `STACK` and `PROJECT_TYPE` from the file tree, then **ask** the caller to confirm or edit each, plus ask for `OWNER_TEAM`. Always ask these three (prefilled with the inference / `REPO_OWNER`).

Stack inference (extend as needed):

| Marker file                          | Stack hint                                               |
| ------------------------------------ | -------------------------------------------------------- |
| `package.json`                       | Node.js / JavaScript (or TypeScript if `typescript` dep) |
| `*.csproj`, `*.sln`                  | .NET / C#                                                |
| `go.mod`                             | Go                                                       |
| `Cargo.toml`                         | Rust                                                     |
| `pom.xml`, `build.gradle`            | Java                                                     |
| `requirements.txt`, `pyproject.toml` | Python                                                   |
| `*.tsx`, `*.jsx`                     | React                                                    |

Suggested `PROJECT_TYPE` prefilled from the dominant stack (e.g. "TypeScript React web app", "Python service", or "markdown + config repo" when no app code is present). `OWNER_TEAM` prefilled from `REPO_OWNER`.

### 4. Substitute placeholders

Replace every `{{ KEY }}` occurrence (no spaces inside the braces — the matched syntax is `{{[A-Z][A-Z0-9_]*}}`) with its value across the deliverable files. Prose in docs that intentionally shows the syntax uses `{{ KEY }}` _with_ spaces; leave those untouched (they are not placeholders).

Recommended approach (deterministic, fast):

```bash
declare -A V=(
  [REPO_NAME]="..."      [REPO_OWNER]="..."   [REMOTE_FULL]="..."
  [STARTED_YEAR]="..."   [SPECIALIZED_DATE]="$(date +%F)"
  [OWNER_TEAM]="..."     [PROJECT_TYPE]="..." [STACK]="..."
)
mapfile -t FILES < <(grep -rlE '[{][{][A-Z][A-Z0-9_]*[}][}]' . \
  --include='*.md' --include='*.sh' --include='*.jsonc' --include='*.code-workspace' \
  --exclude-dir=node_modules --exclude-dir=.git \
  --exclude-dir=specialize-template \
  --exclude=template.config.jsonc \
  --exclude=test-memory-system.sh \
  --exclude=specialize.md 2>/dev/null)
for f in "${FILES[@]}"; do
  for k in "${!V[@]}"; do
    esc="${V[$k]//&/\\&}"                       # escape & (sed replacement metachar)
    sed -i "s|{{${k}}}|${esc}|g" "$f"           # | delimiter: safe unless a value contains |
  done
done
```

If any value contains `|` (unlikely for these variables), switch the sed delimiter or escape it. You may instead use the edit tool per occurrence — slower but equally valid.

### 5. Conditional features

- **Workspace file.** Rename `template.code-workspace` (if present) to `${REPO_NAME}.code-workspace`. Use `git mv` when the file is tracked.
- **Code rules (optional, ask).** If `STACK` indicates application code (TypeScript, React, Python, etc.), offer to copy the matching rules from `docs/rules-examples.md` into `.opencode/rules/` (each as its own file) and add the new file(s) to the `instructions` glob in `opencode.jsonc`. Only do this with caller confirmation.
- **CI note (report only).** If `HAS_CI` is false, mention in the final report that CI is absent and `validation.sh` is the only gate; suggest adding `.github/workflows/` and keeping it in sync. If true, remind that `validation.sh` must mirror what CI runs.

### 6. Flip the marker

Edit `.opencode/template.config.jsonc` and change `"specialized": false` to `"specialized": true`. Leave the rest of the manifest intact (it documents what was specialized and enables future re-runs/warns).

### 7. Validate

Run `./validation.sh`. The placeholder-integrity assertion now enforces the specialized state: **zero** `{{KEY}}` placeholders may remain in deliverables. If it fails, the output lists the offending occurrences — fix them (they are files the substitution missed) and re-run. Do not declare success while `validation.sh` exits non-zero.

## Report

Tell the caller exactly what changed:

- Each detected/asked variable and its final value.
- The list of files substituted.
- The workspace rename (old → new).
- Any code rules activated (or that the offer was declined).
- `validation.sh` final result (exit 0, tests passed count).
- One-line next steps: `/setup-memory` for the personal layer, `/remember` to start capturing.

## Notes

- Never commit or push — that is the caller's job (use `/safe-commit`).
- The manifest, this skill, and the `/specialize` command are intentionally left in the specialized repo so re-runs and the warn-on-rerun guard keep working.
- Placeholder syntax reference: `{{KEY}}` (no spaces) is substituted and scanned; `{{ KEY }}` (spaces) is documentation-only and never matched.
