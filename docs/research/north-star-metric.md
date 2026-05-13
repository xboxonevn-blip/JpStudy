# North Star Metric

`NS = qualified_users / 50 * 100`

A qualified beta user must satisfy all gates within a 14-day window:

- `srs_reviews_completed >= 20`
- `n5_micro_quiz_accuracy >= 0.70`
- `session_quality_rating >= 4`

## Required Fields

- Stable anonymous user id.
- Review event timestamp.
- Review item type and level.
- Review result/grade.
- Micro-quiz session id, level, correct count, total count, completed timestamp.
- Session quality rating 1-5, timestamp, source session id.

## Current Code Mapping

- SRS reviews: local Drift `user_progress.reviewed_count` aggregates by day; per-item state in `srs_state`, `grammar_srs_state`, `kanji_srs_state`, `kana_srs_state`.
- Quiz accuracy: local Drift `test_sessions.score`; learn-session accuracy in `learn_sessions`.
- Session quality: `session_quality_rated` logs from learn/test summaries; no local durable table yet.
- Firebase Analytics: now has `srs_review_completed`, `n5_micro_quiz_completed`, and `session_quality_rated` in addition to learn/auth/sync events.

## Real-User Measurement Gap

The app can now emit the three NS event families, but cannot yet compute NS across 50 beta users without an export/join path and stable anonymous cohort key. N5 micro-quiz telemetry currently treats lesson 1-25 test completions as the N5 proxy; this should become an explicit embedded micro-quiz id.
