# Handwriting Measurement Audit

This note defines the next quality pass for handwriting without starting a broad implementation refactor.

## Goal

Measure handwriting reliability in a way that separates:

- false positives
- false negatives
- template/data defects
- threshold/scoring defects
- UX/session issues that look like scoring issues

## Audit sample set

Build a small repeatable review set across these buckets:

- single-kanji prompts with stable templates
- compound prompts built from lesson examples
- easy shapes that should score highly
- visually similar shapes that should be rejected
- incomplete strokes / wrong order samples
- cross-level examples from `N5` and `N4`

Target a fixed seed set large enough to compare before/after tuning, but small enough to run during iteration.

## Metrics to capture

For each sample, record:

- prompt id / kanji id
- session mode (`single`, `compound`, `mixed`)
- expected verdict (`accept` or `reject`)
- actual verdict
- template version / scoring version
- likely failure bucket (`template`, `threshold`, `normalization`, `session UX`)

Summary metrics should include:

- false positive rate
- false negative rate
- pass rate by mode
- pass rate by level
- top recurring failure buckets

## Execution shape

- add or reuse a deterministic audit runner rather than ad-hoc manual checks
- keep the sample set versioned so improvements are comparable over time
- report results to `docs/reports/` when the workflow is stable enough
- do not change thresholds and templates in the same commit that introduces the audit harness

## Acceptance criteria

- the team can reproduce the same sample run locally
- failures are grouped into actionable buckets
- future tuning can cite measured deltas instead of anecdotal impressions
- the audit remains separate from release-hardening smoke tests
