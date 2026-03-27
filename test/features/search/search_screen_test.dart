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
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/search/search_screen.dart';

class _FakeLessonRepository extends LessonRepository {
  _FakeLessonRepository({required this.vocab, required this.kanji})
    : super(
        AppDatabase(executor: NativeDatabase.memory()),
        ContentDatabase(executor: NativeDatabase.memory()),
      );

  final List<VocabItem> vocab;
  final List<KanjiItem> kanji;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async => vocab;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async => kanji;
}

const _vocab = [
  VocabItem(
    id: 1,
    term: '食べる',
    reading: 'たべる',
    meaning: 'ăn',
    meaningEn: 'eat',
    level: 'N5',
    tags: ['verb'],
  ),
  VocabItem(
    id: 2,
    term: 'ねこ',
    reading: 'ねこ',
    meaning: 'mèo',
    meaningEn: 'cat',
    level: 'N5',
  ),
];

const _kanji = [
  KanjiItem(
    id: 1,
    lessonId: 1,
    character: '森',
    strokeCount: 12,
    onyomi: 'シン',
    kunyomi: 'もり',
    meaning: 'rừng',
    meaningEn: 'forest',
    examples: [],
    jlptLevel: 'N4',
  ),
];

Widget buildSearchScreen({LessonRepository? repo}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      if (repo != null) lessonRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

void main() {
  testWidgets('renders responsive lookup shell and updates query chrome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          searchIndexProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: SearchScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Lookup'), findsAtLeastNWidgets(1));
    expect(find.text('Current search bank'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Vocab'), findsAtLeastNWidgets(1));
    expect(find.text('Kanji'), findsAtLeastNWidgets(1));
    expect(find.text('Kana'), findsAtLeastNWidgets(1));
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'taberu');
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(
      find.text('No matches. Try a word, kanji, or reading.'),
      findsOneWidget,
    );
  });

  testWidgets('shows categorized discovery sections from repository data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Words for this level'), findsOneWidget);
    expect(find.text('Kanji with readings'), findsOneWidget);
    expect(find.text('Kana words'), findsOneWidget);
    expect(find.text('食べる'), findsOneWidget);
    expect(find.text('ねこ'), findsOneWidget);
    expect(find.text('森'), findsOneWidget);
  });

  testWidgets('matches by reading and shows search results summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'たべる');
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('1 result for "たべる"'), findsOneWidget);
    expect(find.text('食べる'), findsOneWidget);
    expect(find.text('ねこ'), findsNothing);
    expect(find.text('森'), findsNothing);
  });

  testWidgets('matches romaji queries and promotes a top hit card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'taberu');
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('TOP HIT'), findsOneWidget);
    expect(find.text('1 result for "taberu"'), findsOneWidget);
    expect(find.text('Romaji'), findsOneWidget);
    expect(find.text('食べる'), findsOneWidget);
  });

  testWidgets('keeps recent lookups after clearing the query', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'taberu');
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Recent lookups'), findsOneWidget);
    expect(find.text('taberu'), findsOneWidget);
  });

  testWidgets('kana filter narrows visible results to kana entries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Kana'));
    await tester.pump();

    expect(find.text('ねこ'), findsOneWidget);
    expect(find.text('食べる'), findsNothing);
    expect(find.text('森'), findsNothing);
  });

  testWidgets('kanji filter narrows visible results to kanji entries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSearchScreen(
        repo: _FakeLessonRepository(vocab: _vocab, kanji: _kanji),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Kanji'));
    await tester.pump();

    expect(find.text('森'), findsOneWidget);
    expect(find.text('食べる'), findsNothing);
    expect(find.text('ねこ'), findsNothing);
  });

  testWidgets('shows load error when search index provider fails', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          searchIndexProvider.overrideWith(
            (ref) async => throw Exception('boom'),
          ),
        ],
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);
  });
}
