# Handwriting Reliability + Route Hardening Plan - 2026-03-24

## Summary

- This branch starts from the shipped grammar-hardening baseline and is the next active hardening milestone after `grammar-hardening-2026-03-24`.
- The goal is to reduce handwriting false positives and false negatives without changing the public handwriting flow unless a proven bug requires it.
- Route and release hardening stay coupled to handwriting work: prefer stable focused regressions over long walkthroughs, and do not add new skipped tests.
- Dependency refresh stays out of scope for this branch.

## Key Changes

- Audit the current handwriting scoring pipeline before changing behavior:
  - use `lib/features/write/services/handwriting_evaluator.dart` as the scoring authority
  - verify template/vector inputs through `kanji_stroke_template_service.dart` and `kanji_stroke_vector_service.dart`
  - list the highest-value wrong accept / wrong reject cases before tuning thresholds or per-kanji overrides
- Keep fixes internal-first:
  - prefer threshold/profile/tier tuning, template projection fixes, and support-asset corrections
  - keep `HandwritingPracticeScreen` session flow, `Next`, completion, wrong-only retry, and randomized session scope behavior stable
  - do not add new practice modes or broaden product scope
- Extend regression coverage around the cases being tuned:
  - strengthen `test/features/write/handwriting_evaluator_regression_test.dart`
  - keep `test/features/write/handwriting_stroke_check_v2_benchmark_test.dart` green with equal-or-better false-positive rate ceilings
  - update `test/features/write/kanji_stroke_template_service_test.dart` when vector/template projection rules change
  - add or tighten focused UI regressions in `test/features/write/handwriting_walkthrough_test.dart` and route smoke coverage when navigation behavior is touched
- Keep release truth unchanged:
  - `flutter analyze`
  - `flutter test`
  - `flutter build web`

## Public Interfaces

- No new public routes, providers, models, or settings are planned for this branch.
- Existing handwriting entry points and config/session behavior should remain stable unless a concrete bug forces a narrow interface change.

## Test Plan

- Targeted scoring checks:
  - `flutter test test/features/write/handwriting_evaluator_regression_test.dart`
  - `flutter test test/features/write/handwriting_stroke_check_v2_benchmark_test.dart`
  - `flutter test test/features/write/kanji_stroke_template_service_test.dart`
- Focused UI / flow checks:
  - `flutter test test/features/write/handwriting_walkthrough_test.dart`
  - `flutter test test/features/ui/app_route_smoke_test.dart`
- Final gates:
  - `flutter analyze`
  - `flutter test`
  - `flutter build web`

## Assumptions

- The shipped grammar-hardening branch remains the merge target before handwriting work is released.
- The current handwriting tier model (`manual`, `curated`, `generated`) stays in place.
- Benchmark and regression tests are the decision source for whether a tuning pass is acceptable.
- Dependency updates, cloud sync, and unrelated feature work remain out of scope for this branch.
