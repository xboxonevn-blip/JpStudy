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
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMistakeLessonRepository extends LessonRepository {
  FakeMistakeLessonRepository(
    super.db,
    super.contentDb, {
    this.kanjiById = const {},
    this.kanjiByLevel = const {},
  });

  final Map<int, KanjiItem> kanjiById;
  final Map<String, List<KanjiItem>> kanjiByLevel;

  @override
  Future<List<KanjiItem>> fetchKanjiByIds(List<int> ids) async => [
    for (final id in ids)
      if (kanjiById[id] != null) kanjiById[id]!,
  ];

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async =>
      kanjiByLevel[level] ?? const [];
}

KanjiItem _kanji(
  int id,
  String character, {
  required String jlptLevel,
  int lessonId = 1,
}) => KanjiItem(
  id: id,
  lessonId: lessonId,
  character: character,
  strokeCount: 4,
  meaning: 'meaning $character',
  meaningEn: 'meaning $character',
  onyomi: '',
  kunyomi: '',
  examples: const [],
  jlptLevel: jlptLevel,
);

Widget buildScreen(
  AppDatabase db,
  ContentDatabase cdb, {
  LessonRepository? repo,
  StudyLevel? level,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith((ref) => AppLanguage.en),
    studyLevelProvider.overrideWith((ref) => level),
    databaseProvider.overrideWithValue(db),
    contentDatabaseProvider.overrideWithValue(cdb),
    mistakeRepositoryProvider.overrideWithValue(
      MistakeRepository(db.mistakeDao),
    ),
    lessonRepositoryProvider.overrideWithValue(
      repo ?? LessonRepository(db, cdb),
    ),
  ],
  child: const MaterialApp(home: MistakeScreen()),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Mistake Bank app bar title', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db, cdb));
    await tester.pump();
    expect(find.text('Mistake Bank'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('shows empty state when no mistakes exist', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(db, cdb));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No mistakes yet'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('same-level kanji mistakes open the typed handwriting session', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final item = _kanji(1, '日', jlptLevel: 'N5');
    final repo = FakeMistakeLessonRepository(
      db,
      cdb,
      kanjiById: {item.id: item},
      kanjiByLevel: {
        'N5': [item],
      },
    );

    await db.mistakeDao.addMistake('kanji', item.id);

    await tester.pumpWidget(buildScreen(db, cdb, repo: repo, level: null));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Practice Kanji (1)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final screen = tester.widget<HandwritingPracticeScreen>(
      find.byType(HandwritingPracticeScreen),
    );
    expect(screen.lessonTitle, 'N5 — Handwriting');
    expect(screen.includeCompoundWords, isFalse);
    expect(screen.items.map((item) => item.id).toList(), [1]);
    expect(find.text('Choose study level'), findsNothing);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets(
    'mixed-level kanji mistakes keep the direct handwriting fallback',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      final cdb = ContentDatabase(executor: NativeDatabase.memory());
      final first = _kanji(1, '日', jlptLevel: 'N5');
      final second = _kanji(2, '語', jlptLevel: 'N4');
      final repo = FakeMistakeLessonRepository(
        db,
        cdb,
        kanjiById: {first.id: first, second.id: second},
      );

      await db.mistakeDao.addMistake('kanji', first.id);
      await db.mistakeDao.addMistake('kanji', second.id);

      await tester.pumpWidget(buildScreen(db, cdb, repo: repo, level: null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Practice Kanji (2)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(screen.lessonTitle, AppLanguage.en.ghostKanjiTitle);
      expect(screen.includeCompoundWords, isFalse);
      expect(
        screen.items.map((item) => item.id).toList(),
        unorderedEquals([1, 2]),
      );

      await tester.pumpWidget(Container());
      await tester.pump(const Duration(milliseconds: 100));
      await db.close();
      await cdb.close();
    },
  );
}
