import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_catalog_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// The provider family key must match what the screen constructs internally:
// HajimeteChapterCatalogArgs(levelCode: levelCode, title: title, subtitle: subtitle)
const _kArgs = HajimeteChapterCatalogArgs(levelCode: 'N5', title: 'はじめて N5');

const _kChapters = [
  HajimeteChapterSummary(
    chapterId: 1,
    title: 'Greetings',
    entryCount: 15,
    previewTerms: ['おはよう', 'こんにちは'],
    sourceVocabIds: [],
  ),
  HajimeteChapterSummary(
    chapterId: 2,
    title: 'Self-Introduction',
    entryCount: 20,
    previewTerms: ['わたし', 'なまえ'],
    sourceVocabIds: [],
  ),
];

// totalTerms = 15 + 20 = 35
const _kCatalog = HajimeteChapterCatalog(levelCode: 'N5', chapters: _kChapters);

const _kEmptyCatalog = HajimeteChapterCatalog(levelCode: 'N5', chapters: []);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  HajimeteChapterCatalog? catalog,
  Object? error,
}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      // Override the exact provider instance the screen will watch.
      // HajimeteChapterCatalogArgs.== is defined by (levelCode, title, subtitle),
      // so _kArgs matches what the screen creates for these constructor params.
      hajimeteChapterCatalogProvider(_kArgs).overrideWith((_) async {
        if (error != null) throw error;
        return catalog ?? _kCatalog;
      }),
    ],
    child: MaterialApp(
      home: const HajimeteChapterCatalogScreen(
        levelCode: 'N5',
        title: 'はじめて N5',
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

// At the default 400×600 test viewport, _ChapterCard's Column (aspect-ratio
// 1.9 grid cell ≈ 210 px) overflows when status pills are in loading state.
// Using a wide viewport switches the grid to 2 columns (1440 ≥ 760 px) with
// aspect ratio 1.18 → ~610 px per card — ample room for all card content.
void _wideViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders catalog title and back button', (tester) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Title rendered in the hero card
    expect(find.text('はじめて N5'), findsOneWidget);
    // Back-to-vocab button always visible
    expect(find.text('Back to vocab'), findsOneWidget);
  });

  testWidgets('hero card shows stat chips for chapter count and term count', (
    tester,
  ) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // _chapterCountLabel(en, 2) = '2 chapters'
    expect(find.text('2 chapters'), findsWidgets);
    // _termCountLabel(en, 35) = '35 terms'  (15 + 20 = 35 total terms)
    expect(find.text('35 terms'), findsOneWidget);
  });

  testWidgets('hero card shows level code tag', (tester) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // The _HeroTag for levelCode is always shown regardless of language
    expect(find.text('N5'), findsOneWidget);
    // EN tag labels
    expect(find.text('Live lane'), findsOneWidget);
    expect(find.text('Topic-first'), findsOneWidget);
  });

  testWidgets('chapter catalog section label and caption are visible', (
    tester,
  ) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Chapter catalog'), findsOneWidget);
    expect(find.text('2 chapters are ready to open directly.'), findsOneWidget);
  });

  testWidgets('chapter cards show title, entry count, and badge', (
    tester,
  ) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Chapter titles from HajimeteChapterSummary.title
    expect(find.text('Greetings'), findsOneWidget);
    expect(find.text('Self-Introduction'), findsOneWidget);

    // _chapterMeta(en, 15) = '15 terms inside this chapter'
    expect(find.text('15 terms inside this chapter'), findsOneWidget);

    // Chapter badge: _chapterBadge(en, '01') = 'Chapter 01'
    expect(find.text('Chapter 01'), findsOneWidget);
  });

  testWidgets('chapter cards show preview terms from fixture', (tester) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Preview terms from chapter 1 appear as _PreviewChip labels
    expect(find.text('おはよう'), findsWidgets);
    expect(find.text('こんにちは'), findsWidgets);
  });

  testWidgets('empty catalog renders empty-state card', (tester) async {
    await tester.pumpWidget(_buildScreen(catalog: _kEmptyCatalog));
    await _pump(tester);

    // _emptyTitle(en)
    expect(find.text('No chapters are ready yet'), findsOneWidget);
    // _emptySubtitle(en)
    expect(
      find.text(
        'The Hajimete data for this level will appear here once it is connected.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('error state renders error card with retry option', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildScreen(error: Exception('catalog load failed')),
    );
    await _pump(tester);

    // _errorTitle(en)
    expect(find.text('Could not load the Hajimete catalog'), findsOneWidget);
    // _retryLabel(en)
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('VI locale shows Vietnamese back button and section labels', (
    tester,
  ) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Quay lại từ vựng'), findsOneWidget);
    expect(find.text('Catalog theo chapter'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese back button and section labels', (
    tester,
  ) async {
    _wideViewport(tester);
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('語彙へ戻る'), findsOneWidget);
    expect(find.text('チャプター別カタログ'), findsOneWidget);
  });
}
