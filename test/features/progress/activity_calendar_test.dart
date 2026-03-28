import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';
import 'package:jpstudy/features/progress/providers/review_forecast_provider.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';

void main() {
  group('_ActivityCalendar smoke tests', () {
    Widget buildSubject({int streak = 0}) {
      return ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguage.en,
          ),
          studyLevelProvider.overrideWith(
            (ref) => null,
          ),
          progressSummaryProvider.overrideWith(
            (_) async => ProgressSummary(
              totalXp: 0,
              todayXp: 0,
              streak: streak,
              longestStreak: streak,
              totalDaysStudied: streak,
              totalAttempts: 0,
              totalCorrect: 0,
              totalQuestions: 0,
            ),
          ),
          reviewHistoryProvider.overrideWith(
            (_) async => <ReviewDaySummary>[],
          ),
          activityCalendarProvider.overrideWith(
            (_) async => <ReviewDaySummary>[],
          ),
          attemptHistoryProvider.overrideWith(
            (_) async => <AttemptSummary>[],
          ),
          srsRetentionProvider.overrideWith(
            (_) async => const SrsStageBreakdown(
              learning: 0,
              young: 0,
              mature: 0,
            ),
          ),
          weaknessRadarProvider.overrideWith((_) async => const []),
          masterySnapshotProvider.overrideWith(
            (_) async => const MasterySnapshot(levels: []),
          ),
          reviewForecastProvider.overrideWith(
            (_) async => const ReviewForecast(
              days: [],
              stabilityBuckets: [],
              confidence: ConfidenceBreakdown(),
              totalTracked: 0,
              totalDueNow: 0,
              avgStability: 0,
            ),
          ),
        ],
        child: const MaterialApp(
          home: ProgressScreen(),
        ),
      );
    }

    testWidgets(
      'renders without crash with empty history and shows Activity title (EN)',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.text('Activity'), findsOneWidget);
      },
    );

    testWidgets(
      'shows streak count in bottom row for a 7-day streak',
      (tester) async {
        await tester.pumpWidget(buildSubject(streak: 7));
        await tester.pumpAndSettle();

        expect(find.text('7-day streak'), findsOneWidget);
      },
    );
  });
}
