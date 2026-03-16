# Retention Audit (2026-03-16)

## Scope

Audit target:
- `.agent/`
- `docs/plans/legacy/`

## `.agent/` classification

Status update: `.agent/` is no longer present in the repository working tree.

### Retired from repo

Reason:
- `.agent/` is not part of runtime app architecture
- the repository now documents its structure without relying on the local agent framework
- active documentation no longer depends on `.agent/` paths

### Verdict

- `REMOVED FROM WORKING TREE`
- no longer part of the active repository layout
- if an external backup exists, keep it outside the repo only

## `docs/plans/legacy/` classification

### Keep in `docs/plans/legacy/`

- `docs/plans/legacy/README.md`
- `docs/plans/legacy/PLAN-vocab-normalization-manual.md`

Reason:
- still useful as historical reference for the old vocab normalization strategy
- retains meaningful context for data migration history

### Archive deeper

Moved to `docs/archive/legacy-plans/`:
- `PLAN-lesson-grammar-ui.md`
- `PLAN-srs-vocab-review.md`
- `PLAN-ui-overhaul.md`
- `PLAN.md`
- `PLAN_ANIMATION_FIX.md`
- `PLAN_ENHANCE_PRACTICE.md`
- `PLAN_GRAMMAR_SRS.md`
- `PLAN_UI_OVERHAUL.md`
- `PLAN_VALIDATION_FIX.md`
- `WALKTHROUGH-srs-vocab-review.md`

Reason:
- mostly tied to older feature iterations
- no longer aligned with the current repository structure
- lower-value for daily navigation than current docs/plans
- some files still carry older wording or encoding damage

### Delete now

No legacy plan file was hard-deleted in this pass.

Reason:
- archive is safer than deletion for historical project context
- content can be removed later after a deliberate second-pass review

## Outcome

This pass reduces noise in active docs while preserving history.

Current recommendation:
- use `docs/plans/` for active planning
- use `docs/plans/legacy/` only for the small set of still-useful historical references
- use `docs/archive/legacy-plans/` for everything else historical and low-priority
