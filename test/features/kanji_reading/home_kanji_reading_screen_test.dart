import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/kanji_reading/providers/kanji_reading_providers.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

KanjiItem _kanji(int id, String character) => KanjiItem(
  id: id,
  lessonId: 1,
  character: character,
  strokeCount: 2,
  onyomi: 'on_$character',
  kunyomi: 'kun_$character',
  meaning: 'meaning $character',
  meaningEn: 'meaning $character',
  examples: const [],
  jlptLevel: 'N5',
);

class _FakeReadingFlowLessonRepository extends LessonRepository {
  _FakeReadingFlowLessonRepository({
    required this.allItemsByLevel,
    required this.dueItemsByLevel,
    required this.unseenItemsByLevel,
  }) : super(
         AppDatabase(executor: NativeDatabase.memory()),
         ContentDatabase(executor: NativeDatabase.memory()),
       );

  final Map<String, List<KanjiItem>> allItemsByLevel;
  final Map<String, List<KanjiItem>> dueItemsByLevel;
  final Map<String, List<KanjiItem>> unseenItemsByLevel;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async =>
      allItemsByLevel[level] ?? const [];

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async =>
      dueItemsByLevel[level] ?? const [];

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async => unseenItemsByLevel[level] ?? const [];
}

List<KanjiItem> get _n5Kanji => [
  _kanji(1, '日'),
  _kanji(2, '月'),
  _kanji(3, '火'),
  _kanji(4, '水'),
];

List<KanjiItem> get _n4Kanji => [
  _kanji(5, '山'),
  _kanji(6, '川'),
  _kanji(7, '田'),
  _kanji(8, '人'),
];

Widget buildScreen({
  required StudyLevel? level,
  AppLanguage language = AppLanguage.en,
  KanjiPracticeArgs? launchArgs,
  Map<String, List<KanjiItem>> allItemsByLevel = const {},
  Map<String, List<KanjiItem>> dueItemsByLevel = const {},
  Map<String, List<KanjiItem>> unseenItemsByLevel = const {},
  LessonRepository? lessonRepo,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      studyLevelProvider.overrideWith((ref) => level),
      kanjiByLevelCodeProvider.overrideWith(
        (ref, levelCode) async => allItemsByLevel[levelCode] ?? const [],
      ),
      kanjiReadingDueItemsByLevelCodeProvider.overrideWith(
        (ref, levelCode) async => dueItemsByLevel[levelCode] ?? const [],
      ),
      kanjiReadingUnseenItemsByLevelCodeProvider.overrideWith(
        (ref, levelCode) async => unseenItemsByLevel[levelCode] ?? const [],
      ),
      if (lessonRepo != null)
        lessonRepositoryProvider.overrideWithValue(lessonRepo),
    ],
    child: MaterialApp(home: HomeKanjiReadingScreen(launchArgs: launchArgs)),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows appBar title with level when level is set', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(level: StudyLevel.n5, allItemsByLevel: {'N5': _n5Kanji}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Read Kanji (N5)'), findsOneWidget);
  });

  testWidgets('shows level prompt when level is null', (tester) async {
    await tester.pumpWidget(buildScreen(level: null));
    await tester.pump();

    expect(find.text('Read Kanji'), findsOneWidget);
    expect(find.text(AppLanguage.en.levelMenuTitle), findsOneWidget);
  });

  testWidgets('shows empty-state with Open library when quiz cannot be built', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        level: StudyLevel.n5,
        allItemsByLevel: {
          'N5': [_kanji(1, '字')],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No terms available for this lesson.'), findsOneWidget);
  });

  testWidgets('shows Start CTA and All caught up chip when no due items', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(level: StudyLevel.n5, allItemsByLevel: {'N5': _n5Kanji}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('All caught up!'), findsOneWidget);
  });

  testWidgets('shows due count chip when items are due', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        level: StudyLevel.n5,
        allItemsByLevel: {'N5': _n5Kanji},
        dueItemsByLevel: {
          'N5': [_n5Kanji[0], _n5Kanji[1], _n5Kanji[2]],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 items due'), findsWidgets);
  });

  testWidgets('JA locale does not show Vietnamese kanji row meaning', (
    tester,
  ) async {
    final kanji = KanjiItem(
      id: 9,
      lessonId: 1,
      character: '火',
      strokeCount: 4,
      onyomi: 'カ',
      kunyomi: 'ひ',
      meaning: 'lửa',
      meaningEn: 'fire',
      examples: const [],
      jlptLevel: 'N5',
    );

    await tester.pumpWidget(
      buildScreen(
        level: StudyLevel.n5,
        language: AppLanguage.ja,
        allItemsByLevel: {
          'N5': [kanji, _kanji(2, '水'), _kanji(3, '木'), _kanji(4, '金')],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('fire'), findsOneWidget);
    expect(find.text('lửa'), findsNothing);
  });

  testWidgets(
    'launchArgs levelCode overrides selected level and keeps focused quiz available',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.read,
            source: 'focus',
            levelCode: 'N4',
            kanjiIds: [5],
            preferredKanjiId: 5,
          ),
          allItemsByLevel: {'N5': _n5Kanji, 'N4': _n4Kanji},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Read Kanji (N4)'), findsOneWidget);
      expect(
        find.text('Focused reading practice for a selected kanji.'),
        findsOneWidget,
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('山'), findsOneWidget);
      expect(find.text('日'), findsNothing);
    },
  );

  testWidgets('source-only due launchArgs uses due items as the quiz scope', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        level: StudyLevel.n5,
        launchArgs: const KanjiPracticeArgs(
          mode: KanjiPracticeMode.read,
          source: 'due',
          levelCode: 'N5',
        ),
        allItemsByLevel: {'N5': _n5Kanji},
        dueItemsByLevel: {
          'N5': [_n5Kanji[2]],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('1 kanji ready for a due reading review.'),
      findsOneWidget,
    );
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('火'), findsOneWidget);
    expect(find.text('日'), findsNothing);
  });

  testWidgets(
    'source-only new launchArgs uses unseen items as the quiz scope',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.read,
            source: 'daily_plan_new',
            levelCode: 'N5',
          ),
          allItemsByLevel: {'N5': _n5Kanji},
          unseenItemsByLevel: {
            'N5': [_n5Kanji[3]],
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('1 new kanji ready for reading practice.'),
        findsOneWidget,
      );
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('水'), findsOneWidget);
      expect(find.text('日'), findsNothing);
    },
  );

  testWidgets(
    'both mode continues to handwriting with the same scoped kanji ids',
    (tester) async {
      final repo = _FakeReadingFlowLessonRepository(
        allItemsByLevel: {'N5': _n5Kanji},
        dueItemsByLevel: {
          'N5': [_n5Kanji[0]],
        },
        unseenItemsByLevel: const {},
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          lessonRepo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            source: 'due',
            levelCode: 'N5',
          ),
          allItemsByLevel: {'N5': _n5Kanji},
          dueItemsByLevel: {
            'N5': [_n5Kanji[0]],
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      final asksForReading = find.text('この漢字の読みは？').evaluate().isNotEmpty;
      await tester.tap(find.text(asksForReading ? 'on_日' : '日').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Good'));
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      expect(find.text('Write'), findsOneWidget);
      await tester.tap(find.text('Write'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final session = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(session.items.map((item) => item.id).toList(), [1]);
      expect(session.initialKanjiId, 1);
    },
  );
}
