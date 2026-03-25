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
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSummary = ProgressSummary(
  totalXp: 500,
  todayXp: 50,
  streak: 7,
  totalAttempts: 20,
  totalCorrect: 160,
  totalQuestions: 200,
);

const _kBreakdown = SrsStageBreakdown(learning: 10, young: 25, mature: 65);

Widget buildProgressScreen({
  ProgressSummary summary = _kSummary,
  List<ReviewDaySummary> reviewHistory = const [],
  List<AttemptSummary> attemptHistory = const [],
  AsyncValue<ProgressSummary>? summaryAsync,
  AsyncValue<List<ReviewDaySummary>>? reviewHistoryAsync,
  AsyncValue<List<AttemptSummary>>? attemptHistoryAsync,
  AsyncValue<SrsStageBreakdown>? retentionAsync,
}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        progressSummaryProvider.overrideWith((ref) async => summaryAsync?.value ?? summary),
        reviewHistoryProvider.overrideWith((ref) async => reviewHistoryAsync?.value ?? reviewHistory),
        attemptHistoryProvider.overrideWith((ref) async => attemptHistoryAsync?.value ?? attemptHistory),
        srsRetentionProvider.overrideWith((ref) async => retentionAsync?.value ?? _kBreakdown),
        weaknessRadarProvider.overrideWith((ref) async => const []),
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
    expect(find.text(AppLanguage.en.itemsReviewedViaSrsLabel(_kBreakdown.total)), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('renders non-empty review history cards', (tester) async {
    await tester.pumpWidget(buildProgressScreen(
      reviewHistory: [
        ReviewDaySummary(
          day: DateTime(2026, 3, 10),
          reviewed: 12,
          again: 2,
          hard: 1,
          good: 6,
          easy: 3,
        ),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('12 reviews / Again 2 / Hard 1'), findsOneWidget);
    expect(find.text('9/12'), findsOneWidget);
  });

  testWidgets('renders non-empty attempt history cards', (tester) async {
    await tester.pumpWidget(buildProgressScreen(
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
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('test / N5'), findsOneWidget);
    expect(find.text('18/20'), findsOneWidget);
  });

  testWidgets('shows load error when progress summary provider fails', (tester) async {
    await tester.pumpWidget(buildProgressScreen(
      summaryAsync: AsyncValue.error(Exception('boom'), StackTrace.empty),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });

  testWidgets('shows load error when review history provider fails', (tester) async {
    await tester.pumpWidget(buildProgressScreen(
      reviewHistoryAsync: AsyncValue.error(Exception('boom'), StackTrace.empty),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });

  testWidgets('shows load error when attempt history provider fails', (tester) async {
    await tester.pumpWidget(buildProgressScreen(
      attemptHistoryAsync: AsyncValue.error(Exception('boom'), StackTrace.empty),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });
}
