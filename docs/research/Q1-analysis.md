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
