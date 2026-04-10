# UI/UX Progress Log

Track each design iteration so everyone can review the process, not just the final screen.

## How to use

1. Add one entry per iteration.
2. Attach screenshot names (before/after).
3. Keep notes short and measurable.

---

## Iteration 001 - Design Lab Setup (2026-02-03)

- Goal: Create a visible workflow for UI/UX design progress.
- Scope:
  - Add in-app design playground route: `/design-lab`.
  - Add quick access from Settings -> Design Lab.
  - Add documentation templates for progress + review checklist.
- Output:
  - `lib/features/design_lab/design_lab_screen.dart`
  - `docs/uiux-progress.md`
  - `docs/uiux-review-checklist.md`
- Next:
  - Move one real screen (recommended: Practice Hub) through Discover -> Visual -> Validate stages.

## Iteration 002 - Learning Path Desktop Variant (2026-02-03)

- Goal: Keep the new reference-inspired visual style while making desktop layout intentional.
- Scope:
  - Add responsive split layout for desktop (map column + action column).
  - Scale node panel sizes/spacing for larger screens.
  - Keep all original navigation and actions unchanged.
- Output:
  - `lib/features/home/screens/learning_path_screen.dart`
  - `lib/features/home/widgets/unit_map_widget.dart`
  - `lib/features/home/widgets/continue_button.dart`
- Verification:
  - `flutter analyze`
  - `flutter test`

## Iteration 003 - Clean Product UI Pass (2026-02-03)

- Goal: Reduce visual noise and improve hierarchy after feedback ("still ugly").
- Scope:
  - Keep all existing functionality/routes, but switch from heavy glow style to a cleaner card-based look.
  - Refine both desktop and mobile presentation in Learning Path screen.
  - Improve readability of lesson labels and CTA actions.
- Output:
  - `lib/features/home/home_screen.dart`
  - `lib/features/home/screens/learning_path_screen.dart`
  - `lib/features/home/widgets/mini_dashboard.dart`
  - `lib/features/home/widgets/unit_map_widget.dart`
  - `lib/features/home/widgets/lesson_node_widget.dart`
  - `lib/features/home/widgets/path_painter.dart`
  - `lib/features/home/widgets/continue_button.dart`
- Verification:
  - `flutter analyze`
  - `flutter test`

## Iteration 004 - Youth UI Production Refresh (2026-02-03)

- Goal: Ship production-ready visual refresh for key daily-use flows (Home + Practice Hub + Immersion).
- Scope:
  - Rework Home header/dashboard/action hierarchy for better scanability and one-primary-action flow.
  - Upgrade Learning Path shell and Practice Hub cards with cleaner spacing, stronger card rhythm, and responsive grids.
  - Redesign Immersion list + reader for easier long-form reading (clear controls for read state, furigana, auto-scroll).
- Output:
  - `lib/features/home/home_screen.dart`
  - `lib/features/home/screens/learning_path_screen.dart`
  - `lib/features/home/widgets/header_bar.dart`
  - `lib/features/home/widgets/mini_dashboard.dart`
  - `lib/features/home/widgets/continue_button.dart`
  - `lib/features/home/widgets/practice_hub.dart`
  - `lib/features/immersion/immersion_home_screen.dart`
  - `lib/features/immersion/screens/immersion_reader_screen.dart`
- Verification:
  - `flutter analyze`
  - `flutter test`

## Iteration 005 - Grammar Hub Refresh (2026-03-20)

- Goal: Turn Grammar into a clearer daily-use hub instead of a plain list + banner screen.
- Scope:
  - Add a responsive hero with deck metrics, due review visibility, and weak-spot status.
  - Replace the old banner/FAB flow with stronger review cards while preserving existing practice routes.
  - Restyle the grammar point list into a more readable bank of tappable study rows.
- Output:
  - `lib/features/grammar/grammar_screen.dart`
  - `docs/uiux-progress.md`
- Notes:
  - Implemented directly in Flutter because the live Pencil desktop bridge was unavailable during this pass.
- Verification:
  - `dart format lib/features/grammar/grammar_screen.dart`
  - `flutter test test/features/ui/ghost_review_walkthrough_test.dart`

## Iteration 006 - Kanji Reading Hub Refresh (2026-03-23)

- Goal: Bring Kanji Reading hub up to the same design language as Grammar and Vocab screens.
- Scope:
  - Replace FutureBuilder + raw Navigator with Riverpod providers + design system widgets.
  - Add `kanjiByLevelProvider` and `kanjiReadingDueItemsProvider` to eliminate inline async logic.
  - Render hero card with due-count badge, primary Start Quiz action, and conditional Review Due action.
  - Add compact kanji list preview (up to 8 items) below the hero.
  - Add `kanjiAllCaughtUpLabel` localization (EN/VI/JA).
  - Fix unrelated bug: Vocab screen secondary toggle button was a no-op (`() {}`).
- Output:
  - `lib/features/kanji_reading/screens/home_kanji_reading_screen.dart`
  - `lib/features/kanji_reading/providers/kanji_reading_providers.dart`
  - `lib/core/app_language.dart`
  - `lib/features/vocab/vocab_screen.dart` (bug fix)
- Verification:
  - `flutter analyze lib/features/kanji_reading/ lib/core/app_language.dart`
  - `flutter test`

## Iteration 007 - Recall Sprint — real vocab data (2026-03-23)

- Goal: Replace hardcoded questions (食べる/飲む) with live data from the SRS review queue.
- Scope:
  - Add `recallSprintQuestionsProvider` (FutureProvider) that picks up to 5 due terms and builds 4-choice MCQs.
  - Export `SprintQuestion` model for test overriding.
  - Fix bug: progress label said "of 5" when `_totalQuestions = 2`.
  - Refactor body into `_SprintBody` stateless widget; remove 110 blank lines.
  - Adopt `AppSectionCard`/`AppPageShell`/`AppThemePalette` for consistent styling.
  - Update `simple_command_center_test.dart`: add `_sprintOverride()` fixture helper; fix assertion strings.
- Output:
  - `lib/features/practice/screens/recall_sprint_screen.dart`
  - `test/features/ui/simple_command_center_test.dart`
  - `docs/uiux-progress.md`
- Verification:
  - `flutter analyze lib/features/practice/`
  - `flutter test` → 206/206 pass

## Iteration 008 - Study Hub Screen (2026-03-24)

- Goal: Build StudyHubScreen to surface the existing study_hub provider data that had no UI.
- Scope:
  - Create `lib/features/study_hub/study_hub_screen.dart`.
  - JLPT Prep hero card linking to `/jlpt/coach`.
  - Textbook Tracker with lesson +/- stepper persisted via `StudyHubNotifier`.
  - Resource Library showing top 8 filterable study guides with topic icons.
  - Exam Checklist with 5-item toggle list persisted via `StudyHubNotifier`.
  - Add `/study-hub` route in `app_router.dart`.
  - Add "Study Hub" panel entry point in `PracticeScreen`.
- Output:
  - `lib/features/study_hub/study_hub_screen.dart`
  - `lib/app/navigation/app_router.dart`
  - `lib/features/practice/practice_screen.dart`
- Verification:
  - `flutter analyze lib/features/study_hub/ lib/app/navigation/app_router.dart lib/features/practice/practice_screen.dart`
  - `flutter test` → 240/240 pass

## Iteration 009 - Study Hub Expansion (2026-03-24)

- Goal: Turn the first Study Hub release into a more actionable planning surface by exposing the rest of the persisted provider state.
- Scope:
  - Add Q&A thread cards with expand/collapse, upvote, answer, and solved-state actions wired to `StudyHubNotifier`.
  - Add filter chips for resource level, topic, and labels plus a clear-filters action.
  - Add Onboarding Roadmap checklist wired to `toggleOnboardingStep()`.
  - Add Target Exam Date card wired to `setExamDate()` / clear.
- Output:
  - `lib/features/study_hub/study_hub_screen.dart`
  - `docs/uiux-progress.md`
- Verification:
  - `flutter analyze lib/features/study_hub/study_hub_screen.dart`
  - `flutter test` → 255/255 pass

## Iteration 010 - Shared Shell + Me/Data UI Sync (2026-04-10)

- Goal: Bring shared shell controls and Me/Data utility surfaces back onto Design System V2 tokens.
- Scope:
  - Replace hardcoded top-bar colors with `AppThemePalette` gradients, outlines, and radius tokens.
  - Localize top-bar profile/menu copy through `AppLanguage` instead of Material locale.
  - Restyle Me/Data Settings section cards and action rows through shared `AppSectionCard`, `AppSectionHeader`, and compact row patterns.
  - Align Personal Bests and Challenge History cards with semantic palette colors.
  - Fix corrupted Me screen Vietnamese/Japanese helper copy.
- Output:
  - `lib/features/common/widgets/global_top_bar.dart`
  - `lib/features/me/me_screen.dart`
  - `lib/features/me/screens/data_settings_screen.dart`
  - `lib/features/me/widgets/personal_bests_card.dart`
  - `lib/features/me/widgets/challenge_history_card.dart`
- Verification:
  - `flutter analyze lib/features/common/widgets/global_top_bar.dart lib/features/me/me_screen.dart lib/features/me/screens/data_settings_screen.dart lib/features/me/widgets/personal_bests_card.dart lib/features/me/widgets/challenge_history_card.dart`
  - `flutter test test/features/common/global_top_bar_test.dart test/features/me/me_screen_test.dart test/features/me/data_settings_screen_test.dart test/features/me/personal_best_test.dart` → 23/23 pass

## Iteration 011 - Vocab UI Token Sync (2026-04-10)

- Goal: Tighten the Vocab catalog surfaces against Design System V2 without changing catalog data or navigation behavior.
- Scope:
  - Replace stray preview separators (`?`) with readable ASCII separators.
  - Move JLPT section accent colors onto the app semantic palette.
  - Restyle Today metrics, hero metric panels, core cards, companion footers, and preview cards to use palette surfaces, outlines, radius tokens, and contrast-aware foreground colors.
  - Blend section accents against the active theme to reduce overly bright level colors.
- Output:
  - `lib/features/vocab/vocab_screen.dart`
  - `lib/features/vocab/vocab_screen_parts.dart`
- Verification:
  - `flutter analyze lib/features/vocab/vocab_screen.dart lib/features/vocab/vocab_screen_parts.dart`
  - `flutter test -r expanded test/features/vocab/vocab_screen_test.dart` → 14/14 pass
  - `flutter test test/features/vocab/vocab_copy_test.dart` → 2/2 pass
- Notes:
  - `flutter test test/features/vocab/vocab_home_provider_test.dart` currently times out during test load without assertion output; this appears separate from the Vocab UI patch because the widget catalog test and copy test pass.

## Iteration 012 - JLPT Prep + Immersion UI Token Sync (2026-04-10)

- Goal: Continue the Design System V2 sync across JLPT Prep and Immersion without changing study behavior.
- Scope:
  - Convert JLPT Prep panels, plan cards, readiness bars, chips, and empty states to shared palette surfaces and radius tokens.
  - Blend Immersion JLPT level accents against the active theme to reduce overly bright card colors.
  - Replace Immersion hardcoded white/gray/blue/yellow/red surfaces with `AppThemePalette` semantic colors.
  - Move Immersion cards, chips, quiz states, reading speed panels, token chips, and queue panels onto `AppSpacing` radius/padding tokens.
- Output:
  - `lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - `lib/features/immersion/immersion_home_screen.dart`
  - `lib/features/immersion/screens/immersion_reader_screen.dart`
- Verification:
  - `flutter analyze lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - `flutter test -r expanded test/features/jlpt/jlpt_coach_screen_test.dart` -> 3/3 pass
  - `flutter analyze lib/features/immersion/immersion_home_screen.dart lib/features/immersion/screens/immersion_reader_screen.dart`
  - `flutter test -r expanded test/features/immersion/immersion_home_screen_test.dart test/features/ui/immersion_walkthrough_test.dart` -> 4/4 pass

## Iteration 013 - Kanji Reading Quiz UI Token Sync (2026-04-10)

- Goal: Bring the Kanji Reading quiz session onto the same Design System V2 surface language as the refreshed Kanji hub.
- Scope:
  - Replace quiz summary score colors with semantic `AppThemePalette` success/warning/error tones.
  - Move prompt card, option states, empty state, and rating buttons to palette surfaces and `AppSpacing` radius/spacing tokens.
  - Add the shared Japanese background to the quiz body while preserving existing quiz labels and flow.
- Output:
  - `lib/features/kanji_reading/screens/kanji_reading_quiz_screen.dart`
- Verification:
  - `flutter analyze lib/features/kanji_reading/screens/kanji_reading_quiz_screen.dart`
  - `flutter test -r expanded test/features/kanji_reading/kanji_reading_quiz_screen_test.dart test/features/kanji_reading/home_kanji_reading_screen_test.dart` -> 8/8 pass

## Iteration 014 - Practice Hub Card Token Sync (2026-04-10)

- Goal: Tighten the Practice hub cards and session plan surfaces against Design System V2 without changing action ranking or navigation.
- Scope:
  - Blend practice action accent colors against the active theme to reduce overly saturated card accents.
  - Move session primary card, follow-up tiles, signal tiles, and spotlight tool cards onto palette surfaces, outlines, and radius tokens.
  - Tokenize key hero radius/inner badge surfaces while keeping the dark hero contrast model intact.
  - Update non-hero mix rows to use palette outlines/surfaces instead of Home-specific hardcoded white/gray colors.
- Output:
  - `lib/features/practice/practice_screen.dart`
- Verification:
  - `flutter analyze lib/features/practice/practice_screen.dart`
  - `flutter test -r expanded test/features/practice/practice_screen_test.dart test/features/home/practice_destination_test.dart test/features/home/models/practice_destination_test.dart` -> 42/42 pass

## Iteration 015 - Recall Sprint Option State Token Sync (2026-04-10)

- Goal: Finish the remaining small hardcoded option state in Recall Sprint.
- Scope:
  - Replace `Colors.green` answer state with `AppThemePalette.success`.
  - Move option button radius and small feedback gaps to `AppSpacing` tokens.
- Output:
  - `lib/features/practice/screens/recall_sprint_screen.dart`
- Verification:
  - `flutter analyze lib/features/practice/screens/recall_sprint_screen.dart`
  - `flutter test -r expanded test/features/practice/recall_sprint_screen_test.dart` -> 11/11 pass
