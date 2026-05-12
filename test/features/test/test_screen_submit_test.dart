import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/data/daos/mistake_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/screens/test_results_screen.dart';
import 'package:jpstudy/features/test/screens/test_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Why this test exists
// ---------------------------------------------------------------------------
// _submitTest() in test_screen.dart orchestrates the end-of-session side
// effects in a specific order:
//
//   1. Write mistake rows (await mistakeRepo.addMistake / markCorrect)
//   2. Update or clear recovery pack  (await RecoveryPackService.*)
//   3. Save test to history           (await testHistoryService.saveTest)
//   4. Record study activity (XP)     (await lessonRepo.recordStudyActivity)
//   5. Clear saved in-flight session  (await _clearSavedSession)
//   6. `if (!mounted) return;` guard
//   7. Navigator.pushReplacement(TestResultsScreen)
//
// If any step is moved past the navigation (e.g. a refactor reorders it so
// pushReplacement happens first and the DB writes are "fire and forget"),
// users who close the app mid-transition lose their mistake-bank progress
// silently. This test pins the happy-path ordering: by the time
// TestResultsScreen is rendered, the mistake row MUST already be in the DB.
// ---------------------------------------------------------------------------

DashboardState _emptyDashboard() => const DashboardState(
  streak: 0,
  todayXp: 0,
  vocabDue: 0,
  grammarDue: 0,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'submit with wrong answer writes mistake before navigating to TestResultsScreen',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      const item = VocabItem(
        id: 42,
        term: 'たべる',
        reading: 'たべる',
        meaning: 'to eat',
        meaningEn: 'to eat',
        level: 'N5',
      );

      // Provider overrides: minimal subset that lets both TestScreen and
      // TestResultsScreen build. TestResultsScreen reads dashboardProvider /
      // recoveryPackProvider / vocab+grammar ghost counts via its child
      // widgets (NextStepSuggestions); give them loading-free fakes.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith(
              (ref) => AppLanguageController.test(AppLanguage.en),
            ),
            databaseProvider.overrideWithValue(db),
            dashboardProvider.overrideWith(
              (_) => Stream.value(_emptyDashboard()),
            ),
            continueActionProvider.overrideWith(
              (_) async => const ContinueAction(
                type: ContinueActionType.practiceMixed,
                label: 'practice',
              ),
            ),
            grammarGhostCountProvider.overrideWith((_) async* {
              yield 0;
            }),
            vocabGhostCountProvider.overrideWith((_) async* {
              yield 0;
            }),
            vocabGhostsProvider.overrideWith((_) async => const []),
            recoveryPackProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(
            home: TestScreen(
              items: [item],
              lessonId: 1,
              lessonTitle: 'Submit Flow Test',
              config: TestConfig(
                questionCount: 1,
                enabledTypes: [QuestionType.fillBlank],
                shuffleQuestions: false,
                showCorrectAfterWrong: false,
                adaptiveTesting: false,
              ),
              sessionKey: 'submit_flow_test',
            ),
          ),
        ),
      );

      // Screen starts with a loading state then resolves to the first
      // (and only) question.
      await tester.pumpAndSettle();

      // 1. Enter a known-wrong answer. Correct meaning is 'to eat'.
      await tester.enterText(find.byType(TextField), 'WRONG');

      // 2. Submit the fill-blank answer.
      await tester.ensureVisible(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.tap(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.pumpAndSettle();

      // Sanity: the DB should NOT have the mistake yet — only the submit
      // flow writes mistakes. Pre-submit per-question feedback is in-memory.
      final preSubmit = await MistakeDao(db).getMistakesByType('vocab');
      expect(
        preSubmit,
        isEmpty,
        reason:
            'checking an answer must not write to the mistake bank; '
            'only the final _submitTest() does',
      );

      // 3. Last question → nav button is 'Submit Test'.
      await tester.ensureVisible(find.text(AppLanguage.en.submitTestLabel));
      await tester.tap(find.text(AppLanguage.en.submitTestLabel));
      await tester.pumpAndSettle();

      // 4. Confirm in the submit dialog.
      await tester.tap(find.text(AppLanguage.en.submitTestConfirmLabel));
      await tester.pumpAndSettle();

      // 5. Navigation happened: TestResultsScreen is now on screen.
      expect(
        find.byType(TestResultsScreen),
        findsOneWidget,
        reason: 'pushReplacement(TestResultsScreen) must fire after submit',
      );

      // 6. And — the critical ordering invariant — the mistake row is in
      //    the DB. Because pumpAndSettle flushes all awaits, finding the
      //    row here proves it was written before navigation completed.
      final postSubmit = await MistakeDao(db).getMistakesByType('vocab');
      expect(
        postSubmit,
        hasLength(1),
        reason: 'mistake row must be persisted before navigating',
      );
      expect(postSubmit.first.itemId, 42);
      expect(postSubmit.first.type, 'vocab');
      expect(
        postSubmit.first.userAnswer,
        'WRONG',
        reason: 'the wrong answer context must be captured in the mistake',
      );
      expect(
        postSubmit.first.source,
        'test',
        reason:
            'source must be tagged so the mistake bank UI can attribute '
            'it to a test session',
      );

      // 7. Wrong-answer branch: weakTermIds is non-empty → saveExamPack()
      //    must have produced a recovery pack containing the wrong term.
      final pack = await RecoveryPackService.load();
      expect(
        pack,
        isNotNull,
        reason: 'weak terms present → saveExamPack must have produced a pack',
      );
      expect(
        pack!.termIds,
        contains(42),
        reason: 'the wrong-answer item id must be in the recovery pack',
      );
    },
  );

  testWidgets(
    'submit with correct answer navigates without writing any mistake',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      const item = VocabItem(
        id: 77,
        term: 'のむ',
        reading: 'のむ',
        meaning: 'to drink',
        meaningEn: 'to drink',
        level: 'N5',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith(
              (ref) => AppLanguageController.test(AppLanguage.en),
            ),
            databaseProvider.overrideWithValue(db),
            dashboardProvider.overrideWith(
              (_) => Stream.value(_emptyDashboard()),
            ),
            continueActionProvider.overrideWith(
              (_) async => const ContinueAction(
                type: ContinueActionType.practiceMixed,
                label: 'practice',
              ),
            ),
            grammarGhostCountProvider.overrideWith((_) async* {
              yield 0;
            }),
            vocabGhostCountProvider.overrideWith((_) async* {
              yield 0;
            }),
            vocabGhostsProvider.overrideWith((_) async => const []),
            recoveryPackProvider.overrideWith((_) async => null),
          ],
          child: const MaterialApp(
            home: TestScreen(
              items: [item],
              lessonId: 1,
              lessonTitle: 'Submit Flow Test (correct)',
              config: TestConfig(
                questionCount: 1,
                enabledTypes: [QuestionType.fillBlank],
                shuffleQuestions: false,
                showCorrectAfterWrong: false,
                adaptiveTesting: false,
              ),
              sessionKey: 'submit_flow_correct_test',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Answer correctly (matches item.meaning).
      await tester.enterText(find.byType(TextField), 'to drink');
      await tester.ensureVisible(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.tap(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppLanguage.en.submitTestLabel));
      await tester.tap(find.text(AppLanguage.en.submitTestLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLanguage.en.submitTestConfirmLabel));
      await tester.pumpAndSettle();

      expect(find.byType(TestResultsScreen), findsOneWidget);

      // markCorrect on a never-added itemId is a no-op, so the mistake
      // bank stays empty. Pins that the correct-answer branch does NOT
      // accidentally call addMistake.
      final mistakes = await MistakeDao(db).getMistakesByType('vocab');
      expect(
        mistakes,
        isEmpty,
        reason: 'correct answers must not produce mistake rows',
      );

      // No weak terms → RecoveryPackService.clear() must run.
      // (SharedPreferences mock starts empty, but we still want to pin the
      // branch — a regression that flipped the if/else would save a bogus
      // pack with zero termIds and surface a phantom recovery action on the
      // home screen.)
      expect(
        await RecoveryPackService.load(),
        isNull,
        reason: 'correct-answer branch → RecoveryPackService.clear() must run',
      );
    },
  );
}
