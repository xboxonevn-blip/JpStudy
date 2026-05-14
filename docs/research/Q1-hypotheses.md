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

## H1.5 - GA4 BigQuery rows can be normalized without lossy event identity

Prediction: raw GA4/Firebase BigQuery export rows can be converted into the normalized NS event contract using `event_name`, `event_timestamp`, `user_id` or `user_pseudo_id`, and repeated `event_params`. Effect size: one local fixture produces the same NS gate breakdown as the normalized event fixture.

Falsifier: the export shape lacks stable per-user identity, timestamp precision, or typed parameter values needed by NS gates.

## H1.6 - Local CLI access can verify GA4 export readiness

Prediction: the local Firebase/GCP CLI environment can confirm project/app identity and BigQuery export readiness without manual console access. Effect size: project, app, and export dataset/table visibility from commands.

Falsifier: Firebase CLI can list projects/apps but cannot expose Analytics BigQuery export status, and `gcloud`/`bq` are unavailable.
