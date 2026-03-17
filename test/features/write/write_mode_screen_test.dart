import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/write/screens/write_mode_screen.dart';

void main() {
  testWidgets('WriteModeScreen shows typing and handwriting entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        ],
        child: MaterialApp(
          home: WriteModeScreen(
            lessonId: 1,
            lessonTitle: 'Lesson 1',
            vocabItems: const [
              VocabItem(
                id: 1,
                term: '食べる',
                reading: 'たべる',
                meaning: 'ăn',
                meaningEn: 'to eat',
                level: 'N5',
              ),
            ],
            kanjiItems: const [
              KanjiItem(
                id: 1,
                lessonId: 1,
                character: '食',
                strokeCount: 9,
                meaning: 'ăn',
                meaningEn: 'eat',
                examples: [],
                jlptLevel: 'N5',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.en.writeModeTypingLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.writeModeHandwritingLabel), findsOneWidget);
  });
}
