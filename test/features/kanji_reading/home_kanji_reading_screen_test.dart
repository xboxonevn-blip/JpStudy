import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';
import 'package:jpstudy/features/kanji_reading/providers/kanji_reading_providers.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

KanjiItem _kanji(int id, String character) => KanjiItem(
      id: id,
      lessonId: 1,
      character: character,
      strokeCount: 2,
      meaning: 'meaning $character',
      examples: const [],
      jlptLevel: 'N5',
    );

// Build enough items to exceed the "< 4" threshold
List<KanjiItem> get _fourKanji =>
    [1, 2, 3, 4].map((i) => _kanji(i, '字$i')).toList();

Widget buildScreen({
  List<KanjiItem> allItems = const [],
  int dueCount = 0,
  List<KanjiItem> dueItems = const [],
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      kanjiByLevelProvider.overrideWith((ref) async => allItems),
      // kanjiReadingDueCountProvider was removed; the screen now derives the
      // count from kanjiDueIdsProvider. Use a synthetic set of the right size
      // so dueCount is honoured independently of the dueItems list.
      kanjiDueIdsProvider.overrideWith(
          (ref) async => Set.from(Iterable.generate(dueCount, (i) => i))),
      kanjiReadingDueItemsProvider.overrideWith((ref) async => dueItems),
    ],
    child: const MaterialApp(home: HomeKanjiReadingScreen()),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows appBar title with level when level is set', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Read Kanji (N5)'), findsOneWidget);
  });

  testWidgets('shows level prompt when level is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(home: HomeKanjiReadingScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Read Kanji'), findsOneWidget);
  });

  testWidgets('shows empty-state with Open library when < 4 kanji', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(allItems: [_kanji(1, '字')]));
    await tester.pumpAndSettle();

    expect(find.text('No terms available for this lesson.'), findsOneWidget);
  });

  testWidgets('shows Start CTA and All caught up chip when no due items', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(allItems: _fourKanji));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('All caught up!'), findsOneWidget);
  });

  testWidgets('shows due count chip when items are due', (tester) async {
    await tester.pumpWidget(
      buildScreen(allItems: _fourKanji, dueCount: 3, dueItems: _fourKanji),
    );
    await tester.pumpAndSettle();

    expect(find.text('3 due'), findsWidgets);
  });
}
