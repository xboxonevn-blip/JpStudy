# Phase 3 FSRS + Ghost 2.0

## Overview
Replace SM-2 with FSRS scheduling (migrate existing SRS data) and upgrade Ghost Reviews to auto-capture mistakes with contextual snapshots across learning flows, including full Kanji/Handwriting FSRS.

## Project Type
MOBILE (Flutter)

## Success Criteria
- FSRS fully replaces SM-2 for vocab + grammar + kanji scheduling and reviews.
- Existing SM-2 data is migrated into FSRS fields without wiping user history.
- Ghosts auto-capture from learn/review/test/grammar/handwriting flows with saved context.
- Ghost UI surfaces last mistake context in Mistake/Ghost flows (including Kanji).
- App builds on Android (`flutter build apk --debug`); iOS noted as pending.

## Tech Stack
- Flutter + Riverpod + Drift (existing app stack)
- Local SQLite migration via Drift migrator

## File Structure
- lib/core/services/fsrs_service.dart (new) or update lib/core/services/srs_service.dart
- lib/data/db/tables.dart
- lib/data/db/grammar_tables.dart
- lib/data/db/mistake_tables.dart
- lib/data/db/kanji_tables.dart (new if separated)
- lib/data/db/app_database.dart
- lib/data/daos/srs_dao.dart
- lib/data/daos/grammar_dao.dart
- lib/data/daos/kanji_srs_dao.dart (new)
- lib/data/daos/mistake_dao.dart
- lib/features/mistakes/repositories/mistake_repository.dart
- lib/features/learn/providers/learn_session_provider.dart
- lib/features/vocab/screens/term_review_screen.dart
- lib/features/lesson/lesson_detail_screen.dart
- lib/features/grammar/screens/grammar_practice_screen.dart
- lib/features/test/screens/test_screen.dart
- lib/features/write/screens/handwriting_practice_screen.dart
- lib/features/mistakes/screens/mistake_screen.dart
- lib/core/app_language.dart
- ROADMAP.md

## Task Breakdown
- task_id: T1
  name: FSRS state + migration
  agent: mobile-developer
  skills: clean-code, mobile-design
  priority: P0
  dependencies: []
  INPUT->OUTPUT->VERIFY: Update SRS/Grammar/Kanji tables + migration to add FSRS fields and map existing SM-2 state -> FSRS; verify schemaVersion bump and migration runs on upgrade.

- task_id: T2
  name: FSRS scheduling service + DAO updates
  agent: mobile-developer
  skills: clean-code
  priority: P0
  dependencies: [T1]
  INPUT->OUTPUT->VERIFY: Implement FSRS review logic and retrievability calculation; update DAOs/repositories to use FSRS fields; verify nextReviewAt updates and no SM-2 usage remains in reviews.

- task_id: T3
  name: Ghost context storage
  agent: mobile-developer
  skills: clean-code
  priority: P1
  dependencies: [T1]
  INPUT->OUTPUT->VERIFY: Extend mistake storage to save context (prompt/answer/source/etc.) and update repo/DAO APIs; verify context persists and updates on repeated mistakes for vocab/grammar/kanji.

- task_id: T4
  name: Auto-ghost capture across flows
  agent: mobile-developer
  skills: clean-code
  priority: P1
  dependencies: [T3]
  INPUT->OUTPUT->VERIFY: Add mistake capture w/ context in learn, review, test, grammar practice, handwriting; verify wrong answers create/refresh ghosts and correct answers decrement.

- task_id: T5
  name: Ghost UI context + retrievability display
  agent: mobile-developer
  skills: clean-code, mobile-design, i18n-localization
  priority: P2
  dependencies: [T2, T3]
  INPUT->OUTPUT->VERIFY: Show last mistake context in Mistake/Ghost screens; show retrievability on review UI; verify localized strings in VI/EN/JP.

- task_id: T6
  name: Roadmap + cleanup + verification
  agent: mobile-developer
  skills: clean-code
  priority: P3
  dependencies: [T1, T2, T3, T4, T5]
  INPUT->OUTPUT->VERIFY: Update ROADMAP progress; run format/analyze/build + mobile audit; verify build APK and note iOS pending.

## Phase X: Verification
- Run `flutter analyze`
- Run `flutter build apk --debug`
- Update ROADMAP.md and mark Phase 3 progress
