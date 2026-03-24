import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/achievements/achievements_screen.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart'
    show dashboardProvider, DashboardState;
import 'package:shared_preferences/shared_preferences.dart';

const _kEmptyDashboard = DashboardState(
  streak: 0,
  todayXp: 0,
  vocabDue: 0,
  grammarDue: 0,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

Widget buildAchievementsScreen(AppDatabase db) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        dashboardProvider.overrideWith(
          (ref) => Stream.value(_kEmptyDashboard),
        ),
      ],
      child: const MaterialApp(home: AchievementsScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows AppBar title "Awards"', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());

    await tester.pumpWidget(buildAchievementsScreen(db));
    await tester.pump();

    expect(find.text('Awards'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('shows loading indicator before data resolves', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());

    await tester.pumpWidget(buildAchievementsScreen(db));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });
}
