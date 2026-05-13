# Synthesis 2026-05-13

## Phase 0 Status

Ready for synthetic measurement; not yet ready for a 50-user beta readout.

## Top Findings

1. Current pre-change Firebase telemetry could not compute NS. Confidence: high.
2. Local Drift had review and quiz/test fragments, but no durable quality rating. Confidence: high.
3. A deterministic scorer can now compute NS from cohort snapshots and reveal gate bottlenecks. Confidence: high for machinery, low for product inference because the dataset is synthetic.

## Ruled Out

1. "Firebase already has enough events" - false.
2. "Quality rating already exists somewhere" - not found in code.
3. "Phase 0 can be only SQL" - false; missing event families required product instrumentation.

## What We Still Do Not Know

- Whether real Vietnamese N5 learners pass the quiz gate after review volume.
- Whether the lesson 1-25 test proxy matches the intended embedded N5 micro-quiz.
- Whether Firebase Analytics export will preserve enough anonymous user continuity for a 14-day cohort.

## Recommendation

Do not recruit 50 beta users yet. Recruit at most 5 internal/friend testers after adding export/join plumbing and an explicit embedded N5 micro-quiz id. Current state is good enough to validate telemetry in a small pilot.
