# Mission Report 2026-05-15

## Verdict

JpStudy-v2 is not ready for a broad 100-user mixed N5-N1 beta.

It is ready for the next controlled gate: a 5-10 learner pilot after the
remaining ops blockers are closed. Later deploy evidence proved current `main`
can serve on `https://jpstudy.web.app`, legacy `https://jpstudy-v2.web.app`
remains `404`, CI is green, and live resource/Lighthouse probes pass.
Anonymous Auth is now enabled and live `accounts:signUp` returns `200`, but
Storage-backed legacy migration is gated off until Firebase Storage is
provisioned. D2 content now reports `0` machine/open-review items across N5-N1;
N3/N2/N1 still need user spot-check before any human-approval claim. Remaining
blockers before the pilot are legal approval, Firebase Storage setup, Sentry
operational proof, deletion proof, GA4 retention proof, exported GA4 learning
rows, and later App Check enforcement.

## Highest-Leverage Findings Shipped

1. Foundations/Kana is now level-gated: non-N5 learners no longer get Kana as a
   primary nav/home path, and `/foundations` explains the lock.
2. Level propagation was hardened so changing level re-renders home and shell
   gates instead of leaving stale N5 surfaces.
3. Vocab catalog WIP gates were removed from data-backed programs, with scope
   notes for Minna, Hajimete, and Shin Kanzen constraints.
4. Radical quality moved from anecdote to audit: `214` rows checked, systemic
   drift documented, and the top visible Han-Viet corrections applied.
5. Radical group header mojibake was fixed through the shared i18n path.
6. Kanji Hub now exposes N2/N1 tabs and richer kanji detail flow, reducing the
   gap between radical-modal UX and kanji-modal UX.
7. Han-Viet rules are now Vietnamese-first with rule examples, category
   filtering, and searchable kanji examples.
8. Desktop nav was compacted into grouped sections, reducing scroll pressure on
   the 11-item sidebar.
9. D8 source gates shipped: Privacy/Terms surface, Sentry source integration,
   primary hosting policy, CI, deploy/live-smoke job, and Java/Firebase CI
   stabilization.
10. Anonymous Auth bootstrap now provides a UID and migration path without
    adding a login wall.

## Top Surprises

1. GA4 BigQuery export appeared after the first absence window, but the first
   sample still has real NS `0.00%` across only `4` observed users and no
   post-onboarding learning events.
2. Radical Han-Viet drift was systemic: mismatch-or-missing compare rows were
   `163 / 214`, far above the expected 5-15%.
3. Vocab readiness split into separate gates: content seed, catalog display,
   CTA availability, and queue count can disagree.
4. Startup performance improved only after removing both grammar seed paths
   from app boot; one scoped fix was not enough.
5. Anonymous Auth can be an identity substrate, separate from account-upgrade
   UX.

## Negative Results Documented

1. `approved-by-user` does not guarantee grammar explanation quality.
2. Cumulative vocab volume does not imply N1/N2 kanji coverage.
3. Vocab-kanji cross-links are too sparse for hard prerequisite gates.
4. Real FSRS calibration is still unproven because beta SRS outcome rows are
   not present yet.
5. Crashlytics/Firebase datasets do not prove runtime error monitoring or
   product analytics readiness.

## Deferred Items

1. Phase 14-19 auth: account linking, soft upgrade UI, community gating, and
   cleanup functions.
2. Upper-level content follow-up: user spot-check for N3/N2/N1 editorial
   samples, plus N1 kanji scope expansion beyond current app coverage.
3. Native release: Android/iOS Firebase App Check, package restrictions, and
   store-ready build pipelines.
4. Performance: live Lighthouse/trace budgets, route-level resource budgets,
   image optimization, and possible deferred-route/code-splitting pilot.
5. Localization: targeted copy centralization first; only pilot ARB/ICU where
   plural/count defects justify it.

## Recommended Next Mission

Run a post-deploy beta-readiness cycle:

1. Set up Firebase Storage for project `jpstudy-v2`, deploy `storage.rules`,
   verify CORS from `https://jpstudy.web.app`, then enable
   `JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION=true`.
2. Configure `JPSTUDY_SENTRY_DSN`, run the Sentry smoke path, and record the
   first issue URL.
3. Record legal approval and GA4 retention proof in the structured proof state.
4. Execute the deletion runbook against a dedicated test UID after Storage and
   GA4 operator access are ready.
5. Keep polling GA4 BigQuery for SRS, micro-quiz, and session-quality rows; the
   current export sample has only open/onboarding events.
6. Decide pilot scope after the remaining operational proof gates close.
