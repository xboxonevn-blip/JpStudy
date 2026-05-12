import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/vocab/widgets/flashcard_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// 食べる contains kanji → term ≠ reading → hasDisplayReading = true
const _kItem = VocabItem(
  id: 1,
  term: '食べる',
  reading: 'たべる',
  meaning: 'ăn',
  meaningEn: 'to eat',
  level: 'N5',
);

// Kana-only term → shouldShowReading returns false → hasDisplayReading = false
const _kKanaItem = VocabItem(
  id: 2,
  term: 'たべる',
  reading: 'たべる',
  meaning: 'ăn',
  meaningEn: 'to eat',
  level: 'N5',
);

// Has kanjiMeaning — only shown for non-EN locales on the front face
const _kKanjiItem = VocabItem(
  id: 3,
  term: '食べる',
  reading: 'たべる',
  meaning: 'ăn',
  meaningEn: 'to eat',
  kanjiMeaning: 'eat + RU verb',
  level: 'N5',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  VocabItem item = _kItem,
  AppLanguage language = AppLanguage.en,
  VoidCallback? onFlip,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          height: 520,
          child: FlashcardWidget(
            item: item,
            language: language,
            onFlip: onFlip,
          ),
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

// Tap the card and wait for the 600 ms flip animation to fully settle.
Future<void> _tapAndFlip(WidgetTester tester) async {
  await tester.tap(find.byType(GestureDetector));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FlashcardWidget – front face', () {
    testWidgets('renders term and EN tap-to-flip hint', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('食べる'), findsOneWidget);
      expect(find.text('Tap to flip'), findsOneWidget);
    });

    testWidgets('VI locale shows Vietnamese tap-to-flip label', (tester) async {
      await tester.pumpWidget(_buildHarness(language: AppLanguage.vi));
      await _pump(tester);

      expect(find.text('Chạm để lật thẻ'), findsOneWidget);
    });

    testWidgets('JA locale shows Japanese tap-to-flip label', (tester) async {
      await tester.pumpWidget(_buildHarness(language: AppLanguage.ja));
      await _pump(tester);

      expect(find.text('タップして裏面を表示'), findsOneWidget);
    });

    testWidgets('non-EN locale shows kanjiMeaning on front when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(item: _kKanjiItem, language: AppLanguage.vi),
      );
      await _pump(tester);

      expect(find.text('食べる'), findsOneWidget);
      expect(find.text('eat + RU verb'), findsOneWidget);
    });

    testWidgets('EN locale does NOT show kanjiMeaning on front', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(item: _kKanjiItem, language: AppLanguage.en),
      );
      await _pump(tester);

      expect(find.text('食べる'), findsOneWidget);
      expect(find.text('eat + RU verb'), findsNothing);
    });
  });

  group('FlashcardWidget – flip interaction', () {
    testWidgets('tapping card shows back face with reading and EN meaning', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      await _tapAndFlip(tester);

      // hasDisplayReading = true: reading shown on back
      expect(find.text('たべる'), findsOneWidget);
      // EN locale: meaningEn preferred over meaning
      expect(find.text('to eat'), findsOneWidget);
      // Front-face hint disappears (front not in tree when showing back)
      expect(find.text('Tap to flip'), findsNothing);
    });

    testWidgets('back face shows meaning (VI) for VI locale', (tester) async {
      await tester.pumpWidget(_buildHarness(language: AppLanguage.vi));
      await _pump(tester);

      await _tapAndFlip(tester);

      // VI locale: item.meaning shown, not meaningEn
      expect(find.text('ăn'), findsOneWidget);
      expect(find.text('to eat'), findsNothing);
    });

    testWidgets('kana-only term: no reading row on back face', (tester) async {
      await tester.pumpWidget(_buildHarness(item: _kKanaItem));
      await _pump(tester);

      await _tapAndFlip(tester);

      // hasDisplayReading = false: reading block not rendered
      expect(find.text('to eat'), findsOneWidget);
      // 'たべる' was on the front (term) and is the reading — neither appears
      // because front is hidden and reading is suppressed on the back
      expect(find.text('たべる'), findsNothing);
    });

    testWidgets('tapping back face flips card back to front', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      await _tapAndFlip(tester); // front → back
      await _tapAndFlip(tester); // back → front

      expect(find.text('食べる'), findsOneWidget);
      expect(find.text('Tap to flip'), findsOneWidget);
    });

    testWidgets('onFlip callback fires on each tap', (tester) async {
      var flipCount = 0;
      await tester.pumpWidget(_buildHarness(onFlip: () => flipCount++));
      await _pump(tester);

      await _tapAndFlip(tester);
      expect(flipCount, equals(1));

      await _tapAndFlip(tester);
      expect(flipCount, equals(2));
    });

    testWidgets(
      'onFlip is optional — tapping without callback does not throw',
      (tester) async {
        await tester.pumpWidget(_buildHarness()); // onFlip = null
        await _pump(tester);

        await expectLater(() => _tapAndFlip(tester), returnsNormally);
      },
    );
  });
}
