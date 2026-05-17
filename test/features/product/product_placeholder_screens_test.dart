import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/leaderboard/leaderboard_screen.dart';
import 'package:jpstudy/features/premium/premium_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
  ],
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
      find.text('Expanded group events and advanced practice tools'),
      findsOneWidget,
    );
  });

  testWidgets('LeaderboardScreen switches ranking range content', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
        ],
        child: const MaterialApp(home: LeaderboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ranking range'), findsOneWidget);
    expect(find.text('This week'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();

    expect(find.text('Friends mini ranking'), findsOneWidget);
    expect(find.text('Private'), findsAtLeastNWidgets(1));
  });

  testWidgets('LeaderboardScreen uses provider-backed learner stats', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
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
                xp: 0,
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
}
