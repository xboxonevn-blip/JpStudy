# Eval Infrastructure

## Current State

- Local Drift captures review totals and quiz/test history.
- Firebase Analytics captures broad learn-session events plus auth/sync and the Phase 0 NS event families.
- `onboarding_completed` is wired after onboarding preferences persist and carries `level` + `goal` for SM1.
- `srs_review_completed` is wired through `LessonRepository.saveTermReview`.
- `n5_micro_quiz_completed` is wired through `TestHistoryService.saveTest` for lesson ids 1-25 as a proxy.
- `session_quality_rated` is wired through learn/test summary star ratings.
- `dart run tool/research/north_star_report.dart` reports a deterministic synthetic NS baseline.
- `dart run tool/research/north_star_report.dart --simulate-users <n> --window-start <iso>` scores deterministic persona-tagged synthetic event replay over a 14-day window.
- `dart run tool/research/north_star_report.dart --events <json> --window-start <iso>` scores normalized event exports over a 14-day window.
- `dart run tool/research/north_star_report.dart --ga4-events <json> --window-start <iso>` scores GA4/Firebase BigQuery export-shaped rows over a 14-day window.
- `dart run tool/research/funnel_report.dart --events <json> --window-start <iso>` scores SM1 open -> onboarding -> first SRS funnel stages.
- `dart run tool/research/content_vi_status_report.dart --content-root assets/data/content` scores Vietnamese review-status tags by level and dataset.
- `dart run tool/research/content_link_graph_report.dart --content-root assets/data/content` scores vocab-kanji and grammar-example cross-link coverage by level.
- `dart run tool/research/content_scope_report.dart --content-root assets/data/content` counts distinct vocab, kanji, grammar points, and grammar example sentences by level.
- `dart run tool/research/kanji_unihan_spot_check_report.dart --content-root assets/data/content --unihan-readings .codex/sources/Unihan/Unihan_Readings.txt` checks a deterministic kanji Han-Viet sample against Unihan `kVietnamese`.
- `dart run tool/research/vietnamese_i18n_audit_report.dart --app-language lib/core/app_language.dart --lib-root lib --content-root assets/data/content --docs-root docs` scores app-language coverage, hardcoded Vietnamese copy, mojibake markers, and decode-error docs.

## Phase 0 Build Target

Add a deterministic eval core that can score a cohort from event-like records:

- fixed seed: `jpstudy-phase0-ns-v1`
- fixed baseline commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`
- output: qualified users, denominator, NS percent, gate pass counts, gaps

## First Harness Scope

The first harness does not mutate production data. It scores a synthetic fixture and exposes missing real-data requirements. Production telemetry wiring now uses the same event contract.

## Synthetic Replay Scope

`SyntheticNorthStarEventSimulator` emits deterministic event-level replay for persona-tagged users. It covers all five JLPT levels by cycling through `linh_n5`, `bac_hung_n4`, `anh_tuan_n3`, `mai_n2`, and `sora_n1`.

This is not yet a full app session replay on Drift. It validates scorer wiring, event shape, segmentation, and reproducibility before real export access exists.

## Event Export Contract

Normalized event rows use:

```json
{
  "userId": "anonymous-user",
  "name": "srs_review_completed",
  "occurredAt": "2026-05-01T00:00:00.000Z",
  "parameters": {"rating": 3}
}
```

Supported event names:

- `srs_review_completed`
- `n5_micro_quiz_completed`
- `session_quality_rated`

Mapper rules:

- count SRS events inside `[windowStart, windowEnd)`;
- choose the best N5 quiz accuracy inside the window;
- choose the maximum quality rating inside the window.

## GA4 BigQuery Export Contract

The raw adapter expects Google's documented export shape:

- `event_name`
- `event_timestamp` as microseconds UTC
- `user_id` when available, otherwise `user_pseudo_id`
- repeated `event_params` rows with `key` plus one typed value field: `string_value`, `int_value`, `double_value`, or `float_value`

Reference: https://support.google.com/analytics/answer/7029846

## BigQuery Export Handoff

`tool/research/ga4_ns_export.sql` exports the narrow event set needed for NS and SM1. Save raw output under `docs/research/secure/`, which is git-ignored.

## Rollback Plan

Phase 0 code is additive: pure eval code, analytics methods, UI quality-rating capture, tests, docs, and tool script. No DB migrations or production data semantics changed.
