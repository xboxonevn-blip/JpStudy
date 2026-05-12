import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/flashcards/screens/enhanced_flashcard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLesson = 'Lesson 1';

VocabItem _item(int id, String term, String meaning) => VocabItem(
  id: id,
  term: term,
  meaning: meaning,
  meaningEn: meaning,
  level: 'N5',
);

Widget buildFlashcardScreen(List<VocabItem> items) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      // srsStateProvider returns null SRS (new card) for every id
      for (final item in items)
        srsStateProvider(item.id).overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      home: EnhancedFlashcardScreen(
        items: items,
        lessonId: 1,
        lessonTitle: _kLesson,
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows lesson title in AppBar', (tester) async {
    final items = [_item(1, '食べる', 'to eat')];
    await tester.pumpWidget(buildFlashcardScreen(items));
    await tester.pump();
    expect(find.text(_kLesson), findsOneWidget);
  });

  testWidgets('shows settings icon in AppBar', (tester) async {
    final items = [_item(1, '食べる', 'to eat')];
    await tester.pumpWidget(buildFlashcardScreen(items));
    await tester.pump();
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('shows first flashcard term', (tester) async {
    final items = [_item(1, '食べる', 'to eat'), _item(2, '飲む', 'to drink')];
    await tester.pumpWidget(buildFlashcardScreen(items));
    await tester.pumpAndSettle();
    expect(find.text('食べる'), findsOneWidget);
  });

  testWidgets('shows progress bar', (tester) async {
    final items = [_item(1, '食べる', 'to eat'), _item(2, '飲む', 'to drink')];
    await tester.pumpWidget(buildFlashcardScreen(items));
    await tester.pump();
    // LinearProgressIndicator represents the card progress
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
