import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMockLessonRepository extends LessonRepository {
  FakeMockLessonRepository(
    super.db,
    super.contentDb, {
    required this.itemsByLevel,
  });

  final Map<String, List<VocabItem>> itemsByLevel;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    return itemsByLevel[level] ?? const [];
  }
}

Widget buildScreen({StudyLevel? level, LessonRepository? repo}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => level),
        if (repo != null) lessonRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: HomeMockExamScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows mock exam title and level prompt when level is not selected',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Mock Exam'), findsOneWidget);
    expect(find.text('Select JLPT level'), findsOneWidget);
  });

  testWidgets('shows JLPT mock exam title for selected level', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': []},
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JLPT N5 Mock Exam'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('shows empty state when no vocab exists for selected level',
      (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': []},
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No terms available for this lesson.'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });
}
