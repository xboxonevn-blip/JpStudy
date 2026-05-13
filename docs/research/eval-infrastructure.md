# Eval Infrastructure

## Current State

- Local Drift captures review totals and quiz/test history.
- Firebase Analytics captures broad learn-session events plus auth/sync and the Phase 0 NS event families.
- `srs_review_completed` is wired through `LessonRepository.saveTermReview`.
- `n5_micro_quiz_completed` is wired through `TestHistoryService.saveTest` for lesson ids 1-25 as a proxy.
- `session_quality_rated` is wired through learn/test summary star ratings.
- `dart run tool/research/north_star_report.dart` reports a deterministic synthetic NS baseline.

## Phase 0 Build Target

Add a deterministic eval core that can score a cohort from event-like records:

- fixed seed: `jpstudy-phase0-ns-v1`
- fixed baseline commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`
- output: qualified users, denominator, NS percent, gate pass counts, gaps

## First Harness Scope

The first harness does not mutate production data. It scores a synthetic fixture and exposes missing real-data requirements. Production telemetry wiring now uses the same event contract.

## Rollback Plan

Phase 0 code is additive: pure eval code, analytics methods, UI quality-rating capture, tests, docs, and tool script. No DB migrations or production data semantics changed.
