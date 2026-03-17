import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/grammar/screens/grammar_detail_screen.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:jpstudy/features/practice/screens/recall_sprint_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';

import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LearningPathScreen shows a single primary CTA hero', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 5,
                todayXp: 12,
                vocabDue: 3,
                grammarDue: 2,
                kanjiDue: 1,
                vocabMistakeCount: 0,
                grammarMistakeCount: 1,
                kanjiMistakeCount: 0,
                totalMistakeCount: 1,
              ),
            ),
          ),
          continueActionProvider.overrideWith(
            (ref) => Stream.value(
              const ContinueAction(
                type: ContinueActionType.vocabReview,
                label: 'Review vocab',
                count: 3,
              ),
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (ref) async => DailySessionProgress.empty('2026-03-17'),
          ),
          backupStatusProvider.overrideWith(
            (ref) async =>
                const BackupStatus(enabled: false, lastBackupAt: null),
          ),
        ],
        child: const MaterialApp(home: LearningPathScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Review vocab'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('JLPT coach'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start session'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'JLPT coach'), findsOneWidget);
    expect(find.text('Clear the review queue first'), findsOneWidget);
  });

  testWidgets('AppRouter opens the Recall Sprint route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          onboardingDoneProvider.overrideWith((ref) => true),
          appInitProvider.overrideWith((ref) async {}),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 0,
                todayXp: 0,
                vocabDue: 3,
                grammarDue: 2,
                kanjiDue: 1,
                vocabMistakeCount: 0,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 0,
              ),
            ),
          ),
          continueActionProvider.overrideWith(
            (ref) => Stream.value(
              const ContinueAction(
                type: ContinueActionType.practiceMixed,
                label: 'practice',
              ),
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (ref) async => DailySessionProgress.empty('2026-03-17'),
          ),
          backupStatusProvider.overrideWith(
            (ref) async =>
                const BackupStatus(enabled: false, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );

    AppRouter.router.go('/practice/recall-sprint');
    await tester.pumpAndSettle();

    expect(find.text('Recall Sprint'), findsWidgets);
  });

  testWidgets('PracticeScreen uses goal-based study layout', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 2,
                todayXp: 0,
                vocabDue: 4,
                grammarDue: 0,
                kanjiDue: 0,
                vocabMistakeCount: 1,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 1,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: PracticeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Study'), findsAtLeastNWidgets(1));
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Due review'), findsOneWidget);
    expect(find.text('Fix weak points'), findsOneWidget);
    expect(find.text('Build speed'), findsOneWidget);
    expect(find.text('Mock exam'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets(
    'PracticeScreen surfaces Recall Sprint when review items are waiting',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
            dashboardProvider.overrideWith(
              (ref) => Stream.value(
                const DashboardState(
                  streak: 2,
                  todayXp: 0,
                  vocabDue: 3,
                  grammarDue: 2,
                  kanjiDue: 1,
                  vocabMistakeCount: 0,
                  grammarMistakeCount: 0,
                  kanjiMistakeCount: 0,
                  totalMistakeCount: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: PracticeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Recall Sprint'), findsAtLeastNWidgets(1));
      expect(
        find.text(
          'Mixed grammar, vocab, and kanji in one quick retry-first session.',
        ),
        findsAtLeastNWidgets(1),
      );
    },
  );

  testWidgets('RecallSprintScreen shows a start CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: RecallSprintScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(JapaneseBackground), findsOneWidget);
    expect(find.text('Recall Sprint'), findsWidgets);
    expect(find.text('Start sprint'), findsOneWidget);
  });

  testWidgets(
    'RecallSprintScreen starts a session when tapping the start CTA',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          ],
          child: const MaterialApp(home: RecallSprintScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Start sprint'));
      await tester.pumpAndSettle();

      expect(find.text('Start sprint'), findsNothing);
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Warm up your mixed recall run.'), findsOneWidget);
    },
  );

  testWidgets(
    'RecallSprintScreen shows the first question card after starting',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          ],
          child: const MaterialApp(home: RecallSprintScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Start sprint'));
      await tester.pumpAndSettle();

      expect(find.text('Choose the best meaning for 食べる.'), findsOneWidget);
      expect(find.text('to eat'), findsOneWidget);
      expect(find.text('to drink'), findsOneWidget);
      expect(find.text('to read'), findsOneWidget);
      expect(find.text('to sleep'), findsOneWidget);
    },
  );

  testWidgets(
    'RecallSprintScreen shows immediate feedback for a wrong answer',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          ],
          child: const MaterialApp(home: RecallSprintScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Start sprint'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('to drink'));
      await tester.pumpAndSettle();

      expect(find.text('Not quite'), findsOneWidget);
      expect(find.text('食べる means to eat.'), findsOneWidget);
    },
  );

  testWidgets(
    'RecallSprintScreen shows positive feedback for a correct answer',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          ],
          child: const MaterialApp(home: RecallSprintScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Start sprint'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('to eat'));
      await tester.pumpAndSettle();

      expect(find.text('Nice'), findsOneWidget);
      expect(find.text('That is the right meaning.'), findsOneWidget);
    },
  );

  testWidgets('RecallSprintScreen shows a Next CTA after answering', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: RecallSprintScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Start sprint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('to eat'));
    await tester.pumpAndSettle();

    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('RecallSprintScreen advances to question two when tapping Next', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: RecallSprintScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Start sprint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('to eat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 5'), findsOneWidget);
    expect(find.text('Choose the best meaning for 飲む.'), findsOneWidget);
    expect(find.text('to drink'), findsOneWidget);
  });

  testWidgets('RecallSprintScreen replays a missed question in a retry pass', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: RecallSprintScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Start sprint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('to drink'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('to drink'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Retry 1 of 1'), findsOneWidget);
    expect(find.text('Choose the best meaning for 食べる.'), findsOneWidget);
  });

  testWidgets(
    'RecallSprintScreen shows completion state after finishing retry pass',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          ],
          child: const MaterialApp(home: RecallSprintScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Start sprint'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('to drink'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('to drink'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('to eat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Sprint complete'), findsOneWidget);
      expect(find.text('Nice run.'), findsOneWidget);
      expect(find.text('Run again'), findsOneWidget);
      expect(find.text('Choose the best meaning for 食べる.'), findsNothing);
    },
  );

  testWidgets('RecallSprintScreen can restart after completion', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: RecallSprintScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Start sprint'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('to eat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('to drink'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Sprint complete'), findsOneWidget);
    await tester.tap(find.text('Run again'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 5'), findsOneWidget);
    expect(find.text('Choose the best meaning for 食べる.'), findsOneWidget);
  });

  testWidgets('SearchScreen keeps search as utility screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          searchIndexProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: SearchScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('MeScreen shows compact profile hero', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        ],
        child: const MaterialApp(home: MeScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ChoiceChip), findsWidgets);
  });

  testWidgets('LibraryScreen shows compact library hierarchy', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          lessonMetaProvider('N5').overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: LibraryScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Library'), findsAtLeastNWidgets(1));
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
  });

  testWidgets('GrammarDetailScreen shows hero and no FAB', (tester) async {
    const point = GrammarPoint(
      id: 1,
      lessonId: 1,
      grammarPoint: '〜てしまう',
      titleEn: null,
      meaning: 'lỡ, xong mất',
      meaningVi: 'lỡ, xong mất',
      meaningEn: 'end up; finish completely',
      connection: 'Vて + しまう',
      connectionEn: 'V-te + shimau',
      explanation: 'Diễn tả hoàn thành hoặc tiếc nuối.',
      explanationVi: 'Diễn tả hoàn thành hoặc tiếc nuối.',
      explanationEn: 'Shows completion or regret.',
      jlptLevel: 'N4',
      isLearned: false,
    );
    const example = GrammarExample(
      id: 1,
      grammarId: 1,
      japanese: '宿題を忘れてしまった。',
      translation: 'Tôi lỡ quên bài tập rồi.',
      translationVi: 'Tôi lỡ quên bài tập rồi.',
      translationEn: 'I ended up forgetting my homework.',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          grammarDetailProvider(1).overrideWith(
            (ref) async => (point: point, examples: const [example]),
          ),
        ],
        child: const MaterialApp(home: GrammarDetailScreen(grammarId: 1)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('〜てしまう'), findsOneWidget);
    expect(find.text('Mark done'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('TermReviewScreen starts with compact preview hero', (
    tester,
  ) async {
    const dueTerm = UserLessonTermData(
      id: 1,
      lessonId: 1,
      term: '準備',
      reading: 'じゅんび',
      definition: 'chuẩn bị',
      definitionEn: 'preparation',
      mnemonicVi: '',
      mnemonicEn: '',
      kanjiMeaning: '',
      isStarred: false,
      isLearned: true,
      orderIndex: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          allDueTermsProvider.overrideWith((ref) async => const [dueTerm]),
        ],
        child: const MaterialApp(home: TermReviewScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Review now'), findsAtLeastNWidgets(1));
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
