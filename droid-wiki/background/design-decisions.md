# Design decisions

The decisions below are recorded in `.agents/memory.md` and represent the load-bearing choices that shaped this repository. Each was made under a specific constraint, often after a real downstream clone or CI run exposed a flaw in the prior approach. The rationale is preserved here so future contributors understand the trade-offs, not just the outcome.

## Admin bypass for branch protection

**Date:** 2026-07-24

The readiness report recommended requiring at least one approving review on `development` and `main`. The problem is that GitHub forbids self-approval, and `nam20485` is the sole maintainer and admin on this repository. A no-bypass one-approval rule would make every pull request unmergeable: there is no second person to approve it.

**Chosen approach:** A GitHub ruleset named `protect-development-and-main` covering `refs/heads/development` and `refs/heads/main` with three rules: `deletion`, `non_fast_forward`, and `pull_request` (one approving review, with required review thread resolution). Admin bypass is enabled via `RepositoryRole` id 5 in `always` mode.

This means agents and non-admin tokens must still open pull requests and get reviews, but the admin retains the ability to push and merge directly when needed. The alternative, dropping the review requirement entirely, would have provided no protection at all.

## Coverage gate scope: entire scripts directory (Option C)

**Date:** 2026-07-24

`.agents/rules/ci-cd.md` mandates greater than 85% code coverage. Three scope options were on the table:

| Option | Scope | Tests needed | Resulting coverage |
|--------|-------|--------------|--------------------|
| A | Two fully-tested files only | 0 | 93% |
| B | All 3 tested files | ~5 | 87% |
| C | Entire scripts directory | ~60 | 85% |

**Chosen approach:** Option C. The entire `.agents/skills/gh-issue-tracking-init/scripts` directory is in scope, not just the files that were already well-tested. This honestly reflects the full codebase and does not game the gate by excluding under-tested files.

The result exceeded the target: 93.91% coverage (802 of 854 commands) across all 11 skill scripts, achieved by 89 new Pester tests written by 3 parallel worker subagents. The coverage gate now measures the real surface area, not a cherry-picked subset.

## Gitleaks binary over gitleaks-action

**Date:** 2026-07-24

The CI workflow uses the gitleaks binary (downloaded directly in `.github/workflows/ci.yml`) instead of the `gitleaks/gitleaks-action` GitHub Action.

**Reason:** The action requires a paid `GITLEAKS_LICENSE` for organization repositories like `intel-agency`. The binary is free and functionally identical for `detect` mode. A `.gitleaks.toml` config file at the repo root allowlists the two intentional fake-secret fixtures in `AssertNoSecrets.Tests.ps1` so the scanner does not flag test data.

## Rules restructuring of local_ai_instruction_modules/

**Date:** 2026-07-18

The legacy `local_ai_instruction_modules/` directory contained instruction modules that had drifted out of sync with the rules system. The restructuring consolidated it:

**Deleted (4 stale modules):**
- `ai-custom-agents.md` - 25-subagent taxonomy that conflicts with `.agents/rules/delegation.md`
- `ai-delegation-mandate.md` - 75% coverage and "FORBIDDEN direct execution" rules that conflict with `.agents/rules/delegation.md`
- `ai-development-instructions.md` - references nonexistent `AGENTS.md mandatory_tool_protocols` and stale `mcp_*` tooling
- `ai-terminal-commands.md` - stale

**Kept (2 modules):**
- `ai-workflow-assignments.md` - path is hard-coded by `scripts/update-remote-indices.ps1` and the `/commands` that resolve shortIds
- `ai-dynamic-workflows.md` - same hard-coded dependency

**Salvaged (2 facts):**
- SHA-Pinned Actions rule moved to `.agents/rules/ci-cd.md`
- CLI error-triage pattern moved to `.agents/rules/practices.md`

Two new rules files were created to absorb the pointer role: `.agents/rules/scripts.md` (repo-root `scripts/` brief, built from each script's header and `param()` block) and `.agents/rules/ai-instructions-modules.md` (pointer to the remote canonical repo `nam20485/agent-instructions`).

## Template versus clone content strategy

**Date:** 2026-07-18, revised 2026-07-19

This repository is a GitHub template. When a downstream clone is created from it, some content should travel unchanged and some must be reset or filtered. The strategy defines two classes:

| Class | Description | Examples |
|-------|-------------|----------|
| Class 1 | Reusable infrastructure that travels to every clone | Skills, scripts, rules, CI config, label taxonomy |
| Class 2 | Template-self-referential state that must be reset on clone or filtered on back-flow | Memory entries, plan docs, project-specific issue hierarchies |

The full strategy is documented in `docs/plans/.deferred/template-content-strategy.md`. An analysis of the external cloning pipeline (`nam20485/workflow-launch2`) verified the model against a real clone (`intel-agency/gap-miner-v2-delta12`). The analysis found that W1 step 4 (seed plan docs) is handled by the external pipeline, but W1 step 5 (build hierarchy trigger) is broken because it dispatches the incompatible `/orchestrate-dynamic-workflow project-setup` instead of `/gh-issue-tracking-init` direct dispatch. W1 steps 1 through 3 (memory reset, clear template plans, remove foreign artifacts) are not handled and remain pending in the external `workflow-launch2` repo.

An AGENTS.md anchor bug was also found and fixed: the cloning script targeted the anchor text `**GitHub template repo**` but the template said `**upstream GitHub template repo**`. The template AGENTS.md first sentence was reworded to contain the correct anchor so the apposition reads correctly in both template and clone contexts.

## Plan-source auto-resolution

**Date:** 2026-07-18

The `gh-issue-tracking-init` skill originally stopped to ask the user "which plan doc?" between a development plan and a reference doc. For a non-interactive skill, this is a defect: it blocks on human input when it should resolve automatically.

**Chosen approach:** Replaced the interactive prompt with a deterministic filename-role resolver. The skill classifies files in `plan_docs/**/*.md` by filename slug:

- **Primary plan** (slugs: `development-plan`, `app-plan`, `application-plan`, `implementation`, `specification`, etc.) becomes the issue tree source
- **Architecture** (slugs: `architecture`, `architecture-guide`, etc.) becomes Plan-body context
- **Reference / background** (everything else) becomes Plan-body context

Resolution rules are deterministic and logged. The only hard stop is an empty or missing `plan_docs/` directory with no plan supplied. No case prompts the user to choose between plan docs. This was applied in commits `9a0cf01` and `1e516a8`, with Pester 46/46 green and both edited files markdownlint-clean.

See also [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) for how this resolver fits into the skill's orchestration, and [Pitfalls and danger zones](pitfalls.md) for the runtime quirks that motivated several of these decisions.
