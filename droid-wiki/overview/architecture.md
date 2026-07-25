# Architecture

The repository is a template that downstream clones inherit. It has no runtime service or build artifacts in the traditional sense. Instead, it provides configuration, documentation, and PowerShell scripts that agents use to manage GitHub-based development workflows.

## Component map

```mermaid
graph TD
    Template["agent-context<br/>(template repo)"]
    AGENTS["AGENTS.md<br/>operating manual"]
    AgentsDir[".agents/<br/>memory + rules + skills"]
    OpenCode[".opencode/<br/>agent definitions + config"]
    Scripts["scripts/<br/>repo-root utilities"]
    GitHub[".github/<br/>CI + templates"]
    Docs["docs/<br/>reference docs"]
    Validation["validation.ps1<br/>build/scan/test"]
    LocalMods["local_ai_instruction_modules/<br/>workflow indices"]

    Template --> AGENTS
    Template --> AgentsDir
    Template --> OpenCode
    Template --> Scripts
    Template --> GitHub
    Template --> Docs
    Template --> Validation
    Template --> LocalMods

    AgentsDir --> Memory[".agents/memory.md"]
    AgentsDir --> Rules[".agents/rules/"]
    AgentsDir --> Skills[".agents/skills/<br/>gh-issue-tracking-init"]

    Skills --> SkillScripts["scripts/<br/>11 PowerShell op scripts"]
    Skills --> SkillAssets["assets/<br/>labels + templates"]
    Skills --> SkillRefs["references/<br/>design plan"]

    GitHub --> CI["workflows/ci.yml"]
    GitHub --> Templates["CODEOWNERS<br/>PR + issue templates"]
```

## Data flow: template to working clone

```mermaid
graph LR
    Template["Template repo<br/>(agent-context)"]
    Clone["Downstream clone<br/>(unique app plan)"]
    PlanDoc["plan_docs/<br/>development plan"]
    Skill["gh-issue-tracking-init<br/>skill"]
    Scripts["PowerShell<br/>op scripts"]
    GitHubAPI["GitHub API<br/>issues + projects + milestones"]
    Board["Projects v2 board<br/>with plan/epic/story/task"]

    Template -->|"clone"| Clone
    Clone --> PlanDoc
    PlanDoc -->|"parse"| Skill
    Skill --> Scripts
    Scripts -->|"gh CLI"| GitHubAPI
    GitHubAPI --> Board
```

The core flow: a downstream clone is created from this template, a development plan is placed in `plan_docs/`, and the `gh-issue-tracking-init` skill parses the plan into a hierarchy of linked GitHub issues with milestones, labels, and a Projects v2 board.

## Data flow: validation pipeline

```mermaid
graph TD
    CodeChange["Code change"]
    ValScript["validation.ps1"]
    Build["Build step<br/>markdownlint + link check"]
    Scan["Scan step<br/>PSScriptAnalyzer + gitleaks"]
    Test["Test step<br/>Pester + coverage gate"]
    CI["GitHub Actions CI"]
    Artifact["coverage-html<br/>artifact"]

    CodeChange --> ValScript
    ValScript --> Build
    ValScript --> Scan
    ValScript --> Test
    Test -->|"JaCoCo XML"| Artifact
    CodeChange -->|"push/PR"| CI
    CI --> ValScript
```

The validation pipeline runs three steps in sequence: build (markdown linting and link checking), scan (static analysis and secret scanning), and test (Pester with an 85% coverage gate and HTML report generation). The CI workflow mirrors this exactly.

## Technology choices

The repo standardizes on cross-platform PowerShell 7+ for all scripting. This is documented in [.agents/rules/coding-style.md](../../.agents/rules/coding-style.md) and enforced by convention. The GitHub CLI (`gh`) is the primary interface to GitHub APIs, with PowerShell scripts wrapping `gh` calls for idempotent operations.

Language breakdown: 60 Markdown files, 25 PowerShell scripts, 5 YAML configs, and a handful of JSON/TOML config files. There is no compiled code, no frontend, and no database.

## Key design principles

1. **Determinism over convenience** - Skills prefer scripts over prose steps so they produce the same output every run.
2. **Self-contained skills** - The `gh-issue-tracking-init` skill vendors its dependencies and works unmodified when copied to another repo.
3. **Idempotent operations** - All scripts match existing resources and skip or update rather than duplicate.
4. **Validation mirrors CI** - `validation.ps1` at the repo root runs the same steps as the CI pipeline.
