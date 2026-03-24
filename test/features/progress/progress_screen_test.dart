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

Widget buildProgressScreen() => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        progressSummaryProvider.overrideWith((ref) async => _kSummary),
        reviewHistoryProvider.overrideWith((ref) async => const []),
        attemptHistoryProvider.overrideWith((ref) async => const []),
        srsRetentionProvider.overrideWith((ref) async => _kBreakdown),
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
}
