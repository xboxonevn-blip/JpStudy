# Q1 Hypotheses - Can We Measure Learning?

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## H1.1 - Local Drift has enough signal for offline NS

Prediction: At least 2 of 3 gates can be computed locally from Drift with no schema change: SRS review count and N5 quiz accuracy. Effect size: 67% gate coverage.

Falsifier: fewer than 2 gates can be computed from durable local tables.

## H1.2 - Firebase Analytics has enough signal for beta NS

Prediction: Firebase has user-level events for at least session start, review complete, quiz complete, and quality rating. Effect size: 4 required event families.

Falsifier: any required family missing or not joinable per anonymous user.

## H1.3 - Session quality is the largest observability gap

Prediction: there is no existing 1-5 quality rating stored locally or logged remotely. Effect size: 0 durable quality records found.

Falsifier: a table, SharedPreferences key, or analytics event stores a 1-5 session-quality rating tied to a session/user.

## H1.4 - Synthetic cohort scoring is the cheapest first eval

Prediction: a pure deterministic scorer can compute NS and gate breakdown faster than DB migration or Firebase export work. Effect size: under 2 hours for first executable report.

Falsifier: existing app already has a one-command NS report from real data.
