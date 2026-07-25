# Maintainers

This is a solo project. The repository has a single human contributor, `nam20485`, who owns every file. The `.github/CODEOWNERS` file reflects this with a single catch-all rule.

## Subsystem ownership

| Subsystem | Official owners (CODEOWNERS) | Recent contributors | Last activity |
|-----------|------------------------------|---------------------|---------------|
| All files | @nam20485 | nam20485 | 2026-07-24 |

## Notes

- Commits are bot-assisted: `factory-droid[bot]` appears as a co-author on commits produced by agent sessions, but all human-authored work is by `nam20485`.
- The branch protection ruleset (`protect-development-and-main`) requires one approving review on pull requests, with admin bypass enabled because GitHub forbids self-approval and `nam20485` is the sole reviewer. See [Design decisions](background/design-decisions.md) for the rationale.
- No additional maintainers are being sought at this time.

## Related reading

- [Configuration](reference/configuration.md) for the CODEOWNERS file and CI pipeline
- [agent-context overview](overview/index.md) for the repository overview
- [Security](security.md) for how ownership and branch protection fit into the security posture
