import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  DashboardState buildDashboard({
    int vocabDue = 0,
    int grammarDue = 0,
    int kanjiDue = 0,
    int mistakes = 0,
  }) {
    return DashboardState(
      streak: 0,
      todayXp: 0,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
      vocabMistakeCount: 0,
      grammarMistakeCount: 0,
      kanjiMistakeCount: mistakes,
      totalMistakeCount: mistakes,
    );
  }

  GoRouter buildRouter() {
    Widget marker(String route) =>
        Scaffold(body: Center(child: Text('route:$route')));
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: DailySessionCard()),
        ),
        GoRoute(
          path: '/grammar',
          builder: (context, state) => marker('/grammar'),
        ),
        GoRoute(
          path: '/vocab/review',
          builder: (context, state) => marker('/vocab/review'),
        ),
        GoRoute(
          path: '/kanji/practice',
          builder: (context, state) => marker('/kanji/practice'),
        ),
        GoRoute(
          path: '/mistakes',
          builder: (context, state) => marker('/mistakes'),
        ),
        GoRoute(
          path: '/immersion',
          builder: (context, state) => marker('/immersion'),
        ),
        GoRoute(
          path: '/grammar-practice',
          builder: (context, state) => marker('/grammar-practice'),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (context, state) =>
              marker('/lesson/${state.pathParameters['id']}'),
        ),
      ],
    );
  }

  testWidgets('Daily session routes to due review first', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith(
            (_) => Stream.value(buildDashboard(grammarDue: 3)),
          ),
          grammarGhostCountProvider.overrideWith((_) async => 0),
          vocabGhostCountProvider.overrideWith((_) async => 0),
          nextVocabReviewProvider.overrideWith((_) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((_) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((_) => Stream.value(null)),
          weekSummaryProvider.overrideWith(
            (_) async => const WeekSummary(
              totalReviewed: 0,
              accuracy: 0,
              daysStudied: 0,
            ),
          ),
          continueActionProvider.overrideWith(
            (_) async => ContinueAction(
              type: ContinueActionType.grammarReview,
              label: 'grammar',
              count: 3,
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (_) async => DailySessionProgress.empty('2026-02-22'),
          ),
          backupStatusProvider.overrideWith(
            (_) async => const BackupStatus(enabled: true, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily_session_cta')));
    await tester.pumpAndSettle();
    expect(find.text('route:/grammar'), findsOneWidget);
  });

  testWidgets('Daily session routes to ghost step when no due', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith((_) => Stream.value(buildDashboard())),
          grammarGhostCountProvider.overrideWith((_) async => 2),
          vocabGhostCountProvider.overrideWith((_) async => 0),
          nextVocabReviewProvider.overrideWith((_) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((_) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((_) => Stream.value(null)),
          weekSummaryProvider.overrideWith(
            (_) async => const WeekSummary(
              totalReviewed: 0,
              accuracy: 0,
              daysStudied: 0,
            ),
          ),
          continueActionProvider.overrideWith(
            (_) async => const ContinueAction(
              type: ContinueActionType.practiceMixed,
              label: 'practice',
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (_) async => DailySessionProgress.empty('2026-02-22'),
          ),
          backupStatusProvider.overrideWith(
            (_) async => const BackupStatus(enabled: true, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily_session_cta')));
    await tester.pumpAndSettle();
    expect(find.text('route:/grammar-practice'), findsOneWidget);
  });

  testWidgets('Daily session routes vocab due work to vocab review session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith(
            (_) => Stream.value(buildDashboard(vocabDue: 4)),
          ),
          grammarGhostCountProvider.overrideWith((_) async => 0),
          vocabGhostCountProvider.overrideWith((_) async => 0),
          nextVocabReviewProvider.overrideWith((_) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((_) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((_) => Stream.value(null)),
          weekSummaryProvider.overrideWith(
            (_) async => const WeekSummary(
              totalReviewed: 0,
              accuracy: 0,
              daysStudied: 0,
            ),
          ),
          continueActionProvider.overrideWith(
            (_) async => const ContinueAction(
              type: ContinueActionType.vocabReview,
              label: 'review vocab',
              count: 4,
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (_) async => DailySessionProgress.empty('2026-02-22'),
          ),
          backupStatusProvider.overrideWith(
            (_) async => const BackupStatus(enabled: true, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily_session_cta')));
    await tester.pumpAndSettle();
    expect(find.text('route:/vocab/review'), findsOneWidget);
  });

  testWidgets('Daily session routes kanji due work to kanji practice hub', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith(
            (_) => Stream.value(buildDashboard(kanjiDue: 2)),
          ),
          grammarGhostCountProvider.overrideWith((_) async => 0),
          vocabGhostCountProvider.overrideWith((_) async => 0),
          nextVocabReviewProvider.overrideWith((_) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((_) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((_) => Stream.value(null)),
          weekSummaryProvider.overrideWith(
            (_) async => const WeekSummary(
              totalReviewed: 0,
              accuracy: 0,
              daysStudied: 0,
            ),
          ),
          continueActionProvider.overrideWith(
            (_) async => const ContinueAction(
              type: ContinueActionType.kanjiReview,
              label: 'review kanji',
              count: 2,
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (_) async => DailySessionProgress.empty('2026-02-22'),
          ),
          backupStatusProvider.overrideWith(
            (_) async => const BackupStatus(enabled: true, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily_session_cta')));
    await tester.pumpAndSettle();
    expect(find.text('route:/kanji/practice'), findsOneWidget);
  });

  testWidgets('Daily session resumes stored route when in progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith((_) => Stream.value(buildDashboard())),
          grammarGhostCountProvider.overrideWith((_) async => 0),
          vocabGhostCountProvider.overrideWith((_) async => 0),
          nextVocabReviewProvider.overrideWith((_) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((_) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((_) => Stream.value(null)),
          weekSummaryProvider.overrideWith(
            (_) async => const WeekSummary(
              totalReviewed: 0,
              accuracy: 0,
              daysStudied: 0,
            ),
          ),
          continueActionProvider.overrideWith(
            (_) async => const ContinueAction(
              type: ContinueActionType.practiceMixed,
              label: 'practice',
            ),
          ),
          dailySessionProgressProvider.overrideWith(
            (_) async => DailySessionProgress(
              dateKey: '2026-02-22',
              started: true,
              doneSteps: const <int>{1, 2},
              lastRoute: '/mistakes',
              updatedAt: DateTime(2026, 2, 22, 8, 0),
            ),
          ),
          backupStatusProvider.overrideWith(
            (_) async => const BackupStatus(enabled: true, lastBackupAt: null),
          ),
        ],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily_session_cta')));
    await tester.pumpAndSettle();
    expect(find.text('route:/mistakes'), findsOneWidget);
  });
}
