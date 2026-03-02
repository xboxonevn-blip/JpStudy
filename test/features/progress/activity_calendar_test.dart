import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
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
