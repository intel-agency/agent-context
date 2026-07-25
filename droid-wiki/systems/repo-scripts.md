# Repository scripts

nam20485

The `scripts/` directory holds seven cross-platform PowerShell 7+ scripts that wrap the GitHub CLI (`gh`) for common repository operations. They cover authentication, label synchronization, PR review-thread management, permission verification, dispatch-issue creation, and remote-instruction-module index regeneration. Most accept a `-DryRun` switch so you can preview what a script would do without making any changes.

## Script inventory

| Script | Purpose | Key parameters |
| --- | --- | --- |
| `scripts/common-auth.ps1` | Dot-sourceable `gh` auth bootstrap. Exports `Initialize-GitHubAuth`, which verifies `gh` is on PATH and triggers `gh auth login` if unauthenticated. | `-DryRun` |
| `scripts/gh-auth.ps1` | `gh` auth bootstrap with non-interactive PAT-stdin support (`gh auth login --with-token`). Falls back to interactive login. | `-DryRun`, `-Token <pat>` |
| `scripts/import-labels.ps1` | Syncs labels from a JSON export into a target repo. Creates missing labels, updates color and description when they differ, and optionally deletes labels not in the source. | `-Repo <owner/repo>`, `-LabelsFile ./.labels.json`, `-DryRun`, `-DeleteMissing` |
| `scripts/query.ps1` | PR review-thread management via GraphQL. Lists unresolved threads, optionally posts a reply to each, then resolves them. The canonical tool for resolving PR review comments. | `-Owner`, `-Repo`, `-PullRequestNumber`, `-ThreadId`, `-Path <wildcard>`, `-BodyContains`, `-Interactive`, `-AutoResolve`, `-NoResolve`, `-DryRun`, `-VerboseLogging`, `-ReplyEach "<msg>"` |
| `scripts/create-dispatch-issue.ps1` | Creates a GitHub issue on a target repo. Defaults the title to `orchestrate-dynamic-workflow` so it triggers the orchestrator match clause. Title and body can be overridden for arbitrary issue creation. | `-Repo <owner/repo>`, `-Title`, `-Body <text>`, `-Labels[]`, `-Project`, `-Milestone`, `-Template`, `-Assignee[]`, `-DryRun` |
| `scripts/test-github-permissions.ps1` | End-to-end permission verifier. Checks `gh` auth status, scopes (`user:email`, `repo`, `project`), repo create/delete, project create, and the label, milestone, and branch-permission workflow. Optional auto-fix for missing scopes. | `-Owner <user>`, `-TestRepoName`, `-TestProjectName`, `-Cleanup`, `-AutoFixAuth` |
| `scripts/update-remote-indices.ps1` | Regenerates the two `local_ai_instruction_modules/` index files from the remote canonical `nam20485/agent-instructions` repo listing. Writes only if content changed. | `-Owner <owner>`, `-Repo <repo>`, `-Branch <branch>` |

The table is a quick reference. Each script's header comments and `param()` block are the authoritative documentation for parameters, examples, and notes.

## Common conventions

Every auth-aware script in this directory follows the same conventions, documented in `.agents/rules/scripts.md`:

- **Strict mode and error preference**: `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` are active. Missing properties are accessed via `PSObject.Properties` rather than direct member access, and fatal errors use `throw` rather than `Write-Error` plus `exit 1`.
- **Auth bootstrap**: auth-aware scripts dot-source `common-auth.ps1` (or `gh-auth.ps1`) if present and call `Initialize-GitHubAuth` before doing any API work. This guarantees `gh` is available and authenticated before the script proceeds.
- **Repo validation**: `-Repo` parameters validate against the pattern `^[^/]+/[^/]+$`, ensuring the value is in `owner/repo` form before any API call is made.
- **Dry run**: most scripts accept a `-DryRun` switch that prints what the script would do (often as `[dry-run] Would run: ...`) without making any mutations. This lets you preview destructive or batch operations safely.

## The two most-used scripts

### query.ps1

This is the canonical PR review-thread manager. It uses the GraphQL API to list unresolved review threads on a pull request, optionally post a reply to each thread, and then resolve them. The rules file explicitly warns against rewriting this ad hoc in Python or shell: `query.ps1` handles the GraphQL pagination, thread selection (by thread ID, file path wildcard, or body content match), and reply-and-resolve flow correctly. Use it directly.

### import-labels.ps1

This script syncs labels from a JSON export into a target repo. It is idempotent: it creates labels that are missing, updates color and description when they differ from the source, and with `-DeleteMissing` it removes labels that no longer exist in the source. Without `-DeleteMissing`, default GitHub labels are left intact. The JSON export is produced by:

```bash
gh api repos/{owner}/{repo}/labels --paginate > .labels.json
```

## The scratch file

`scripts/tmp-issue-body-project-setup.txt` is a kept scratch file, not a script. It is a staged draft of the `-Body` payload for a `create-dispatch-issue.ps1` project-setup dispatch. It is not consumed by anything (`create-dispatch-issue.ps1` takes `-Body` as a string argument, not a file), but it is retained as a reference example of a dispatch body.

## Note on scripts versus the skill's scripts

The `scripts/` directory at the repo root is separate from `.agents/skills/gh-issue-tracking-init/scripts/`. The skill directory is a self-contained set of operation scripts (vendored copies of generic helpers plus skill-specific ops) documented in the skill's own `scripts/README.md`, not here.

## Key source files

| Path | What it contains |
| --- | --- |
| `scripts/common-auth.ps1` | Dot-sourceable auth bootstrap (`Initialize-GitHubAuth`) |
| `scripts/gh-auth.ps1` | Auth bootstrap with PAT-stdin support |
| `scripts/import-labels.ps1` | Idempotent label sync from JSON export |
| `scripts/query.ps1` | PR review-thread management via GraphQL |
| `scripts/create-dispatch-issue.ps1` | GitHub issue creation with orchestrator trigger default |
| `scripts/test-github-permissions.ps1` | End-to-end permission and scope verifier |
| `scripts/update-remote-indices.ps1` | Remote instruction-module index regenerator |
| `.agents/rules/scripts.md` | Rules file with the full script inventory and conventions |

## Related pages

- [Systems](index.md)
- [AI instruction modules](../features/ai-instruction-modules.md)
- [Memory and rules system](memory-and-rules.md)
- [Validation pipeline](validation-pipeline.md)
- [Configuration](../reference/configuration.md)
