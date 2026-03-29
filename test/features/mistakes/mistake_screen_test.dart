import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
<<<<<<< HEAD
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/db/database_provider.dart';
=======
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
>>>>>>> claude/confident-carson
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

<<<<<<< HEAD
Widget ProviderScope buildScreen(AppDatabase db, ContentDatabase cdb) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(cdb),
        mistakeRepositoryProvider.overrideWithValue(
          MistakeRepository(db.mistakeDao),
        ),
        lessonRepositoryProvider.overrideWithValue(
          LessonRepository(db, cdb),
=======
Widget _build(AppDatabase db) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        mistakeRepositoryProvider.overrideWithValue(
          MistakeRepository(db.mistakeDao),
        ),
        lessonRepositoryProvider.overrideWith(
          (ref) => LessonRepository(db, ref.watch(contentDatabaseProvider)),
>>>>>>> claude/confident-carson
        ),
      ],
      child: const MaterialApp(home: MistakeScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

<<<<<<< HEAD
  testWidgets('shows Mistake Bank app bar title', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db, cdb));
=======
  testWidgets('shows Mistake Bank AppBar title', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(_build(db));
>>>>>>> claude/confident-carson
    await tester.pump();
    expect(find.text('Mistake Bank'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
<<<<<<< HEAD
    await cdb.close();
  });

  testWidgets('shows empty state when no mistakes exist', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db, cdb));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
=======
  });

  testWidgets('shows empty state when no mistakes', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(_build(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
>>>>>>> claude/confident-carson
    expect(find.text('No mistakes yet'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
<<<<<<< HEAD
    await cdb.close();
=======
>>>>>>> claude/confident-carson
  });
}
