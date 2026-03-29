import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart'
    show dashboardProvider, DashboardState;
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDashboard = DashboardState(
  streak: 3,
  todayXp: 50,
  vocabDue: 5,
  grammarDue: 2,
  kanjiDue: 1,
  vocabMistakeCount: 2,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 2,
);

Widget _build({StudyLevel level = StudyLevel.n5}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => level),
        dashboardProvider.overrideWith(
          (ref) => Stream.value(_kDashboard),
        ),
      ],
      child: const MaterialApp(home: PracticeScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Study AppBar title', (tester) async {
    await tester.pumpWidget(_build());
    await tester.pump();
    expect(find.text('Study'), findsOneWidget);
  });

  testWidgets('shows search icon in AppBar', (tester) async {
    await tester.pumpWidget(_build());
    await tester.pump();
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  testWidgets('renders without error for N4 level', (tester) async {
    await tester.pumpWidget(_build(level: StudyLevel.n4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Study'), findsOneWidget);
  });
}
