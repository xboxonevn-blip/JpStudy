# Autonomous Loop Status

## 2026-05-17

- Track A P0/P1 seed backlog created in `docs/research/quality-backlog.md`.
- Verified locally: Profile shell click routes to `/me`; selected branch is derived from URL path; stale branch index no longer drives selection.
- Verified locally: VI copy guards cover the reported vocab/review leaks and review-page metaphors.
- Verified locally: Vietnamese vocab catalog status badges no longer render `Companion` or duplicate `Bổ trợ`.
- Verified locally: upper-level generated/prefixed Minna lesson titles fall back to Shin Kanzen curriculum titles.
- Verified locally: the Home/Review next-lesson action maps level-scoped storage IDs such as `200001` back to Shin Kanzen source lesson titles.
- Still unverified: live deployed proof on `https://jpstudy.web.app` after deploy/cache-clear.
- Still pending: Track B `vi-source-verified` content verification loop. No `vi-human-approved` tags added.

## 2026-05-17 Continued

- Verified + pushed: `624ac24c fix(vocab): wire Shin Kanzen catalog tracks`.
- Verified locally: `flutter analyze lib test`, `python tooling/audit_ui_string_literals.py --check`, `flutter test test/data/content_review_taxonomy_integrity_test.dart`, and full `flutter test` passed with 2298 tests.
- Deployed: Firebase Hosting `jpstudy` from `624ac24c`.
- Verified live after deploy: `/#/vocab/shinkanzen?level=N3` shows 25 lessons / 404 terms and non-zero rows; N2 shows 25 lessons / 1797 terms; N1 shows 25 lessons / 3476 terms.
- Added pending backlog: roadmap honesty gate (P0), grammar practice gate (P1), quiz answer-selection redesign (P1).
- Still pending: Track A roadmap honesty gate next; Track B `vi-source-verified` loop not started in this continuation.
