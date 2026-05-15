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

Current measurement status: BigQuery service-account auth and Job User access are available for `jpstudy-v2`. Use `tool/research/bigquery_rest_runner.js` with `GOOGLE_APPLICATION_CREDENTIALS` set because the local default Python is the Inkscape Python without `pip`. The matching key present in this workspace is `C:\Users\xboxo\.config\gcp\jpstudy-v2-591716a5e835.json`. On `2026-05-15`, `SELECT 1 AS ok` passed; `asia-southeast1` listed `firebase_crashlytics`, `firebase_messaging`, and `firebase_sessions`; `US` listed zero datasets; and GA4 dataset `analytics_536663906` was still absent in both locations. Real-user NS remains blocked until `analytics_536663906.events_*` exists.

Current content blocker: `tool/research/content_vi_status_report.dart` finds `1,886` explicit open-review items, including `1,744` grammar examples, plus `5,273` machine-origin vocab items without approval/open-review status. Q2.2 also found `4 / 4` sampled N1/N2 approved grammar explanations scored clarity `2/5`.

Current D2 routing note: local Minna vocab route stops at N4, but N3-N1 have `ShinKanzen`/`hajimete`; do not market N3+ as Minna continuation.

Current link graph blocker: grammar examples are mostly linked, but vocab-to-kanji coverage remains too shallow for hard prerequisite gating. Cumulative lower-or-same-level kanji coverage fully covers only N1 `2483/6379`, N2 `1098/2991`, N3 `545/1786`, N4 `672/1719`, and N5 `549/1470` kanji-bearing vocab entries.

Current scope blocker: cumulative vocab count is broad enough by rough JLPT targets, but cumulative N1 kanji is only `889 / 2,000`; do not claim full N1/N2 kanji scope.

Current upper-kanji metadata blocker: Q2.6 sampled N3/N2/N1 kanji found only `22 / 50` exact Unihan Han-Viet matches and `23 / 50` missing local Han-Viet values; do not present upper Han-Viet as fully trusted yet.

Current D3 blocker: UI Vietnamese is structurally present in `app_language.dart` (`680` returns per locale, no blanks), but `1,893` Vietnamese lines bypass it after excluding research helper code. Runtime Dart mojibake and docs decode errors are currently guarded at `0` hits. Q3.4 sampled `100` strings: `92/100` clean, `8/100` raw-English-term warnings. Q3.5 recommends no full ARB migration before beta: surface is `140` files and `5,219` `AppLanguage.en/vi/ja` references. Q3.6 found `41` raw English plural-risk strings and `0` ICU usage; central `AppLanguage` helpers were patched, leaving `31` feature-local matches.

Current D4.P2 blocker: N3/VI works after root start, but direct deep links skip level init and fall back to N5, live `/exam-center` does not match the local rich JLPT hub, mobile reading CTA can be occluded by bottom nav, and N3 vocab shows `Hajimete N3 (0 mục từ)`. Local patch fixed study-goal mojibake and JLPT reading meta chips, but live remains pre-fix.

Current D4.P3 blocker: N2/VI root start works, but live direct grammar/vocab/kanji/coach/reading routes still fall to N5 and `/exam-center` remains stale/empty. Mai's 3-hour/day cramming need is not represented by onboarding or the daily plan; group study is share/roadmap only.

Current D4.P4 blocker: N4/VI root and slow-tap learning plan work at tablet 125% zoom, but live direct study routes fall to N5. There is no travel/fun study goal and no visible font-size/accessibility setting.

Current D4.P5 blocker: N1 immersion content exists after root init, but direct advanced routes fall to N5, study hub advanced resources do not surface N1 reading, and no news/current-world reading path is visible.

Current D4 synthesis blocker: P2-P5 all fail broad beta readiness. Universal priority is deploy/channel parity plus route-level level persistence; persona scope decisions follow immediately after.

Current hosting posture: primary web Hosting is now `hosting:jpstudy` at `https://jpstudy.web.app`. Legacy default site `hosting:jpstudy-v2` / `https://jpstudy-v2.web.app` was disabled on `2026-05-14T20:18+07` with Firebase release type `SITE_DISABLE`; it still exists as a Firebase default site identity but should not receive deploys. Local `.firebaserc`, `firebase.json`, and release docs now target only `hosting:jpstudy`.

Current D5.Q5.1 blocker: `FsrsService` is a legacy `17`-parameter FSRS-like scheduler, not current FSRS-6. New-card `Again`, `Hard`, and `Good` first intervals are `576`, `864`, and `3,456` minutes locally versus reference scheduler `1`, `5.5`, and `10` minutes; persisted SRS state has no FSRS learning/relearning state or step.

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

Current D6.Q6.5 blocker: contrast is acceptable for nav and core body text, but not for small helper/status text. Input hints are `2.57:1`, `ink 0.45` helper text is `2.79:1`, `AppStatusChip.warning` is `2.55:1`, and warning/success/info/error semantic foregrounds are not safe for normal-size text on light surfaces.

Current D6.Q6.6 blocker: primary nav/quiz/grid targets mostly pass, but compact overrides break touch safety. Clear risks include discover reorder `28/34` shrink-wrapped icon, discover focus chip small `GestureDetector`, top-bar notification `36/40`, mistake delete `36`, library/practice `minimumSize: Size(0, 0)` action CTAs, lesson inline zero-constraint icons, and interactive `StarRating`.

Current D6.Q6.7 blocker: dark mode is wired and focused tests pass, but it is not parity-ready. Dark `ThemeData` lacks several light-theme component families, `ThemeMode.system` is unsupported, hardcoded light surfaces remain in Grammar repair prompts and Design Lab, and only one route-level dark visual probe exists.

Current D7.Q7.1-Q7.7 blocker: release web build passes and E7.2 added a reproducible build-artifact budget gate. E7.3 fixed discovered all-level grammar seed paths; E7.5 removed app DB startup grammar seeding while preserving requested-level lazy seeding for grammar screens, lessons, and JLPT mock. E7.6 added `npm run test:web-resource-smoke`; local first-route resource count is gated at `<=80` and currently passes at `38`, down from the original `250`, with first-route grammar JSON `0`. Current artifact budget passes with `main.dart.js` `6.53 MB` raw / `1.83 MB` gzip, total `build/web` `70.64 MB` raw, total assets `30.07 MB` raw, and JSON assets `27.24 MB` raw. A 2026-05-15 live probe on `https://jpstudy.web.app` returned `resourceCount=30`, `jsonCount=1`, `grammarResourceCount=0`, and Lighthouse scores performance `62`, accessibility `100`, best-practices `77`, SEO `100`. Q7.2 shows raw build composition is CanvasKit/Skwasm and content/support JSON dominated; no deferred route chunks are emitted. Q7.3 says keep default `dart2js` + CanvasKit for beta. Q7.4 says route-level code splitting is feasible only as a controlled leaf-route pilot after route gating settles. Q7.5 says primary Firebase Hosting already serves Brotli, so remaining perf risk is route-specific live budgets and console cleanliness, not a missing compression switch. Q7.6 says bundled icon/product fonts are small enough but live startup still fetches remote Roboto and Noto CJK fallback fonts from `fonts.gstatic.com`. Q7.7 says home is clean and grammar is active-level scoped, but direct `/kanji` still fetches active-level grammar (`25`), examples (`25`), and vocab (`46`) JSON files.

Current D8.Q8.1 blocker: release readiness is gated by hygiene and parity, not build compilation alone. Focused route/layout smoke tests pass after a stale `/exam-center` smoke assertion was updated, and `3ae2ded9` was manually deployed to primary Hosting on 2026-05-15. Fresh live proof: primary `https://jpstudy.web.app/` returned `200`, legacy `https://jpstudy-v2.web.app/` returned `404`, resource smoke passed, and Lighthouse passed the current thresholds. Remaining blockers: GA4 event tables are still absent, anonymous Auth is disabled server-side, Sentry lacks a real DSN/first issue, and legal copy still needs human approval.

Current D8-compliance blocker: Privacy Policy / Terms route/link surface now has a minimal tested draft implementation, but it is not public-launch legal clearance. `/privacy` and `/terms` exist, VI+EN copy is present, and Settings/Data, Onboarding, and Login links are covered by focused tests. All copy remains marked `review-needed draft`; final legal review, support/contact details, and deletion-policy approval are still required.

Current D8.Q8.2 status: web Firebase API key referrer restriction is currently passing for Identity Toolkit. Fake `https://evil.example/probe` referrer returns `403 API_KEY_HTTP_REFERRER_BLOCKED`; allowed Firebase Hosting referrers reach endpoint validation (`400 MISSING_ID_TOKEN`). `docs/FIREBASE_SECURITY_CHECKLIST.md` now records the repeatable non-mutating probe. Still manually verify GCP Console allowed-referrer list before public launch.

Current D8.Q8.3 status: Auth authorized-domain source audit is measured but console-blocked for final proof. Source still correctly uses `authDomain: jpstudy-v2.firebaseapp.com`, while primary web Hosting is `https://jpstudy.web.app`; the disabled `https://jpstudy-v2.web.app` legacy site should be removed from production Auth/API-key allowlists where possible. Repository docs require removing `localhost` from production Auth authorized domains unless a time-boxed exception exists.

Current D8.Q8.4 status: Sentry web monitoring is source-wired but not live-verified. The app now has `sentry_flutter`, optional `JPSTUDY_SENTRY_DSN`/environment/release dart-defines, startup and runtime consent/sign-in gates, Do Not Track opt-out, `sendDefaultPii=false`, and no auto session tracking. Remaining blocker: user must provide a real Sentry DSN and a deployed first-crash issue URL before claiming production observability.

Current D8.Q8.5 status: CI is stronger than assumed. GitHub Actions run UI string guard, `flutter analyze`, `flutter test`, release-like web build, D7 web artifact budget, D7 local web resource smoke, and Firebase Storage rules tests. E8.7 renamed the workflow to `CI`, changed web build to `flutter build web --release --base-href=/ --dart-define=JPSTUDY_RECAPTCHA_SITE_KEY=ci-placeholder`, and added D7 budget gates. E8.10 adds a `main`-only `deploy-hosting` job that builds with real App Check/Sentry secrets, deploys only `hosting:jpstudy`, checks primary `200` and legacy `404`, then runs live web resource smoke plus Lighthouse. Manual live gates passed for `3ae2ded9` on 2026-05-15, but the deploy job still skips until `FIREBASE_TOKEN` and `JPSTUDY_RECAPTCHA_SITE_KEY` are configured. Still missing: first successful secret-backed deploy proof, explicit notification, and branch-protection proof.

Current D8.Q8.6 status: manual release process is primary-only and verified, and E8.10 adds a skip-safe automated deploy/live-smoke/Lighthouse job for `main`. Phase 5 and the 2026-05-15 `3ae2ded9` release both deployed with `hosting:jpstudy`; primary returned `200`, legacy `jpstudy-v2.web.app` returned `404`, and Firebase channel metadata shows legacy release type `SITE_DISABLE`. `docs/FIREBASE_SECURITY_CHECKLIST.md` no longer uses generic `firebase deploy --only hosting`. Still missing: first secret-backed automated deploy proof, notification policy, and App Check/Auth operational proof.

Current D8.Q8.7 status: telemetry is acceptable only for closed beta with explicit caveats. Analytics is opt-in, Do Not Track disables collection, custom events are coarse/non-free-text, and E8.11 adds anonymous Auth bootstrap with consent-gated Analytics identity plus one-time legacy preference migration to `users/{uid}/legacy_migration.json`. Live verification on 2026-05-15 found `accounts:signUp` returns `400 ADMIN_ONLY_OPERATION`, so Firebase Anonymous provider is disabled server-side; the app falls back to local-only boot, but the failed request is still a console error. Public-launch compliance still lacks in-app `resetAnalyticsData`, GA4 user-deletion runbook, source-verifiable GA4 retention setting, BigQuery export TTL proof, and working live Auth/App Check proof. Docs: `D8-compliance/Q8.7-hypotheses.md`, `D8-compliance/Q8.7-experiment.md`, `D8-compliance/Q8.7-raw-output.md`, `D8-compliance/Q8.7-analysis.md`.

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
- D5 status update: Q5.4 measured; onboarding needs a small profile/policy layer before claiming persona-specific first sessions or daily plans.
- D5 status update: Q5.5 measured; grammar ghost state needs unification before using ghost practice as a reliable remediation loop.
- D5 status update: Q5.6 measured; prerequisite logic should remain advisory until item-level dependency extraction, coverage labels, and telemetry exist.
- D5 status update: Q5.7 implemented; home now exposes a source-aware textbook roadmap per JLPT level, but progress normalization remains a future data-model step.
- D6 status: Q6.1 measured; visual card drift is manageable if the surface taxonomy is documented before more UI work.
- D6 status update: Q6.2 measured; empty-state consistency needs a visible-primary vs optional-collapsible policy before broad UI polish.
- D6 status update: Q6.3 measured; loading-state consistency needs a primary-blocking vs optional-panel policy before broad UI polish.
- D6 status update: Q6.4 measured; error-state consistency needs severity rules before broad UI polish.
- D6 status update: Q6.5 measured; contrast needs token-level fixes before claiming WCAG 2.1 AA.
- D6 status update: Q6.6 measured; touch target consistency needs a `44x44` hitbox policy before claiming mobile/tablet accessibility readiness.
- D6 status update: Q6.7 measured; dark mode can remain available, but route-level parity needs component-theme mirroring, light-surface cleanup, and broader dark tests.
- D7 status: Q7.1-Q7.7 measured and partially remediated; build-artifact and local Playwright resource-count budgets exist and pass, all-level/root grammar startup seeding is fixed, and local first-route resource count dropped from `250` baseline to `38` in the checked-in smoke. Bundle composition shows renderer/runtime and content assets dominate raw bytes, with no route-level deferred chunks. Renderer decision: stay on default `dart2js` + CanvasKit for beta; reserve `--wasm`/Skwasm for preview-channel testing. Code-splitting decision: feasible as a leaf-route pilot, not a broad beta-blocking refactor. Compression decision: Firebase Hosting already serves Brotli on primary, so do not add precompressed repo artifacts. Font decision: bundled icon/product fonts are small enough, but live fallback fonts from `fonts.gstatic.com` remain part of the first-route resource budget. Route lazy-load decision: home and grammar are acceptable, but Kanji route overfetch remains. Performance readiness still needs route-specific live budgets and Lighthouse/trace metrics.
- D8 status: Q8.1-Q8.7 measured except remaining console-only proofs. Shipping/security doc drift is patched, primary-only deploy is verified, API-key fake-referrer probe passes, CI has local D7 gates, and telemetry is consent-gated/minimized. Remaining public-launch gaps: legal review, automated deploy/live smoke/Lighthouse, error monitoring implementation, GA4 retention/deletion runbook, BigQuery TTL proof, and App Check telemetry/enforcement proof.
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
