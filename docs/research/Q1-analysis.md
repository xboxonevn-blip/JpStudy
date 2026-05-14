# Q1 Analysis - E1.1

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## Gate Classification

- SRS review count: locally measurable via `user_progress.reviewed_count`, but not remotely measurable per beta user from current Firebase events.
- N5 micro-quiz accuracy: locally approximable via `test_sessions` if the micro-quiz is represented as a test session; no explicit embedded micro-quiz marker found.
- Session quality >= 4/5: not measurable in current durable code paths.

## Hypothesis Update

- H1.1: partially supported. Local Drift can compute review count and quiz/test accuracy, but lacks quality rating.
- H1.2: falsified. Firebase Analytics lacks per-review, quiz-complete, and quality-rating event families.
- H1.3: supported. Quality rating is the largest hard blocker.
- H1.4: supported. Synthetic cohort scoring is the cheapest next executable artifact.

## Negative Results

- No real-user NS can be computed from current Firebase events.
- No existing one-command NS report found.
- No durable session-quality rating found.

## Red Team

Steelman opposite: quality rating may exist in a screen not matched by search terms, or Firebase DebugView/GA4 has default engagement events not visible in source. That still would not satisfy NS because the app needs a rating >= 4/5 tied to a learning session and anonymous beta user. Falsifier: find a deployed event export or table with `session_quality_rating` and stable user id.

## Action

Implemented deterministic synthetic NS scorer and CLI report. Added telemetry event families for SRS reviews, N5 quiz proxy completion, and session quality rating.

## E1.2 Result

Synthetic baseline: 2 / 50 qualified users, NS 4.00%.

Gate pass counts:

- Review: 29 / 50
- Quiz: 9 / 50
- Quality: 12 / 50

Interpretation: in the synthetic cohort, quiz accuracy and quality rating are the bottlenecks; review volume is less limiting. This is not a product conclusion yet because the dataset is synthetic. It validates the scorer and exposes what a real report will need.

## E1.2 Red Team

Steelman opposite: synthetic output can create false confidence because distributions are arbitrary. The correct conclusion is not "NS is 4%" for real users; it is "the scorer can compute NS if event records exist." Falsifier: a GA4 export with stable anonymous user ids produces a different gate bottleneck, or the N5 proxy overcounts non-micro-quiz test completions.

## E1.3 Result

The report can now score normalized event exports over a 14-day window. Fixture result: 1 / 50 qualified users, NS 2.00%, observed users 2. User `u1` qualifies; `u2` fails review and quiz gates.

Interpretation: Phase 0 no longer depends on manually prepared per-user snapshots. The remaining gap is upstream normalization from Firebase/GA4 export into the event-row contract.

## E1.3 Red Team

Steelman opposite: normalized JSON is not the same as raw GA4 BigQuery export. The adapter proves event-contract scoring, not actual Firebase export readiness. Falsifier: run against a real exported GA4 sample and find missing `userId`, event params, or timestamp precision problems.

## E1.4 Result

The report can now score GA4/Firebase BigQuery export-shaped rows via `--ga4-events`. Fixture result: 1 / 50 qualified users, NS 2.00%, observed users 2. This matches the normalized event fixture gate breakdown.

Interpretation: Phase 0 has a local bridge from documented GA4 export rows into the NS scorer. The remaining uncertainty is not schema mechanics; it is whether the deployed app actually emits the required event families at sufficient quality and whether BigQuery export is enabled for the project.

## E1.4 Red Team

Steelman opposite: the fixture follows documentation, not a real project export. GA4 export can still fail NS measurement if consent suppresses analytics storage, `user_pseudo_id` continuity resets, or event params are absent because app instrumentation is disabled. Falsifier: export one real beta-day sample and score it without adapter changes.

## E1.5 Result

Local Firebase CLI access can confirm `jpstudy-v2` project identity and all configured apps. It cannot confirm GA4 BigQuery export readiness from this environment: `gcloud` and `bq` are not installed, and Firebase CLI help does not expose an Analytics/BigQuery export inspection command.

Interpretation: the next real-data step is operational, not code-level. Phase 0 needs either a real exported GA4 JSON sample, GCP Console confirmation of the Analytics BigQuery link, or installed/authenticated `gcloud`/`bq` access.

## E1.5 Red Team

Steelman opposite: Firebase CLI project/app visibility is still useful because it proves auth and project scope. But it is insufficient evidence for export readiness; app config can be correct while Analytics BigQuery export is disabled or empty. Falsifier: a successful BigQuery query against `analytics_*` tables for `jpstudy-v2`.
