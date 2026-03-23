import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLevel = 'N5';

VocabData _vocab(int id, String term, String meaning) => VocabData(
      id: id,
      term: term,
      reading: null,
      meaning: meaning,
      meaningEn: meaning,
      level: _kLevel,
    );

Widget buildVocabScreen({
  List<VocabData> items = const [],
  List<UserLessonTermData> dueTerms = const [],
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      vocabPreviewProvider(_kLevel).overrideWith((ref) async => items),
      allDueTermsProvider.overrideWith((ref) async => dueTerms),
      nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: const MaterialApp(home: VocabScreen()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('VocabScreen shows title when level is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => null),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Words'), findsOneWidget);
  });

  testWidgets('VocabScreen shows empty-state when no vocab available', (
    tester,
  ) async {
    await tester.pumpWidget(buildVocabScreen());
    await tester.pumpAndSettle();

    expect(find.text('Vocab'), findsWidgets);
    expect(
      find.text('No words are available for this level yet.'),
      findsOneWidget,
    );
    expect(find.text('Open library'), findsOneWidget);
  });

  testWidgets('VocabScreen shows hero Review CTA when vocab loaded', (
    tester,
  ) async {
    final items = [
      _vocab(1, '食べる', 'to eat'),
      _vocab(2, '飲む', 'to drink'),
    ];
    await tester.pumpWidget(buildVocabScreen(items: items));
    await tester.pumpAndSettle();

    expect(find.text('Review now'), findsOneWidget);
    expect(find.text('List mode'), findsOneWidget);
  });

  testWidgets('VocabScreen appBar title includes level label', (tester) async {
    await tester.pumpWidget(buildVocabScreen());
    await tester.pump();
    expect(find.text('Words (N5)'), findsOneWidget);
  });

  testWidgets('VocabScreen preview shows up to 6 terms', (tester) async {
    final items = List.generate(8, (i) => _vocab(i + 1, '語$i', 'word $i'));
    await tester.pumpWidget(buildVocabScreen(items: items));
    await tester.pumpAndSettle();

    expect(find.text('語0'), findsOneWidget);
    expect(find.text('語5'), findsOneWidget);
    expect(find.text('語6'), findsNothing);
  });
}
