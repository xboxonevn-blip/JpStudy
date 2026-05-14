# JpStudy Research Notebook

Commit baseline: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## North Star

Measure the percentage of 50 beta users who:

1. complete at least 20 SRS reviews over 14 days,
2. pass an embedded N5 micro-quiz with at least 70% accuracy,
3. rate session quality at least 4 out of 5.

Phase 0 status: synthetic snapshot, synthetic persona-event replay, normalized-event, GA4-shaped fixture NS eval, and SM1 funnel reporting work; production telemetry contract is now partially wired. Real-user NS still needs export enablement and a real beta-day sample from Firebase/GA4 or another beta telemetry sink.

Current D1.Q1.1 gap map: `D1-measurement/Q1.1-observability-gap-map.md`

Current D1.Q1.2 simulator docs: `D1-measurement/Q1.2-hypotheses.md`, `D1-measurement/Q1.2-experiment.md`, `D1-measurement/Q1.2-raw-output.md`, `D1-measurement/Q1.2-analysis.md`

Current D1.Q1.3 event-set docs: `D1-measurement/Q1.3-hypotheses.md`, `D1-measurement/Q1.3-experiment.md`, `D1-measurement/Q1.3-raw-output.md`, `D1-measurement/Q1.3-analysis.md`

Current D1.Q1.4 export handoff docs: `D1-measurement/Q1.4-hypotheses.md`, `D1-measurement/Q1.4-experiment.md`, `D1-measurement/Q1.4-raw-output.md`, `D1-measurement/Q1.4-analysis.md`

Current D2.Q2.1 content-status docs: `D2-content/Q2.1-hypotheses.md`, `D2-content/Q2.1-experiment.md`, `D2-content/Q2.1-raw-output.md`, `D2-content/Q2.1-analysis.md`

Current D2.Q2.2 grammar sample docs: `D2-content/Q2.2-hypotheses.md`, `D2-content/Q2.2-experiment.md`, `D2-content/Q2.2-raw-output.md`, `D2-content/Q2.2-analysis.md`, `D2-content-sample-eval.md`

Current D2.Q2.3 Minna gap docs: `D2-content/Q2.3-hypotheses.md`, `D2-content/Q2.3-experiment.md`, `D2-content/Q2.3-raw-output.md`, `D2-content/Q2.3-analysis.md`

Current D2.Q2.4 link graph docs: `D2-content/Q2.4-hypotheses.md`, `D2-content/Q2.4-experiment.md`, `D2-content/Q2.4-raw-output.md`, `D2-content/Q2.4-analysis.md`

Current D2.Q2.5 scope docs: `D2-content/Q2.5-hypotheses.md`, `D2-content/Q2.5-experiment.md`, `D2-content/Q2.5-raw-output.md`, `D2-content/Q2.5-analysis.md`

Current D2.Q2.6 kanji Unihan docs: `D2-content/Q2.6-hypotheses.md`, `D2-content/Q2.6-experiment.md`, `D2-content/Q2.6-raw-output.md`, `D2-content/Q2.6-analysis.md`

Current D2 synthesis: `D2-content/D2-synthesis-2026-05-14.md`

Current D3.Q3.1 app-language docs: `D3-vietnamese/Q3.1-hypotheses.md`, `D3-vietnamese/Q3.1-experiment.md`, `D3-vietnamese/Q3.1-raw-output.md`, `D3-vietnamese/Q3.1-analysis.md`

Current D3.Q3.2 hardcoded-Vietnamese docs: `D3-vietnamese/Q3.2-hypotheses.md`, `D3-vietnamese/Q3.2-experiment.md`, `D3-vietnamese/Q3.2-raw-output.md`, `D3-vietnamese/Q3.2-analysis.md`

Current D3.Q3.3 mojibake docs: `D3-vietnamese/Q3.3-hypotheses.md`, `D3-vietnamese/Q3.3-experiment.md`, `D3-vietnamese/Q3.3-raw-output.md`, `D3-vietnamese/Q3.3-analysis.md`

Current D3.Q3.4 typography docs: `D3-vietnamese/Q3.4-hypotheses.md`, `D3-vietnamese/Q3.4-experiment.md`, `D3-vietnamese/Q3.4-raw-output.md`, `D3-vietnamese/Q3.4-analysis.md`

Current D3.Q3.5 ARB recommendation docs: `D3-vietnamese/Q3.5-hypotheses.md`, `D3-vietnamese/Q3.5-experiment.md`, `D3-vietnamese/Q3.5-raw-output.md`, `D3-vietnamese/Q3.5-analysis.md`

Current D3.Q3.6 plural/ICU docs: `D3-vietnamese/Q3.6-hypotheses.md`, `D3-vietnamese/Q3.6-experiment.md`, `D3-vietnamese/Q3.6-raw-output.md`, `D3-vietnamese/Q3.6-analysis.md`

Current D3 ownership/glossary docs: `D3-vietnamese/hardcoded-copy-ownership-2026-05-14.md`, `D3-vietnamese/terminology-glossary-seed-2026-05-14.md`

Current D3 synthesis: `D3-vietnamese/D3-synthesis-2026-05-14.md`

Current D4.P2 persona docs: `D4-personas/Q4.P2-hypotheses.md`, `D4-personas/Q4.P2-experiment.md`, `D4-personas/Q4.P2-raw-output.md`, `D4-personas/Q4.P2-analysis.md`; UAT note: `docs/notes/2026-05-14-uat-anh-tuan-n3-session.md`.

Current blocker: Firebase CLI can see `jpstudy-v2`, but local `gcloud`/`bq` are unavailable, so GA4 BigQuery export readiness is not verified.

Current content blocker: `tool/research/content_vi_status_report.dart` finds `1,886` explicit open-review items, including `1,744` grammar examples, plus `5,273` machine-origin vocab items without approval/open-review status. Q2.2 also found `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5`.

Current D2 routing note: local Minna vocab route stops at N4, but N3-N1 have `ShinKanzen`/`hajimete`; do not market N3+ as Minna continuation.

Current link graph blocker: grammar examples are mostly linked, but same-level vocab-to-kanji coverage is shallow; do not add prerequisite gating yet.

Current scope blocker: cumulative vocab count is broad enough by rough JLPT targets, but cumulative N1 kanji is only `889 / 2,000`; do not claim full N1/N2 kanji scope.

Current upper-kanji metadata blocker: Q2.6 sampled N3/N2/N1 kanji found only `22 / 50` exact Unihan Han-Viet matches and `23 / 50` missing local Han-Viet values; do not present upper Han-Viet as fully trusted yet.

Current D3 blocker: UI Vietnamese is structurally present in `app_language.dart` (`680` returns per locale, no blanks), but `1,893` Vietnamese lines bypass it after excluding research helper code. Runtime Dart mojibake and docs decode errors are currently guarded at `0` hits. Q3.4 sampled `100` strings: `92/100` clean, `8/100` raw-English-term warnings. Q3.5 recommends no full ARB migration before beta: surface is `140` files and `5,219` `AppLanguage.en/vi/ja` references. Q3.6 found `41` raw English plural-risk strings and `0` ICU usage; central `AppLanguage` helpers were patched, leaving `31` feature-local matches.

Current D4.P2 blocker: N3/VI works after root start, but direct deep links skip level init and fall back to N5, live `/exam-center` does not match the local rich JLPT hub, mobile reading CTA can be occluded by bottom nav, and N3 vocab shows `Hajimete N3 (0 mục từ)`. Local patch fixed study-goal mojibake and JLPT reading meta chips, but live remains pre-fix.

## Open Questions

- Q1: Can we measure learning happening? Active.
- Q2: Where do users drop off before first SRS review? Pending eval events.
- Q3: Is FSRS scheduling calibrated for Vietnamese N5 learners? Pending simulator.
- Q4: Does Han Viet help? Pending experiment design.
- Q5: What retention curve is plausible? Pending simulator.
- Q6: Which personas beyond Linh? Pending qualitative design.
- Q7: Smallest test vs Anki + free decks? Pending after measurement.
- Q8: Is Vietnamese content safe enough for beta learners? Active; D2 says measured but not ready for broad mixed-level beta.
- D2 status: measured but not ready; move to D3 editorial/i18n audit before D4 persona UAT.
- D3 status: Q3.1-Q3.6 measured; D3 synthesis and targeted plural/glossary fixes pending.
- D4 status: P2 Anh Tuấn N3 measured; P3-P5 pending.

## Phase 0 Definition Of Done

- Event/data contract for NS exists.
- Synthetic seeded cohort exists.
- One-command 10-user persona simulator exists.
- One command reports current synthetic NS.
- One command reports SM1 funnel stages from event exports.
- SRS review, N5 quiz, and quality-rating telemetry events exist.
- Onboarding completion telemetry exists for SM1.
- Report states observability gaps for real beta users.
- Research journal records experiment, negative results, surprise updates.
