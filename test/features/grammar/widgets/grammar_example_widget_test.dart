import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/widgets/grammar_example_widget.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Default translation is English so that EN locale resolves to it
// (resolveEnglishGrammarExampleTranslation rejects Vietnamese text via
// containsVietnameseGrammarText — falling through to `japanese.trim()`).
Widget _buildWidget({
  AppLanguage language = AppLanguage.en,
  String japanese = '食べてもいいですか。',
  String translation = 'May I eat?',
  String? translationVi,
  String? translationEn,
  bool showVietnamese = true,
}) {
  return MaterialApp(
    home: Scaffold(
      body: GrammarExampleWidget(
        language: language,
        japanese: japanese,
        translation: translation,
        translationVi: translationVi,
        translationEn: translationEn,
        showVietnamese: showVietnamese,
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('always renders the Japanese text', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    expect(find.text('食べてもいいですか。'), findsOneWidget);
  });

  testWidgets('EN locale uses translationEn when provided', (tester) async {
    await tester.pumpWidget(
      _buildWidget(
        language: AppLanguage.en,
        translation: 'Fallback translation.',
        translationEn: 'Is it okay to eat?',
      ),
    );
    await _pump(tester);

    expect(find.text('Is it okay to eat?'), findsOneWidget);
    // Fallback should NOT appear
    expect(find.text('Fallback translation.'), findsNothing);
  });

  testWidgets('EN locale falls back to translation when translationEn is null', (
    tester,
  ) async {
    // translation must be English — _cleanEnglishFreeText rejects Vietnamese text.
    await tester.pumpWidget(
      _buildWidget(
        language: AppLanguage.en,
        translation: 'Can I eat it?',
        translationEn: null,
      ),
    );
    await _pump(tester);

    expect(find.text('Can I eat it?'), findsOneWidget);
  });

  testWidgets('VI locale uses translationVi when provided', (tester) async {
    await tester.pumpWidget(
      _buildWidget(
        language: AppLanguage.vi,
        translation: 'Fallback.',
        translationVi: 'Có được ăn không?',
      ),
    );
    await _pump(tester);

    expect(find.text('Có được ăn không?'), findsOneWidget);
    expect(find.text('Fallback.'), findsNothing);
  });

  testWidgets(
    'VI locale falls back to translation when translationVi is null',
    (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          language: AppLanguage.vi,
          translation: 'Fallback VI',
          translationVi: null,
        ),
      );
      await _pump(tester);

      expect(find.text('Fallback VI'), findsOneWidget);
    },
  );

  testWidgets('JA locale always uses translation field directly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildWidget(
        language: AppLanguage.ja,
        translation: '食べてもいいですか？',
        translationVi: 'Không dùng cái này.',
        translationEn: 'Not this either.',
      ),
    );
    await _pump(tester);

    // JA: always shows translation, ignores the Vi/En overrides
    expect(find.text('食べてもいいですか？'), findsOneWidget);
    expect(find.text('Không dùng cái này.'), findsNothing);
    expect(find.text('Not this either.'), findsNothing);
  });

  testWidgets(
    'showVietnamese=false renders translation directly regardless of locale',
    (tester) async {
      // showVietnamese=false returns `translation` directly, skipping all locale
      // dispatch — used when the caller wants the raw fallback translation.
      await tester.pumpWidget(
        _buildWidget(
          language: AppLanguage.vi,
          translation: 'Direct raw translation.',
          translationVi: 'Should be ignored.',
          translationEn: 'Also ignored.',
          showVietnamese: false,
        ),
      );
      await _pump(tester);

      expect(find.text('Direct raw translation.'), findsOneWidget);
      expect(find.text('Should be ignored.'), findsNothing);
    },
  );
}
