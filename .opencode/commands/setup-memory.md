---
description: Bootstrap the personal memory + rules layer in ~/.config/opencode (idempotent, does not overwrite)
---

Bootstrap the personal memory and rules layer under `~/.config/opencode/`. This is idempotent: NEVER overwrite an existing file. Perform each step below, creating files only when absent, and report at the end which files were created versus already present.

## Steps

1. Ensure the directory `~/.config/opencode/` exists.

2. Create `~/.config/opencode/memories.md` ONLY if it does not exist. Seed it with exactly:
   ```
   # My Development Memory

   > Personal memory — follows you across all projects. Add with /remember ## <text>.

   ## Preferences

   ## Tool Preferences

   ## Communication Style

   ## Past Decisions
   ```

3. Ensure `~/.config/opencode/rules/` exists. Create two files ONLY if absent:
   - `style.md`:
     ```
     # Personal Style Rules

     - Prefer early returns over deeply nested conditionals.
     ```
   - `tools.md`:
     ```
     # Tool Preferences Rules
     ```

4. Create `~/.config/opencode/AGENTS.md` ONLY if it does not exist, with content:
   ```
   # Personal AGENTS.md

   ## Personal Memory & Rules

   My coding preferences and tool choices live in `memories.md` and `rules/` in this directory; reference them when making style/tooling decisions.
   ```

## Constraints

- CRITICAL: never overwrite existing personal files. If a file already exists, leave it untouched.
- These files live outside the repository and are personal. They must NOT be committed to any repo.

## Report

After running, list every file path with its status: CREATED or ALREADY PRESENT. Confirm to the user that the personal layer is ready and that `/remember ## <text>` can now be used to append personal memories.
