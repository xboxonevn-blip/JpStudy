# JpStudy Research Notebook

Commit baseline: `51d3d55f6fb3b3da7a699253841b18579cc4e815`

## North Star

Measure the percentage of 50 beta users who:

1. complete at least 20 SRS reviews over 14 days,
2. pass an embedded N5 micro-quiz with at least 70% accuracy,
3. rate session quality at least 4 out of 5.

Phase 0 status: synthetic snapshot, synthetic persona-event replay, normalized-event, GA4-shaped fixture NS eval, and SM1 funnel reporting work are in place. Production telemetry now has a first source-verifiable GA4/BigQuery learning sample; real-user NS still needs a real beta cohort, not export enablement.

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

Current D2 synthesis: `D2-content/D2-synthesis-2026-05-15.md`

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

Current D5.Q5.4 onboarding fork docs: `D5-pedagogy/Q5.4-hypotheses.md`, `D5-pedagogy/Q5.4-experiment.md`, `D5-pedagogy/Q5.4-raw-output.md`, `D5-pedagogy/Q5.4-analysis.md`.

Current D5.Q5.5 mistake/ghost docs: `D5-pedagogy/Q5.5-hypotheses.md`, `D5-pedagogy/Q5.5-experiment.md`, `D5-pedagogy/Q5.5-raw-output.md`, `D5-pedagogy/Q5.5-analysis.md`.

Current D5.Q5.6 cross-skill prerequisite docs: `D5-pedagogy/Q5.6-hypotheses.md`, `D5-pedagogy/Q5.6-experiment.md`, `D5-pedagogy/Q5.6-raw-output.md`, `D5-pedagogy/Q5.6-analysis.md`.

Current D5.Q5.7 roadmap rationale: `D5-pedagogy/Q5.7-roadmap-design-rationale.md`.

Current D6.Q6.1 card pattern docs: `D6-ui-ux/Q6.1-hypotheses.md`, `D6-ui-ux/Q6.1-experiment.md`, `D6-ui-ux/Q6.1-raw-output.md`, `D6-ui-ux/Q6.1-analysis.md`.

Current D6.Q6.2 empty-state docs: `D6-ui-ux/Q6.2-hypotheses.md`, `D6-ui-ux/Q6.2-experiment.md`, `D6-ui-ux/Q6.2-raw-output.md`, `D6-ui-ux/Q6.2-analysis.md`.

Current D6.Q6.3 loading-state docs: `D6-ui-ux/Q6.3-hypotheses.md`, `D6-ui-ux/Q6.3-experiment.md`, `D6-ui-ux/Q6.3-raw-output.md`, `D6-ui-ux/Q6.3-analysis.md`.

Current D6.Q6.4 error-state docs: `D6-ui-ux/Q6.4-hypotheses.md`, `D6-ui-ux/Q6.4-experiment.md`, `D6-ui-ux/Q6.4-raw-output.md`, `D6-ui-ux/Q6.4-analysis.md`.

Current D6.Q6.5 contrast docs: `D6-ui-ux/Q6.5-hypotheses.md`, `D6-ui-ux/Q6.5-experiment.md`, `D6-ui-ux/Q6.5-raw-output.md`, `D6-ui-ux/Q6.5-analysis.md`, plus required violation register `D6-contrast-audit.md`.

Current D6.Q6.6 touch-target docs: `D6-ui-ux/Q6.6-hypotheses.md`, `D6-ui-ux/Q6.6-experiment.md`, `D6-ui-ux/Q6.6-raw-output.md`, `D6-ui-ux/Q6.6-analysis.md`.

Current D6.Q6.7 dark-mode parity docs: `D6-ui-ux/Q6.7-hypotheses.md`, `D6-ui-ux/Q6.7-experiment.md`, `D6-ui-ux/Q6.7-raw-output.md`, `D6-ui-ux/Q6.7-analysis.md`.

Current D7.Q7.1 performance baseline docs: `D7-performance/Q7.1-hypotheses.md`, `D7-performance/Q7.1-experiment.md`, `D7-performance/Q7.1-raw-output.md`, `D7-performance/Q7.1-analysis.md`. Build budget: `D7-performance/web_perf_budget.json`; command: `dart run tool/research/web_perf_budget_report.dart --build-root build/web --budget docs/research/D7-performance/web_perf_budget.json --fail-on-violation`.

Current D7.Q7.2 bundle-composition docs: `D7-performance/Q7.2-hypotheses.md`, `D7-performance/Q7.2-experiment.md`, `D7-performance/Q7.2-raw-output.md`, `D7-performance/Q7.2-analysis.md`.

Current D7.Q7.3 renderer-choice docs: `D7-performance/Q7.3-hypotheses.md`, `D7-performance/Q7.3-experiment.md`, `D7-performance/Q7.3-raw-output.md`, `D7-performance/Q7.3-analysis.md`.

Current D7.Q7.5 compression docs: `D7-performance/Q7.5-hypotheses.md`, `D7-performance/Q7.5-experiment.md`, `D7-performance/Q7.5-raw-output.md`, `D7-performance/Q7.5-analysis.md`.

Current D7.Q7.6 font-subset docs: `D7-performance/Q7.6-hypotheses.md`, `D7-performance/Q7.6-experiment.md`, `D7-performance/Q7.6-raw-output.md`, `D7-performance/Q7.6-analysis.md`.

Current D7.Q7.7 route lazy-load docs: `D7-performance/Q7.7-hypotheses.md`, `D7-performance/Q7.7-experiment.md`, `D7-performance/Q7.7-raw-output.md`, `D7-performance/Q7.7-analysis.md`.

Current D8.Q8.1 compliance docs: `D8-compliance/Q8.1-hypotheses.md`, `D8-compliance/Q8.1-experiment.md`, `D8-compliance/Q8.1-raw-output.md`, `D8-compliance/Q8.1-analysis.md`.

Current D8.Q8.2 API-key restriction docs: `D8-compliance/Q8.2-hypotheses.md`, `D8-compliance/Q8.2-experiment.md`, `D8-compliance/Q8.2-raw-output.md`, `D8-compliance/Q8.2-analysis.md`.

Current D8.Q8.3 Auth authorized-domain docs: `D8-compliance/Q8.3-hypotheses.md`, `D8-compliance/Q8.3-experiment.md`, `D8-compliance/Q8.3-raw-output.md`, `D8-compliance/Q8.3-analysis.md`.

Current D8.Q8.4 error-monitoring docs: `D8-compliance/Q8.4-hypotheses.md`, `D8-compliance/Q8.4-experiment.md`, `D8-compliance/Q8.4-raw-output.md`, `D8-compliance/Q8.4-analysis.md`.

Current D8.Q8.5 CI/CD docs: `D8-compliance/Q8.5-hypotheses.md`, `D8-compliance/Q8.5-experiment.md`, `D8-compliance/Q8.5-raw-output.md`, `D8-compliance/Q8.5-analysis.md`.

Current D8.Q8.1 release-risk docs: `D8-release-risk/Q8.1-hypotheses.md`, `D8-release-risk/Q8.1-experiment.md`, `D8-release-risk/Q8.1-raw-output.md`, `D8-release-risk/Q8.1-analysis.md`.

Current mission completion audit: `mission-completion-audit-2026-05-17.md`.

Current app-coherence audit: `app-coherence-audit-2026-05-17.md`; Phase 1 content-pipeline follow-up: `app-coherence-phase1-content-pipeline-2026-05-17.md`; latest full live-audit root-cause pass: `full-audit-2026-05-17.md`. Phase 0 confirmed 11 shell branches, 68 `GoRoute` declarations, duplicate Home routes (`/`, `/roadmap`, `/today`), dual onboarding gates, split desktop/mobile Home implementations, and a stale content manifest. Phase 1 made `/lesson/:id` vocab source-aware (`minna_*` for N5/N4, `shinkanzen_*` for N3/N2/N1), regenerated `assets/data/content/index.json` from actual assets, and added guards for manifest drift plus N5-N1 lesson vocab seeding. The full audit confirmed the live P0 lesson symptom remained because route identity was not level-scoped and loading collapsed pending futures to empty UI. The P0 source patch now uses level-scoped storage lesson IDs for N3/N2/N1, emits `level=` in lesson links, hides fake zero totals while loading, adds vocab content timeouts, and removes shell double navigation. It was deployed and live-verified on 2026-05-17: N5/N4/N3/N2/N1 lesson routes all showed non-zero vocab totals, `/premium` rendered Upgrade, and `/search` rendered vocab results. Phase 2 unified study-level writes through persisted helper methods, added a feature guard against direct provider writes, and live-verified fresh `/exam-center` N2 rendering after fixing both the mock exam route and the sidebar-linked exam-center hub. Phase 3 reduced the shell to five destinations (`Home`, `Learn`, `Review`, `Exam`, `Profile`), made `/roadmap`, `/today`, `/memory`, `/active`, `/study`, and `/community` legacy redirects, removed the dead Community placeholder and old custom-deck surface, redirected old enhanced lesson-mode URLs to `/lesson/:id/practice/:mode`, aligned the Review page title, and removed duplicate `/progress` routing from the Profile branch. Phase 4 split lesson detail into screen/controls/card parts, renamed the first lesson tab to Vocab, hard-gated fixed curriculum edit/copy/add/combine flows, redirected legacy edit/match routes, wired the Kanji study-flow card, removed blocking Home achievement dialogs, and stopped live SRS writes from touching legacy SM-2 `box`/`ease` fields. Phase 5 rewrote learner-facing copy away from developer/product jargon, removed the Design Lab dev surface from learner routing/source, and guarded roadmap titles from raw-ID leaks. Phase 6 added an N5-only foundations soft-suggest guard, verified search already indexes vocab/kanji/kana, unified remaining vocab CTA/path wording, deployed `812b4e0` to `hosting:jpstudy`, and live-verified N3 `/vocab` without the Kana prompt after cache-disabled reload. Remaining open work: external launch-proof gates and any newly added full-app P0 follow-up.

Current measurement status: BigQuery service-account auth and Job User access are available for `jpstudy-v2`. Use `npm run report:ga4-export -- --out output/research/ga4-export-status-latest.md` for the one-command dataset/event/funnel/NS/TTL/Admin-retention report; it wraps `tool/research/bigquery_rest_runner.js`, probes GA4 Admin retention with `analytics.readonly`, and uses `GOOGLE_APPLICATION_CREDENTIALS`. The matching key present in this workspace is `C:\Users\xboxo\.config\gcp\jpstudy-v2-591716a5e835.json`. On `2026-05-16T08:12+07:00`, `analytics_536663906` still had only `events_20260514`; the current sample had `4` observed users, `1` onboarded user, `0` first-SRS users, and real NS `0.00%`. BigQuery retention is proven at 60 days by dataset defaults and `events_20260514` expiration `2026-07-14T02:56:46.272Z`. The GA4 Admin retention probe still returns `403` because `analyticsadmin.googleapis.com` is disabled for project `129949648924`; `gcloud` is not installed in this environment and the service account receives `403 PERMISSION_DENIED` for Service Usage, so Codex cannot enable the API from here. Live Playwright network smokes prove the deployed app emits all three learning event families (`22` batched `srs_review_completed` rows, `session_quality_rated`, and `n5_micro_quiz_completed`) to GA4 with `204` responses. Real-user NS is therefore no longer blocked on client emission, including the quiz-pass client sample; it remains blocked on BigQuery export ingestion of those learning rows.

Update 2026-05-16T10:38+07: a live Playwright smoke rechecked `https://jpstudy.web.app` and observed `n5_micro_quiz_completed` (`correct_count=4`, `total_count=10`, `accuracy=0.4`) plus `session_quality_rated` (`mode=test`, `rating=5`) returning GA `204`; the same smoke session already had SRS review GA `204` evidence. `npm run report:ga4-export -- --json` now sees `events_20260514` and `events_20260515`, but the learning rows still are not exported, so `ga4-learning-events-missing` remains open.

Update 2026-05-16T17:17+07: a follow-up live Playwright smoke completed `/#/lesson/1/test-enhanced` with `10/10` correct and observed `n5_micro_quiz_completed` returning GA `204` with `correct_count=10`, `total_count=10`, `accuracy=1.0`. A fresh `npm run report:ga4-export -- --json` at `2026-05-16T17:20+07` still sees only daily tables `events_20260514` and `events_20260515` without learning rows, so the remaining GA4 blocker is daily export ingestion, not client-side quiz-pass emission.

Update 2026-05-17T07:13+07: `npm run report:ga4-export -- --json`
still sees only `events_20260514` and `events_20260515`. Exported events are
limited to page/session engagement (`page_view`, `user_engagement`,
`session_start`, `first_visit`), so `srs_review_completed`,
`n5_micro_quiz_completed`, and `session_quality_rated` remain missing from
BigQuery export.

Update 2026-05-17T08:28+07: GA4 BigQuery export ingested the learning rows.
`npm run report:ga4-export -- --json` now sees `events_20260516` with
`srs_review_completed=69`, `n5_micro_quiz_completed=3`, and
`session_quality_rated=2`. The first source-verifiable North Star sample has
`observedUsers=5`, `reviewGatePasses=1`, `quizGatePasses=1`,
`qualityGatePasses=1`, and `qualifiedUsers=1`.

Update 2026-05-17T09:57+07: recheck still sees the same three learning-event
families in BigQuery, with `events_20260514`/`15`/`16`, dataset/table TTL proof
at 60 days, and GA4 Admin retention still blocked by `403` permission.

Current content status: the 2026-05-16 all-levels D2 audit scans `23,444` items. N5-N1 all have `0` machine/open-review items. N5/N4 are launch-tier for the beginner-heavy pilot; N3/N2/N1 have launch-tier editorial quality with user spot-check still pending. Do not describe N5-N1 as fully human-approved, and do not add `vi-human-approved` without user item-level review.

Current D2 routing note: local Minna vocab route stops at N4, but N3-N1 have `ShinKanzen`/`hajimete`; do not market N3+ as Minna continuation.

Current link graph blocker: grammar examples are mostly linked, but vocab-to-kanji coverage remains too shallow for hard prerequisite gating. Cumulative lower-or-same-level kanji coverage fully covers only N1 `2483/6379`, N2 `1098/2991`, N3 `545/1786`, N4 `672/1719`, and N5 `549/1470` kanji-bearing vocab entries.

Current scope blocker: cumulative vocab count is broad enough by rough JLPT targets, but cumulative N1 kanji is only `889 / 2,000`; do not claim full N1/N2 kanji scope.

Current upper-kanji metadata note: Q2.6 originally sampled N3/N2/N1 kanji and found only `22 / 50` exact Unihan Han-Viet matches plus `23 / 50` missing local Han-Viet values. Checked upper-kanji metadata is represented by `kanji-metadata-approved`; mixed-debt kanji files no longer carry `vi-human-approved`. The cumulative N1 kanji scope is still `889 / 2,000`, so do not claim full N1/N2 kanji coverage or full N5-N1 human approval.

Current Kanji per-language UX status: Hán-Việt rules are Kanji-owned and visible only in Vietnamese. Kanji detail, search keywords, lesson Kanji list, reading practice, and handwriting practice now hide Hán-Việt/Vietnamese-only aids for EN/JA and fall back to English meanings where no localized Japanese definition exists. Deployed `4747b677` and follow-up `b07d10f6`; live proof covers JA Kanji detail, JA Search `nhan` gating, JA lesson Kanji tab, JA Kanji Reading, and JA Handwriting. The model/DB/runtime path now supports `meaningJa` via `labels.meaningJa`, but the current assets contain `0` Japanese definition fields. Remaining gap: source-backed Japanese definition data and phased JLPT-complete kanji expansion.

Current D3 blocker: UI Vietnamese is structurally present in `app_language.dart` (`680` returns per locale, no blanks), but `1,893` Vietnamese lines bypass it after excluding research helper code. Runtime Dart mojibake and docs decode errors are currently guarded at `0` hits. Q3.4 sampled `100` strings: `92/100` clean, `8/100` raw-English-term warnings. Q3.5 recommends no full ARB migration before beta: surface is `140` files and `5,219` `AppLanguage.en/vi/ja` references. Q3.6 found `41` raw English plural-risk strings and `0` ICU usage; central `AppLanguage` helpers plus vocab/feature-local follow-ups reduced the tracked plural-risk grep to `0` matches.

Current D4.P2 blocker: N3/VI works after root start, the latest live vocab re-check shows Hajimete N3 plus Shin Kanzen N3 open with real counts, and the 2026-05-16 live direct-route matrix after `558fc151` preserved N3 on grammar/kanji/immersion/reading/coach with no N5 fallback markers. Remaining P2 risks are route-depth confidence, mobile CTA/live copy defects, and lack of a sharper busy-professional plan.

Current D4.P3 blocker: N2/VI root start works, and the latest live vocab re-check shows Hajimete N2 plus Shin Kanzen N2 open with real counts. Mai's 3-hour/day cramming need is still not represented by onboarding or the daily plan; group study is share/roadmap only.

Current D4.P4 blocker: N4/VI root and slow-tap learning plan work at tablet 125% zoom, and the post-deploy route-matrix retest preserved N4 on grammar/kanji/immersion/reading/coach with no N5 fallback markers. There is no travel/fun study goal and no visible font-size/accessibility setting.

Current D4.P5 blocker: N1 immersion content exists after root init, and the latest live vocab re-check shows Hajimete N1 plus Shin Kanzen N1 open with real counts while N1+ correctly remains future scope. Advanced-reader discovery is still incomplete: no obvious news/current-world reading path and no public claim of full N1 kanji coverage.

Current D4 synthesis blocker: P2-P5 still fail broad beta readiness, but the live upper-vocab availability blocker is cleared and the 2026-05-16/17 live direct-route matrix for N4/N3/N2/N1 shows no N5 fallback markers after `558fc151`. `npm run report:live-route-matrix -- --json` now reproduces this as a 36-route live smoke. Universal priority has shifted to external launch proofs, route-depth/persona confidence, and explicit persona scope limits.

Current hosting posture: primary web Hosting is now `hosting:jpstudy` at `https://jpstudy.web.app`. Legacy default site `hosting:jpstudy-v2` / `https://jpstudy-v2.web.app` was disabled on `2026-05-14T20:18+07` with Firebase release type `SITE_DISABLE`; it still exists as a Firebase default site identity but should not receive deploys. Local `.firebaserc`, `firebase.json`, and release docs now target only `hosting:jpstudy`.

Current D5.Q5.1 status: P0 scheduler bug remediated. `FsrsService` now uses the current FSRS-6 default vector (`21` params including decay), persists `fsrs_state` and `fsrs_step` across vocab/grammar/kanji/kana SRS tables, and pins new-card intervals to `Again=1m`, `Hard=5.5m`, `Good=10m`, `Easy=4d`. Remaining gap is calibration/outcome proof from real beta SRS events, not scheduler conformance.

Current D5.Q5.2 blocker: global streak is device-local-midnight only, has no freeze/grace/repair policy, can miss grammar-review credit, and `user_progress.day` is not unique/upserted. Treat streak as gamification display, not a reliable cross-skill retention signal.

Current D5.Q5.3 blocker: XP is fragmented across modules and has no daily cap, diminishing-return, or visible account-XP policy. Learn and flashcard screens can show `+XP` without a discovered global `user_progress` write, while tests/games/challenges do write globally. Treat `todayXp` and level as partially populated gamification counters, not normalized learning effort.

Current D5.Q5.4 blocker: onboarding captures only level and one broad goal, then most downstream surfaces ignore the goal. There is no exam date, daily-minute, cramming, travel/fun, news-reading, group-study, or text-size/accessibility fork. Treat onboarding as minimal setup, not persona personalization.

Current D5.Q5.5 blocker: grammar ghost review has split sources of truth. The visible ghost provider uses `grammar_srs_state.ghostReviewsDue`, but ghost practice answers do not update that field, and "mark mastered" clears old `AttemptAnswer` data instead. Vocab/kanji mistake bank is a simple correct-streak queue, not a scheduler.

Current D5.Q5.6 blocker: cross-skill prerequisite remediation is not product-ready. Scoped kanji practice exists through `KanjiPracticeArgs.kanjiIds`, but there is no policy that maps weak vocab/grammar items to missing prerequisites; use advisory suggestions only, not hard gates.

Current D5.Q5.7 status: textbook-aligned learning path is source-aware and advisory. N5/N4 show the local Minna I/II + Hajimete route, N3/N2/N1 show Hajimete + Shin Kanzen tracks, and N1 adds immersion. Remaining gap: per-textbook progress counters are not normalized yet.

Current D6.Q6.1 blocker: card surfaces have an implicit taxonomy, not a documented one. `AppSectionCard`/`AppFeatureCard`, `HomeSurface.softPanel`, and practice-specific panels all exist; avoid mass refactor, but document allowed surface families before adding more one-off cards.

Current D6.Q6.2 blocker: empty states are locally implemented and uneven. `EmptyStateWidget` exists but has zero feature usages; primary no-data states should be visible/explanatory/actionable, while optional dashboard cards may collapse only after successful loaded-empty state.

Current D6.Q6.3 blocker: loading states work but are uneven. `CircularProgressIndicator` appears `69` times across `53` files, only one structured skeleton was found, and six home/me loading branches collapse with `SizedBox.shrink()`. Primary blocking routes need localized visible loaders; optional panels need compact loading/error treatment before beta telemetry.

Current D6.Q6.4 blocker: error handling has good primitives but uneven adoption. `ErrorStateWidget` has `13` feature usages, broad error/retry grep finds `269` matches in `69` files, at least eight sampled error branches collapse with `SizedBox.shrink()`, and Foundations/Grammar/Recall Sprint can show raw exception text.

Current D6.Q6.5 status: token-level and primary helper-caption contrast remediation is shipped. Light semantic foregrounds now pass `>=4.5:1` on light surfaces, input hints moved from `ink 0.42` to `ink 0.68`, shared status chips have regression coverage, and shared empty/error, lesson, Search, and Vocab flashcard helper captions now use `ink 0.64`. Remaining contrast work is an ad hoc sweep of active helper captions still using low-alpha `ink 0.45`-`0.55`.

Current D6.Q6.6 status: min-touch remediation is largely shipped. `AppTouchTargets.min = 44` now guards compact top-bar notifications, Discover reorder/focus controls, mistake delete buttons, interactive `StarRating`, library/practice compact action CTAs, handwriting free-practice CTA, and lesson inline actions. Remaining work is a final grep/screenshot pass for active custom controls outside the audited risk list.

Current D6.Q6.7 blocker: dark mode is wired and focused tests pass, but it is not parity-ready. Dark `ThemeData` lacks several light-theme component families, `ThemeMode.system` is unsupported, hardcoded light surfaces remain in Grammar repair prompts, and only one route-level dark visual probe exists. The former Design Lab dev surface has been removed from learner routing/source.

Current D7.Q7.1-Q7.7 blocker: release web build passes and E7.2 added a reproducible build-artifact budget gate. E7.3 fixed discovered all-level grammar seed paths; E7.5 removed app DB startup grammar seeding while preserving requested-level lazy seeding for grammar screens, lessons, and JLPT mock. E7.6 added `npm run test:web-resource-smoke`; local first-route resource count is gated at `<=80` and currently passes at `38`, down from the original `250`, with first-route grammar JSON `0`. Current artifact budget passes with `main.dart.js` `6.53 MB` raw / `1.83 MB` gzip, total `build/web` `70.64 MB` raw, total assets `30.07 MB` raw, and JSON assets `27.24 MB` raw. A 2026-05-15 live probe on `https://jpstudy.web.app` returned `resourceCount=30`, `jsonCount=1`, `grammarResourceCount=0`, and Lighthouse scores performance `62`, accessibility `100`, best-practices `77`, SEO `100`. Q7.2 shows raw build composition is CanvasKit/Skwasm and content/support JSON dominated; no deferred route chunks are emitted. Q7.3 says keep default `dart2js` + CanvasKit for beta. Q7.4 says route-level code splitting is feasible only as a controlled leaf-route pilot after route gating settles. Q7.5 says primary Firebase Hosting already serves Brotli, so remaining perf risk is route-specific live budgets and console cleanliness, not a missing compression switch. Q7.6 says bundled icon/product fonts are small enough but live startup still fetches remote Roboto and Noto CJK fallback fonts from `fonts.gstatic.com`. Q7.7 says home is clean and grammar is active-level scoped, but direct `/kanji` still fetches active-level grammar (`25`), examples (`25`), and vocab (`46`) JSON files.

Current D8.Q8.1 blocker: release readiness is gated by external proof, not build compilation alone. Focused route/layout smoke tests pass after a stale `/exam-center` smoke assertion was updated. Secret-backed automated deploy is active on `main`; use `docs/compliance/beta-launch-proof-checklist-2026-05-15.md` or the current GitHub Actions run for the newest exact run ID. Latest live host re-check on 2026-05-16T08:05+07 visually verified Kanji radical headers, Han-Viet rules, and Review Forecast labels on `https://jpstudy.web.app/`. GA4 BigQuery learning export proof closed on 2026-05-17 with all three learning-event families present. Remaining blockers: legal approval, Sentry DSN/first issue, first deletion-runbook proof, GA4 retention proof, and App Check enforcement. Firebase Storage is descoped for beta by owner decision on 2026-05-17 because the project stays on Spark and beta backup is local file export/import.

Current D8-compliance blocker: Privacy Policy / Terms route/link surface now has a minimal tested draft implementation, but it is not public-launch legal clearance. `/privacy` and `/terms` exist, VI+EN copy is present, and Settings/Data, Onboarding, and Login links are covered by focused tests. All copy remains marked `review-needed draft`; final legal review, support/contact details, and deletion-policy approval are still required.

Current D8.Q8.2 status: web Firebase API key referrer restriction is currently passing for Identity Toolkit. Fake `https://evil.example/probe` referrer returns `403 API_KEY_HTTP_REFERRER_BLOCKED`; allowed Firebase Hosting referrers reach endpoint validation (`400 MISSING_ID_TOKEN`). `docs/FIREBASE_SECURITY_CHECKLIST.md` now records the repeatable non-mutating probe. Still manually verify GCP Console allowed-referrer list before public launch.

Current D8.Q8.3 status: Auth authorized-domain source audit is measured but console-blocked for final proof. Source still correctly uses `authDomain: jpstudy-v2.firebaseapp.com`, while primary web Hosting is `https://jpstudy.web.app`; the disabled `https://jpstudy-v2.web.app` legacy site should be removed from production Auth/API-key allowlists where possible. Repository docs require removing `localhost` from production Auth authorized domains unless a time-boxed exception exists.

Current D8.Q8.4 status: Sentry web monitoring is source-wired but not live-verified. The app now has `sentry_flutter`, optional `JPSTUDY_SENTRY_DSN`/environment/release dart-defines, startup and runtime consent/sign-in gates, Do Not Track opt-out, `sendDefaultPii=false`, no auto session tracking, and a disabled-by-default smoke trigger gated by both `JPSTUDY_SENTRY_SMOKE_EVENT=true` and `?sentry-smoke=1`. Recheck on 2026-05-17T09:57+07 with `npm run report:sentry-readiness -- --json` found source/workflow smoke gates present and repository secrets `FIREBASE_TOKEN` plus `JPSTUDY_RECAPTCHA_SITE_KEY`, but no `JPSTUDY_SENTRY_DSN`; readiness remains `false` with reason `sentry-dsn-missing`, and no event was sent. Remaining blocker: user must provide a real Sentry DSN and a deployed first-crash issue URL before claiming production observability.

Current D8.Q8.5 status: CI is stronger than assumed. GitHub Actions run UI string guard, `flutter analyze`, `flutter test`, release-like web build, D7 web artifact budget, D7 local web resource smoke, and Firebase Storage rules tests. E8.7 renamed the workflow to `CI`, changed web build to `flutter build web --release --base-href=/ --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=ci-placeholder`, and added D7 budget gates. E8.10 adds a `main`-only `deploy-hosting` job that builds with real App Check/Sentry secrets, deploys only `hosting:jpstudy`, checks primary `200` and legacy `404`, then runs live web resource smoke plus Lighthouse. E8.13 added manual `workflow_dispatch`, job timeouts, concurrency, and serialized source checks after GitHub runner queue failures. The latest checked main run must have `ui-string-guard`, `firebase-security-rules`, and the real `deploy-hosting` path all completed with `success`, including production build, primary deploy, primary/legacy smoke, live resource smoke, and Lighthouse live gate. Required deploy secrets `FIREBASE_TOKEN` and `JPSTUDY_RECAPTCHA_SITE_KEY` are present. Still missing: external notification or branch-protection proof.

Current D8.Q8.6 status: release process is primary-only and verified, and E8.10 adds a skip-safe automated deploy/live-smoke/Lighthouse job for `main`. The deployment contract is `hosting:jpstudy`; primary must return `200`, legacy `jpstudy-v2.web.app` must return `404`, and Firebase channel metadata keeps legacy release type `SITE_DISABLE`. `docs/FIREBASE_SECURITY_CHECKLIST.md` no longer uses generic `firebase deploy --only hosting`. Latest exact secret-backed automated deploy proof is tracked in `docs/compliance/beta-launch-proof-checklist-2026-05-15.md` and GitHub Actions. Still missing: notification policy and App Check enforcement proof.

Current D8.Q8.7 status: telemetry is acceptable only for closed beta with explicit caveats. Analytics is opt-in, Do Not Track disables collection, custom events are coarse/non-free-text, E8.11 adds anonymous Auth bootstrap with consent-gated Analytics identity, Data controls exposes device-side Analytics reset plus Support ID copy, and `docs/compliance/user-data-deletion-runbook.md` defines the manual support deletion flow. Live verification on 2026-05-15 initially found `accounts:signUp` returning `400 ADMIN_ONLY_OPERATION`; Anonymous provider was then enabled and production-referrer REST + browser probes returned `200`. BigQuery export exists, has 60-day dataset/table expiration proof, and on 2026-05-17T08:28+07 ingested all three learning-event families. Current blockers: GA4 Admin retention remains blocked by disabled Admin API plus insufficient Service Usage permission; public-launch compliance still lacks first executed deletion proof and source-verifiable GA4 UI retention setting. Firebase Storage migration is descoped for beta, with local file export/import as the backup path and `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=false` / unset. Docs: `D8-compliance/Q8.7-hypotheses.md`, `D8-compliance/Q8.7-experiment.md`, `D8-compliance/Q8.7-raw-output.md`, `D8-compliance/Q8.7-analysis.md`.

## Open Questions

- Q1: Can we measure learning happening? Active.
- Q2: Where do users drop off before first SRS review? Pending eval events.
- Q3: Is FSRS scheduling calibrated for Vietnamese N5 learners? Scheduler conformance fixed; real beta retention data still pending.
- Q4: Does Han Viet help? Pending experiment design.
- Q5: What retention curve is plausible? Pending simulator.
- Q6: Which personas beyond Linh? Pending qualitative design.
- Q7: Smallest test vs Anki + free decks? Pending after measurement.
- Q8: Is Vietnamese content safe enough for beta learners? Active; D2 now supports a controlled N5-N1 pilot content set, with N3+ scope/routing caveats still visible.
- D2 status: launch-readiness pass is clean across N5-N1 for machine/open-review debt. Keep scope language visible because N1 kanji coverage remains below target and N3/N2/N1 spot-check is still pending; do not claim full N5-N1 human approval.
- D3 status: Q3.1-Q3.6 measured; targeted English plural-risk fixes are guarded at `0` tracked matches. Glossary consolidation remains pending.
- D4 status: P2-P5 measured; D4 synthesis complete. Live channel parity, upper-vocab availability, and the N4/N3/N2/N1 direct-route N5-fallback class are improved, but broad beta still needs route-depth confidence and explicit persona-scope limits.
- D5 status: Q5.1 remediated at scheduler level; FSRS-6 state/step persistence and pinned learning intervals are implemented. Real learner calibration remains pending.
- D5 status update: Q5.2 measured; streak policy/write paths need normalization before using streak in beta-retention interpretation.
- D5 status update: Q5.3 measured; XP/level policy needs centralization before using XP for beta motivation analytics or competitive framing.
- D5 status update: Q5.4 measured; onboarding needs a small profile/policy layer before claiming persona-specific first sessions or daily plans.
- D5 status update: Q5.5 measured; grammar ghost state needs unification before using ghost practice as a reliable remediation loop.
- D5 status update: Q5.6 measured; prerequisite logic should remain advisory until item-level dependency extraction, coverage labels, and telemetry exist.
- D5 status update: Q5.7 implemented; home now exposes a source-aware textbook roadmap per JLPT level, but progress normalization remains a future data-model step.
- D6 status: Q6.1 measured; visual card drift is manageable if the surface taxonomy is documented before more UI work.
- D6 status update: Q6.2 measured; empty-state consistency needs a visible-primary vs optional-collapsible policy before broad UI polish.
- D6 status update: Q6.3 measured; loading-state consistency needs a primary-blocking vs optional-panel policy before broad UI polish.
- D6 status update: Q6.4 measured; error-state consistency needs severity rules before broad UI polish.
- D6 status update: Q6.5 token-level contrast fixes shipped for light semantic colors, input hints, shared status chips, shared empty/error active helper captions, core lesson-card helper labels, and primary Search helper captions. Remaining work is a feature-local ad hoc small-label sweep before claiming full WCAG 2.1 AA.
- D6 status update: Q6.6 min-touch policy uses `AppTouchTargets.min = 44` with focused coverage for compact top bar, Discover controls, mistake delete, interactive stars, library/practice CTAs, handwriting free-practice, and lesson inline actions; remaining work is final custom-control sweep.
- D6 status update: Q6.7 measured; dark mode can remain available, but route-level parity needs component-theme mirroring, light-surface cleanup, and broader dark tests.
- D7 status: Q7.1-Q7.7 measured and partially remediated; build-artifact and local Playwright resource-count budgets exist and pass, all-level/root grammar startup seeding is fixed, and local first-route resource count dropped from `250` baseline to `38` in the checked-in smoke. Bundle composition shows renderer/runtime and content assets dominate raw bytes, with no route-level deferred chunks. Renderer decision: stay on default `dart2js` + CanvasKit for beta; reserve `--wasm`/Skwasm for preview-channel testing. Code-splitting decision: feasible as a leaf-route pilot, not a broad beta-blocking refactor. Compression decision: Firebase Hosting already serves Brotli on primary, so do not add precompressed repo artifacts. Font decision: bundled icon/product fonts are small enough, but live fallback fonts from `fonts.gstatic.com` remain part of the first-route resource budget. Route lazy-load decision: home and grammar are acceptable, but Kanji route overfetch remains. Performance readiness still needs route-specific live budgets and Lighthouse/trace metrics.
- D8 status: Q8.1-Q8.7 measured except remaining console-only proofs. Shipping/security doc drift is patched, primary-only deploy is verified, API-key fake-referrer probe passes, CI has local D7 gates plus a secret-backed deploy/live-smoke/Lighthouse proof, telemetry is consent-gated/minimized, GA4 deletion runbook exists, and BigQuery TTL proof exists. Remaining public-launch gaps: legal review, Sentry first-event proof, GA4 UI retention proof, first executed deletion proof, and App Check enforcement proof. Firebase Storage is beta-deferred, not a launch blocker.
- D8 launch-readiness aggregate: `npm run report:launch-readiness -- --json` added on 2026-05-16. Latest Storage-aware run on 2026-05-17T10:00+07 returns `complete=false` without `storage-not-provisioned` or `ga4-learning-events-missing`; unresolved gates are legal approval, Sentry DSN/first issue, executed deletion proof, GA4 retention proof, and later App Check enforcement. Current launch/storage/deletion/GA4 reports print operator URLs so handoff is direct, but URLs do not close proof gates. Client-side live emission and BigQuery export of all three learning events are now proven.
- D8 compliance status: Q8.1 measured and minimally implemented; Privacy/Terms routes, VI+EN draft copy, and links from Settings/Data, Onboarding, and Login exist, but final legal review remains required before public launch.
- D8 compliance status update: Q8.2 measured; web API-key fake-referrer probe is blocked with `API_KEY_HTTP_REFERRER_BLOCKED`, but console restriction list still needs manual launch-gate review.
- D8 compliance status update: Q8.3 measured; Auth authorized-domain final proof is manual Console work, and the security checklist now records the production-domain/localhost gate.
- D8 compliance status update: Q8.4 measured and partially implemented; Sentry web error capture is optional and consent-gated in source, but DSN setup and first-crash live verification remain open.
- D8 compliance status update: Q8.5 measured and mostly remediated in source; local CI gates plus build-artifact/resource-count budgets exist, and `main` has a skip-safe deploy/live-smoke/Lighthouse job. Remaining gap is operational proof after GitHub deploy secrets are configured, plus notification/branch-protection policy.
- D8 compliance status update: Q8.6 measured and partially remediated; manual primary-only deploy is proven, legacy default Hosting remains disabled, and active docs now avoid generic all-hosting deploy. Automated release remains deferred until secrets, live smoke, Lighthouse/trace, and notification policy are defined.

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
