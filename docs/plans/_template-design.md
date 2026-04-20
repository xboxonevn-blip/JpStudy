# Technical Design Template

Use this template for `docs/plans/YYYY-MM-DD-feature-design.md`.

Write a design doc when the task needs technical decisions, tradeoff analysis, interface choices, or risk management before implementation.

---

# [Feature Name] Design

**Date:** YYYY-MM-DD  
**Status:** Draft | Approved | Superseded  
**Owner:** [agent / person]  
**Related docs:** [spec doc], [plan doc], [issue], [roadmap item]

## Summary

Briefly describe the technical problem and the proposed direction.

## Problem

Describe the current technical gap, bug source, or architecture pressure.

## Desired Result

State the concrete technical outcome this design should achieve.

## Constraints

- [technical constraint]
- [backward-compatibility constraint]
- [performance / migration / platform constraint]

## Non-goals

- [non-goal]
- [non-goal]

## Current State

- [relevant existing file / component / provider]
- [current behavior or limitation]
- [tests or docs that define current truth]

## Proposed Design

Describe the chosen design and why it is the right level of change.

### Architecture / Data Flow

```text
[optional simple flow or component diagram]
```

### Interfaces Affected

- [route / provider / DAO / service / model / widget]
- [contract or API change]

### Files Likely To Change

- `[path/to/file]` - [why]
- `[path/to/file]` - [why]

## Alternatives Considered

### Option A

- Pros: [benefit]
- Cons: [cost]

### Option B

- Pros: [benefit]
- Cons: [cost]

## Risks

- [regression risk]
- [data or state risk]
- [UI / localization / migration risk]

## Failure Modes

- [failure mode]
- [failure mode]

## Test Strategy

### Targeted Checks

- `[command or test file]`
- `[command or test file]`

### Final Gates

- `flutter analyze`
- `flutter test`
- `flutter build web`

## Acceptance Criteria

- [clear engineering acceptance criterion]
- [clear engineering acceptance criterion]

## Rollout / Follow-up

- [migration note]
- [cleanup note]
- [future improvement intentionally deferred]
