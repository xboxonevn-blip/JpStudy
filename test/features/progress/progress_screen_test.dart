import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';

void main() {
  testWidgets(
    'Progress screen renders desktop analytics layout with history panels',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime(2026, 3, 19, 9, 30);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
            progressSummaryProvider.overrideWith(
              (ref) async => const ProgressSummary(
                totalXp: 420,
                todayXp: 36,
                streak: 8,
                totalAttempts: 48,
                totalCorrect: 39,
                totalQuestions: 48,
              ),
            ),
            reviewHistoryProvider.overrideWith(
              (ref) async => [
                ReviewDaySummary(
                  day: DateTime(2026, 3, 18),
                  reviewed: 12,
                  again: 2,
                  hard: 3,
                  good: 5,
                  easy: 2,
                ),
              ],
            ),
            activityCalendarProvider.overrideWith(
              (ref) async => [
                ReviewDaySummary(
                  day: DateTime(2026, 3, 18),
                  reviewed: 12,
                  again: 2,
                  hard: 3,
                  good: 5,
                  easy: 2,
                ),
              ],
            ),
            attemptHistoryProvider.overrideWith(
              (ref) async => [
                AttemptSummary(
                  id: 1,
                  mode: 'Grammar',
                  level: 'N5',
                  startedAt: now,
                  finishedAt: now.add(const Duration(minutes: 8)),
                  score: 8,
                  total: 10,
                ),
              ],
            ),
            srsRetentionProvider.overrideWith(
              (ref) async =>
                  const SrsStageBreakdown(learning: 4, young: 7, mature: 9),
            ),
            weaknessRadarProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Progress (N5)'), findsAtLeastNWidgets(1));
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Review history'), findsOneWidget);
      expect(find.text('Attempt history'), findsOneWidget);
      expect(find.text('Words SRS'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('8-day streak'), findsOneWidget);
    },
  );
}
