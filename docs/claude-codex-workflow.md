# Codex + Claude Workflow

This repository works best when Codex is the execution and integration agent, and Claude is the review and design-pressure agent.

Use two lanes instead of forcing one workflow onto every task:

- `Fast lane`: small, clear, low-risk changes
- `Spec lane`: larger, ambiguous, or higher-risk changes

## Recommended Roles

Use Codex in the main repository checkout:

- read the codebase and trace dependencies across `lib/`, `test/`, `tooling/`, and `assets/`
- implement features and bug fixes
- run validation such as `flutter analyze` and `flutter test`
- make the final integrated patch after review feedback

Use Claude in a separate worktree:

- review architecture and design tradeoffs
- review diffs for bugs, regressions, and missing tests
- challenge assumptions around Riverpod state, Drift queries, and navigation flow
- review spec and design docs before large refactors

Do not let both agents edit the same file at the same time.

## Setup

Create a dedicated worktree for Claude from the repository root:

```powershell
git worktree add .claude/worktrees/feature-x -b claude/feature-x
```

Then open Claude in:

```text
.claude/worktrees/feature-x
```

Keep Codex in the main checkout:

```text
C:\Users\xboxo\Documents\GitHub\JpStudy-v2
```

If Claude only needs to review and not edit, you can skip the worktree and just paste the diff or the design doc.

## Task Triage

Use the `fast lane` when most of these are true:

- the task is a bug fix, narrow refactor, test update, or doc/tooling change
- acceptance criteria are already clear from the repo or the user request
- the change is bounded to a small surface area
- there is no meaningful product-behavior shift
- there is no new route, schema, provider contract, or cross-cutting architecture change

Use the `spec lane` when any of these are true:

- the task introduces a new feature or a meaningful behavior change
- requirements are ambiguous or there are multiple reasonable designs
- the task touches navigation, Drift schema/data shape, Riverpod state contracts, sync, or a broad UI flow
- the work is large enough that design mistakes would be expensive
- the user asked for planning, design, or a written spec before implementation

Do not force a spec doc for every small bug fix.
Do not jump straight into implementation for a spec-lane task.

## Problem Framing For Spec Lane

Before proposing a solution for a spec-lane task, Codex should capture:

1. `Desired Result`: the concrete target outcome
2. `Purpose`: why the change matters
3. `Constraints`: technical, product, migration, or UX limits
4. `Non-goals`: what this change will not do
5. `Failure Modes`: how the plan could fail or regress
6. `Acceptance Criteria`: what must be true for the change to count as done
7. `Stretch Goal` optional: a harder target if the core scope lands cleanly

If you use a tougher internal target such as a `Hard Result`, treat it as optional internal pressure, not a mandatory artifact for every task.

## Requirement Gathering

Codex should gather requirements in this order:

1. read the relevant code
2. read the relevant tests
3. read the relevant docs and roadmap
4. ask the user only if unresolved ambiguity would materially change the design or implementation

Do not ask the user to reconfirm information that is already clear in the repository.
Do not add a confirmation gate for a small, already-clear bug fix.

## Artifacts And Naming

Follow the repo split between `specs` and `plans`:

- `docs/specs/YYYY-MM-DD-feature-spec.md`
  - what the feature or behavior should be
- `docs/plans/YYYY-MM-DD-feature-design.md`
  - technical design, tradeoffs, risks, and interfaces
- `docs/plans/YYYY-MM-DD-feature-plan.md`
  - implementation steps, verification plan, rollout notes

Do not force all three artifacts for every task.
Do not put an implementation breakdown into `docs/specs/`.

## Hybrid Workflow

### Fast Lane

Use this for most clear bug fixes and focused improvements.

1. Codex reads the relevant code and implements the change.
2. Codex runs the most relevant checks.
3. Claude reviews the diff if the change is risky enough to justify review.
4. Codex applies valid fixes and reruns checks.

Prompt for Codex:

```text
In this Flutter repository, implement feature or fix X.
Read the relevant code first, make the code changes, run the most relevant checks,
and summarize the result with files changed, tests run, and remaining risks.
```

Prompt for Claude:

```text
Review this Flutter change.
Focus on bugs, regressions, Riverpod state issues, Drift/database risks,
navigation mistakes, UI edge cases, and missing tests.
List findings by severity. Keep the review concise.
```

### Spec Lane

Use this for larger or less-clear changes.

1. Codex frames the problem.
2. Codex gathers context from code, tests, and docs.
3. Codex writes the smallest useful artifact set:
   - spec
   - design
   - plan
4. Claude reviews the spec/design for bugs, missing cases, risky assumptions, and test gaps.
5. The user confirms before implementation when the scope or behavior is non-trivial.
6. Codex implements.
7. Claude reviews the diff.
8. Codex integrates valid fixes and verifies the result.

Prompt for Codex when preparing the design:

```text
Before implementing this change, classify whether it needs a spec lane.
If yes, read the relevant code, tests, and docs first, then produce the smallest useful
spec/design/plan artifact set under docs/specs or docs/plans using the repo naming convention.
State constraints, non-goals, failure modes, and acceptance criteria.
```

Prompt for Claude when reviewing the design:

```text
Review this Flutter spec/design proposal.
Focus on incorrect assumptions, regression risks, Riverpod state issues, Drift/data shape risks,
navigation mistakes, UI edge cases, missing test strategy, and scope creep.
List findings by severity. Keep the review concise.
```

## Task Split For This Repo

Codex is a better fit for:

- editing Flutter feature code under `lib/features/`
- updating repositories, services, and providers under `lib/data/` and `lib/core/`
- fixing tests under `test/`
- running or adjusting Python scripts under `tooling/`
- writing the final integrated implementation and verification result

Claude is a better fit for:

- reviewing app flow across FSRS, ghost review, handwriting, immersion, and mock exam features
- reviewing large UI changes for consistency with the existing design direction
- reviewing risky changes that touch Riverpod providers, Drift DAOs, backup/sync, or router behavior
- reviewing whether a spec, design, or test plan is complete enough before merge

## Useful Review Targets

When a change is risky, ask Claude to focus on one of these areas:

- `lib/app/navigation/`
- `lib/core/services/`
- `lib/data/daos/`
- `lib/data/db/`
- `lib/features/home/`
- `lib/features/write/`
- `lib/features/grammar/`
- `lib/features/test/`
- `test/features/`
- `test/data/`

## Rules That Prevent Conflict

- one agent owns the final patch
- one agent edits a given file at a time
- prefer Codex for final integration and verification
- use Claude for review, critique, and design pressure
- if Claude also writes code, isolate that work in its own worktree and merge deliberately
- use spec lane only when it reduces risk or ambiguity; otherwise stay in fast lane

## Minimal Loop

Use one of these loops:

### Most bug fixes

1. Codex implements.
2. Claude reviews if the change is risky enough.
3. Codex fixes and verifies.

### Most feature work

1. Codex writes the smallest useful spec/design/plan set.
2. Claude reviews the design if the change is risky or broad.
3. User confirms when behavior or scope is non-trivial.
4. Codex implements.
5. Claude reviews the diff.
6. Codex fixes and verifies.

That keeps the repo fast on small tasks without skipping design on large ones.
