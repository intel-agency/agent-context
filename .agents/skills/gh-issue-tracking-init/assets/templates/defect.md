---
name: Defect
about: Report a defect / bug-fix task
title: 'Defect: '
labels: ['defect']
assignees: []
---

# Defect: [Short symptom]

## Reproduction

1. [Step 1: Exact action taken]
2. [Step 2: Observed trigger]
3. [Expected vs actual result]

## Root Cause

[Concise first-hand finding (logs, code, output) identifying the cause. Cite file:line.]

## Fix

[Smallest surgical change that resolves the defect. Link the PR/commit.]

## Verification

```bash
# Commands that reproduce the defect before the fix and pass after it
```

- [ ] Regression test added that fails before / passes after the fix
- [ ] Full test suite green
