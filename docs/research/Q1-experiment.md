# Q1 Experiment - Eval Surface Audit

Commit: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## Experiment E1.1

Question: Which current code/data surfaces can compute the NS gates?

Method:

- Search actual code for Drift tables, DAOs, FSRS review writes, Firebase Analytics calls, quiz/test persistence, and quality rating storage.
- Classify each NS gate as measurable locally, measurable remotely, or absent.
- Build the cheapest executable artifact after classification: a deterministic synthetic scorer if real beta NS is not computable.

Expected information gain: high. This distinguishes "query existing data" vs "build telemetry contract first".

Cost: 1-2 hours.

Seed: `jpstudy-phase0-ns-v1`

Dataset: codebase at commit `51d3d55f6fb3b3da7a699253841b18579cc4e815`; synthetic fixture to be added after RED test.

## Experiment E1.3

Question: Can the one-command NS report score a real telemetry export shape instead of only synthetic snapshots?

Method:

- Add a normalized event-row model with stable `userId`, `name`, `occurredAt`, and `parameters`.
- Map event rows to North Star user snapshots over a fixed 14-day window.
- Verify with a fixture where one user qualifies and one does not.

Expected information gain: high. This separates "we can score arbitrary events" from "we can only score hand-made snapshot summaries".

Cost: 0.5-1 hour.

Seed: `jpstudy-phase0-ns-v1`

Dataset: `docs/research/fixtures/north-star-events-e1.3.json`

## Experiment E1.4

Question: Can the NS report score GA4/Firebase BigQuery export rows directly?

Method:

- Use Google's documented GA4 BigQuery export shape: `event_name`, microsecond UTC `event_timestamp`, `user_id`/`user_pseudo_id`, repeated `event_params`, and typed parameter value fields.
- Add a raw GA4-row mapper that preserves event identity and parameter values before passing through the normalized event mapper.
- Verify with a fixture where `u1` qualifies and `u2` fails review and quiz gates.

Expected information gain: high. This tests the bridge from actual export-shaped records to the Phase 0 scorer without requiring production data access.

Cost: 0.5-1 hour.

Seed: `jpstudy-phase0-ns-v1`

Dataset: `docs/research/fixtures/north-star-ga4-events-e1.4.json`

Schema source: https://support.google.com/analytics/answer/7029846

## Experiment E1.5

Question: Can local CLI access verify GA4/Firebase export readiness?

Method:

- Read `.firebaserc`, `firebase.json`, and `lib/firebase_options.dart` to verify project/app identity from source.
- Run local Firebase CLI via `npx firebase projects:list --json` and `npx firebase apps:list --project jpstudy-v2 --json`.
- Check whether `gcloud` or `bq` is available for BigQuery dataset/table inspection.

Expected information gain: medium. This distinguishes "adapter ready" from "real export plumbing visible".

Cost: 0.25-0.5 hour.

Dataset: local Firebase project config and authenticated Firebase CLI metadata.
