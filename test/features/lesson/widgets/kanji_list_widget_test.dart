import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/lesson/widgets/kanji_list_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kLessonId = 42;

const _kKanji = KanjiItem(
  id: 1,
  lessonId: _kLessonId,
  character: '食',
  strokeCount: 9,
  onyomi: 'ショク',
  kunyomi: 'た-べる',
  meaning: 'ăn',
  meaningEn: 'eat',
  examples: [],
  jlptLevel: 'N5',
);

const _kKanji2 = KanjiItem(
  id: 2,
  lessonId: _kLessonId,
  character: '飲',
  strokeCount: 12,
  onyomi: 'イン',
  kunyomi: 'の-む',
  meaning: 'uống',
  meaningEn: 'drink',
  examples: [],
  jlptLevel: 'N5',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  AppLanguage language = AppLanguage.en,
  List<KanjiItem>? items,
  Object? error,
}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      lessonKanjiProvider(_kLessonId).overrideWith((_) async {
        if (error != null) throw error;
        return items ?? const [_kKanji];
      }),
    ],
    child: const MaterialApp(
      home: Scaffold(body: KanjiListWidget(lessonId: _kLessonId)),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// Expanded kanji card body adds ~400 px. A large viewport avoids overflow
// inside nested Column containers in the expanded detail section.
void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('KanjiListWidget – async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      tester,
    ) async {
      // Use a Completer so the future stays pending — async => value resolves
      // before the first pump() and would skip straight to data state.
      final completer = Completer<List<KanjiItem>>();
      await tester.pumpWidget(
        ProviderScope(
          retry: (retryCount, error) => null,
          overrides: [
            appLanguageProvider.overrideWith(
              (ref) => AppLanguageController.test(AppLanguage.en),
            ),
            lessonKanjiProvider(
              _kLessonId,
            ).overrideWith((_) => completer.future),
          ],
          child: const MaterialApp(
            home: Scaffold(body: KanjiListWidget(lessonId: _kLessonId)),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const []); // resolve so teardown is clean
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('shows empty-state label when list is empty', (tester) async {
      await tester.pumpWidget(_buildHarness(items: const []));
      await _pump(tester);

      expect(find.text('No kanji data for this lesson.'), findsOneWidget);
    });

    testWidgets('VI locale shows Vietnamese empty label', (tester) async {
      await tester.pumpWidget(
        _buildHarness(language: AppLanguage.vi, items: const []),
      );
      await _pump(tester);

      expect(find.text('Chưa có dữ liệu kanji cho bài này.'), findsOneWidget);
    });

    testWidgets('error state shows kanjiListLoadErrorLabel', (tester) async {
      await tester.pumpWidget(
        _buildHarness(error: Exception('db connection failed')),
      );
      await _pump(tester);

      expect(find.textContaining('Failed to load kanji:'), findsOneWidget);
    });
  });

  group('KanjiListWidget – collapsed row rendering', () {
    // NOTE: AnimatedCrossFade always keeps BOTH firstChild (collapsed) and
    // secondChild (expanded body) in the widget tree. Texts that appear in
    // both (character, primary meaning, stroke pill) will therefore find 2+
    // widgets — use findsWidgets / findsAtLeast(1) for those.

    testWidgets('renders kanji character in the row header', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // '食' appears in collapsed row (32px) AND AnimatedCrossFade secondChild
      // (38px, always in tree).  Use findsWidgets — presence is what matters.
      expect(find.text('食'), findsWidgets);
    });

    testWidgets('EN locale shows meaningEn as primary meaning', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // 'eat' (meaningEn) appears in row header + secondChild expanded body
      expect(find.text('eat'), findsWidgets);
    });

    testWidgets('VI locale shows meaning (Vietnamese) as primary meaning', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness(language: AppLanguage.vi));
      await _pump(tester);

      expect(find.text('ăn'), findsWidgets);
    });

    testWidgets('renders combined onyomi/kunyomi subtitle', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // _subtitle(EN) = 'On: ショク | Kun: た-べる'
      // This combined form only appears in the collapsed row header — expanded
      // body shows onyomi and kunyomi as separate meta pills.
      expect(find.text('On: ショク | Kun: た-べる'), findsOneWidget);
    });

    testWidgets('renders stroke-count meta pill', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // handwritingStrokeShortLabel(9, EN) = '9 strokes'
      // Appears in both collapsed pill and expanded body pill
      expect(find.text('9 strokes'), findsAtLeast(1));
    });

    testWidgets('all kanji items rendered in multi-item list', (tester) async {
      await tester.pumpWidget(_buildHarness(items: const [_kKanji, _kKanji2]));
      await _pump(tester);

      expect(find.text('食'), findsWidgets);
      expect(find.text('飲'), findsWidgets);
    });
  });

  group('KanjiListWidget – expand/collapse', () {
    testWidgets('tapping a row changes crossFadeState to showSecond', (
      tester,
    ) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // Initially collapsed
      expect(
        tester
            .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
            .crossFadeState,
        CrossFadeState.showFirst,
      );

      // Tap the collapsed row header (first '食' text at 32px, inside InkWell)
      await tester.tap(find.text('食').first);
      await tester.pumpAndSettle();

      // Now expanded
      expect(
        tester
            .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
            .crossFadeState,
        CrossFadeState.showSecond,
      );
    });

    testWidgets('tapping an expanded row collapses back to showFirst', (
      tester,
    ) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // Expand
      await tester.tap(find.text('食').first);
      await tester.pumpAndSettle();

      // Collapse
      await tester.tap(find.text('食').first);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
            .crossFadeState,
        CrossFadeState.showFirst,
      );
    });
  });
}
