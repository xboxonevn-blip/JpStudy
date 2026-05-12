import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/progress/providers/progress_coach_provider.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSummary = ProgressSummary(
  totalXp: 500,
  todayXp: 50,
  streak: 7,
  longestStreak: 14,
  totalDaysStudied: 30,
  totalAttempts: 20,
  totalCorrect: 160,
  totalQuestions: 200,
);

const _kBreakdown = SrsStageBreakdown(learning: 10, young: 25, mature: 65);
const _kDashboard = DashboardState(
  streak: 7,
  todayXp: 50,
  vocabDue: 3,
  grammarDue: 2,
  kanjiDue: 1,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

ProgressCoachBoard buildCoachBoard({
  String headline = 'Protect the queue first',
  String caption =
      'Progress says overdue reviews are the biggest source of drag right now.',
  ProgressCoachAction? primaryAction,
  List<ProgressCoachAction> quickActions = const <ProgressCoachAction>[],
  List<ProgressCoachSignal> signals = const <ProgressCoachSignal>[
    ProgressCoachSignal(
      id: 'consistency',
      label: 'Rhythm',
      value: '5/7',
      detail: 'You touched Japanese on most days this week.',
      icon: Icons.bolt_rounded,
      color: Color(0xFF16A34A),
    ),
    ProgressCoachSignal(
      id: 'retention',
      label: 'Retention',
      value: '35 fragile',
      detail: '65 mature cards are now doing the heavy lifting.',
      icon: Icons.stacked_bar_chart_rounded,
      color: Color(0xFF16A34A),
    ),
    ProgressCoachSignal(
      id: 'exam_trend',
      label: 'Exam trend',
      value: '85%',
      detail: 'Average across recent saved attempts.',
      icon: Icons.insights_rounded,
      color: Color(0xFFD97706),
    ),
  ],
  List<WeaknessRadarItem> recoveryItems = const <WeaknessRadarItem>[],
}) {
  return ProgressCoachBoard(
    headline: headline,
    caption: caption,
    primaryAction:
        primaryAction ??
        const ProgressCoachAction(
          id: 'due_reviews',
          title: 'Review 6 due items now',
          subtitle: '3 vocab · 2 grammar · 1 kanji are waiting in the queue.',
          ctaLabel: 'Start due session',
          route: AppRoutePath.grammarPractice,
          icon: Icons.schedule_rounded,
          color: Color(0xFF1D4ED8),
          badge: 'Due now',
        ),
    quickActions: quickActions,
    signals: signals,
    recoveryItems: recoveryItems,
  );
}

Widget buildProgressScreen({
  ProgressSummary summary = _kSummary,
  List<ReviewDaySummary> reviewHistory = const [],
  List<AttemptSummary> attemptHistory = const [],
  DashboardState dashboard = _kDashboard,
  ContinueAction continueAction = const ContinueAction(
    type: ContinueActionType.grammarReview,
    label: 'Review grammar',
    count: 2,
    data: <int>[1, 2],
  ),
  List<WeaknessRadarItem> weaknessItems = const [],
  AsyncValue<ProgressSummary>? summaryAsync,
  AsyncValue<List<ReviewDaySummary>>? reviewHistoryAsync,
  AsyncValue<List<AttemptSummary>>? attemptHistoryAsync,
  AsyncValue<SrsStageBreakdown>? retentionAsync,
  ProgressCoachBoard? coachBoard,
}) => ProviderScope(
  retry: (retryCount, error) => null,
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    progressSummaryProvider.overrideWith(
      (ref) async => summaryAsync?.requireValue ?? summary,
    ),
    reviewHistoryProvider.overrideWith(
      (ref) async => reviewHistoryAsync?.requireValue ?? reviewHistory,
    ),
    attemptHistoryProvider.overrideWith(
      (ref) async => attemptHistoryAsync?.requireValue ?? attemptHistory,
    ),
    srsRetentionProvider.overrideWith(
      (ref) async => retentionAsync?.requireValue ?? _kBreakdown,
    ),
    dashboardProvider.overrideWith((ref) => Stream.value(dashboard)),
    continueActionProvider.overrideWith((ref) async => continueAction),
    weaknessRadarProvider.overrideWith((ref) async => weaknessItems),
    masterySnapshotProvider.overrideWith(
      (ref) async => const MasterySnapshot(levels: []),
    ),
    progressCoachBoardProvider.overrideWith(
      (ref) async => coachBoard ?? buildCoachBoard(),
    ),
  ],
  child: const MaterialApp(home: ProgressScreen()),
);
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows AppBar title with level', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    expect(find.text('Progress (N5)'), findsWidgets);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows streak and today XP after data resolves', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('7'), findsWidgets);
    expect(find.text('50'), findsWidgets);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows 80% accuracy from 160/200', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('80%'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows 500 total XP value', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('500'), findsWidgets);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows empty review and attempt history states', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(AppLanguage.en.reviewHistoryEmptyLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.attemptHistoryEmptyLabel), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows SRS retention section summary', (tester) async {
    await tester.pumpWidget(buildProgressScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(AppLanguage.en.vocabularySrsTitle), findsOneWidget);
    expect(
      find.text(AppLanguage.en.itemsReviewedViaSrsLabel(_kBreakdown.total)),
      findsOneWidget,
    );
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('renders non-empty review history cards', (tester) async {
    await tester.pumpWidget(
      buildProgressScreen(
        reviewHistory: [
          ReviewDaySummary(
            day: DateTime(2026, 3, 10),
            reviewed: 12,
            again: 2,
            hard: 1,
            good: 6,
            easy: 3,
            xp: 0,
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.textContaining('12 reviews / Again 2 / Hard 1'),
      findsOneWidget,
    );
    expect(find.text('9/12'), findsOneWidget);
  });

  testWidgets('renders non-empty attempt history cards', (tester) async {
    await tester.pumpWidget(
      buildProgressScreen(
        attemptHistory: [
          AttemptSummary(
            id: 1,
            mode: 'test',
            level: 'N5',
            startedAt: DateTime(2026, 3, 10, 14, 30),
            finishedAt: DateTime(2026, 3, 10, 14, 45),
            score: 18,
            total: 20,
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('test / N5'), findsOneWidget);
    expect(find.text('18/20'), findsOneWidget);
  });

  testWidgets('shows coach board with due review primary action', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildProgressScreen(
        coachBoard: buildCoachBoard(
          quickActions: const [
            ProgressCoachAction(
              id: 'immersion',
              title: 'Do one immersion pass',
              subtitle: 'Read briefly and save unknown words.',
              ctaLabel: 'Open immersion',
              route: AppRoutePath.immersion,
              icon: Icons.article_rounded,
              color: Color(0xFF059669),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const ValueKey('progress_focus_headline')),
      findsOneWidget,
    );
    expect(find.text('Protect the queue first'), findsOneWidget);
    expect(find.text('Review 6 due items now'), findsOneWidget);
    expect(find.text('Start due session'), findsOneWidget);
  });

  testWidgets(
    'switches primary action to weakness repair when due queue is clear',
    (tester) async {
      await tester.pumpWidget(
        buildProgressScreen(
          coachBoard: buildCoachBoard(
            headline: 'Repair the weak spots',
            caption:
                'Your queue is manageable, so targeted repair gives the fastest lift.',
            primaryAction: const ProgressCoachAction(
              id: 'grammar_mistakes',
              title: 'Grammar slipping: 〜てしまう',
              subtitle: '2 grammar ghosts are still open.',
              ctaLabel: 'Drill now',
              route: AppRoutePath.grammarPractice,
              icon: Icons.auto_stories_rounded,
              color: Color(0xFF7C3AED),
              badge: 'Weak spot',
            ),
            recoveryItems: const [
              WeaknessRadarItem(
                id: 'grammar_mistakes',
                title: 'Grammar slipping: 〜てしまう',
                subtitle: '2 grammar ghosts are still open.',
                route: AppRoutePath.grammarPractice,
                icon: Icons.auto_stories_rounded,
                color: Color(0xFF7C3AED),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Repair the weak spots'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('progress_primary_action_title')),
        findsOneWidget,
      );
      expect(find.text('Grammar slipping: 〜てしまう'), findsWidgets);
      expect(find.text('Drill now'), findsWidgets);
    },
  );

  testWidgets('shows recent exam trend signal when attempt history exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildProgressScreen(
        coachBoard: buildCoachBoard(
          signals: const [
            ProgressCoachSignal(
              id: 'consistency',
              label: 'Rhythm',
              value: '5/7',
              detail: 'You touched Japanese on most days this week.',
              icon: Icons.bolt_rounded,
              color: Color(0xFF16A34A),
            ),
            ProgressCoachSignal(
              id: 'retention',
              label: 'Retention',
              value: '35 fragile',
              detail: '65 mature cards are now doing the heavy lifting.',
              icon: Icons.stacked_bar_chart_rounded,
              color: Color(0xFF16A34A),
            ),
            ProgressCoachSignal(
              id: 'exam_trend',
              label: 'Exam trend',
              value: '85%',
              detail: 'Average across recent saved attempts.',
              icon: Icons.insights_rounded,
              color: Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Exam trend'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('progress_signal_exam_trend')),
      findsOneWidget,
    );
    expect(find.text('85%'), findsWidgets);
  });

  testWidgets('shows load error when progress summary provider fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildProgressScreen(
        summaryAsync: AsyncValue.error(Exception('boom'), StackTrace.empty),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });

  testWidgets('shows load error when review history provider fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildProgressScreen(
        reviewHistoryAsync: AsyncValue.error(
          Exception('boom'),
          StackTrace.empty,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });

  testWidgets('shows load error when attempt history provider fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildProgressScreen(
        attemptHistoryAsync: AsyncValue.error(
          Exception('boom'),
          StackTrace.empty,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });
}
