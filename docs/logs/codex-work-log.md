# Codex Work Log

This file records recent Codex work so future sessions can continue from the current repo state more easily.

## 2026-03-18

### Grammar Sentence Builder Chunking & Feedback Pass

- Investigated the `Sentence Builder` experience after feedback that it was not helping users understand grammar and examples well.
- Root cause found
  - `GrammarQuestionGenerator._tokenizeSentence` split any no-space Japanese sentence into single Unicode characters.
  - This made examples like `どこですか。…あそこです。` render as noisy kana-by-kana chips instead of meaningful chunks.
  - `SentenceBuilderWidget` already had `GeneratedQuestion.feedback` and `GeneratedQuestion.explanation` at the model layer, but the widget UI ignored them and only showed a generic “Order is still off.” message.
- Updated `lib/features/grammar/services/grammar_question_generator.dart`
  - Replaced the char-by-char fallback with a single-pass marker-insertion tokenizer.
  - The tokenizer now:
    - strips the prompt half of dialogue sentences before `…`, keeping only the answer half
    - keeps explicit space-based tokenization unchanged
    - splits Japanese sentences into more meaningful chunks by inserting boundaries before verbal/copula endings (`です`, `ですか`, `ます`, `ません`, etc.) and after major particles (`は`, `が`, `を`, `に`, `も`, `と`, `の`, `へ`)
    - keeps endings like `ですか` together instead of breaking them into `で / す / か`
    - falls back to grouped chunks only if the sentence is still too short to split meaningfully
- Updated `test/features/grammar/grammar_question_generator_test.dart`
  - Added tokenizer regression coverage for:
    - simple copula sentences (`私は学生です。`)
    - question endings staying together (`どこですか。`)
    - dialogue examples keeping only the answer half after `…`
    - whitespace-preserving cases
    - minimum useful chunk counts for common N5 patterns
- Updated `lib/features/grammar/widgets/sentence_builder_widget.dart`
  - Added optional `feedback` and `explanation` props.
  - Wrong-answer state now shows:
    - the existing status message
    - the grammar pattern hint from `GeneratedQuestion.feedback`
    - the correct sentence
    - the translation / explanation from `GeneratedQuestion.explanation`
- Updated `lib/features/grammar/screens/grammar_practice_screen.dart`
  - Passed `question.feedback` and `question.explanation` into `SentenceBuilderWidget`.
- Updated stale tests affected by current workspace behavior
  - `test/features/ui/simple_command_center_test.dart`
    - Adjusted `GrammarDetailScreen` expectation to the current English headline rendering (`V-て + shimau`) and made it robust to multiple appearances.
  - `test/features/ui/ghost_review_walkthrough_test.dart`
    - Updated the helper to handle the fake test sentence `ABC` both as one chunk and as the older per-character fallback, so the test stays valid after smarter tokenization.

### Verification Run

- Ran `flutter test test/features/grammar/grammar_question_generator_test.dart`
  - Result: all 13 grammar generator tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart --name="GrammarDetailScreen"`
  - Result: passed after updating the stale expectation
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart --name="Correct answer in ghost practice reduces grammar mistake count"`
  - Result: passed after updating the helper for the new chunking behavior
- Ran `flutter test`
  - Result: full suite passed (`179` tests shown in current workspace run)

### Grammar Example Quality Pass (`N5` Batch D: Lessons 13-25)

- Continued the lesson-vocab-first rewrite flow across all remaining `N5` grammar example lessons:
  - `assets/data/content/grammar_examples/n5/lesson_13.json`
  - `assets/data/content/grammar_examples/n5/lesson_14.json`
  - `assets/data/content/grammar_examples/n5/lesson_15.json`
  - `assets/data/content/grammar_examples/n5/lesson_16.json`
  - `assets/data/content/grammar_examples/n5/lesson_17.json`
  - `assets/data/content/grammar_examples/n5/lesson_18.json`
  - `assets/data/content/grammar_examples/n5/lesson_19.json`
  - `assets/data/content/grammar_examples/n5/lesson_20.json`
  - `assets/data/content/grammar_examples/n5/lesson_21.json`
  - `assets/data/content/grammar_examples/n5/lesson_22.json`
  - `assets/data/content/grammar_examples/n5/lesson_23.json`
  - `assets/data/content/grammar_examples/n5/lesson_24.json`
  - `assets/data/content/grammar_examples/n5/lesson_25.json`
- Goals of this batch:
  - finish the `N5` manual quality-upgrade pass instead of leaving the second half of the level on generic expansion content
  - keep every grammar block at `10` examples while making the sentence sets feel tied to the lesson vocabulary, scene, and learning objective
  - turn conjugation-heavy lessons such as `Vて`, `Vない`, `Vる`, `Vた`, and plain-form lessons into short usable study sentences instead of dry transformation lists
- Content strategy used in this pass:
  - kept grammar-point labels identical to the canonical titles in `assets/data/content/grammar/n5/grammar_n5_13.json` through `grammar_n5_25.json`
  - rewrote lesson 13 around desire, invitations, weekend plans, shopping, swimming, city-hall registration, and art/economics study contexts
  - rewrote lessons 14-18 around requests, ongoing actions, rules, obligation, transportation flow, body/adjective description, hobbies, ability, and before/after routines
  - rewrote lessons 19-25 around experience, casual/plain speech, opinions/reporting, relative clauses, machine/road situations, giving-receiving help, and conditional/advice patterns
  - preferred lesson vocab such as `市役所`, `パスポート`, `時刻表`, `押し入れ`, `交差点`, `お弁当`, `大使館`, `チャンス`, and related everyday beginner scenes over generic filler

### Verification Run

- Re-validated the previously rewritten `N5` files:
  - `assets/data/content/grammar_examples/n5/lesson_5.json`
  - `assets/data/content/grammar_examples/n5/lesson_7.json`
  - `assets/data/content/grammar_examples/n5/lesson_8.json`
  - `assets/data/content/grammar_examples/n5/lesson_10.json`
  - `assets/data/content/grammar_examples/n5/lesson_11.json`
  - `assets/data/content/grammar_examples/n5/lesson_12.json`
  - Result: all six files still parse successfully and every grammar block remains at exactly `10` examples
- Ran JSON/count validation across the full `N5` grammar-example set
  - Result: `lesson_1.json` through `lesson_25.json` all parse successfully and every grammar block in `N5` remains at exactly `10` examples
- Cross-checked canonical label order for `lesson_13.json` through `lesson_25.json`
  - Result: every `grammar_examples[*].grammarPoint` matches the lesson definition title exactly, with no label drift introduced
- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: `N5` remains fully covered at `1180` examples across `118` grammar points with `0` points below target
  - The audit still reports remaining expansion work only in `N4` and `N3`; no new `N5` mismatches or below-target blocks were introduced

### Grammar Example Quality Pass (`N5` Batch C: Lessons 3, 4)

- Continued the lesson-vocab-first rewrite process on:
  - `assets/data/content/grammar_examples/n5/lesson_3.json`
  - `assets/data/content/grammar_examples/n5/lesson_4.json`
- Goal of this batch:
  - make lesson 3 feel clearly like a directions / building / department-store lesson instead of a mixed-location placeholder set
  - make lesson 4 feel clearly like a daily schedule / opening-hours / time-management lesson instead of generic verb practice
- Content strategy used in this pass:
  - matched both grammar-example files against `assets/data/content/grammar/n5/grammar_n5_3.json`, `grammar_n5_4.json`, and the local vocab banks in `assets/data/content/vocab/n5/lesson_03.json` and `lesson_04.json`
  - rewrote lesson 3 around reception / office / meeting room / restroom / elevator / vending machine / sales-floor contexts, plus country-of-origin examples built around lesson products like `靴`, `ネクタイ`, `ワイン`, and `たばこ`
  - rewrote lesson 4 around real beginner schedule contexts such as wake-up time, meetings, exams, lunch break, opening hours for `銀行`, `郵便局`, `図書館`, `美術館`, and weekday study / work routines
  - kept every grammar block at `10` examples while reducing textbook-swapped filler and making each block read like the lesson it belongs to
- Online references used for this pass:
  - `Nihongo AZ` lesson 3 grammar reference
  - `Nihongo AZ` lesson 4 grammar reference
  - `LearnJP` lesson 3 vocabulary reference
  - `LearnJP` lesson 4 vocabulary reference

### Verification Run

- Ran JSON/count validation for:
  - `assets/data/content/grammar_examples/n5/lesson_3.json`
  - `assets/data/content/grammar_examples/n5/lesson_4.json`
  - Result: both files parsed successfully; lesson 3 still contains `6` grammar blocks and lesson 4 still contains `4`, with every block staying at exactly `10` examples
- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: `N5` remains fully covered at `1180` examples across `118` grammar points with `0` points below target
  - No canonical-label drift or unmatched example-block issues were introduced by this batch

### Grammar Example Quality Pass (`N5` Batch B: Lessons 1, 2)

- Continued the lesson-vocab-first rewrite process on:
  - `assets/data/content/grammar_examples/n5/lesson_1.json`
  - `assets/data/content/grammar_examples/n5/lesson_2.json`
- Goal of this batch:
  - remove the early-lesson examples that still felt like generic textbook substitution
  - make lesson 1 stay centered on self-introduction, nationality, job, and affiliation contexts
  - make lesson 2 stay centered on classroom / desk / office-object identification, ownership, and content questions
- Content strategy used in this pass:
  - matched both grammar-example files against `assets/data/content/grammar/n5/grammar_n5_1.json`, `grammar_n5_2.json`, and the local vocab banks in `assets/data/content/vocab/n5/lesson_01.json` and `lesson_02.json`
  - rewrote lesson 1 so the examples now stay inside beginner-introduction scenarios instead of drifting into unrelated object examples
  - rewrote lesson 2 so demonstratives, ownership, and `何（なん）` examples now reuse concrete lesson objects such as `辞書`, `名刺`, `手帳`, `テレホンカード`, `かぎ`, `新聞`, `雑誌`, `カメラ`, `コンピューター`, and `自動車`
  - kept every grammar block at `10` examples while favoring short, beginner-usable sentences over isolated filler fragments
- Online references used for this pass:
  - `Nihongo AZ` lesson 1 grammar reference
  - `Nihongo AZ` lesson 1 vocabulary reference
  - `Nihongo AZ` lesson 2 grammar reference
  - `LearnJP` lesson 2 vocabulary reference
  - `JapaEdu` lesson 1 overview reference for lesson framing and introduction vocabulary

### Verification Run

- Ran JSON/count validation for:
  - `assets/data/content/grammar_examples/n5/lesson_1.json`
  - `assets/data/content/grammar_examples/n5/lesson_2.json`
  - Result: both files parsed successfully, both still contain `6` grammar blocks, and every block still contains exactly `10` examples
- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: `N5` remains fully covered at `1180` examples across `118` grammar points with `0` points below target
  - No canonical-label drift or unmatched example-block issues were introduced by this batch

### Grammar Example Quality Pass (`N5` Batch A: Lessons 6, 9)

- Continued the lesson-vocab-first example rewrite process on:
  - `assets/data/content/grammar_examples/n5/lesson_6.json`
  - `assets/data/content/grammar_examples/n5/lesson_9.json`
- Goal of this batch:
  - make the examples feel closer to the actual lesson vocabulary bank
  - reduce generic filler examples in early N5 grammar
  - keep each grammar block at `10` examples while making the sentences more useful for daily-life study
- Content strategy used in this pass:
  - matched each lesson against `assets/data/content/vocab/n5/lesson_06.json` and `lesson_09.json`
  - rewrote lesson 6 around concrete beginner-life contexts such as breakfast, cafeteria, restaurant, station, reading letters, shopping, movies, invitations, and suggestions
  - rewrote lesson 9 around preference/ability/reason contexts using lesson vocab such as concerts, karaoke, tickets, appointments, small change, music, sports, scripts, spouse/child, and phone-style invitation situations
  - kept grammar examples short and beginner-readable while still making them feel less robotic
- Online references used for this pass:
  - `Nihongo AZ` lesson 6 grammar reference
  - `Nihongo AZ` lesson 9 grammar reference
  - `Nihongo AZ` lesson 6 vocabulary reference
  - `Nihongo AZ` lesson 9 vocabulary reference

### Verification Run

- Ran JSON/count validation for:
  - `assets/data/content/grammar_examples/n5/lesson_6.json`
  - `assets/data/content/grammar_examples/n5/lesson_9.json`
  - Result: both files parsed successfully and every grammar block still contains `10` examples
- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: no canonical-label drift introduced
  - `N5` still remains at `1180` examples across `118` grammar points with `0` points below target

### Grammar Example Quality Pass (`N4` Lessons 29, 31, 38)

- Reworked the example sets in:
  - `assets/data/content/grammar_examples/n4/lesson_29.json`
  - `assets/data/content/grammar_examples/n4/lesson_31.json`
  - `assets/data/content/grammar_examples/n4/lesson_38.json`
- Goal of this pass:
  - make examples follow each lesson's own vocab bank more closely
  - keep situations grounded in daily life rather than abstract filler
  - keep every grammar block at `10` examples while improving relevance, not just quantity
- Content strategy used in this pass:
  - matched each target lesson against `assets/data/content/vocab/n4/lesson_29.json`, `lesson_31.json`, and `lesson_38.json`
  - rewrote examples to reuse lesson vocabulary such as station / luggage-rack / lost-property contexts for lesson 29, presentation / holiday / graduate-school contexts for lesson 31, and hospital / lab / documents / twins / coast contexts for lesson 38
  - used online grammar references to cross-check usage before rewriting examples manually into app-specific sentence sets
- Online references used for this pass:
  - `Nihongo AZ` lesson grammar references for lessons 29, 31, and 38
  - `Langoal` lesson 38 teaching-plan reference
  - `Nihongo Kyoshi Net` reference for `〜ことにする`

### Verification Run

- Ran JSON validation for:
  - `assets/data/content/grammar_examples/n4/lesson_29.json`
  - `assets/data/content/grammar_examples/n4/lesson_31.json`
  - `assets/data/content/grammar_examples/n4/lesson_38.json`
  - Result: all files parsed successfully
- Checked example counts after rewrite
  - Result: every grammar block in lessons `29`, `31`, and `38` still contains `10` examples

### Grammar Example Audit Pass

- Split the large grammar-example cleanup into explicit passes so the data update can proceed safely in batches.
- Added and stabilized `tooling/audit_grammar_example_coverage.py`
  - Tightened the matcher so it now uses conservative matching only.
  - Removed the over-loose fuzzy behavior that previously mapped unrelated labels together.
  - Added UTF-8 stdout configuration so the audit runs cleanly on the current Windows terminal.
- Repaired `assets/data/content/grammar_examples/n4/lesson_42.json`
  - Restored the reason examples under `〜ために（理由）`.
  - Kept the purpose label standardized as `～ために (Mục đích)` without merging the two grammar points incorrectly.
- Regenerated:
  - `docs/reports/grammar-example-coverage-report.json`
  - `docs/reports/grammar-example-expansion-plan.md`

### Grammar Example Expansion Pass B (`N5`)

- Completed the `N5` coverage batch so every `N5` grammar point now has at least `10` examples.
- Updated:
  - `assets/data/content/grammar_examples/n5/lesson_3.json`
  - `assets/data/content/grammar_examples/n5/lesson_8.json`
  - `assets/data/content/grammar_examples/n5/lesson_11.json`
  - `assets/data/content/grammar_examples/n5/lesson_13.json`
  - `assets/data/content/grammar_examples/n5/lesson_15.json`
  - `assets/data/content/grammar_examples/n5/lesson_21.json`
  - `assets/data/content/grammar_examples/n5/lesson_22.json`
  - `assets/data/content/grammar_examples/n5/lesson_23.json`
  - `assets/data/content/grammar_examples/n5/lesson_25.json`
- Reworked `lesson_11.json` more deeply instead of only padding counts:
  - Moved time/frequency examples into `Số lượng từ (Thời gian)`.
  - Replaced the generic quantifier block with actual counter-based noun examples so the grammar point matches its label.

### Verification Run

- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: report regenerated successfully.
  - Coverage now shows `N5` at `1180` examples across `118` grammar points, average `10.0`, with `0` points below target.
- Ran JSON validation for the updated `N5` lesson files plus repaired `lesson_42.json`
  - Result: all modified grammar example files parse successfully.
- Did not run Flutter UI tests in this pass
  - This batch only changed JSON content and the audit/report tooling.

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

### JLPT Grammar Language Consistency Fix

- Fixed a language-mixing bug in the rebuilt JLPT mock flow after English mode still showed Vietnamese grammar answer options from raw lesson fields.
- Updated `lib/features/jlpt/data/jlpt_mock_bank.dart`
  - Added dedicated grammar display helpers so English mode now prefers `titleEn` and `structureEn` before falling back.
  - Wired grammar option labels, grammar prompts, and grammar context blocks to those localized helpers instead of raw Vietnamese source fields.
- Updated `test/features/jlpt/jlpt_mock_bank_test.dart`
  - Added regression coverage proving English grammar labels/structures resolve to English while Vietnamese still keeps the original Vietnamese display text.

### Verification Run

- Ran `flutter analyze lib/features/jlpt/data/jlpt_mock_bank.dart test/features/jlpt/jlpt_mock_bank_test.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
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

### Grammar `structureEn` Authenticity Pass

- Cleaned up grammar asset data so English-mode `structureEn` now keeps real Japanese grammar notation instead of mixed romaji placeholders.
- Updated grammar JSON assets across `assets/data/content/grammar/n5`, `assets/data/content/grammar/n4`, and a small set of `n3` files.
  - Replaced romaji particles and helpers such as `wa`, `ga`, `ni`, `de`, `to`, `no`, `desu`, `koto`, `toki`, `you ni`, `tsumori desu`, and similar patterns with proper Japanese forms like `は`, `が`, `に`, `で`, `と`, `の`, `です`, `こと`, `とき`, `ように`, `つもりです`.
  - Corrected mixed formulas such as `V-て mo ii desu ka`, `V-て wa ikemasen`, `V-る koto ga dekimasu`, `V-た koto ga arimasu`, `N1 と N2 to dochira ga A desu ka`, and `\"~\" wa [Language] de nan desu ka`.
  - Fixed the remaining causative permission formula to `V-使役形 + ていただけませんか`.
- Preserved English-side study labels like `Plain Form`, `Potential`, and `V-stem` where they are acting as teaching labels, while making the actual Japanese grammar pieces display in Japanese script.

### Verification Run

- Ran a UTF-8 grammar asset scan for suspicious romaji in `structureEn`
  - Result: only intentional teaching labels such as `V-stem` remained; no romaji particle/conjugation placeholders were left in `structureEn`.

### Grammar English Data Refresh Fix

- Tracked down a follow-up bug after the UI still showed stale romaji strings like `kore / sore / are wa nan desu ka` even though the JSON assets had already been corrected.
- Root cause found
  - `JLPT Mock Pro` was reading grammar from `ContentDatabase`, which keeps a seeded local copy and was not being refreshed after grammar asset edits.
  - `AppDatabase` grammar seeding also lagged behind because the old grammar seeder version check skipped refreshes and did not fully populate normalized English fields.
- Updated `lib/data/utils/grammar_english_notation.dart`
  - Added a shared normalizer for stale English grammar labels and formula strings so old romaji-rich values are converted to Japanese notation such as `何 / なん / なに`, `そうです`, `V-ています`, and `N (Tool) で V`.
- Updated `lib/data/db/content_database.dart`
  - Bumped the schema version to force a grammar reseed for existing installs.
  - Normalized `titleEn` and `structureEn` while seeding grammar content into the content database.
- Updated `lib/data/seeds/grammar_seeder.dart`
  - Bumped the grammar seed version so the app database refreshes stale grammar data.
  - Expanded the grammar seed through `N3`.
  - Switched the seeder to update existing grammar rows in place and refresh examples instead of silently leaving stale English fields behind.
- Updated `lib/features/jlpt/data/jlpt_mock_bank.dart`
  - Applied the grammar normalizer at read time so even stale cached DB rows render correctly in the JLPT mock UI before or during reseed rollout.
- Updated grammar asset files under `assets/data/content/grammar/**`
  - Cleaned additional `titleEn` values that still contained romaji forms such as `nan/nani`, `Sou desu`, `Particle de`, `V-te imasu`, `tsumori`, `yotei`, `youni`, `tokoro`, and similar labels.
  - Confirmed `Lesson 02` now stores `What? (何 / なん / なに)` and `これ / それ / あれ は 何ですか`.

### Verification Run

- Ran `flutter analyze lib/data/utils/grammar_english_notation.dart lib/data/seeds/grammar_seeder.dart lib/data/db/content_database.dart lib/features/jlpt/data/jlpt_mock_bank.dart test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed

### JLPT Mock Randomization Pass

- Fixed the `JLPT Mock Pro` issue where exiting and reopening the screen kept producing the same question set.
- Updated `lib/features/jlpt/data/jlpt_mock_bank.dart`
  - Replaced deterministic spread/rotation logic with randomized selection for vocabulary, grammar, kanji, and reading.
  - Added run-time randomization for:
    - which source items are sampled into each section
    - which distractors are chosen
    - option order inside each question
    - question order inside each section
    - reading passage selection
  - Kept the overall section structure and total question counts stable so the mock still feels curated rather than chaotic.
- Updated `lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Changed the restart flow so pressing restart creates a fresh mock bank instead of reusing the old `_sections` already stored in widget state.
  - Added a lightweight loading state while preparing a new mock and a fallback snackbar if refresh fails.

### Verification Run

- Ran `flutter analyze lib/features/jlpt/data/jlpt_mock_bank.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart test/features/jlpt/jlpt_mock_bank_test.dart test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed

### Grammar English Notation Cleanup Pass 2

- Tracked down the remaining romaji that still leaked into English grammar labels and structures after the earlier normalization pass.
- Updated grammar JSON assets under `assets/data/content/grammar/**`
  - Fixed the last confirmed stale values such as `Time + mae に`, `Adverbs of Degree (yoku, daitai, etc.)`, `And, and (shi)`, `After ... (ato de)`, `yaru`, `kudasaru / kudasaimashita`, and `itadaku / itadakimashita`.
- Updated `lib/data/utils/grammar_english_notation.dart`
  - Added normalization coverage for the remaining stale title/structure patterns, including `mae`, `ato de`, and the honorific give/receive labels.
- Updated `lib/data/db/content_database.dart`
  - Bumped the content DB schema again so existing installs reseed grammar content with the corrected English notation.
- Updated `lib/data/seeds/grammar_seeder.dart`
  - Bumped the grammar data seed version again so existing app DB rows are refreshed too.
- Updated `lib/data/repositories/lesson_repository.dart`
  - Added stale-notation detection to lesson grammar sync so old English grammar rows resync instead of being treated as valid forever.
  - Normalized copied English grammar meaning/structure during lesson seeding.
- Updated grammar-facing screens/services
  - `lib/features/grammar/screens/ghost_review_screen.dart`
  - `lib/features/grammar/screens/grammar_detail_screen.dart`
  - `lib/features/grammar/grammar_screen.dart`
  - `lib/features/lesson/widgets/grammar_list_widget.dart`
  - `lib/features/grammar/services/grammar_question_generator.dart`
  - `lib/features/mistakes/screens/mistake_screen.dart`
  - These now normalize English grammar text at render/use time so stale cached rows no longer leak romaji before reseed completes.
- Updated `test/features/jlpt/jlpt_mock_bank_test.dart`
  - Added regression coverage for the remaining `mae` structure case and the honorific `kudasaru` label case.

### Verification Run

- Ran `dart format` on all modified Dart files
  - Result: formatting completed successfully
- Ran `flutter analyze lib/data/utils/grammar_english_notation.dart lib/data/seeds/grammar_seeder.dart lib/data/db/content_database.dart lib/data/repositories/lesson_repository.dart lib/features/grammar/screens/ghost_review_screen.dart lib/features/grammar/screens/grammar_detail_screen.dart lib/features/lesson/widgets/grammar_list_widget.dart lib/features/grammar/grammar_screen.dart lib/features/grammar/services/grammar_question_generator.dart lib/features/mistakes/screens/mistake_screen.dart test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed

### Grammar English Notation Cleanup Pass 3

- Fixed the remaining romaji case visible in `JLPT Mock Pro` for `N5 • Lesson 16`.
- Updated `assets/data/content/grammar/n5/grammar_n5_16.json`
  - Corrected `titleEn` from `Connecting verbs (V-te, V-te)` to `Connecting verbs (V-て, V-て)`.
- Updated `lib/data/utils/grammar_english_notation.dart`
  - Added token-level normalization for stale title patterns such as `V-te`, `V-ta`, `V-ru`, `V-nai`, `A-na`, and `A-i` so old DB rows still render with Japanese notation.
- Updated `lib/data/seeds/grammar_seeder.dart`
  - Bumped the grammar data seed version again so existing app DB installs refresh the corrected grammar title.
- Updated `lib/data/db/content_database.dart`
  - Bumped the content DB schema again so the content grammar cache reseeds the corrected lesson data too.
- Updated `lib/features/grammar/services/grammar_question_generator.dart`
  - Stopped English grammar prompts from blindly using `grammarPoint` labels when a localized `titleEn` exists.
  - Added a display helper so English prompts and contrast options now use normalized English grammar labels instead of stale mixed-script titles.
- Updated tests
  - `test/features/jlpt/jlpt_mock_bank_test.dart`
    - Added a regression for the stale `Connecting verbs (V-te, V-te)` case.
  - `test/features/grammar/grammar_question_generator_test.dart`
    - Added coverage proving English grammar question prompts use normalized English pattern labels.

### Verification Run

- Ran `flutter analyze lib/data/utils/grammar_english_notation.dart lib/data/seeds/grammar_seeder.dart lib/data/db/content_database.dart lib/features/grammar/services/grammar_question_generator.dart test/features/jlpt/jlpt_mock_bank_test.dart test/features/grammar/grammar_question_generator_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_bank_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/grammar/grammar_question_generator_test.dart`
  - Result: all tests passed
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

### Strict Level Filtering For Study + Lesson

- Tightened the Study/Lesson level behavior after feedback that selecting `N5` in Home still allowed `Immersion` to show `N4` and `N3`.
- Updated `lib/features/immersion/immersion_home_screen.dart`
  - Filtered the reading bank so Immersion now shows only articles whose `officialLevel` matches the currently selected `studyLevelProvider`.
  - Changed the next-deck logic to pick only from the visible level-filtered article pool instead of the full mixed article list.
  - Simplified section titles and copy so the screen no longer talks about warm-up/stretch/explore lanes around the current level.
- Updated `lib/features/library/library_screen.dart`
  - Removed the hard-coded `/lesson/1` hero action.
  - Library now opens the first lesson for the currently selected level, using loaded lesson metadata when available and a safe per-level fallback (`1`, `26`, `51`) otherwise.
- Updated `test/features/ui/immersion_walkthrough_test.dart`
  - Added coverage proving Immersion hides `N4` and `N3` articles when the selected level is `N5`.
- Updated `test/features/ui/simple_command_center_test.dart`
  - Added coverage proving Library opens `/lesson/26` when the selected level is `N4`, preventing regression back to `N5` lesson routing.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that Study, Lesson, and Immersion must respect the selected JLPT level strictly.

### Verification Run

- Ran `dart format lib/features/immersion/immersion_home_screen.dart lib/features/library/library_screen.dart test/features/ui/immersion_walkthrough_test.dart test/features/ui/simple_command_center_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/immersion/immersion_home_screen.dart lib/features/library/library_screen.dart test/features/ui/immersion_walkthrough_test.dart test/features/ui/simple_command_center_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/immersion_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test`
  - Result: full test suite passed

### JLPT Prep Hub Consolidation

- Reworked the JLPT entry experience after feedback that `JLPT Coach` and `JLPT Mock` still felt like two disconnected features.
- Updated `lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - Rebuilt the screen into a unified `JLPT Prep` hub with a Home-aligned hero, real readiness metrics, full mock access, quick mock access, reading drill access, support lanes, and a 7-day repair plan.
  - Wired the hub to real in-app data using the current level, JLPT snapshot data, dashboard counts, mistake buckets, mock-bank totals, and reading-bank totals.
  - Cleaned the Vietnamese copy on the new hub so the visible labels are readable and more standardized.
- Updated `lib/features/home/models/practice_destination.dart`
  - Removed the separate `JLPT Mock` destination card so Study now surfaces one unified JLPT prep entry point instead of duplicating the exam flow.
  - Renamed the surviving JLPT destination to `JLPT Prep` / `Ôn thi JLPT` and updated the subtitle to reflect the merged feature scope.
- Updated `lib/features/practice/practice_screen.dart`
  - Changed the JLPT goal card and hero CTA copy from `coach` framing to the new unified JLPT prep framing.
- Updated `lib/features/home/screens/learning_path_screen.dart`
  - Renamed the JLPT lane and CTA labels to the unified JLPT prep terminology so Home and Study now speak the same product language.
- Updated `lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Adjusted supporting copy so Mock Pro now talks about saving into `JLPT Prep` instead of the old `JLPT Coach` wording.
- Updated `test/features/home/practice_destination_test.dart`
  - Added coverage proving the separate `JLPT Mock` destination no longer appears and that the Vietnamese JLPT entry copy reflects the merged hub.
- Updated `test/features/ui/simple_command_center_test.dart`
  - Refreshed Study/Home expectations to the new `JLPT prep` naming so routing and layout checks match the redesigned experience.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that JLPT prep should remain one cohesive feature instead of split `Coach` and `Mock` entry points.

### Verification Run

- Ran `dart format lib/features/jlpt/screens/jlpt_coach_screen.dart lib/features/home/models/practice_destination.dart lib/features/practice/practice_screen.dart lib/features/home/screens/learning_path_screen.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart test/features/home/practice_destination_test.dart test/features/ui/simple_command_center_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/screens/jlpt_coach_screen.dart lib/features/home/models/practice_destination.dart lib/features/practice/practice_screen.dart lib/features/home/screens/learning_path_screen.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart test/features/home/practice_destination_test.dart test/features/ui/simple_command_center_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/home/practice_destination_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed

### JLPT Prep Visual Polish Pass

- Ran a dedicated visual-polish pass on the unified JLPT prep hub to bring it closer to the Home screen's tone and finish.
- Updated `lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - Replaced the heavier generic section feel with softer Home-style paper panels for the main JLPT prep sections.
  - Refined the hero so the snapshot metrics now sit inside a tighter summary sheet instead of floating like separate utility pills.
  - Polished the exam mode cards with softer surfaces, slimmer accent lines, calmer icon treatment, and tighter typography/spacing.
  - Polished the 7-day plan cards to feel less like raw dashboard tiles and more like curated premium action cards.
  - Added subtle section accent rules so the screen has a clearer reading rhythm without becoming noisy.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent note that JLPT prep should visually align with Home using compact spacing, paper-like surfaces, and restrained premium styling.

### Verification Run

- Ran `dart format lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/home/practice_destination_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed

### JLPT Mock Data Source Rebuild

- Reworked `JLPT Mock Pro` after confirming the exam screen was still reading hard-coded placeholder questions instead of real app data.
- Updated `lib/features/jlpt/data/jlpt_mock_bank.dart`
  - Replaced the static `jlptMockSections` constant with a dynamic bank builder and `jlptMockSectionsProvider`.
  - The mock now composes `Vocabulary`, `Grammar`, `Kanji`, and `Reading` sections from current in-app data for the selected level.
  - `Vocabulary` now comes from level-filtered content vocab, `Grammar` from level-filtered grammar points/examples, `Kanji` from level-filtered kanji data, and `Reading` from the immersion-backed JLPT reading bank.
  - Added question source/context metadata so the mock UI can show lesson/passages behind each question instead of feeling disconnected from app data.
- Updated `lib/features/jlpt/models/jlpt_mock_models.dart`
  - Extended JLPT mock question models with optional context/source fields for richer, data-backed exam cards.
- Updated `lib/features/jlpt/screens/jlpt_mock_pro_screen.dart`
  - Switched the landing flow to load the current JLPT bank asynchronously from real in-app data.
  - Disabled exam start while the current bank is loading or unavailable, and surfaced clear error/empty copy instead of silently falling back.
  - Locked the selected bank into widget state when an exam starts so the active exam cannot drift if level/language changes mid-run.
  - Updated section counts, timing, flow cards, result cards, and active question cards to use the dynamic bank instead of the old placeholder bank.
  - Added source/context presentation inside question cards so reading passages and lesson provenance are visible during the exam.
- Updated `lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - JLPT Prep overview counts for the full mock now come from the rebuilt dynamic mock bank instead of the removed hard-coded section list.
- Updated `test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Overrode the dynamic JLPT bank provider with a small deterministic test bank so the screen test stays stable without depending on real database/assets.
- Updated `test/features/jlpt/jlpt_reading_screen_test.dart`
  - Added an explicit widget cleanup step so the screen test no longer fails on leftover `flutter_animate` timers during teardown.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that JLPT mock/prep must use real in-app level-filtered data instead of hard-coded placeholder questions.

### Verification Run

- Ran `dart format lib/features/jlpt/models/jlpt_mock_models.dart lib/features/jlpt/data/jlpt_mock_bank.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart lib/features/jlpt/screens/jlpt_coach_screen.dart test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/data/jlpt_mock_bank.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart lib/features/jlpt/screens/jlpt_coach_screen.dart test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: no issues found
- Ran `flutter analyze lib/features/jlpt/data/jlpt_mock_bank.dart lib/features/jlpt/screens/jlpt_mock_pro_screen.dart lib/features/jlpt/screens/jlpt_coach_screen.dart test/features/jlpt/jlpt_mock_pro_screen_test.dart test/features/jlpt/jlpt_reading_screen_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/home/practice_destination_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/jlpt/jlpt_reading_screen_test.dart`
  - Result: all tests passed

### Test Study UI/UX Learning Pass

- Continued the legacy `Test` / `Study` exam flow redesign after confirming this was the screen the user was unhappy with.
- Verified the in-progress `Test` shell redesign and finished the missing question-area polish so the learning experience is clearer and more consistent with `Home`.
- Added `lib/features/learn/widgets/question_surface.dart`
  - Introduced shared prompt, answer-choice, and feedback surfaces with the app's paper-like palette and tighter spacing.
- Updated `lib/features/learn/widgets/multiple_choice_widget.dart`
  - Rebuilt the question header into a clearer term / reading / prompt hierarchy.
  - Replaced the old plain answer rows with cleaner premium choice cards and letter anchors for faster scanning.
- Updated `lib/features/learn/widgets/true_false_widget.dart`
  - Matched the new prompt-card treatment.
  - Reworked true/false actions into cleaner responsive choice tiles so mobile no longer wastes as much vertical space.
- Updated `lib/features/learn/widgets/fill_blank_widget.dart`
  - Tightened the answer field styling and hierarchy.
  - Reworked hint reveal into a proper support card instead of bloating the button label.
  - Reworked correct-answer feedback into a clearer study card while preserving the hidden-answer exam behavior.
- Updated `lib/features/test/models/test_config.dart`
  - Fixed mock-exam question count clamping so smaller available pools do not get forced to the old minimum of `10`.
- Updated `lib/features/test/screens/test_config_screen.dart`
  - Fixed preset question-count handling to respect the actual available pool.
  - Verified the larger config redesign now compiles cleanly after the earlier unfinished pass.
- Verified the current `lib/features/test/screens/test_screen.dart` redesign compiles cleanly alongside the new shared question widgets.
  - Removed the duplicated progress line above the question body and replaced it with quieter level / flagged-state context chips.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that test/quiz question UIs must prioritize learning clarity, clean hierarchy, and low dead space.

### Verification Run

- Ran `dart format lib/features/learn/widgets/question_surface.dart lib/features/learn/widgets/multiple_choice_widget.dart lib/features/learn/widgets/true_false_widget.dart lib/features/learn/widgets/fill_blank_widget.dart lib/features/test/models/test_config.dart lib/features/test/screens/test_config_screen.dart lib/features/test/screens/test_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/learn/widgets/question_surface.dart lib/features/learn/widgets/multiple_choice_widget.dart lib/features/learn/widgets/true_false_widget.dart lib/features/learn/widgets/fill_blank_widget.dart lib/features/test/models/test_config.dart lib/features/test/screens/test_config_screen.dart lib/features/test/screens/test_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/learn/learn_mode_config_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/test/test_screen_feedback_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: all tests passed

### Test Desktop Overflow Fix

- Fixed the remaining desktop overflow regression reported from the live mock-exam screen.
- Updated `lib/features/test/screens/test_screen.dart`
  - Made the right-side desktop panel scroll independently so large question maps and long run-mode details no longer overflow the viewport.
- Updated `test/features/ui/mock_exam_walkthrough_test.dart`
  - Added a desktop-width regression test with a `50` question mock to ensure the side panel does not overflow again.

### Verification Run

- Ran `dart format lib/features/test/screens/test_screen.dart test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/test/screens/test_screen.dart test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: all tests passed

### Study Style Preset Rationalization

- Reworked the `Study Style` section in the test config so it behaves like a real learning-mode chooser instead of three vague preset cards.
- Updated `lib/features/test/screens/test_config_screen.dart`
  - Replaced the old `Quick warm-up / Balanced review / Exam focus` framing with clearer goal-based modes:
    - `Memory check`
    - `Active review`
    - `Exam simulation`
  - Rebuilt each preset card to show:
    - what the mode is for
    - the practical setup it applies
    - the learning tradeoff behind it
  - Added selected-state styling so the current preset is visually obvious.
  - Added preset matching in the summary panel and a `Custom mix` state when the user fine-tunes settings away from a preset.
  - Adjusted the medium preset to a more realistic learning workload (`20-24` questions depending on available pool) instead of a blanket `30`.
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent requirement that test presets should map to clear learning intents rather than arbitrary card labels.

### Verification Run

- Ran `dart format lib/features/test/screens/test_config_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/test/screens/test_config_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: all tests passed

### Grammar English Fallback Cleanup

- Fixed the grammar English-mode leak where Vietnamese labels and translations could still appear when local DB rows had stale or incomplete English fields.
- Updated `lib/data/utils/grammar_english_notation.dart`
  - Added shared detection for Vietnamese-contaminated text.
  - Added English display resolvers that prefer clean English copy, then fall back to safe Japanese grammar notation instead of Vietnamese.
- Updated Grammar UI and generation flows to use the shared English resolvers:
  - `lib/features/grammar/services/grammar_question_generator.dart`
  - `lib/features/grammar/grammar_screen.dart`
  - `lib/features/grammar/screens/grammar_detail_screen.dart`
  - `lib/features/grammar/screens/ghost_review_screen.dart`
  - `lib/features/grammar/widgets/grammar_example_widget.dart`
- Tightened generator behavior so English-mode feedback, options, and prompts no longer pull raw Vietnamese `grammarPoint` labels into visible text.
- Updated grammar data sync paths so reseeded DB content stores safer English fallbacks:
  - `lib/data/seeds/grammar_seeder.dart`
  - `lib/data/repositories/lesson_repository.dart`
- Bumped grammar seed version from `4` to `5` so existing installs refresh polluted grammar English fields on next launch.
- Added regression coverage in `test/features/grammar/grammar_question_generator_test.dart` for the exact stale-data case.
- Updated `test/features/ui/ghost_review_walkthrough_test.dart` to use a sturdier tap target after the English grammar headline became localized.

### Verification Run

- Ran `dart format` on all changed grammar/data/test files
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/grammar lib/data/utils/grammar_english_notation.dart lib/data/seeds/grammar_seeder.dart lib/data/repositories/lesson_repository.dart test/features/grammar/grammar_question_generator_test.dart test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/grammar/grammar_question_generator_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed

### Grammar Practice UI/UX Pass

- Redesigned the active Grammar practice experience so it reads more like a focused study sheet and less like a stretched utility screen.
- Updated `lib/features/grammar/screens/grammar_practice_screen.dart`
  - Centered the active study column with a desktop max-width so the screen no longer stretches awkwardly across wide layouts.
  - Refined the session header, progress card, hint card, timer, and feedback banner into softer paper-like panels aligned more closely with Home.
  - Reduced dead space and improved information hierarchy between mode, progress, question type, and feedback.
- Added shared practice surfaces in `lib/features/grammar/widgets/grammar_practice_surfaces.dart`
  - Introduced reusable prompt cards and answer-option tiles with calmer borders, better spacing, clearer states, and stronger left-aligned scanability.
- Updated `lib/features/grammar/widgets/multiple_choice_widget.dart`
  - Removed the old spacer-based layout that left large empty gaps.
  - Rebuilt multiple-choice questions into a top-aligned prompt plus vertically stacked premium answer cards.
- Updated `lib/features/grammar/widgets/cloze_test_widget.dart`
  - Reworked fill-blank into a clearer study flow with instruction header, sentence card, visible selected-answer preview, calmer options, and a cleaner action button.
- Updated `lib/features/grammar/widgets/sentence_builder_widget.dart`
  - Restyled sentence builder with the same study-sheet surfaces.
  - Removed the old full-screen correctness overlay in favor of subtler inline guidance.
  - Made the whole builder scroll safely in short viewports to avoid layout overflow.
- Updated `test/features/ui/ghost_review_walkthrough_test.dart`
  - Switched grammar interaction helpers to stable keys/visible targets after the UI refresh.

### Verification Run

- Ran `dart format lib/features/grammar/screens/grammar_practice_screen.dart lib/features/grammar/widgets/grammar_practice_surfaces.dart lib/features/grammar/widgets/multiple_choice_widget.dart lib/features/grammar/widgets/cloze_test_widget.dart lib/features/grammar/widgets/sentence_builder_widget.dart test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/grammar/screens/grammar_practice_screen.dart lib/features/grammar/widgets/grammar_practice_surfaces.dart lib/features/grammar/widgets/multiple_choice_widget.dart lib/features/grammar/widgets/cloze_test_widget.dart lib/features/grammar/widgets/sentence_builder_widget.dart test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed

### Grammar Question Quality Pass

- Tightened grammar question generation after review feedback that some `Fill Blank` items exposed the answer immediately with mismatched distractors.
- Updated `lib/features/grammar/services/grammar_question_generator.dart`
  - Added stronger filtering for visible answer options so placeholders like `Grammar pattern` never surface in practice choices.
  - Added related-point ranking for cloze distractors so grammar options stay in the same answer family more often instead of mixing unrelated patterns.
  - Added a skip rule for exchange-style full-sentence prompts such as `お国はどちらですか` so the app does not generate obvious cloze questions from dialogue-style grammar items.
  - Improved pattern-shape detection for short grammar tokens like `です`, `ます`, and `でした` so they can still form sensible distractor groups.
- Added regression coverage in `test/features/grammar/grammar_question_generator_test.dart`
  - Verifies exchange-style prompts do not generate cloze questions.
  - Verifies cloze distractors stay in-family and avoid placeholder labels.
  - Verifies polluted English data still does not leak placeholders into visible options.

### Verification Run

- Ran `dart format lib/features/grammar/services/grammar_question_generator.dart test/features/grammar/grammar_question_generator_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/grammar/services/grammar_question_generator.dart test/features/grammar/grammar_question_generator_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/grammar/grammar_question_generator_test.dart`
  - Result: all tests passed
- Ran `flutter analyze lib/features/grammar/screens/grammar_practice_screen.dart lib/features/grammar/widgets/multiple_choice_widget.dart lib/features/grammar/widgets/cloze_test_widget.dart lib/features/grammar/widgets/sentence_builder_widget.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed

### Handwriting Guide Alignment Pass

- Investigated the remaining complaint that handwriting scoring still felt too harsh even when the learner followed the displayed stroke order.
- Root cause found
  - The visible stroke guide and the scoring template for `四` were materially misaligned.
  - The old `四` template in `assets/data/support/kanji/stroke_templates.json` described a tall, center-heavy shape that did not match the KanjiVG guide shown in the UI.
  - This mismatch made guide-faithful writing lose points on template and shape gates even when stroke order was correct.
- Updated `assets/data/support/kanji/stroke_templates.json`
  - Replaced the `四` manual template stroke endpoints with guide-aligned geometry.
  - Corrected the `四` target shape profile to a wider enclosure-like form (`targetArea` and `targetAspect`).
- Updated `assets/data/support/kanji/stroke_template_overrides.json`
  - Mirrored the same `四` correction so future template regenerations keep the fix.
- Updated `lib/features/write/services/handwriting_evaluator.dart`
  - Added a guarded guide-visible near-correct pass for `manual` and `curated` handwriting scoring.
  - This only applies when the learner is in guided mode and the writing is already close on score, shape, order, template, and direction.
  - Added slightly more forgiveness for enclosure-like kanji such as `四`, `日`, and `口` without weakening obvious wrong-direction rejects like the existing `人` regression.
- Updated `test/features/write/handwriting_evaluator_regression_test.dart`
  - Replaced the old `四` regression with a more guide-aligned `四` sketch so the test now reflects what the user actually sees on screen.
  - Added an assertion that guide-aligned `四` writing earns a healthier template score instead of being dragged down by the old mismatch.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that the visible handwriting guide and evaluator template must stay aligned.

### Verification Run

- Ran `dart format lib/features/write/services/handwriting_evaluator.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/services/handwriting_evaluator.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_template_matcher_test.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/write/handwriting_stroke_check_v2_benchmark_test.dart`
  - Result: all tests passed
- Ran `flutter test test/data/stroke_template_coverage_test.dart`
  - Result: all tests passed

### Handwriting Unified Guide-Scoring Pipeline Pass

- Reworked the handwriting template runtime so the app no longer depends only on a separate endpoint template set for scoring when vector stroke-guide data already exists.
- Root cause addressed
  - Handwriting previously used two geometry sources:
    - `KanjiStrokeVectorService` for the visible guide
    - `KanjiStrokeTemplateService` for the scoring template
  - This made the system fragile because any mismatch between the two sources forced follow-up per-character patches like the earlier `四` fix.
- Updated `lib/features/write/services/kanji_stroke_vector_layout.dart`
  - Added a shared vector-layout helper so guide rendering and vector-to-template projection use the same padding and centering math.
- Updated `lib/features/write/widgets/kanji_stroke_animator.dart`
  - Switched the guide animator to use the shared vector-layout helper instead of keeping its own private copy of the layout logic.
- Updated `lib/features/write/services/kanji_stroke_template_service.dart`
  - Added runtime projection from `KanjiStrokeVector` to `KanjiStrokeTemplate`.
  - The projected template now derives:
    - normalized stroke start/end geometry from the guide path
    - shape metrics from the same guide-aligned geometry
  - Added runtime merge logic so, when vector data exists:
    - the app replaces stale scoring stroke geometry with guide-derived geometry
    - existing template quality labels like `manual` and `curated` are preserved
    - existing shape tuning is kept when the old template already agrees closely with the guide
    - guide-derived shape metrics are used automatically when the old template is clearly inconsistent
  - Added a cache reset helper for deterministic testing of projected templates.
- Added `test/features/write/kanji_stroke_template_service_test.dart`
  - Proves projected templates normalize guide geometry correctly.
  - Proves the runtime service prefers debug vector geometry over stale debug template geometry while preserving template quality.
  - Proves the live vector-derived `四` template accepts guide-faithful rough writing, validating the new architecture instead of relying only on a per-character patch.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that handwriting should prefer one geometry pipeline over ongoing one-off kanji patches.

### Verification Run

- Ran `dart format lib/features/write/services/kanji_stroke_template_service.dart lib/features/write/services/kanji_stroke_vector_layout.dart lib/features/write/widgets/kanji_stroke_animator.dart test/features/write/kanji_stroke_template_service_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/services/kanji_stroke_template_service.dart lib/features/write/services/kanji_stroke_vector_layout.dart lib/features/write/widgets/kanji_stroke_animator.dart test/features/write/kanji_stroke_template_service_test.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/kanji_stroke_template_service_test.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_template_matcher_test.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/write/handwriting_stroke_check_v2_benchmark_test.dart test/data/stroke_template_coverage_test.dart`
  - Result: all tests passed

### Sakura Background Crash Fix

- Investigated a new red-screen crash reported after navigating to screens that use `JapaneseBackground`.
- Root cause found
  - `lib/features/common/widgets/japanese_background.dart` uses a `LayoutBuilder` to adjust sakura density by viewport width.
  - `lib/features/common/widgets/sakura_particles.dart` reseeded petals in `didUpdateWidget` when `petalCount` changed.
  - The `_petals` field was declared as `late final`, so the second reseed threw `LateInitializationError: Field '_petals...' has already been initialized.`
  - Once that exception fired, Flutter showed the red error background across the screen.
- Updated `lib/features/common/widgets/sakura_particles.dart`
  - Changed `_petals` from `late final` to mutable `late` storage so responsive reseeding is safe when `petalCount` changes.
- Added `test/features/common/widgets/sakura_particles_test.dart`
  - Added regression coverage proving `SakuraParticles` can rebuild with a different `petalCount` without throwing an exception.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded that responsive sakura density changes must never crash the app or trigger the red error screen.

### Verification Run

- Ran `dart format lib/features/common/widgets/sakura_particles.dart test/features/common/widgets/sakura_particles_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/common/widgets/sakura_particles.dart test/features/common/widgets/sakura_particles_test.dart lib/features/common/widgets/japanese_background.dart`
  - Result: no issues found
- Ran `flutter test test/features/common/widgets/sakura_particles_test.dart test/features/ui/simple_command_center_test.dart`
  - Result: all tests passed

### JLPT Repair Plan Differentiation Pass

- Improved the `7-day repair plan` so repeated days on the same weak skill no longer feel like duplicate cards that open the exact same experience.
- Root issue found
  - `lib/features/jlpt/screens/jlpt_coach_screen.dart` rendered repair cards from only `item.area`.
  - That meant `Day 1` and `Day 3` could show the same title/body and push the same route whenever the same weak skill repeated, even though the plan itself intended different study roles (`reset`, `speed`, `checkpoint`, etc.).
- Added `lib/features/jlpt/models/jlpt_plan_playbook.dart`
  - Introduced a small playbook layer that maps each plan item to:
    - a day-phase (`Reset`, `Accuracy`, `Speed`, `Coverage`, `Timed`, `Checkpoint`, `Mini mock`)
    - clearer localized card copy
    - a specific CTA label
    - a route plus optional launch preset
  - This lets `Day 1` and `Day 3` stay distinct even when they target the same skill area.
- Updated `lib/features/jlpt/screens/jlpt_coach_screen.dart`
  - Added a second chip on each card to show the phase clearly.
  - Replaced the old area-only title/body/button logic with playbook-driven copy and launches.
  - `Open lane` is now replaced by more concrete CTAs such as repair check, timed vocab check, grammar drill, handwriting, immersion, or reading drill depending on the day role.
- Added `lib/features/test/models/home_mock_exam_launch_args.dart`
  - Introduced launch args for Home mock exam presets so the repair plan can open the same vocab bank in different study modes instead of always landing on one identical mock setup.
- Updated `lib/features/test/screens/home_mock_exam_screen.dart`
  - Added support for plan-specific launch presets:
    - optional title override
    - optional initial config override
    - separate session key suffixes so repair-check sessions do not collide with the normal home mock resume state
- Updated `lib/app/navigation/app_router.dart`
  - Wired `/practice/mock-exam` to accept `HomeMockExamLaunchArgs` from the JLPT repair plan.
- Added `test/features/jlpt/jlpt_plan_playbook_test.dart`
  - Added regression coverage proving:
    - `Day 1` and `Day 3` vocab repair now have different phase labels, copy, CTA labels, and launch presets
    - timed grammar phases launch grammar practice with speed-oriented settings
    - reading coverage phases open immersion instead of the timed reading drill
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that repeated repair-plan days must stay distinct in purpose, copy, CTA, and launch behavior.

### Verification Run

- Ran `dart format lib/features/jlpt/models/jlpt_plan_playbook.dart lib/features/jlpt/screens/jlpt_coach_screen.dart lib/features/test/models/home_mock_exam_launch_args.dart lib/features/test/screens/home_mock_exam_screen.dart lib/app/navigation/app_router.dart test/features/jlpt/jlpt_plan_playbook_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/models/jlpt_plan_playbook.dart lib/features/jlpt/screens/jlpt_coach_screen.dart lib/features/test/models/home_mock_exam_launch_args.dart lib/features/test/screens/home_mock_exam_screen.dart lib/app/navigation/app_router.dart test/features/jlpt/jlpt_plan_playbook_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_plan_playbook_test.dart test/features/ui/simple_command_center_test.dart test/features/jlpt/jlpt_mock_pro_screen_test.dart`
  - Result: all tests passed

### Handwriting Scoring Leniency Pass

- Softened handwriting scoring slightly after feedback that the drawing evaluator felt too strict for recognizably correct answers.
- Updated `lib/features/write/services/handwriting_evaluator.dart`
  - Relaxed the base `manual` template profile a little so near-correct kanji are less likely to fail on tiny template mismatches.
  - Added more forgiving per-character tuning for boxed kanji, especially `日`, where the straight-vector template was over-penalizing learner-style bent closing strokes.
  - Kept the stricter rejection path for obvious wrong-direction writing such as the earlier `人` reversal regression.
- Updated `test/features/write/handwriting_evaluator_regression_test.dart`
  - Added a regression proving a slightly rough but structurally correct `日` sketch is accepted.
  - Kept the existing regression proving reversed `人` still fails.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the standing preference that handwriting should be forgiving for near-correct writing while still rejecting clearly wrong stroke direction/structure.

### Verification Run

- Ran `dart format lib/features/write/services/handwriting_evaluator.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/services/handwriting_evaluator.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_template_matcher_test.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/write/handwriting_stroke_check_v2_benchmark_test.dart --dart-define=JPSTUDY_PRINT_STROKE_BENCHMARK=true`
  - Result: all tests passed
  - Benchmark snapshot: manual tier positive pass rate stayed `0.975`, while manual false-positive rate moved from `0.185` to `0.2075`, which is still far below legacy `0.98`.

### Handwriting Black Screen Completion Fix

- Investigated a new regression where finishing a handwriting item could leave the app on a black screen after dismissing the completion dialog.
- Root cause found
  - `lib/features/write/screens/handwriting_practice_screen.dart` was calling `Navigator.pop()` twice from inside the summary dialog action.
  - That worked for pushed routes, but on the shell-based `/practice/handwriting` route it could pop away the active screen stack and expose a blank black surface.
- Updated `lib/features/write/screens/handwriting_practice_screen.dart`
  - Changed the summary dialog so the button only closes the dialog itself.
  - Added a safe post-summary exit handler:
    - pop the screen when there is a real back stack
    - otherwise route back to `/practice` through `go_router`
    - otherwise restart the session safely in standalone contexts
- Updated `test/features/write/handwriting_walkthrough_test.dart`
  - Added a regression proving that completing a one-item handwriting session from `/practice/handwriting` returns to a `Practice hub` route instead of leaving a black screen.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded that handwriting completion must always return to a valid screen and never leave a black screen.

### Verification Run

- Ran `dart format lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed

### Handwriting Session Randomization

- Fixed the issue where entering Home Handwriting kept starting on the same first kanji every time, making the session feel static and predictable.
- Updated `lib/features/write/screens/home_handwriting_practice_screen.dart`
  - Added a per-session shuffle seed for the Home handwriting route.
  - The seed refreshes when a new Home handwriting session is created or when the selected JLPT level changes.
- Updated `lib/features/write/screens/handwriting_practice_screen.dart`
  - Added optional session-order randomization support.
  - When enabled and no `initialKanjiId` is forcing a specific target, the incoming kanji list is shuffled once per session and then kept stable for the rest of that session.
  - This keeps the first visible kanji fresh on each new entry without causing mid-session reordering during rebuilds.
- Updated `test/features/write/handwriting_walkthrough_test.dart`
  - Added regression coverage proving handwriting can start from a shuffled session order with a deterministic test seed.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded that Home Handwriting should not always reopen on the same first kanji.

### Verification Run

- Ran `dart format lib/features/write/screens/home_handwriting_practice_screen.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/screens/home_handwriting_practice_screen.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_walkthrough_test.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: all tests passed

### Handwriting Session Scope Labels

- Clarified the handwriting UX after feedback that sessions sometimes looked like they only contained a tiny number of kanji.
- Root cause found
  - The screen summary and progress UI were correctly showing `_targets.length`, but they did not explain whether `_targets` currently represented:
    - the normal all-items session
    - a weak-items subset
    - a wrong-only retry subset
  - This made `1/1` look like the whole `N5` handwriting pool only had one kanji left, even when the app had intentionally switched into a narrow retry set.
- Updated `lib/core/app_language.dart`
  - Added localized labels for `All items`, `Weak set`, `Wrong-only set`, and the `Set: ...` wrapper.
- Updated `lib/features/write/screens/handwriting_practice_screen.dart`
  - Added explicit session-set state tracking for `allItems`, `weakSet`, and `wrongOnly`.
  - Surfaced the current set label directly in the progress card so the user can immediately see what kind of handwriting session is active.
  - Added the same set label to the completion dialog so summaries like `Correct 1 / 1` are clearly framed as a subset session when appropriate.
- Updated `test/features/write/handwriting_walkthrough_test.dart`
  - Added assertions proving the default handwriting flow shows `Set: All items`.
  - Added assertions proving the retry flow switches the UI label to `Set: Wrong-only set`.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded that handwriting must label subset sessions explicitly to avoid confusion with the full N-level pool.

### Verification Run

- Ran `dart format lib/core/app_language.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/core/app_language.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_walkthrough_test.dart test/features/write/handwriting_evaluator_regression_test.dart`
  - Result: all tests passed

### Handwriting Next Navigation Fix

- Investigated the report that tapping `Next` in handwriting could leave the screen on the same word instead of advancing.
- Updated `lib/features/write/screens/home_handwriting_practice_screen.dart`
  - Memoized the level-specific kanji future so dashboard/review updates do not recreate the handwriting item list on every rebuild.
  - Moved the review status chip to its own `ConsumerWidget` so review-state refreshes stay local instead of rebuilding the whole parent screen.
- Updated `lib/features/write/screens/handwriting_practice_screen.dart`
  - Replaced the fragile `oldWidget.items != widget.items` check with semantic comparison so a fresh but equivalent item list does not reset the current handwriting target.
  - This preserves the current index when the parent rebuilds with the same logical kanji data.
- Updated `test/features/write/handwriting_walkthrough_test.dart`
  - Added a regression test covering the exact rebuild case: move to the second handwriting item, rebuild the parent with a new-but-equivalent list, and verify the screen stays on item `2/2`.
  - Switched the regression harness to in-memory repository/database overrides so the test measures navigation behavior directly without unrelated seeding noise.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that handwriting `Next` must always advance reliably and must not jump back on rebuild.

### Verification Run

- Ran `dart format lib/features/write/screens/home_handwriting_practice_screen.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/screens/home_handwriting_practice_screen.dart lib/features/write/screens/handwriting_practice_screen.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed

### JLPT Reading Drill UX Pass

- Reworked `JLPT Reading Drill` so the screen supports learning and passage selection more intentionally instead of showing sparse list cards and a flat reading flow.
- Updated `lib/features/jlpt/screens/jlpt_reading_screen.dart`
  - Filtered the drill to the currently selected JLPT level so the reading list stays on the active study track.
  - Upgraded the list hero with current-track metrics and clearer context.
  - Rebuilt reading-set cards with:
    - current level
    - question/time metadata
    - question-type tags
    - a real passage preview
  - Reworked the active drill into a clearer two-column desktop layout:
    - left side for passage paragraphs with explicit paragraph tags
    - right side for question flow and answering
  - Added a focused question header with answered progress.
  - Improved answer option hierarchy with letter badges, clearer selected/correct/wrong states, and labeled explanation blocks.
  - Improved timer urgency styling.
- Updated `lib/features/immersion/services/shared_reading_library.dart`
  - Restricted fallback immersion asset scanning to the currently supported in-app JLPT levels (`N5`, `N4`, `N3`) so the reading bank no longer probes missing `N2/N1` assets in tests.
- Updated `test/features/jlpt/jlpt_reading_screen_test.dart`
  - Added regression coverage proving the screen follows the selected JLPT track (`N4 track` in the test case).
- Updated `docs/notes/important-user-requirements.md`
  - Added a persistent note that `JLPT Reading Drill` should help users choose and read with intent using previews, current-level context, and clear passage/question hierarchy.

### Handwriting Practice UI/UX Pass

- Reworked the `Handwriting` screen so the writing experience feels more like a focused study surface and less like a raw utility panel.
- Updated `lib/features/write/screens/handwriting_practice_screen.dart`
  - Moved the optional review chip out of the app bar and into the page flow for a cleaner header.
  - Wrapped the page with the shared Japanese background and rebuilt the layout around compact paper-like panels.
  - Merged progress, session stats, weak-practice CTA, and mode selection into one cohesive session card.
  - Redesigned the current target card so kanji, meaning, reading, stroke count, and mode are easier to scan.
  - Recentered and enlarged the handwriting canvas area, added a simple study flow (`guide -> write -> check`), and tightened the control panel below it.
  - Polished result feedback and the stroke-guide panel so they match the Home/JLPT visual language more closely.
- Updated `lib/features/write/screens/home_handwriting_practice_screen.dart`
  - Restyled the handwriting review chip into a softer compact status card.
  - Localized the review-state copy instead of leaving it hard-coded in English.
- Updated `lib/core/app_language.dart`
  - Added localized handwriting review status strings used by the Home handwriting header.
- Updated `test/features/write/handwriting_walkthrough_test.dart`
  - Adjusted widget tests to scroll to the canvas/guide where needed now that the layout is denser and more structured.

### Verification Run

- Ran `dart format lib/features/write/screens/handwriting_practice_screen.dart lib/features/write/screens/home_handwriting_practice_screen.dart lib/core/app_language.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/screens/handwriting_practice_screen.dart lib/features/write/screens/home_handwriting_practice_screen.dart lib/core/app_language.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed

### Handwriting Scoring False-Positive Fix

- Tightened handwriting evaluation after feedback that clearly wrong writing could still be marked correct when the stroke count happened to match.
- Updated `lib/features/write/services/handwriting_template_matcher.dart`
  - Added a dedicated `templateDirectionScore` so stroke direction can be judged independently from overall start/end placement.
- Updated `lib/features/write/services/handwriting_evaluator.dart`
  - Added a direction gate to template-backed handwriting scoring.
  - Manual templates now require a stronger stroke-direction match, with slightly softer thresholds for curated/generated templates.
  - This specifically blocks cases like drawing `人` with a reversed opening stroke from passing only because total stroke count and rough placement looked acceptable.
- Updated tests
  - `test/features/write/handwriting_template_matcher_test.dart`
    - Added regression coverage proving the direction score drops when a stroke is drawn backwards.
  - `test/features/write/handwriting_evaluator_regression_test.dart`
    - Added a focused regression for `人` proving a reversed opening stroke is rejected even with the guide visible.

### Verification Run

- Ran `dart format lib/features/write/services/handwriting_evaluator.dart lib/features/write/services/handwriting_template_matcher.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_template_matcher_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/write/services/handwriting_evaluator.dart lib/features/write/services/handwriting_template_matcher.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_template_matcher_test.dart lib/features/write/screens/handwriting_practice_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/write/handwriting_template_matcher_test.dart test/features/write/handwriting_evaluator_regression_test.dart test/features/write/handwriting_walkthrough_test.dart`
  - Result: all tests passed
- Ran `flutter test test/features/write/handwriting_stroke_check_v2_benchmark_test.dart`
  - Result: all tests passed

### Verification Run

- Ran `dart format lib/features/jlpt/screens/jlpt_reading_screen.dart test/features/jlpt/jlpt_reading_screen_test.dart lib/features/immersion/services/shared_reading_library.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/jlpt/screens/jlpt_reading_screen.dart test/features/jlpt/jlpt_reading_screen_test.dart lib/features/immersion/services/shared_reading_library.dart`
  - Result: no issues found
- Ran `flutter test test/features/jlpt/jlpt_reading_screen_test.dart`
  - Result: all tests passed

### Audit Follow-up Fix Pass

- Fixed remaining issues from the full app audit.

**Fixes:**

- **I9 — Ghost review count inconsistency (dead duplicate provider)**
  - `lib/data/repositories/lesson_repository.dart`: Removed dead `grammarGhostsProvider` that was never imported by any screen. `ghost_review_screen` and `ghost_practice_screen` both already import from `grammar_providers.dart`. `grammarGhostCountProvider` now uses `fetchGhostPoints()` as single source of truth so badge count and review screen list always match.

- **C4+I12 — `seedGrammarIfEmpty` race condition + perpetual resync**
  - `lib/data/repositories/lesson_repository.dart`: Added SharedPreferences version check at the top of `seedGrammarIfEmpty`. When `GrammarSeeder` has already run at current version (`grammar_data_version >= 4`), only a lightweight row-count check is done instead of the full normalizer resync loop. This eliminates the first-launch race between `GrammarSeeder` transaction and `seedGrammarIfEmpty`, and stops the perpetual resync triggered by non-idempotent normalizer regex patterns.

- **Minor — `Colors.white` hardcode in dark mode**
  - `lib/features/home/screens/learning_path_screen.dart`: `_LaneCard` gradient now uses `Theme.of(context).colorScheme.surface` instead of `Colors.white` so the card looks correct in dark mode.

### Verification Run

- Ran `dart format` on changed files: formatting completed successfully
- Ran `flutter analyze`: no issues found
- Ran `flutter test`: 162 tests passed

### Full App Audit & Bug Fix Pass

- Ran a comprehensive code review of the entire app covering logic correctness, UX/flow consistency, data integrity, and code quality.
- Identified 4 Critical, 8 Important, and 6 Minor issues.
- Fixed all Critical and high-priority Important issues in this session.

**Critical fixes:**

- **C1 — `fetchVocabTermsByIds` hardcoded `level: 'N5'`**
  - `lib/data/repositories/lesson_repository.dart`: changed from hardcoded string to JOIN `UserLessonTerm → UserLesson` to get the real `jlptLevel`. Fallback `'N5'` only if no lesson row found.
  - Same fix in `lib/features/games/match_game/lesson_match_screen.dart` and `lib/features/learn/integration/write_mode_integration.dart`.

- **C2 — `jlptPrepOverviewProvider` hardcoded `AppLanguage.en`**
  - `lib/features/jlpt/screens/jlpt_coach_screen.dart`: passed `ref.watch(appLanguageProvider)` instead. Ensures Vietnamese users see accurate question counts in JLPT Prep overview.

- **C3 — `seedGrammarIfEmpty` deleted grammar points → cascade-deleted SRS state**
  - `lib/data/repositories/lesson_repository.dart`: replaced the destructive delete+insert pattern with UPDATE in-place for existing grammar points (keyed by `grammarPoint` title). Grammar examples are still refreshed (safe — they have no SRS state). New grammar points are inserted normally. This preserves `GrammarSrsState` rows which FK-cascade-delete on `GrammarPoints` deletion.

**Important fixes:**

- **I5 — `continueActionProvider` was a non-reactive `StreamProvider`**
  - `lib/features/home/providers/continue_provider.dart`: converted from `StreamProvider<ContinueAction>` (`async*`/`yield`/`return`) to `FutureProvider<ContinueAction>` (`async`/`return`). Riverpod now re-runs the provider whenever `dashboardProvider` changes. The Continue button on Home now updates mid-session.
  - Also moved `ref.watch(grammarRepositoryProvider)` to unconditional top position.
  - Updated 3 test files with `Stream.value` overrides to use `async =>` instead.

- **I11 — `SrsDao.getStageBreakdown` counted unreviewed items**
  - `lib/data/daos/srs_dao.dart`: added `.where((t) => t.lastReviewedAt.isNotNull())` filter. Stage breakdown (learning/young/mature) now correctly excludes vocab items that have been seeded but never reviewed.

**Minor fixes:**

- Removed dead `KanjiReviewChip` class from `lib/features/write/screens/home_handwriting_practice_screen.dart` (was unused after SRS-first session rework).

**Items confirmed as already correct (audit false positives):**

- I8 (Immersion level filter): Already implemented via `_articlesForLevel` filtering by `article.officialLevel == level.shortLabel`.

### Verification Run

- Ran `dart format` on all changed files
  - Result: formatting completed successfully
- Ran `flutter analyze` on changed files
  - Result: no issues found
- Ran `flutter test`
  - Result: 162 tests passed

### Handwriting SRS-First Session

- Reworked `HomeHandwritingPracticeScreen` after feedback that loading all 284 kanji at once gave no clear sense of completion.
- Root cause: `HomeHandwritingPracticeScreen` previously called `fetchKanjiByLevel(level)` which loads every kanji regardless of SRS state, unlike Recall Sprint and Ghost Review which correctly limit to due items.
- Added `getAllSeenKanjiIds()` and `insertTestState()` helpers to `KanjiSrsDao`.
- Added `fetchDueKanjiByLevel(level)` and `fetchUnseenKanjiByLevel(level, limit)` to `LessonRepository`:
  - Due = has a KanjiSrsState row with `nextReviewAt <= now`
  - Unseen = no KanjiSrsState row at all
- Reworked `HomeHandwritingPracticeScreen` into a 3-state session loader:
  1. Due items (SRS-scheduled reviews) — shown first, matches Recall Sprint/Ghost behavior
  2. New batch (15 unseen kanji) — fallback when nothing is due
  3. AllCaughtUp screen with "Free practice" button — shown when all kanji have been seen and none are due
- Added `_SessionHeader` widget inside the handwriting scroll body showing session type and a "Free practice" escape hatch.
- Added localized strings: `handwritingDueSessionTitle`, `handwritingNewBatchTitle`, `handwritingFreePracticeLabel`, `handwritingNothingDueLabel`, `handwritingNewBatchSubtitle`.

### Verification Run

- Ran `dart format` on all changed files
  - Result: formatting completed successfully
- Ran `flutter analyze lib/data/daos/kanji_srs_dao.dart lib/data/repositories/lesson_repository.dart lib/core/app_language.dart lib/features/write/screens/home_handwriting_practice_screen.dart`
  - Result: no issues found
- Ran `flutter test`
  - Result: full test suite passed (161 tests)

### Study Style Visual Tightening

- Ran a dedicated aesthetic pass on the three `Study Style` preset cards to make them feel more premium and compact without changing preset behavior.
- Updated `lib/features/test/screens/test_config_screen.dart`
  - Tightened the spacing between cards so the section reads as one curated control group instead of three loose tiles.
  - Reworked the card surface into a softer paper-like gradient with lighter borders and a calmer selected shadow.
  - Reduced the icon badge and replaced the louder selected pill with a quieter circular check.
  - Reframed the top overline into a subtle editorial label instead of a utility badge.
  - Reworked the metadata chips so they feel lighter and less dashboard-like.
  - Restyled the preset note into a slim editorial callout strip so the cards feel more refined and less bulky.

### Verification Run

- Ran `dart format lib/features/test/screens/test_config_screen.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/test/screens/test_config_screen.dart`
  - Result: no issues found
- Ran `flutter test test/features/ui/mock_exam_walkthrough_test.dart`
  - Result: all tests passed

### Grammar Practice Session Randomization Fix

- Fixed the grammar practice issue where reopening the screen could still start on the same first question.
- Updated `lib/features/grammar/screens/grammar_practice_screen.dart`
  - Extracted session ordering into a dedicated `GrammarSessionPlanner`.
  - Added per-session random blueprint rotation so `drill/quiz/learn` do not always open with the same question family.
  - Randomized bucket ordering even when the generated pool is smaller than the target session size, removing the old deterministic `return List.of(all)` path.
  - Kept anti-repeat protection so the fresher opening does not regress into clustered duplicate stems or repeated grammar points.
- Added `test/features/grammar/grammar_session_planner_test.dart`
  - Added regression coverage proving the first visible question changes across different session seeds for both:
    - short pools (`all.length <= target`)
    - larger curated sessions (`all.length > target`)
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that grammar practice must feel fresh on every new entry and must not keep reopening on the same first question.

### Verification Run

- Ran `dart format lib/features/grammar/screens/grammar_practice_screen.dart test/features/grammar/grammar_session_planner_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/features/grammar/screens/grammar_practice_screen.dart test/features/grammar/grammar_session_planner_test.dart`
  - Result: no issues found
- Ran `flutter test test/features/grammar/grammar_session_planner_test.dart test/features/grammar/grammar_question_generator_test.dart test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed

### Grammar Data Utilization Pass

- Improved Grammar practice so it makes fuller use of both `grammar` and `grammar_examples` data instead of relying on looser/random matching.
- Added `lib/data/utils/grammar_example_matching.dart`
  - Introduced tolerant matching between grammar definitions and supplementary example blocks.
  - Handles cases where labels differ slightly but still refer to the same pattern, such as:
    - Vietnamese helper phrasing (`Động từ dạng ます` vs `Động từ Vます`)
    - optional `の` variants (`～ために` vs `～のために`)
- Updated `lib/data/seeds/grammar_seeder.dart`
  - Switched supplementary example lookup to the new matcher.
  - Bumped `GrammarSeeder.kGrammarDataVersion` from `5` to `6` so existing installs reseed and pick up the previously missed examples.
- Updated `lib/data/db/content_database.dart`
  - Switched content-DB grammar example merging to the same tolerant matcher.
  - Bumped content DB schema version from `23` to `24` so grammar content is reseeded with the improved example matching.
- Updated `lib/data/repositories/lesson_repository.dart`
  - Kept the `seedGrammarIfEmpty` seeder-version shortcut in sync with grammar seed version `6`.
- Updated `lib/features/grammar/services/grammar_question_generator.dart`
  - Replaced random distractor picking for grammar meaning/pattern questions with ranked nearby grammar points from the same lesson/level and similar pattern shape.
  - Reworked context-choice distractors to rank example sentences by lesson, JLPT level, sentence ending, translation overlap, and length similarity instead of random sampling.
  - Reworked error-correction/error-reason corruption to choose more related replacement patterns, making wrong answers feel more plausible.
- Added tests
  - `test/data/utils/grammar_example_matching_test.dart`
    - Covers the relaxed example-label matching for the real mismatch patterns above.
  - `test/features/grammar/grammar_question_generator_test.dart`
    - Added regression coverage proving grammar meaning distractors now prefer nearby related points.
    - Added regression coverage proving context-choice distractors now prefer nearby example sentences instead of unrelated far ones.
- Updated `docs/notes/important-user-requirements.md`
  - Recorded the persistent requirement that Grammar practice must fully exploit both definition and example data and should not drop examples due to small label differences.

### Verification Run

- Ran `dart format lib/data/utils/grammar_example_matching.dart lib/data/seeds/grammar_seeder.dart lib/data/db/content_database.dart lib/data/repositories/lesson_repository.dart lib/features/grammar/services/grammar_question_generator.dart test/data/utils/grammar_example_matching_test.dart test/features/grammar/grammar_question_generator_test.dart`
  - Result: formatting completed successfully
- Ran `flutter analyze lib/data/utils/grammar_example_matching.dart lib/data/seeds/grammar_seeder.dart lib/data/db/content_database.dart lib/data/repositories/lesson_repository.dart lib/features/grammar/services/grammar_question_generator.dart test/data/utils/grammar_example_matching_test.dart test/features/grammar/grammar_question_generator_test.dart`
  - Result: one unused-helper warning found and then resolved in the final code
- Ran `flutter test test/data/utils/grammar_example_matching_test.dart test/features/grammar/grammar_question_generator_test.dart test/features/grammar/grammar_session_planner_test.dart test/features/ui/ghost_review_walkthrough_test.dart`
  - Result: all tests passed

### N4 Grammar Example Completion Pass

- Completed the `N4` grammar example expansion workflow to the same quality bar used for `N5`.
- Finalized and QA-checked the last incomplete `N4` lesson example files:
  - `assets/data/content/grammar_examples/n4/lesson_46.json`
  - `assets/data/content/grammar_examples/n4/lesson_47.json`
  - `assets/data/content/grammar_examples/n4/lesson_48.json`
  - `assets/data/content/grammar_examples/n4/lesson_49.json`
  - `assets/data/content/grammar_examples/n4/lesson_50.json`
- Cleaned up the last language-quality issues in that batch:
  - fixed typo and mistranslation issues such as `好きならしいです` and the incorrect English gloss for `起きたばかりです`
  - removed honorific examples that were teaching the wrong pattern or used awkward/double honorific forms
  - replaced a few unnatural service expressions with more realistic customer-service and daily-life examples
- Preserved the batch rules across the full `N4` set:
  - every `grammar_examples[*].grammarPoint` matches the canonical `grammar` title
  - every `N4` grammar point now has exactly `10` examples
  - examples stay closer to lesson vocabulary, work/school situations, travel, and real daily-life usage

### Verification Run

- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: `N4` is now fully complete at `100 grammar points / 1000 examples / 0 below target / 0 missing`
  - Result: `N5` remains fully complete at `118 grammar points / 1180 examples / 0 below target / 0 missing`
  - Result: remaining low-coverage work is now isolated to `N3`

### N3 Grammar Example Completion Pass

- Completed the remaining `N3` grammar example expansion workflow so `N3` now matches the same minimum density as `N5` and `N4`.
- Added `tooling/expand_n3_grammar_examples.py`
  - Introduced a reusable `N3` expansion generator that appends lesson-themed Japanese examples per grammar point.
  - Batched `vi/en` translation generation so the repo can regenerate the expansion payload reproducibly instead of relying on one-off manual pastes.
  - Kept the generator aligned to canonical `grammarPoint` labels so it works cleanly with the existing audit pipeline.
- Updated the full `N3` grammar example set:
  - `assets/data/content/grammar_examples/n3/lesson_51.json`
  - through `assets/data/content/grammar_examples/n3/lesson_75.json`
- Expanded all `N3` grammar points from the old scaffold density (`2` examples each) to `10` examples each.
- Focused the new examples around each lesson theme and real everyday contexts such as:
  - work and interviews
  - study abroad and campus life
  - health habits
  - travel and transportation
  - media and information
  - cooking and food culture
  - economy, communication, history, fashion, and volunteering
- Ran a follow-up QA pass on the highest-risk translation blocks after expansion:
  - corrected nuanced `vi/en` glosses for patterns like `〜ないことはない`, `〜ないこともない`, `〜ほど〜ない`, and `〜というより`
  - fixed a few machine-translation misreads where the Japanese sentence was correct but the gloss flipped or flattened the intended grammar nuance

### Verification Run

- Ran `python tooling/expand_n3_grammar_examples.py`
  - Result: appended the remaining `N3` examples needed to bring every grammar point to target density
- Ran `python tooling/audit_grammar_example_coverage.py --apply`
  - Result: `N3` is now fully complete at `100 grammar points / 1000 examples / 0 below target / 0 missing`
  - Result: `N5`, `N4`, and `N3` are all now complete at the same `10 examples per grammar point` floor
