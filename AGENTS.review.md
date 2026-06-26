# AGENTS.md Review — Feedback for Improvement

**Reviewed file:** `AGENTS.md` (160 lines, 8152 bytes)
**Date:** 2026-06-26
**Method:** First-principles line-by-line review of the file, benchmarked against current (2025–2026) industry best practices for the `AGENTS.md` convention (official spec at https://agents.md/, plus practitioner guidance from Anthropic, Builder.io, Philipp Schmid, and Addy Osmani).
**Repo context noted:** The repository currently contains *only* an `AGENTS.md` — no `README.md`, no `validation.sh` / `validation.ps1`, no test suite, and no `.github/workflows`. Several rules in the file therefore mandate tooling that does not yet exist (see §3).

---

## TL;DR — Priority actions

| # | Priority | Issue | Fix |
|---|---|---|---|
| 1 | 🔴 High | No project overview / purpose / stack section | Add a 3–5 line "Project overview" at the top |
| 2 | 🔴 High | Validation commands are abstract ("build/scan/test") with no actual commands, and the mandated `validation.sh` does not exist | Add exact commands; create the script; or scope the rule to repos that have one |
| 3 | 🔴 High | 10+ spelling/grammar errors throughout | Copy-edit pass (see §1) |
| 4 | 🟠 Medium | ~70 lines (≈45% of the file) are generic tool documentation (Sequential-Thinking, Memory) rather than project-specific rules | Move to referenced docs; keep only the project-specific decision rules |
| 5 | 🟠 Medium | Missing standard sections: environment setup, project structure, code style, boundaries/"do-not-modify", security/secrets, escape hatch | Add per §2 |
| 6 | 🟡 Low | No README; AGENTS.md is the only doc in the repo | Add a minimal README for humans |
| 7 | 🟡 Low | "Monitor Workflows" references workflows but none exist | Either add CI or mark the rule as conditional |

---

## 1. Spelling, grammar, and typos (line-precise)

These are mechanical defects. Each should be fixed; they undercut the file's authority since the file itself demands precision.

| Line | Current | Corrected |
|---|---|---|
| 12 | `The follwing steps` | `The following steps` |
| 19 | `It should be mirror exactly` | `It should mirror exactly` |
| 35 | `Implemment changes` | `Implement changes` |
| 68 | `esp. if you're agent type` | `esp. if your agent type` |
| 71 | `## Making Chnages` | `## Making Changes` |
| 77 | trailing whitespace after `Investigation ` | remove trailing space |
| 80 | `Always invesitage the issue by using first hand sources,i.e.` | `Always investigate the issue using first-hand sources, i.e.` |
| 81 | `Do not make or report assertins withoutspecific details, ... toi backup your claims.` | `Do not make or report assertions without specific details (line numbers, files, log messages, etc.) to back up your claims.` |
| 82 | `decesively` | `decisively` |

---

## 2. Missing standard sections (vs. the AGENTS.md convention)

The official `AGENTS.md` spec (https://agents.md/) and practitioner consensus recommend a predictable set of sections. This file is missing the ones that actually make an agent *productive*:

### 2.1 🔴 Project overview / purpose  *(missing — top of file)*
Best practice is a 3–5 line opener: what the project is, why it exists, the stack and versions. An agent landing cold in this repo cannot tell whether `agent-context` is a library, a CLI, a docs repo, or a template. **Recommend adding immediately under the `# AGENTS.md` heading.**

*Sources: https://agents.md/ ; https://www.philschmid.de/writing-good-agents*

### 2.2 🔴 Environment setup  *(missing)*
Prerequisites, package manager, language/runtime versions. Currently absent. Even for a docs-only repo, state that (e.g. "This repo is documentation-only; no build step").

### 2.3 🔴 Concrete build/test/scan commands  *(declared but not specified)*
The file mandates `build → scan → test` but never gives the actual commands (e.g. `./validation.sh`, `dotnet test --coverage`, `npm run lint`). Best practice is **copy-pasteable, file-scoped commands first, full suite "only when explicitly requested."** Right now an agent must guess.

*Sources: https://www.builder.io/blog/agents-md ; https://agents.md/*

### 2.4 🟠 Project structure / key files  *(missing)*
A tiny index ("routes live in `App.tsx`", "memory graph is at `…`"). Keep it short — research shows full directory dumps *don't* help agents and waste tokens.

*Source: https://www.philschmid.de/writing-good-agents*

### 2.5 🟠 Code style & conventions  *(missing)*
Even a docs repo has conventions (markdown style, heading depth, line length). State them, or point at the formatter/linter that enforces them. Best practice: prefer deterministic tooling over prose rules.

### 2.6 🟠 Boundaries / "Do Not Modify"  *(missing — flagged by multiple sources as one of the most important sections)*
E.g. `.git/`, `.env`, lockfiles, generated artefacts. Without it, agents edit things they shouldn't.

*Source: https://addyosmani.com/agents/15-agents-md/*

### 2.7 🟠 Security / secrets  *(missing at the file level)*
The `Memory` section says "do not store secrets," but there is **no general secret-handling rule** for the repo (where secrets live, that `scan-uncommitted-secrets` must run pre-commit). Ironic given the `/safe-commit` skill is mandated. **Add a short Security section.**

*Sources: https://agents.md/ ; https://gist.github.com/0xfauzi/7c8f65572930a21efa62623557d83f6e*

### 2.8 🟠 Escape hatch / "when stuck"  *(missing)*
Best practice: tell the agent what to do when uncertain — "ask a clarifying question, propose a short plan, or open a draft PR; do not push speculative changes." Currently the file implies agents should always proceed; that produces low-quality changes.

*Source: https://www.builder.io/blog/agents-md*

### 2.9 🟡 Good/bad example pointers  *(missing)*
Point to an exemplar file to mimic and a legacy file to avoid. Strongly recommended by Builder.io.

---

## 3. Internal consistency problems (the file mandates what the repo lacks)

The `AGENTS.md` is the *only* file in the repo, yet it mandates:

- **A `validation.sh` / `validation.ps1`** (L18) — does not exist.
- **An automated test suite with >85% coverage** (L24–28) — no tests exist.
- **CI/CD workflows to monitor** (L46–48) — `.github/workflows` is absent.

**Recommendation:** Either (a) create these artefacts so the file describes reality, or (b) reframe the rules as *standards to establish when this repo gains code* (clearly conditional). As written, an agent that follows the file literally will immediately fail its own validation step.

---

## 4. Length & signal-to-noise (Tool Usage section)

The file is 160 lines — within the commonly cited <200-line guideline, but **~70 lines (≈45%) are generic tool documentation** (Sequential-Thinking L94–119 and Memory L121–160). These read like copied tool manuals rather than *project-specific* rules.

Concerns:
- ETH Zurich (2025, "Evaluating AGENTS.md") found context files *on average reduce* agent success ~and raise cost ~20%; the actionable lesson is **be surgical and non-redundant**. Generic tool docs are exactly the kind of redundancy that hurts.
- The Memory guidance is excellent in quality, but it is a *general* memory-tool usage guide, not `agent-context`-specific.

**Recommendation:** Move the detailed Sequential-Thinking and Memory guidance into separate referenced files (e.g. `docs/tool-sequential-thinking.md`, `docs/tool-memory.md`) and replace the in-file content with a 2–3 line decision rule + a link. Keep the main `AGENTS.md` focused on what is *unique to this project*.

*Sources: https://www.philschmid.de/writing-good-agents ; https://code.claude.com/docs/en/memory ("files over 200 lines reduce adherence")*

---

## 5. Structural / formatting suggestions

- **Heading order:** Consider reordering to the conventional flow: *Overview → Environment → Build/Test → Project structure → Code style → Workflow (commit/branch/PR) → Boundaries → Security → Tool usage → When stuck*. The current order puts Validation first, before the agent even knows what the project is.
- **"Monitor Workflows" (L44):** name the specific workflow files or mark the section conditional.
- **Branching prefix `mn/` (L54):** presumably initials; either explain the convention (`<your-initials>/<feature>`) or generalise.
- **Duplication:** L8 ("All changes must be validated before committing") and L42 ("Always run `/safe-commit` before committing") overlap. Consolidate so the safe-commit skill is presented *as* the validation enforcement mechanism.
- **Tone inconsistency:** Most rules are imperative ("must"), but TDD (L32) and delegation (L67) are "should"/"when possible." Decide whether these are hard gates or guidance and make the modality consistent.

---

## 6. What the file does well (keep these)

- ✅ Strong, clear validation/testing/coverage philosophy (build→scan→test, >85%).
- ✅ Explicit TDD loop (red→green→iterate).
- ✅ Safe-commit + workflow-monitoring discipline.
- ✅ Branching convention with a concrete example.
- ✅ Thorough PR-comment-resolution workflow (address all comments, reply, resolve threads).
- ✅ Delegation guidance — ahead of public consensus; good for orchestrator-style agents.
- ✅ "Smallest surgical change" principle.
- ✅ Investigation discipline ("never guess; cite line numbers; don't implement until root cause found").
- ✅ Planning discipline (≥3 steps / ≥5 min threshold, present-for-approval).
- ✅ The Memory section is high-quality guidance in its own right.

---

## 7. Suggested revised top-of-file (illustrative)

```markdown
# AGENTS.md

## Project overview
<agent-context> is a <one-line purpose>. Documentation-only repo (no runtime).
Stack: Markdown. Maintainer prefix: `mn/`.

## Environment
No build step. Editor: any Markdown-aware editor.

## Validation (when code/scripts are present)
Run `./validation.sh` — mirrors CI (`.github/workflows/ci.yml`).
Steps: build → scan (secrets + lint) → test (coverage gate >85%).
File-scoped fast loop: <example command> before running the full suite.

## …(existing sections, copy-edited, condensed)…
```

---

## 8. Sources consulted

- Official spec — https://agents.md/  ·  repo https://github.com/agentsmd/agents.md
- Philipp Schmid (ETH Zurich "Evaluating AGENTS.md") — https://www.philschmid.de/writing-good-agents
- Builder.io — https://www.builder.io/blog/agents-md
- Addy Osmani — https://addyosmani.com/agents/15-agents-md/
- Anthropic Claude Code memory docs — https://code.claude.com/docs/en/memory
- 0xfauzi gist (comprehensive) — https://gist.github.com/0xfauzi/7c8f65572930a21efa62623557d83f6e
- GitHub Copilot AGENTS.md support changelog — https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/
- Real-world reference: OpenAI Codex `AGENTS.md` — https://github.com/openai/codex/blob/main/AGENTS.md

---

*Bottom line: The file's **process philosophy is strong and ahead of the public consensus** (delegation, investigation, planning, memory hygiene). Its **weaknesses are the fundamentals**: no project overview, no concrete commands, generic tool-doc bloat, internal inconsistencies (mandating absent tooling), and ~10 typos. Fixing §1–§3 alone would lift it from "good draft" to "production-grade."*
