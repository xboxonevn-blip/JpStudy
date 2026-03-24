import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/daos/test_dao.dart';
import 'package:jpstudy/features/test/providers/test_providers.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';
import 'package:jpstudy/features/test/services/test_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildScreen(AppDatabase db) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        testHistoryServiceProvider.overrideWithValue(
          TestHistoryService(TestDao(db)),
        ),
      ],
      child: const MaterialApp(
        home: TestHistoryScreen(lessonId: 1, lessonTitle: 'Lesson 1'),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows attempt history app bar title with lesson name',
      (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    expect(find.text('Attempt history: Lesson 1'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('shows empty state when no history exists', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No attempts yet.'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });
}
