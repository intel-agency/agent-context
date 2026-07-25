# Security

Security in this repo is defense in depth across four layers: secret management at the configuration level, pre-post scanning of issue bodies, secret scanning in CI, and branch protection on the protected branches. No layer is trusted alone.

```mermaid
flowchart TD
    A[Secret management<br/>{env:VAR} pattern] --> B[No hardcoded secrets in code]
    B --> C[assert-no-secrets.ps1<br/>scans issue bodies before posting]
    C --> D[gitleaks in CI<br/>scans entire repo]
    D --> E[Branch protection ruleset<br/>1 approval, no force push]
    E --> F[CODEOWNERS<br/>review required]
    F --> G[GitHub native secret scanning<br/>push protection]
```

## Secret management

All secrets are resolved from environment variables at runtime. No secret is hardcoded in any tracked file. The agent runtime config in `.opencode/opencode.jsonc` uses the `{env:VAR}` pattern to inject credentials into MCP server URLs and provider options:

```jsonc
"headers": {
  "Authorization": "{env:Z_AI_API_KEY}",
}
```

```jsonc
"options": {
  "apiKey": "{env:CLINE_API_KEY}",
  "baseURL": "https://api.cline.bot/api/v1",
}
```

The full list of required and optional environment variables is documented in `docs/environment-variables.md`. The minimum set for a downstream clone is:

```sh
export EXA_API_KEY="..."
export Z_AI_API_KEY="..."
export GITHUB_AUTH_TOKEN="ghp_..."
export GITHUB_USERNAME="..."
```

One variable, `GHIT_LOG_FILE`, is intentionally **not** a secret and must not be pre-defined in the environment. It is set at runtime by the skill's `common.ps1` to carry the active log-file path between scripts. Pre-defining it could interfere with log-file management.

See [Configuration](reference/configuration.md) for the full config reference.

## Pre-post secret scanning

Before the `gh-issue-tracking-init` skill creates any GitHub issue, it runs `assert-no-secrets.ps1` against the rendered issue body files. This is a throw-and-halt assertion: if it detects a potential secret, the entire run stops before any `gh issue create` call fires. The rationale is that secrets posted to public GitHub issues are a one-way door. They are scraped within seconds and cached by archives even after deletion. The cost of a false positive is a re-run; the cost of a false negative is catastrophic.

The scanner uses three detection tiers:

1. **Token patterns** - format-specific prefixes (AWS `AKIA`, GitHub `ghp_`, OpenAI `sk-`, Stripe `sk_live_`, Google `AIza`, Slack `xox`, JWT, private key blocks). These are never allowlisted. If the format matches, the token is flagged.
2. **Structural** - connection strings with embedded `user:pass@host` credentials and hardcoded password assignments. A value-level allowlist suppresses placeholders like `${VAR}` and `changeme`.
3. **Credential-keyed** - any key name containing a credential word (password, token, secret, api_key, access_key, AccountKey, etc.) whose value is not a placeholder.

The placeholder allowlist is applied at the value level, never at the line level. A placeholder substring on the same line as a real secret does not suppress detection of the secret.

## CI secret scanning

[gitleaks](https://github.com/gitleaks/gitleaks) (version 8.21.2) runs in the scan step of every CI pipeline. Configuration lives in `.gitleaks.toml`, which extends the default rule set with `useDefault = true` and allowlists one test fixture:

```toml
[allowlist]
description = "Test fixtures with intentional fake secrets for AssertNoSecrets"
paths = [
    '''\.agents/skills/gh-issue-tracking-init/scripts/tests/AssertNoSecrets\.Tests\.ps1$''',
]
```

The allowlist is scoped to the exact test file that contains intentional fake secrets for testing the assertion scanner. No other paths are allowlisted. The scan runs with `--redact` so any detected secret is masked in CI output.

See [Tooling](how-to-contribute/tooling.md) for how gitleaks fits into the validation pipeline.

## Branch protection

A GitHub ruleset (id 19712997) protects both the `development` and `main` branches:

- **1 approval** required before merge.
- **Deletion blocked**: protected branches cannot be deleted.
- **Non-fast-forward blocked**: force pushes that rewrite history are blocked.
- **Admin bypass**: admins can bypass when needed.

No change reaches a protected branch without a passing CI run and at least one approval. See [Deployment](deployment.md) for how this combines with the CI pipeline.

## CODEOWNERS

The `.github/CODEOWNERS` file is a single line:

```
* @nam20485
```

Every file in the repository is owned by `@nam20485`, which means GitHub automatically requests a review from that user on any pull request that touches tracked files. This ensures no change merges without owner awareness.

## GitHub native secret scanning

GitHub's built-in secret scanning and push protection are enabled on the repository. This catches credentials at push time, blocking commits that contain recognized secret formats before they reach the remote. The repository currently has 0 secret scanning alerts.

## Related pages

- [Deployment](deployment.md) - CI pipeline and branch protection details
- [Tooling](how-to-contribute/tooling.md) - gitleaks and the validation pipeline
- [Configuration](reference/configuration.md) - environment variables and config files
- [Debugging](how-to-contribute/debugging.md) - forensic logging and the `GHIT_LOG_FILE` variable
