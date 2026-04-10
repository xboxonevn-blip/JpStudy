import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/community/community_screen.dart';
import 'package:jpstudy/features/custom_decks/custom_decks_screen.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/leaderboard/leaderboard_screen.dart';
import 'package:jpstudy/features/premium/premium_screen.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_board_provider.dart';

Widget _wrap(Widget child) => ProviderScope(
  overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
  child: MaterialApp(home: child),
);

void main() {
  testWidgets('PremiumScreen switches selected plan details', (tester) async {
    await tester.pumpWidget(_wrap(const PremiumScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Choose a plan'), findsOneWidget);
    expect(find.text('49.00 / year'), findsOneWidget);

    await tester.tap(find.text('Coach'));
    await tester.pumpAndSettle();

    expect(find.text('79.00 / year'), findsOneWidget);
    expect(
      find.text('Expanded community events and advanced labs'),
      findsOneWidget,
    );
  });

  testWidgets('LeaderboardScreen switches ranking range content', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(home: LeaderboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ranking range'), findsOneWidget);
    expect(find.text('This week'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(find.text('Friends mini ladder'), findsOneWidget);
    expect(find.text('Private'), findsAtLeastNWidgets(1));
  });

  testWidgets('LeaderboardScreen uses provider-backed learner stats', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 9,
                todayXp: 30,
                vocabDue: 4,
                grammarDue: 2,
                kanjiDue: 1,
                vocabMistakeCount: 1,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 1,
              ),
            ),
          ),
          progressSummaryProvider.overrideWith(
            (ref) async => const ProgressSummary(
              totalXp: 18000,
              todayXp: 30,
              streak: 9,
              longestStreak: 9,
              totalDaysStudied: 9,
              totalAttempts: 12,
              totalCorrect: 88,
              totalQuestions: 100,
            ),
          ),
          reviewHistoryProvider.overrideWith(
            (ref) async => [
              ReviewDaySummary(
                day: DateTime(2026, 3, 20),
                reviewed: 17,
                again: 2,
                hard: 3,
                good: 8,
                easy: 4,
              ),
            ],
          ),
          attemptHistoryProvider.overrideWith(
            (ref) async => [
              AttemptSummary(
                id: 1,
                mode: 'Grammar',
                level: 'N5',
                startedAt: DateTime(2026, 3, 20, 9),
                finishedAt: DateTime(2026, 3, 20, 9, 10),
                score: 9,
                total: 10,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: LeaderboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('17'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.textContaining('17 reviewed'), findsOneWidget);
  });

  testWidgets('CustomDecksScreen switches study recipe content', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CustomDecksScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Study recipes'), findsOneWidget);
    expect(find.text('18 min'), findsOneWidget);

    await tester.tap(find.text('Mixed sprint'));
    await tester.pumpAndSettle();

    expect(find.text('22 min'), findsOneWidget);
    expect(find.text('18 high-frequency prompts.'), findsOneWidget);
  });

  testWidgets('CustomDecksScreen uses study hub and continue data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyHubDecksProvider.overrideWith(
            (ref) async => const StudyHubDecksBoard(
              nextUp: StudyHubLessonDeck(
                id: 3,
                title: 'Lesson 3',
                progressPercent: 64,
                dueCount: 5,
                isFinished: false,
              ),
              activeDecks: [
                StudyHubLessonDeck(
                  id: 5,
                  title: 'Lesson 5',
                  progressPercent: 30,
                  dueCount: 2,
                  isFinished: false,
                ),
              ],
              completedDecks: [
                StudyHubLessonDeck(
                  id: 1,
                  title: 'Lesson 1',
                  progressPercent: 100,
                  dueCount: 0,
                  isFinished: true,
                ),
              ],
            ),
          ),
          continueActionProvider.overrideWith(
            (ref) async => const ContinueAction(
              type: ContinueActionType.vocabReview,
              label: 'Review vocab',
              count: 7,
            ),
          ),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 4,
                todayXp: 12,
                vocabDue: 7,
                grammarDue: 3,
                kanjiDue: 2,
                vocabMistakeCount: 1,
                grammarMistakeCount: 2,
                kanjiMistakeCount: 0,
                totalMistakeCount: 3,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: CustomDecksScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Lesson 3'), findsAtLeastNWidgets(1));
    expect(
      find.textContaining('7 items need quick attention.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('1 active deck available right now.'),
      findsOneWidget,
    );
  });

  testWidgets('CommunityScreen routes profile and data shortcuts', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/community',
      routes: [
        GoRoute(
          path: '/community',
          builder: (context, state) => ProviderScope(
            overrides: [
              appLanguageProvider.overrideWith((ref) => AppLanguage.en),
            ],
            child: const CommunityScreen(),
          ),
        ),
        GoRoute(
          name: 'me',
          path: '/me',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('ME'))),
        ),
        GoRoute(
          name: 'me-data',
          path: '/me/data',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('DATA'))),
        ),
        GoRoute(
          path: '/design-lab',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('LAB'))),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Core shortcuts'), findsOneWidget);

    await tester.tap(find.text('Open profile'));
    await tester.pumpAndSettle();
    expect(find.text('ME'), findsOneWidget);

    router.go('/community');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Data tools'));
    await tester.pumpAndSettle();
    expect(find.text('DATA'), findsOneWidget);
  });
}
