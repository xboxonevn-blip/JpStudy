# Synthesis 2026-05-13

## Phase 0 Status

Ready for synthetic snapshot, synthetic persona-event replay, normalized-event, and GA4-shaped fixture measurement; not yet ready for a 50-user beta readout.

## Top Findings

1. Current pre-change Firebase telemetry could not compute NS. Confidence: high.
2. Local Drift had review and quiz/test fragments, but no durable quality rating. Confidence: high.
3. A deterministic scorer can now compute NS from cohort snapshots, persona-tagged synthetic event replay, normalized event exports, or GA4-shaped export rows and reveal gate bottlenecks. Confidence: high for machinery, low for product inference because datasets are synthetic/fixture-level.
4. `--simulate-users 10` gives a one-command event-level replay harness across N5-N1 personas. Confidence: high for event-contract regression, low for real app navigation/Drift replay.
5. `onboarding_completed {level, goal}` closes the cheapest SM1 funnel gap in app telemetry. Confidence: medium; service-level event shape is tested, but DebugView/export delivery is unverified.
6. `tool/research/funnel_report.dart` can score SM1 from event exports; current fixtures prove old data lacks open/onboarding events. Confidence: high for report mechanics, low for product inference.
7. `tool/research/ga4_ns_export.sql` defines the narrow real-export handoff for NS + SM1. Confidence: high for query intent, unverified until BigQuery access exists.

## Ruled Out

1. "Firebase already has enough events" - false.
2. "Quality rating already exists somewhere" - not found in code.
3. "Phase 0 can be only SQL" - false; missing event families required product instrumentation.

## What We Still Do Not Know

- Whether real Vietnamese N5 learners pass the quiz gate after review volume.
- Whether the lesson 1-25 test proxy matches the intended embedded N5 micro-quiz.
- Whether real Firebase/GA4 export is enabled and preserves anonymous user continuity for beta users.
- Whether the workspace can get `gcloud`/`bq` access or a real exported GA4 JSON sample.

## Recommendation

Do not recruit 50 beta users yet. Recruit at most 5 internal/friend testers after adding export/join plumbing and an explicit embedded N5 micro-quiz id. Current state is good enough to validate telemetry in a small pilot.
