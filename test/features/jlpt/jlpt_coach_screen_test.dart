import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart'
    show dashboardProvider, DashboardState;
import 'package:jpstudy/features/jlpt/screens/jlpt_coach_screen.dart';
import 'package:jpstudy/features/jlpt/services/jlpt_coach_service.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDashboard = DashboardState(
  streak: 0,
  todayXp: 0,
  vocabDue: 4,
  grammarDue: 2,
  kanjiDue: 1,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

const _kOverview = JlptPrepOverview(
  quickMockQuestionCount: 20,
  readingPassageCount: 3,
  readingQuestionCount: 12,
  fullMockQuestionCount: 60,
  fullMockMinutes: 95,
  fullMockSectionCount: 4,
);

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const JlptCoachScreen()),
    GoRoute(path: '/jlpt/mock-pro', builder: (_, _) => const Scaffold()),
    GoRoute(path: '/jlpt/reading', builder: (_, _) => const Scaffold()),
  ],
);

Widget buildCoach(AppDatabase db) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith((ref) => AppLanguage.en),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    dashboardProvider.overrideWith((ref) => Stream.value(_kDashboard)),
    jlptCoachSnapshotProvider.overrideWith((ref) async => null),
    jlptPrepOverviewProvider(
      StudyLevel.n5,
    ).overrideWith((ref) async => _kOverview),
    mistakeRepositoryProvider.overrideWithValue(
      MistakeRepository(db.mistakeDao),
    ),
  ],
  child: MaterialApp.router(routerConfig: _router),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows JLPT Prep app bar title', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildCoach(db));
    await tester.pump();
    expect(find.text('JLPT Prep'), findsWidgets);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('shows JLPT N5 prep hub hero title', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildCoach(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('JLPT N5 prep hub'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('shows full mock and reading CTA labels', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildCoach(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('mock'), findsWidgets);
    expect(find.textContaining('Reading'), findsWidgets);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });
}
