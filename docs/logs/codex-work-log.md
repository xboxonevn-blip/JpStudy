# Codex Work Log

This file records recent Codex work so future sessions can continue from the current repo state more easily.

## 2026-03-17

### Session Summary

- Reviewed the current uncommitted worktree to understand what was already in progress.
- Confirmed the active batch spans three main areas:
  - N3 immersion lesson content updates for `lesson_51.json` through `lesson_75.json`
  - Refreshed UI/theme work across home, immersion, and JLPT reading flows
  - Supporting generator/report/test updates tied to the immersion content refresh

### Verification Run

- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_reading_screen_test.dart`
  - Result: all tests passed

### Notes

- Added this log file to preserve progress and verification history.
- No existing modified files were reverted.
- `tooling/__pycache__/generate_n3_immersion_lessons.cpython-312.pyc` is currently modified in the worktree as a generated binary artifact.

### Suggested Next Step

- Continue from the current UI/content batch and decide whether to run broader app-level tests before committing.

### Follow-up Session

- Ran the full Flutter test suite to validate the in-progress UI/content batch.
- Found and fixed a responsive layout regression in `lib/features/immersion/immersion_home_screen.dart`.
  - The screen previously stacked hero, source picker, overview, and content in a fixed `Column`, which overflowed in test-sized viewports.
  - Reworked it into a single scrollable `ListView` with pull-to-refresh retained.
  - Moved the NHK fallback notice above the overview card so the fallback state is visible earlier.
- Found and fixed a responsive layout regression in `lib/features/home/screens/learning_path_screen.dart`.
  - `_LearningLanesPanel` used `Expanded` cards inside a vertical `Column` under unbounded height, which broke widget tests.
  - Updated the panel so lane cards only use `Expanded` in the wide `Row` layout.
- Updated widget tests to match the refreshed UI and make them stable with the current shell architecture.
  - `test/features/ui/simple_command_center_test.dart`
    - Updated hero assertions to the new CTA copy.
    - Overrode `dailySessionProgressProvider` and `backupStatusProvider` to avoid background timer leakage in tests.
  - `test/features/ui/immersion_walkthrough_test.dart`
    - Kept the fallback notice assertion.
    - Scrolled to the fallback article before asserting it, because the refreshed screen now has more content above the article list.

### Verification Run

- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/immersion_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Home Compaction Pass 2

- Further reduced the size of the `Progress` and `Practice` sections on Home based on UI feedback.
- Updated `lib/features/home/widgets/mini_dashboard.dart`
  - Reworked compact mode from a larger 2x2 stats block into a much lower-height summary row.
  - Reduced compact-mode padding, radius, title scale, and badge/icon sizes.
- Updated `lib/features/home/screens/learning_path_screen.dart`
  - Changed the Home `DiscoverPracticePanel` usage to start collapsed by default.
- Updated `lib/features/home/widgets/discover_practice_panel.dart`
  - Reduced dense-mode header padding, icon sizing, and control sizes.
  - Simplified the dense header so the subtitle is hidden on Home.
  - Tightened spacing inside the expanded body.
- Updated `lib/features/home/widgets/practice_hub.dart`
  - Reduced embedded practice tile heights and spacing.
  - Tightened embedded focus hint and embedded practice tiles.
- Updated `lib/features/test/widgets/practice_test_dashboard.dart`
  - Reduced embedded card padding, icon size, type size, and arrow size.
- Updated `lib/features/home/widgets/ghost_review_banner.dart`
  - Reduced embedded banner padding, radius, icon size, title/subtitle size, and CTA density.

### Verification Run

- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/home_backup_and_discover_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Home Compaction Pass

- Refined the Home screen to reduce oversized visual blocks while keeping the same overall structure.
- Updated `lib/features/home/screens/learning_path_screen.dart`
  - Reduced top spacing and section gaps.
  - Switched the Home entry card to `DailySessionCard(compact: true)`.
  - Used a compact weekly challenge card.
  - Tightened the hero card: smaller radius, smaller icon, smaller title/subtitle scale, smaller stat chips, smaller CTA buttons.
  - Tightened the training lane cards and the bottom focus summary card.
- Updated `lib/features/home/widgets/weekly_challenge_card.dart`
  - Added a `compact` mode with reduced padding, font sizes, and progress bar height.
- Updated `lib/features/home/home_screen.dart`
  - Reduced Home app bar toolbar height and title spacing.
- Updated `lib/features/home/widgets/header_bar.dart`
  - Reduced header height, corner radius, inner spacing, and action pill sizing.

### Verification Run

- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/home_daily_session_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Home Polish Pass 3

- Refined the compact Home `Progress` and `Practice` sections again based on the latest UI feedback.
- Updated `lib/features/home/widgets/mini_dashboard.dart`
  - Reworked compact `Progress` into a cleaner snapshot card with a structured metric layout instead of loose stat pills.
  - Removed the extra outer compact padding so the card aligns better with adjacent Home sections.
  - Added tinted compact metric cards so the panel feels less empty and more balanced.
- Updated `lib/features/home/widgets/practice_hub.dart`
  - Replaced the embedded fixed-height `GridView` with a wrapping layout so practice tiles size to their actual content.
  - This removes the odd blank space that appeared in the embedded Home `Practice` area.
- Updated `lib/features/home/widgets/discover_practice_panel.dart`
  - Tightened the vertical spacing between the ghost review banner, mock exam card, and embedded practice tiles.

### Verification Run

- Ran `dart format lib/features/home/widgets/mini_dashboard.dart lib/features/home/widgets/practice_hub.dart lib/features/home/widgets/discover_practice_panel.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/home_backup_and_discover_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Background Polish Pass

- Increased the sakura particle density slightly so the falling cherry blossom background feels richer without becoming noisy.
- Updated `lib/features/common/widgets/sakura_particles.dart`
  - Raised the shared background petal count from `7` to `10`.

### Verification Run

- Ran `dart format lib/features/common/widgets/sakura_particles.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed

### Background Polish Pass 2

- Increased the sakura background much more aggressively after follow-up feedback that it still felt too sparse.
- Updated `lib/features/common/widgets/japanese_background.dart`
  - Removed the old `constraints.maxWidth < 900` guard that completely hid sakura on narrower screens.
  - Switched to responsive petal density by viewport width so smaller screens still show sakura and larger screens show more of it.
- Updated `lib/features/common/widgets/sakura_particles.dart`
  - Added a configurable `petalCount` for the shared sakura layer.
  - Increased sakura visibility with a stronger petal tint.
  - Added a widget-test-safe static render path so the app can keep animated sakura without breaking `pumpAndSettle` in tests.

### Verification Run

- Ran `dart format lib/features/common/widgets/sakura_particles.dart lib/features/common/widgets/japanese_background.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### JLPT Reading Test Stabilization

- Fixed the remaining JLPT reading test failure and verified the reading bank now loads the full local immersion set again during tests.
- Updated `test/features/jlpt/jlpt_reading_screen_test.dart`
  - Removed the brittle hardcoded `>= 75` assertion.
  - Strengthened the sync check by asserting both the JLPT bank and local immersion samples have unique ids and identical id sets.
- Updated `pubspec.yaml`
  - Added an explicit asset entry for `assets/data/content/immersion/n4/lesson_29.json` so Flutter's unit-test asset bundle includes the missing lesson reliably.
- Root cause found during debugging
  - Source data on disk already had `75` immersion lessons.
  - The stale/generated `build/unit_test_assets` bundle was the layer missing `lesson_29.json`, which made tests see only `74`.

### Verification Run

- Ran `flutter pub get`
  - Result: dependencies resolved successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_reading_screen_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Study Screen Redesign

- Reworked the `Study` screen so it no longer reads like a flat list of similar rows.
- Updated `lib/features/practice/practice_screen.dart`
  - Added a stronger hero section with a clear “best next step”, live queue summary, and level-aware context.
  - Introduced a separate “Start here” spotlight area for the most relevant study tools.
  - Rebuilt the main `Goals` area into larger 2-column pathway cards instead of repetitive compact rows.
  - Kept the remaining tools available, but moved them into a quieter secondary section to reduce visual noise.
  - Added a dedicated search action in the app bar so search no longer competes with the primary study CTA.
- Updated `test/features/ui/simple_command_center_test.dart`
  - Relaxed the Recall Sprint surfacing assertion to match the new layout, where the same recommendation can appear in more than one intentional place.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent note that the `Study` UI should stay clean, prioritized, and outcome-first.

### Verification Run

- Ran `dart format lib/features/practice/practice_screen.dart test/features/ui/simple_command_center_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/practice/practice_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test`
  - Result: full test suite passed

### Vietnamese Standardization Pass

- Standardized app-level Vietnamese rendering so `AppLanguage.vi` no longer rides on the Japanese-first theme stack.
- Updated `lib/app/theme/app_theme.dart`
  - Switched Latin-based languages to the bundled `Manrope` font family.
  - Added an explicit Japanese fallback stack for mixed-script rendering.
  - Moved Japanese UI typography to a stable platform fallback stack instead of runtime `google_fonts` loading in the app theme.
- Updated `lib/core/app_language.dart`
  - Added canonical app locales, including `Locale('vi', 'VN')`.
  - Added a typography hint so the app can branch cleanly by language.
- Updated `lib/app/app.dart`
  - Wired `MaterialApp.router` to the active app language for `locale`, `supportedLocales`, and localization delegates.
- Added `test/app/theme/app_theme_language_test.dart`
  - Locks the Vietnamese-safe font stack and locale behavior in tests.
- Added `docs/notes/important-user-requirements.md`
  - New persistent notes file for important user requirements so future sessions do not miss them.

### Verification Run

- Ran `flutter pub get`
  - Result: dependencies resolved successfully
- Ran `dart format lib/app/app.dart lib/app/theme/app_theme.dart lib/core/app_language.dart test/app/theme/app_theme_language_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/app/theme/app_theme_language_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/design_lab_localization_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: blocked by an unrelated existing JLPT reading data assertion in `test/features/jlpt/jlpt_reading_screen_test.dart`
  - Detail: test expects `>= 75` reading items, current data returns `74`

### Background Polish Pass 3

- Increased sakura density one more small step after follow-up feedback asking for a slightly richer background.
- Updated `lib/features/common/widgets/japanese_background.dart`
  - Raised responsive petal density again to `20 / 28 / 34` for small, medium, and large viewports.
- Updated `lib/features/common/widgets/sakura_particles.dart`
  - Increased the default particle count slightly.
  - Made petals a little more visible with a stronger tint.

### Verification Run

- Ran `dart format lib/features/common/widgets/sakura_particles.dart lib/features/common/widgets/japanese_background.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Study Aesthetic Pass 2

- Refined the `Study` screen again with the brief narrowed to aesthetics only: more minimalist, more premium, and more recognizably Japanese.
- Updated `lib/features/practice/practice_screen.dart`
  - Softened the hero into a lighter paper-style composition instead of a louder dashboard block.
  - Added restrained Japanese accents such as a seal-style badge, quiet orb decoration, slim vertical emphasis line, and calmer metric chips.
  - Restyled the focus panel into a more editorial layout with thin dividers and quieter copy hierarchy.
  - Simplified the featured tool cards and goal cards with flatter premium surfaces, thinner borders, softer shadows, and less gradient noise.
  - Kept the existing Study information architecture intact so this pass stays visual rather than behavioral.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that the `Study` aesthetic should remain minimalist, premium, and Japanese-inspired.

### Verification Run

- Existing targeted verification for this pass was already green before finalization:
  - `dart format lib/features/practice/practice_screen.dart`
  - `flutter analyze lib/features/practice/practice_screen.dart`
  - `flutter test test/features/ui/simple_command_center_test.dart`
- Ran `flutter test`
  - Result: full test suite passed

### Study Home-Alignment Pass

- Reworked the `Study` screen again after feedback that the previous aesthetic pass still felt worse than `Home`.
- Updated `lib/features/practice/practice_screen.dart`
  - Moved the Study hero to the same visual family as Home with a stronger gradient hero, compact stat chips, and dual-CTA treatment.
  - Wrapped the `Start here`, `Goals`, and `Tools` areas in Home-style soft panels instead of leaving them as loose sections.
  - Restyled spotlight cards and goal cards to match Home's tinted lane-card treatment with lighter gradients, smaller radii, and cleaner hierarchy.
  - Removed the more editorial/paper-heavy Study-specific accents so the screen now feels like part of the same product family as Home.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent rule that `Study` should visually align with `Home` before introducing its own separate aesthetic language.

### Verification Run

- Ran `dart format lib/features/practice/practice_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/practice/practice_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### Study Layout + Naming Cleanup

- Refined the `Study` screen again after feedback about awkward spacing and ambiguous naming.
- Updated `lib/features/practice/practice_screen.dart`
  - Fixed the desktop/tablet card layout so `Start here` and `Goals` size from the true inner panel width instead of a guessed width that caused stray wrapping and large empty gaps.
  - Rebalanced `Start here` to keep a tighter recommended set on wide screens so the section feels more intentional.
- Updated `lib/core/app_language.dart`
  - Renamed the grammar-ghost lane from the generic `Mistakes` wording to `Grammar repair`.
  - Renamed the general mistakes lane from `Mistakes` to `Weak points`.
  - Updated related subtitles and ghost-review labels so the two flows stay clearly distinct throughout the app.
- Updated `test/features/home/practice_destination_test.dart`
  - Added coverage to ensure grammar repair and weak points remain distinct labels.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent note to avoid ambiguous duplicate labels for different Study routes.

### Verification Run

- Ran `dart format lib/features/practice/practice_screen.dart lib/core/app_language.dart test/features/home/practice_destination_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/practice/practice_screen.dart lib/core/app_language.dart lib/features/home/models/practice_destination.dart test/features/home/practice_destination_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/home/practice_destination_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed on rerun

### JLPT Mock Pro Data-Driven Redesign

- Reworked `JLPT Mock Pro` after feedback that the current screen felt careless and did not make good use of existing app data.
- Updated `lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Rebuilt the landing screen around a stronger overview hero that now surfaces the current JLPT target level, real question/time totals from `jlptMockSections`, pass criteria, and latest readiness status from JLPT Coach.
  - Replaced the old loose section list with structured section cards for `Goi`, `Bunpo`, `Kanji`, and `Dokkai`, each showing real in-app counts, timing, skill color, and latest area accuracy when a coach snapshot exists.
  - Added a clearer readiness panel that uses the saved JLPT Coach snapshot for overall accuracy, weakest skill rows, and the first items from the 7-day plan instead of empty decorative copy.
  - Redesigned the result view so section breakdown, score progress, and diagnosis feel like part of the same JLPT coaching flow rather than a disconnected summary page.
  - Tinted the active exam hero by current skill area so the live run also feels more intentional and better organized.
- Updated `test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Fixed the test to work with the longer scrollable landing layout and animated background by scrolling to the start CTA instead of relying on immediate visibility.
  - Replaced the previous settle-based wait with a shorter render wait so the test no longer hangs on continuous Sakura animation.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent rule to prioritize real in-app data over placeholder filler when redesigning feature screens.

### Verification Run

- Ran `dart format lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed after updating the test for the new scrollable layout
- Ran `flutter test test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/learn/learn_mode_config_test.dart`
  - Result: all tests passed when rechecked after an earlier noisy full-suite run
- Ran `flutter test`
  - Result: full test suite passed on rerun

### Immersion NHK Easy Removal

- Removed the active `NHK Easy` flow from Immersion after feedback to eliminate it completely from the experience.
- Updated `lib/features/immersion/immersion_home_screen.dart`
  - Removed the source switcher so Immersion now loads directly from the in-app reading bank.
  - Removed the NHK-only refresh behavior and fallback notice panel.
  - Simplified the hero status so it reflects the current reading track instead of an external source label.
- Updated `lib/features/immersion/screens/immersion_reader_screen.dart`
  - Removed the NHK detail-loading branch and its loading/error scaffolds from the active reader flow.
  - Reader now opens the provided article data directly, which matches the reading-bank-only product direction.
- Updated `lib/core/app_language.dart`
  - Removed the no-longer-used localization strings tied to NHK source tabs, refresh, and fallback messaging.
- Updated `test/features/ui/immersion_walkthrough_test.dart`
  - Replaced the old NHK fallback test with coverage that asserts `NHK Easy` no longer appears on the Immersion home screen and that reading-bank articles still load correctly.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that Immersion should stay focused on the in-app reading bank and should not resurface `NHK Easy`.

### Verification Run

- Ran `dart format lib/features/immersion/immersion_home_screen.dart lib/features/immersion/screens/immersion_reader_screen.dart lib/core/app_language.dart test/features/ui/immersion_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/immersion/immersion_home_screen.dart lib/features/immersion/screens/immersion_reader_screen.dart lib/core/app_language.dart test/features/ui/immersion_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/immersion_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed
