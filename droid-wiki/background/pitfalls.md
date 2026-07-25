# Pitfalls and danger zones

The `gh-issue-tracking-init` skill and its PowerShell scripts operate against live GitHub APIs under real-world constraints. Several limitations are baked into the platform or the PowerShell runtime and cannot be worked around in code. Know them before you run, not after a half-finished hierarchy sits on the board.

These are documented in the "Known limitations" and "Out of scope" sections of `.agents/skills/gh-issue-tracking-init/SKILL.md`, plus the driver-fix notes in `.agents/memory.md`.

## GitHub database IDs exceed Int32.MaxValue

GitHub issue database IDs have grown past `Int32.MaxValue` (2,147,483,647). The `Get-IssueDbId` function in `.agents/skills/gh-issue-tracking-init/scripts/common.ps1` casts to `[long]` instead of `[int]`, so `link-sub-issue.ps1` and `set-dependency.ps1` work against modern repos. This was fixed during a real hierarchy recovery run on `intel-agency/gap-miner-v2-oscar32` where sub-issue linking silently broke because the ID overflowed.

If you copy any of these scripts or write new ones that handle issue IDs, always use `[long]`.

## Project views are not automatable

`gh` and the GraphQL API have no supported "create view" operation. The `ensure-project.ps1` script prints four views that must be added once in the Project UI:

1. By Phase
2. By Status
3. By Epic
4. Current work

There is no script path around this. After a successful run, relay the printed view list to the user and add them manually.

## Built-in Status options are limited

`gh` cannot add options to an existing single-select field after it is created. The initial `Status` field has three options:

- Todo
- In Progress
- Done

If your workflow needs `In Review` or `Blocked`, add those once in the Project UI after the field exists. The skill cannot do it programmatically.

## Defects and bugs are deferred

Adding a `defect` level to the hierarchy would require extending the Project `Level` single-select field after creation. Since `gh` and the API cannot add options to an existing single-select field, a defect level would force a manual UI step on every re-run. Shipping it half-working would be worse than omitting it, so defects are intentionally out of scope until the field-option limitation can be fully automated.

## Integer-keyed dictionaries are unreliable in PowerShell

PowerShell integer-keyed `[ordered]@{}` and `@{}` indexing is unreliable for some keys. This was reproduced on PowerShell 7.6: keys 1 through 6 resolve correctly while key 7 returns empty, even though `.Keys` and `.Values` confirm the entry is present.

When composing a driver script that needs milestone or phase lookup maps, do not build them as integer-keyed dictionaries. Prefer, in order:

1. A `switch` function (single source of truth, fails loudly on unknown keys)
2. A `[string]`-keyed `@{}` accessed via `$map["7"]`

```pwsh
function Milestone-For {
    param([int]$N)
    switch ($N) {
        1 { 'Gate 1: Foundation' }
        2 { 'Gate 1: Foundation' }
        3 { 'Gate 2: Pipelines' }
        default { throw "Unknown epic number for milestone: $N" }
    }
}
```

## GraphQL rate limit is separate from REST

Heavy GraphQL usage (Projects v2 field staging) exhausts a 5000-point-per-hour GraphQL budget that is separate from the REST core limit. A run can hit the GraphQL ceiling while REST calls still have budget to spare. The skill scripts include recovery switches (`-ProjectNumber` and `-SkipFields`) that let re-runs proceed REST-only while the GraphQL budget resets.

Plan large hierarchies with this in mind: field-setting calls are the most GraphQL-intensive step.

## PowerShell case-insensitive variable naming

PowerShell variables are case-insensitive. A variable named `$num` and one named `$Num` are the same variable. During the `gap-miner-v2-oscar32` recovery run, this collision was the root cause of a lookup bug: the driver used `$num` for one purpose and `$Num` for another, and they silently overwrote each other.

The fix renamed all such variables to distinct names: `$issueNum` and `$NumberByKey`. When writing driver scripts, use fully distinct names even when the casing differs, because PowerShell will not warn you.

## Find-IssueNumberByTitle uses REST, not GraphQL Search

The `Find-IssueNumberByTitle` function in `.agents/skills/gh-issue-tracking-init/scripts/common.ps1` was rewritten to use the REST issues endpoint (paginated) instead of `gh issue list --search`. The search route goes through the GraphQL Search API, which has its own separate rate limit and fails under load. The REST endpoint is slower but reliable under the REST core budget.

This change was made during a real run where title-based issue lookup started failing because the GraphQL Search API budget was exhausted while the REST budget was fine.

## Related reading

- [Design decisions](design-decisions.md) for the rationale behind the choices that created these constraints
- [gh-issue-tracking-init](../features/gh-issue-tracking-init/index.md) for the skill's full operation sequence
- [Validation pipeline](../systems/validation-pipeline.md) for how the CI pipeline handles script failures
