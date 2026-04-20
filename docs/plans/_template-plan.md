# Implementation Plan Template

Use this template for `docs/plans/YYYY-MM-DD-feature-plan.md`.

Write a plan when the implementation needs an execution breakdown, ownership, checkpoints, or a clear verification sequence.

---

# [Feature Name] Plan

**Date:** YYYY-MM-DD  
**Status:** Draft | Active | Completed | Superseded  
**Owner:** [agent / person]  
**Related docs:** [spec doc], [design doc], [issue], [roadmap item]

## Goal

State the concrete delivery target for this implementation pass.

## Scope

- [in-scope item]
- [in-scope item]

## Non-goals

- [out-of-scope item]
- [out-of-scope item]

## Assumptions

- [assumption]
- [assumption]

## Dependencies / Preconditions

- [dependency]
- [required baseline or prior branch state]

## Execution Steps

### Step 1: [name]

- Files:
  - `[path/to/file]`
- Work:
  - [change]
  - [change]
- Verify:
  - `[command or test]`

### Step 2: [name]

- Files:
  - `[path/to/file]`
- Work:
  - [change]
  - [change]
- Verify:
  - `[command or test]`

### Step 3: [name]

- Files:
  - `[path/to/file]`
- Work:
  - [change]
  - [change]
- Verify:
  - `[command or test]`

## Risks / Watchouts

- [risk]
- [risk]

## Verification Plan

### Targeted Verification

- `[command or test file]`
- `[command or test file]`

### Final Gates

- `flutter analyze`
- `flutter test`
- `flutter build web`

## Exit Criteria

- [done condition]
- [done condition]

## Follow-up Candidates

- [next task]
- [next task]
