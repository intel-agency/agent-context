# Dependencies

The repository depends on a set of runtime tools, PowerShell modules, npm packages, MCP servers, and model providers. This page lists them with their pinned versions and the environment variables they require. The source of truth for environment variables is `docs/environment-variables.md`; the source of truth for MCP servers and model providers is `.opencode/opencode.jsonc`.

## Runtime tools

| Tool | Version | Used by | Purpose |
|------|---------|---------|---------|
| PowerShell (`pwsh`) | 7+ | All scripts | Cross-platform scripting runtime |
| GitHub CLI (`gh`) | latest | All skill and repo scripts | GitHub API operations (issues, projects, milestones, labels) |
| Node.js | latest | markdownlint-cli2 | Required to run the markdown linter |
| .NET SDK | latest | ReportGenerator | Required for the `dotnet tool` command that installs ReportGenerator |

The GitHub CLI must be authenticated with `repo`, `project`, and `user:email` scopes. The `$GITHUB_TOKEN` environment variable is honored by the skill scripts.

## Pinned tool versions

The CI pipeline in `.github/workflows/ci.yml` pins two tools to exact versions:

| Tool | Pinned version | Install method |
|------|---------------|----------------|
| markdownlint-cli2 | 0.22.1 | `npm install -g markdownlint-cli2@0.22.1` |
| gitleaks | 8.21.2 | Binary download from GitHub releases |

ReportGenerator is installed on demand by `validation.ps1` if not already present:

| Tool | Pinned version | Install method |
|------|---------------|----------------|
| ReportGenerator | 5.5.10 | `dotnet tool install --global dotnet-reportgenerator-globaltool --version 5.5.10` |

## PowerShell modules

`validation.ps1` auto-installs these modules if they are missing (via `Install-Module -Scope CurrentUser`):

| Module | Minimum version | Used in | Purpose |
|--------|----------------|---------|---------|
| Pester | 5.0.0 | Test step | Pester test framework and code coverage |
| PSScriptAnalyzer | 1.20.0 | Scan step | PowerShell static analysis (error severity) |

## MCP servers

Configured in `.opencode/opencode.jsonc` under the `mcp` key. Local servers run via `npx`; remote servers connect to hosted endpoints.

| Server | Type | Package / URL | Auth |
|--------|------|---------------|------|
| `sequential-thinking` | local | `npx -y @modelcontextprotocol/server-sequential-thinking` | none |
| `memory-graph` | local | `npx -y @modelcontextprotocol/server-memory` | none |
| `web-reader` | remote | `https://api.z.ai/api/mcp/web_reader/mcp` | `Z_AI_API_KEY` |
| `zread` | remote | `https://api.z.ai/api/mcp/zread/mcp` | `Z_AI_API_KEY` |
| `web-search-prime` | remote | `https://api.z.ai/api/mcp/web_search_prime/mcp` | `Z_AI_API_KEY` |
| `exa` | remote | `https://mcp.exa.ai/mcp?tools=...` | `EXA_API_KEY` |

The Exa server URL includes tool selectors: `web_search_exa`, `web_fetch_exa`, `web_search_advanced_exa`, `get_code_context_exa`, `crawling_exa`. The API key is passed as a query parameter (`exaApiKey`).

## Model providers

Configured in `.opencode/opencode.jsonc` under the `provider` key. Each provider resolves credentials from an `auth.json` file first, then falls back to environment variables.

| Provider | Credential env var (fallback) | Models | Endpoint |
|----------|------------------------------|--------|----------|
| `zai-coding-plan` | `ZAI_CODING_PLAN_OPEN_AI_API_KEY` or `Z_AI_API_KEY` | GLM 5.2, GLM 4.7, GLM 4.5 Air | Built-in (Z.AI) |
| `opencode-go` | `OPENCODE_GO_API_KEY` | GLM 5.2/5.1, Kimi K2.7 Code/K2.6, DeepSeek V4 Pro/Flash, MiMo V2.5/V2.5 Pro, MiniMax M3/M2.7/M2.5, Qwen 3.7 Max/Plus, Qwen 3.6 Plus | OpenCode Go subscription |
| `nvidia` | `NVIDIA_NIM_API_KEY` | MiniMax M3 (via NIM) | `NVIDIA_NIM_BASE_URL` (defaults to `https://integrate.api.nvidia.com/v1`) |
| `cline-pass` | `CLINE_API_KEY` | GLM 5.2, Kimi K2.7 Code/K2.6, DeepSeek V4 Pro/Flash, MiMo V2.5/V2.5 Pro, MiniMax M3, Qwen 3.7 Max/Plus | `https://api.cline.bot/api/v1` |

The default model is `zai-coding-plan/glm-5.2` and the default small model is `zai-coding-plan/glm-4.5-air`. The `nvidia` provider overrides the built-in `NVIDIA_API_KEY` with `NVIDIA_NIM_API_KEY` via the `apiKey` option.

## Environment variables

### Required

| Variable | Used by | Purpose |
|----------|---------|---------|
| `EXA_API_KEY` | Exa MCP server | Exa search, fetch, and crawling tools |
| `Z_AI_API_KEY` | Z.AI MCP servers | Authorization header for web-search, web-reader, and zread |
| `GITHUB_AUTH_TOKEN` | `scripts/gh-auth.ps1`, `scripts/test-github-permissions.ps1` | Primary GitHub auth token |
| `GITHUB_USERNAME` | `scripts/test-github-permissions.ps1` | Default repository owner for permission checks |

`GITHUB_TOKEN` is accepted as a fallback by `scripts/update-remote-indices.ps1`. Defining both `GITHUB_AUTH_TOKEN` and `GITHUB_TOKEN` is harmless.

### Optional (model provider credentials)

Only required when the corresponding provider is actually used:

| Variable | Used by |
|----------|---------|
| `NVIDIA_NIM_API_KEY` | NVIDIA NIM provider |
| `NVIDIA_NIM_BASE_URL` | NVIDIA NIM provider |
| `CLINE_API_KEY` | Cline Pass provider |
| `ZAI_CODING_PLAN_OPEN_AI_API_KEY` | zai-coding-plan provider (fallback when `auth.json` absent) |
| `OPENCODE_GO_API_KEY` | opencode-go provider (fallback when `auth.json` absent) |

### Do not set

| Variable | Owner | Reason |
|----------|-------|--------|
| `GHIT_LOG_FILE` | `gh-issue-tracking-init` skill | Set at runtime by `common.ps1` to carry the active log-file path between scripts. Pre-defining it could interfere with log-file management. |

## Quick-start minimum set

For a clone environment that needs only the default MCP tools and standard GitHub automation:

```sh
export EXA_API_KEY="..."
export Z_AI_API_KEY="..."
export GITHUB_AUTH_TOKEN="ghp_..."   # or GITHUB_TOKEN
export GITHUB_USERNAME="..."
```

## Related reading

- [Configuration](configuration.md) for the config files that reference these dependencies
- [Validation pipeline](../systems/validation-pipeline.md) for how Pester, PSScriptAnalyzer, gitleaks, and ReportGenerator are invoked
- [Getting started](../overview/getting-started.md) for installation and setup steps
