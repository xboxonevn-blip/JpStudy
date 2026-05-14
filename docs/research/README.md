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

Current D4.P3 persona docs: `D4-personas/Q4.P3-hypotheses.md`, `D4-personas/Q4.P3-experiment.md`, `D4-personas/Q4.P3-raw-output.md`, `D4-personas/Q4.P3-analysis.md`; UAT note: `docs/notes/2026-05-14-uat-mai-n2-session.md`.

Current D4.P4 persona docs: `D4-personas/Q4.P4-hypotheses.md`, `D4-personas/Q4.P4-experiment.md`, `D4-personas/Q4.P4-raw-output.md`, `D4-personas/Q4.P4-analysis.md`; UAT note: `docs/notes/2026-05-14-uat-bac-hung-n4-session.md`.

Current D4.P5 persona docs: `D4-personas/Q4.P5-hypotheses.md`, `D4-personas/Q4.P5-experiment.md`, `D4-personas/Q4.P5-raw-output.md`, `D4-personas/Q4.P5-analysis.md`; UAT note: `docs/notes/2026-05-14-uat-sora-n1-session.md`.

Current D4 synthesis: `D4-persona-synthesis.md`.

Current D5.Q5.1 FSRS correctness docs: `D5-pedagogy/Q5.1-hypotheses.md`, `D5-pedagogy/Q5.1-experiment.md`, `D5-pedagogy/Q5.1-raw-output.md`, `D5-pedagogy/Q5.1-analysis.md`.

Current D5.Q5.2 streak docs: `D5-pedagogy/Q5.2-hypotheses.md`, `D5-pedagogy/Q5.2-experiment.md`, `D5-pedagogy/Q5.2-raw-output.md`, `D5-pedagogy/Q5.2-analysis.md`.

Current D5.Q5.3 XP/level docs: `D5-pedagogy/Q5.3-hypotheses.md`, `D5-pedagogy/Q5.3-experiment.md`, `D5-pedagogy/Q5.3-raw-output.md`, `D5-pedagogy/Q5.3-analysis.md`.

Current blocker: Firebase CLI can see `jpstudy-v2`, but local `gcloud`/`bq` are unavailable, so GA4 BigQuery export readiness is not verified.

Current content blocker: `tool/research/content_vi_status_report.dart` finds `1,886` explicit open-review items, including `1,744` grammar examples, plus `5,273` machine-origin vocab items without approval/open-review status. Q2.2 also found `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5`.

Current D2 routing note: local Minna vocab route stops at N4, but N3-N1 have `ShinKanzen`/`hajimete`; do not market N3+ as Minna continuation.

Current link graph blocker: grammar examples are mostly linked, but same-level vocab-to-kanji coverage is shallow; do not add prerequisite gating yet.

Current scope blocker: cumulative vocab count is broad enough by rough JLPT targets, but cumulative N1 kanji is only `889 / 2,000`; do not claim full N1/N2 kanji scope.

Current upper-kanji metadata blocker: Q2.6 sampled N3/N2/N1 kanji found only `22 / 50` exact Unihan Han-Viet matches and `23 / 50` missing local Han-Viet values; do not present upper Han-Viet as fully trusted yet.

Current D3 blocker: UI Vietnamese is structurally present in `app_language.dart` (`680` returns per locale, no blanks), but `1,893` Vietnamese lines bypass it after excluding research helper code. Runtime Dart mojibake and docs decode errors are currently guarded at `0` hits. Q3.4 sampled `100` strings: `92/100` clean, `8/100` raw-English-term warnings. Q3.5 recommends no full ARB migration before beta: surface is `140` files and `5,219` `AppLanguage.en/vi/ja` references. Q3.6 found `41` raw English plural-risk strings and `0` ICU usage; central `AppLanguage` helpers were patched, leaving `31` feature-local matches.

Current D4.P2 blocker: N3/VI works after root start, but direct deep links skip level init and fall back to N5, live `/exam-center` does not match the local rich JLPT hub, mobile reading CTA can be occluded by bottom nav, and N3 vocab shows `Hajimete N3 (0 mục từ)`. Local patch fixed study-goal mojibake and JLPT reading meta chips, but live remains pre-fix.

Current D4.P3 blocker: N2/VI root start works, but live direct grammar/vocab/kanji/coach/reading routes still fall to N5 and `/exam-center` remains stale/empty. Mai's 3-hour/day cramming need is not represented by onboarding or the daily plan; group study is share/roadmap only.

Current D4.P4 blocker: N4/VI root and slow-tap learning plan work at tablet 125% zoom, but live direct study routes fall to N5. There is no travel/fun study goal and no visible font-size/accessibility setting.

Current D4.P5 blocker: N1 immersion content exists after root init, but direct advanced routes fall to N5, study hub advanced resources do not surface N1 reading, and no news/current-world reading path is visible.

Current D4 synthesis blocker: P2-P5 all fail broad beta readiness. Universal priority is deploy/channel parity plus route-level level persistence; persona scope decisions follow immediately after.

Current hosting parity note: `firebase.json` targets both `jpstudy-v2` and `jpstudy`; read-only Firebase channel check shows `jpstudy-v2` live last released `2026-05-13 01:32:40`, older than local `HEAD` `e468d6c7` (`2026-05-14T11:52:56+07:00`). No deploy has been attempted in this pass.

Current D5.Q5.1 blocker: `FsrsService` is a legacy `17`-parameter FSRS-like scheduler, not current FSRS-6. New-card `Again`, `Hard`, and `Good` first intervals are `576`, `864`, and `3,456` minutes locally versus reference scheduler `1`, `5.5`, and `10` minutes; persisted SRS state has no FSRS learning/relearning state or step.

Current D5.Q5.2 blocker: global streak is device-local-midnight only, has no freeze/grace/repair policy, can miss grammar-review credit, and `user_progress.day` is not unique/upserted. Treat streak as gamification display, not a reliable cross-skill retention signal.

Current D5.Q5.3 blocker: XP is fragmented across modules and has no daily cap, diminishing-return, or visible account-XP policy. Learn and flashcard screens can show `+XP` without a discovered global `user_progress` write, while tests/games/challenges do write globally. Treat `todayXp` and level as partially populated gamification counters, not normalized learning effort.

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
- D4 status: P2-P5 measured; D4 synthesis complete. Next highest-leverage action is live channel parity verification before D5/D6 hardening.
- D5 status: Q5.1 measured; SRS scheduling is not FSRS-6-conformant and needs a state/step-aware scheduler decision before production SRS claims.
- D5 status update: Q5.2 measured; streak policy/write paths need normalization before using streak in beta-retention interpretation.
- D5 status update: Q5.3 measured; XP/level policy needs centralization before using XP for beta motivation analytics or competitive framing.

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
