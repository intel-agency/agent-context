# Lore

The story of how `intel-agency/agent-context` evolved from a single operating manual into a 100-file template repository with a tested skill, a CI pipeline, and a rules system. All dates are taken from git commit timestamps.

## Eras

### The foundation (June 26, 2026)

The repository was born in a single day. On June 26, 2026, 18 commits landed in a burst of activity that established the entire structural backbone.

- **Jun 26, 01:20** - The first commit adds `AGENTS.md`, the agent operating manual with validation, planning, and tool-usage rules.
- **Jun 26, 01:21** - OpenCode agent definitions arrive for the orchestration team hierarchy (orchestrator, team-lead, developer, planner, researcher).
- **Jun 26, 01:49** - Memory and Sequential-Thinking tools are documented.
- **Jun 26, 02:55 - 03:52** - AGENTS.md is improved, agent permissions are broadened, and parallel dispatching guidance is added for orchestrator and team-lead.
- **Jun 26, 06:50 - 06:53** - OpenCode configuration lands with providers, MCP servers, and default models. Subagents are assigned models. A researcher agent is added for web research and cited briefs.
- **Jun 26, 07:23** - Workspace configuration is initialized.
- **Jun 26, 10:26** - `AGENTS.review.md` is deleted after its recommendations are folded back into AGENTS.md.
- **Jun 26, 15:27 - 16:03** - OpenCode config is updated and agent command prompts are added.

By the end of the day the repo had its operating manual, its agent hierarchy, its tool guidance, and its workspace configuration. The rules system did not yet exist as separate files; everything lived in AGENTS.md.

### Cleanup and consolidation (June 29, 2026)

Three days later, a focused cleanup session removed content that had been migrated to global providers and introduced new tooling.

- **Jun 29, 15:31** - Agent skills (`safe-commit`, `scan-uncommitted-secrets`) are removed because they are now provided globally, deleting 596 lines.
- **Jun 29, 15:31** - All 20 OpenCode command files are removed for the same reason, deleting 1,943 lines. This is the largest single deletion in the repo's history.
- **Jun 29, 15:31** - Developer agent raw-git deny rules are removed.
- **Jun 29, 15:31 - 15:38** - New providers are added: Exa MCP, Alibaba Model Studio, and GLM 4.x models. Z.AI MCP research tools and the missing-validation-script policy are documented.

This era established a pattern the repo would follow repeatedly: build something, then either move it to a better home or delete it outright rather than letting it linger.

### The rules system (July 9-10, 2026)

After a quiet stretch in early July, work resumed with a major restructuring of how project conventions are stored and discovered.

- **Jul 9, 22:46** - Semantic search tool documentation is added for codebase indexing.
- **Jul 9, 22:47** - Formatting issues in AGENTS.md are fixed.
- **Jul 9, 23:42** - The memory and rules system is born: `memory.md` and `tools.md` are created, and AGENTS.md gains documentation describing them.
- **Jul 9, 23:45** - Markdownlint configuration is added.
- **Jul 10, 11:54** - AGENTS.md is restructured from a monolithic document into a brief index that links to subject-specific rules files. The `.kilo` agent session state is gitignored.
- **Jul 10, 11:54** - `memory.md` is restructured with named sections (Current Activity, Completed Work Items, Decisions, Remember To Do).
- **Jul 10, 20:36 - 21:14** - The relocation directive is reworded, orientation guidance moves into `practices.md`, the section-brief directive is clarified, and initial CI/CD rules are written.
- **Jul 10, 21:18** - Review comments on memory.md and practices.md are fixed.

This era transformed AGENTS.md from a long document into a concise index. The subject-specific rules files (`tools.md`, `practices.md`, `ci-cd.md`, and others) became the authoritative source for each topic.

### The gh-issue-tracking-init skill (July 15-21, 2026)

The longest and most productive era. Over seven days the repo gained its signature skill: a set of idempotent PowerShell scripts that scaffold a GitHub issue-based planning hierarchy.

- **Jul 15, 10:49** - PR #1 merges, bringing the new memory system into the main branch.
- **Jul 15, 10:51 - 10:54** - GitHub issue tracking templates and implementation plan arrive, followed by the tracking scripts and label taxonomy.
- **Jul 15, 11:01** - Scripts are hardened per review feedback.
- **Jul 15, 11:40** - A fix for empty-string body handling using an explicit null check.
- **Jul 15, 11:43** - PR #2 merges the issue-tracking skill.
- **Jul 15, 11:46** - Scripts for GitHub issue management and permissions verification are added.
- **Jul 15, 11:53 - 12:01** - App-stack rule definitions are added (dotnet-aspire-aspnet-blazor, dotnet-avalonia-xplatform-desktop, python-uv-fastapi-vite) and PR #3 merges.
- **Jul 15, 13:20 - 14:58** - Three batches of PR #4 review comments are addressed. The OpenCode configuration is updated with new models, and a deprecated memory file path is removed. The standalone `ci-rules.md` is retired in favor of `ci-cd.md`.
- **Jul 16** - PR #5 review comments are addressed. Platform and OS sections are added to app-stack docs. EF Core is added to dotnet stack package sections. Milestone action output formatting is improved.
- **Jul 16, 07:43** - An execution review and issue report for `gh-issue-tracking-init` is added.
- **Jul 17, 22:28 - 22:29** - Coding style guidelines are added. An upstream fix plan addresses Int32 overflow and documentation gaps. GitHub issue ID handling is updated to support larger values.
- **Jul 18, 03:07** - The skill is made fully self-contained; a defect level is added.
- **Jul 18, 03:13 - 03:24** - Completed plan documents are archived. The defect level is deferred and a broken footnote link is dropped.
- **Jul 18, 11:17 - 11:23** - PRs are excluded from title lookup, splatting examples are corrected, and `Find-IssueNumberByTitle` is guarded against malformed and null API elements.
- **Jul 18, 12:08 - 12:58** - `scripts.md` and `ai-instructions-modules.md` rules files are added. Four stale `local_ai_instruction_modules` files are retired. PR #7 merges.
- **Jul 18, 13:56 - 16:34** - Multiple null-safety fixes in `Get-JsonProp`. Project number emission and driver-composition guidance are added. Edge-case tests are added.
- **Jul 18, 19:36** - Interactive plan-doc selection is replaced with auto-resolution.
- **Jul 19, 04:12 - 04:17** - Enriched issue templates with validation plans are migrated. A repository identity section is added to AGENTS.md. The application plan template is enhanced with success metrics.
- **Jul 19, 13:47 - 13:48** - Application plan and epic/story templates are refined. Markdownlint is configured to disable MD060.
- **Jul 19, 15:30** - Forensic logging is added to `common.ps1`. Child-issue identifier requirement is enforced. Skills and cross-platform PowerShell rules are added. Milestone and project requirements on pull requests are enforced. Forensic run logs are gitignored.
- **Jul 19, 21:38 - 21:41** - A template-content-strategy plan outlines the cloning pipeline. The strategy is refactored to fix a broken hierarchy-init trigger.
- **Jul 20, 20:53 - 20:55** - `set-project-fields` single-select guards are fixed via `PSBoundParameters`. SKILL.md is enhanced with detailed mapping guidelines for plan hierarchy levels.
- **Jul 21, 00:47 - 05:30** - PR #10 review is addressed. A plan for issue body content fidelity and a defect inventory are added.
- **Jul 21, 08:54** - The body composition and filler-detection spec is added to `gh-issue-tracking-init`.
- **Jul 21, 09:47** - The regex section parser is replaced with a robust line-by-line parser in the filler detector.
- **Jul 21, 11:51 - 14:16** - The filler detector is refactored: `saveSection` is hoisted, null lines are filtered, and the heading is included in the hash key.
- **Jul 21, 14:28** - A pre-post secret scanner for issue body files is added, along with an allowlist for synthetic test fixtures.

### Readiness hardening (July 22-24, 2026)

The final era focused on making the repository production-ready as a GitHub template.

- **Jul 22, 05:48** - Orchestration signal labels are added to `gh-issue-tracking-init`.
- **Jul 24, 13:10** - The Google Gemini provider is removed and `small_model` is switched to `glm-4.5-air`.
- **Jul 24, 13:10** - An environment variables reference doc is added for downstream clones.
- **Jul 24, 13:40** - The `ask` permission is replaced with `deny` to prevent headless deadlocks in agent definitions.
- **Jul 24, 14:16** - Workspace scratch directory is enforced for subagents.
- **Jul 24, 15:44** - A root `README.md` is added and readiness hardening is recorded in memory.
- **Jul 24, 16:32** - The GitHub Actions CI pipeline, `validation.ps1`, `.github` templates, and 89 new tests are added in the final commit.

## Longest-standing features

Several pieces of the codebase have survived from the earliest commits through every subsequent refactor:

- **AGENTS.md** (Jun 26) - Touched 21 times but never replaced. It was restructured from a monolith into an index on Jul 10, but the file itself has been the entry point since day one.
- **The OpenCode agent hierarchy** (Jun 26) - The orchestrator, team-lead, developer, and planner agent definitions were added on the first day and are still present, though their permissions and prompts have evolved.
- **The memory system** (Jun 26, formalized Jul 9) - Memory was documented on the first day and later formalized into `memory.md` with named sections. The four-section structure (Current Activity, Completed Work Items, Decisions, Remember To Do) has persisted since Jul 10.
- **The op scripts** (Jul 15) - `create-dispatch-issue.ps1`, `gh-auth.ps1`, `query.ps1`, and `test-github-permissions.ps1` were added in mid-July and have remained stable, accumulating only small fixes.

## Deprecated features

The repository has been ruthless about removing things that no longer belong:

- **`safe-commit` and `scan-uncommitted-secrets` skills** (removed Jun 29) - 596 lines deleted across 3 files. These were migrated to a global provider and removed from the repo.
- **20 OpenCode command files** (removed Jun 29) - 1,943 lines deleted. The entire `.opencode/commands/` directory was emptied because the commands are now provided globally.
- **`AGENTS.review.md`** (deleted Jun 26) - Created and deleted on the same day after its recommendations were folded back into AGENTS.md.
- **Four stale `local_ai_instruction_modules`** (retired Jul 18) - `ai-custom-agents.md`, `ai-delegation-mandate.md`, `ai-development-instructions.md`, and `ai-terminal-commands.md` were removed because the content had been salvaged into rules files.
- **`defect.md` template** (deferred Jul 18) - The defect level was built and then dropped from the skill's templates.
- **`ci-rules.md`** (retired Jul 18) - Replaced by `ci-cd.md` as part of the rules system consolidation.
- **`docs/tool-memory.md` and `docs/tool-sequential-thinking.md`** (deleted Jul 10) - Content moved into the rules system under `.agents/rules/tools.md`.
- **Google Gemini provider** (removed Jul 24) - The provider was removed from OpenCode config and `small_model` was switched to `glm-4.5-air`.

## Major rewrites

Several components underwent significant rework after their initial creation:

- **`Find-IssueNumberByTitle`** (Jul 17-18) - Initially could not handle large issue IDs (Int32 overflow). Over two days it was rewritten to support larger values, exclude PRs from the title lookup, and guard against malformed and null API elements.
- **`set-project-fields` guards** (Jul 20) - Single-select field handling was broken until `PSBoundParameters` was used to distinguish explicitly-passed parameters from defaults. Tests were hardened the next day.
- **Filler detector** (Jul 21) - The section parser was rewritten from regex-based to line-by-line for robustness. `saveSection` was hoisted out of the inner loop, null lines were filtered, and the hash key was corrected to include the heading so that identical body text under different headings would not be flagged as filler.
- **AGENTS.md restructure** (Jul 10) - The monolithic operating manual was split into a brief index linking to subject-specific rules files. This was the structural change that defined the repo's current organization.
- **Plan-source selection** (Jul 18) - Interactive plan-document selection was replaced with auto-resolution, eliminating a headless-blocking prompt.

## Growth trajectory

The repository grew at a steep and accelerating pace.

- **June 2026**: 23 commits, all concentrated on June 26 (18 commits) and June 29 (5 commits). The month established the foundation and performed the first cleanup.
- **July 2026**: 97 commits, spread across 12 days from July 9 to July 24. The month brought the rules system, the `gh-issue-tracking-init` skill with its scripts and templates, the filler detector, the secret scanner, the CI pipeline, and 89 new tests.

The file count grew from a handful on day one to 100 tracked files by the final commit. The ratio of test code to production code climbed as the `gh-issue-tracking-init` skill matured, ending at 190 Pester tests covering 93.91% of the PowerShell codebase. The trajectory suggests a project that found its purpose in the second month and then executed aggressively on it.

---

See also: [agent-context overview](overview/index.md), [Architecture](overview/architecture.md), [Patterns and conventions](how-to-contribute/patterns-and-conventions.md), [gh-issue-tracking-init](features/gh-issue-tracking-init/index.md), [By the numbers](by-the-numbers.md), [Fun facts](fun-facts.md).
