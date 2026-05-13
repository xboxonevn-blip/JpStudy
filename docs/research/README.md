# JpStudy Research Notebook

Commit baseline: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## North Star

Measure the percentage of 50 beta users who:

1. complete at least 20 SRS reviews over 14 days,
2. pass an embedded N5 micro-quiz with at least 70% accuracy,
3. rate session quality at least 4 out of 5.

Phase 0 status: synthetic NS eval works; production telemetry contract is now partially wired. Real-user NS still needs export/join plumbing from Firebase/GA4 or another beta telemetry sink.

## Open Questions

- Q1: Can we measure learning happening? Active.
- Q2: Where do users drop off before first SRS review? Pending eval events.
- Q3: Is FSRS scheduling calibrated for Vietnamese N5 learners? Pending simulator.
- Q4: Does Han Viet help? Pending experiment design.
- Q5: What retention curve is plausible? Pending simulator.
- Q6: Which personas beyond Linh? Pending qualitative design.
- Q7: Smallest test vs Anki + free decks? Pending after measurement.

## Phase 0 Definition Of Done

- Event/data contract for NS exists.
- Synthetic seeded cohort exists.
- One command reports current synthetic NS.
- SRS review, N5 quiz, and quality-rating telemetry events exist.
- Report states observability gaps for real beta users.
- Research journal records experiment, negative results, surprise updates.
