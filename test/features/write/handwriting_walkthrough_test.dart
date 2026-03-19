import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';
import 'package:jpstudy/features/write/screens/write_mode_screen.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';
import 'package:jpstudy/features/write/widgets/handwriting_canvas.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Finder animationControlFinder() => find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        ((widget.data ?? '') == AppLanguage.en.handwritingAnimateLabel ||
            (widget.data ?? '') == AppLanguage.en.handwritingPauseLabel),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'write.handwriting.strokeGuide.defaultExpanded': true,
    });
  });

  Map<String, KanjiStrokeTemplate> oneStrokeTemplate() => {
    '\u4E00': const KanjiStrokeTemplate(
      character: '\u4E00',
      quality: 'manual',
      strokes: [StrokeTemplate(start: Point(0.1, 0.5), end: Point(0.9, 0.5))],
    ),
  };

  testWidgets('Write Mode opens Handwriting screen', (tester) async {
    KanjiStrokeTemplateService.setDebugTemplateOverrides(oneStrokeTemplate());
    addTearDown(() {
      KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
    });

    final vocabItems = [
      const VocabItem(
        id: 1,
        term: '\u4E00',
        reading: 'ichi',
        meaning: 'mot',
        meaningEn: 'one',
        level: 'N5',
      ),
    ];
    final kanjiItems = [
      const KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [],
        jlptLevel: 'N5',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: WriteModeScreen(
            lessonId: 1,
            lessonTitle: 'Lesson 1',
            vocabItems: vocabItems,
            kanjiItems: kanjiItems,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.writeModeHandwritingLabel));
    await tester.pumpAndSettle();

    expect(find.byType(HandwritingPracticeScreen), findsOneWidget);
  });

  testWidgets(
    'Handwriting walkthrough updates SRS and creates mistake on wrong answer',
    (tester) async {
      KanjiStrokeTemplateService.setDebugTemplateOverrides(oneStrokeTemplate());
      addTearDown(() {
        KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
      });

      final db = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = LessonRepository(db, contentDb);
      addTearDown(() async {
        await contentDb.close();
        await db.close();
      });

      const kanjiId = 99901;
      const item = KanjiItem(
        id: kanjiId,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [],
        jlptLevel: 'N5',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            lessonRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(
            home: HandwritingPracticeScreen(
              lessonTitle: 'Lesson 1',
              items: [item],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final canvas = find.byType(HandwritingCanvas, skipOffstage: false);
      expect(canvas, findsOneWidget);
      await tester.ensureVisible(canvas);
      await tester.pumpAndSettle();
      final rect = tester.getRect(canvas);

      Future<void> drawStroke(Offset start, Offset end) async {
        final gesture = await tester.startGesture(start);
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.moveTo(end);
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Draw 2 strokes while expected is 1 -> deterministic wrong case.
      await drawStroke(
        rect.topLeft + const Offset(16, 16),
        rect.bottomRight - const Offset(16, 16),
      );
      await drawStroke(
        rect.bottomLeft + const Offset(16, -16),
        rect.topRight - const Offset(16, -16),
      );

      final checkButton = find
          .text(AppLanguage.en.handwritingCheckLabel, skipOffstage: false)
          .last;
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();
      expect(
        find.text(AppLanguage.en.handwritingPracticeWrongFirstLabel),
        findsOneWidget,
      );
      expect(
        find.text(AppLanguage.en.handwritingRetryWrongCharactersLabel),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.text(AppLanguage.en.handwritingPracticeWrongFirstLabel),
      );
      await tester.tap(
        find.text(AppLanguage.en.handwritingPracticeWrongFirstLabel),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, 600));
      await tester.pumpAndSettle();

      expect(
        find.text(
          AppLanguage.en.handwritingCurrentSetLabel(
            AppLanguage.en.handwritingSessionWrongOnlySetLabel,
          ),
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      final srs = await db.kanjiSrsDao.getSrsState(kanjiId);
      expect(srs, isNotNull);
      expect(srs!.lastConfidence, equals(1));

      final mistakes = await db.mistakeDao.getMistakesByType('kanji');
      final targetMistake = mistakes.where((m) => m.itemId == kanjiId).toList();
      expect(targetMistake, hasLength(1));
      expect(targetMistake.first.source, equals('handwriting'));
    },
  );

  testWidgets('Handwriting builds compound target from kanji examples', (
    tester,
  ) async {
    KanjiStrokeTemplateService.setDebugTemplateOverrides({
      ...oneStrokeTemplate(),
      '\u4E8C': const KanjiStrokeTemplate(
        character: '\u4E8C',
        quality: 'manual',
        strokes: [StrokeTemplate(start: Point(0.1, 0.4), end: Point(0.9, 0.4))],
      ),
    });
    addTearDown(() {
      KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
    });

    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = LessonRepository(db, contentDb);
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });

    const items = [
      KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [
          KanjiExample(
            word: '\u4E00\u4E8C',
            reading: 'ichini',
            meaning: 'mot hai',
            meaningEn: 'one two',
          ),
        ],
        jlptLevel: 'N5',
      ),
      KanjiItem(
        id: 2,
        lessonId: 1,
        character: '\u4E8C',
        strokeCount: 1,
        meaning: 'hai',
        meaningEn: 'two',
        examples: [],
        jlptLevel: 'N5',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          lessonRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: HandwritingPracticeScreen(
            lessonTitle: 'Lesson 1',
            items: items,
            maxCompoundsPerKanji: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        AppLanguage.en.practiceProgressLabel(1, 3),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        AppLanguage.en.handwritingCurrentSetLabel(
          AppLanguage.en.handwritingSessionAllItemsLabel,
        ),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('一二'), findsNothing);

    await tester.tap(find.text(AppLanguage.en.handwritingModeCompoundLabel));
    await tester.pumpAndSettle();

    expect(
      find.text(
        AppLanguage.en.practiceProgressLabel(1, 1),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('一二'), findsOneWidget);
  });

  testWidgets(
    'Handwriting keeps compound example even when other kanji is outside lesson list',
    (tester) async {
      KanjiStrokeTemplateService.setDebugTemplateOverrides({
        ...oneStrokeTemplate(),
        '\u4E8C': const KanjiStrokeTemplate(
          character: '\u4E8C',
          quality: 'manual',
          strokes: [
            StrokeTemplate(start: Point(0.1, 0.4), end: Point(0.9, 0.4)),
          ],
        ),
      });
      addTearDown(() {
        KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
      });

      const items = [
        KanjiItem(
          id: 1,
          lessonId: 1,
          character: '\u4E00',
          strokeCount: 1,
          meaning: 'mot',
          meaningEn: 'one',
          examples: [
            KanjiExample(
              word: '\u4E00\u4E8C',
              reading: 'ichini',
              meaning: 'mot hai',
              meaningEn: 'one two',
            ),
          ],
          jlptLevel: 'N5',
        ),
      ];

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HandwritingPracticeScreen(
              lessonTitle: 'Lesson 1',
              items: items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(AppLanguage.en.practiceProgressLabel(1, 2)),
        findsOneWidget,
      );

      await tester.tap(find.text(AppLanguage.en.handwritingModeCompoundLabel));
      await tester.pumpAndSettle();

      expect(
        find.text(AppLanguage.en.practiceProgressLabel(1, 1)),
        findsOneWidget,
      );
      expect(find.text('一二'), findsOneWidget);
    },
  );

  testWidgets('Handwriting supports single/compound/mixed mode selection', (
    tester,
  ) async {
    KanjiStrokeTemplateService.setDebugTemplateOverrides({
      ...oneStrokeTemplate(),
      '\u4E8C': const KanjiStrokeTemplate(
        character: '\u4E8C',
        quality: 'manual',
        strokes: [StrokeTemplate(start: Point(0.1, 0.4), end: Point(0.9, 0.4))],
      ),
    });
    addTearDown(() {
      KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
    });

    const items = [
      KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [
          KanjiExample(
            word: '\u4E00\u4E8C',
            reading: 'ichini',
            meaning: 'mot hai',
            meaningEn: 'one two',
          ),
        ],
        jlptLevel: 'N5',
      ),
      KanjiItem(
        id: 2,
        lessonId: 1,
        character: '\u4E8C',
        strokeCount: 1,
        meaning: 'hai',
        meaningEn: 'two',
        examples: [],
        jlptLevel: 'N5',
      ),
    ];

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HandwritingPracticeScreen(
            lessonTitle: 'Lesson 1',
            items: items,
            maxCompoundsPerKanji: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.en.handwritingModeLabel), findsOneWidget);
    expect(
      find.text(AppLanguage.en.practiceProgressLabel(1, 3)),
      findsOneWidget,
    );

    await tester.tap(find.text(AppLanguage.en.handwritingModeCompoundLabel));
    await tester.pumpAndSettle();

    expect(
      find.text(AppLanguage.en.practiceProgressLabel(1, 1)),
      findsOneWidget,
    );
    final guideTitle = find
        .text(AppLanguage.en.handwritingStrokeGuideTitle, skipOffstage: false)
        .last;
    expect(guideTitle, findsOneWidget);
    await tester.ensureVisible(guideTitle);
    await tester.pumpAndSettle();
    expect(
      find.text(
        AppLanguage.en.handwritingWriteOrderByCharacterLabel,
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('1. 一', skipOffstage: false), findsOneWidget);
    expect(find.text('2. 二', skipOffstage: false), findsOneWidget);
    expect(animationControlFinder(), findsWidgets);
  });

  testWidgets(
    'Handwriting uses default stroke guide setting from preferences',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'write.handwriting.strokeGuide.defaultExpanded': false,
      });

      KanjiStrokeTemplateService.setDebugTemplateOverrides(oneStrokeTemplate());
      addTearDown(() {
        KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
      });

      const items = [
        KanjiItem(
          id: 1,
          lessonId: 1,
          character: '\u4E00',
          strokeCount: 1,
          meaning: 'mot',
          meaningEn: 'one',
          examples: [],
          jlptLevel: 'N5',
        ),
      ];

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HandwritingPracticeScreen(
              lessonTitle: 'Lesson 1',
              items: items,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final guideTitle = find
          .text(AppLanguage.en.handwritingStrokeGuideTitle, skipOffstage: false)
          .last;
      expect(guideTitle, findsOneWidget);
      await tester.ensureVisible(guideTitle);
      await tester.pumpAndSettle();
      expect(animationControlFinder(), findsNothing);

      await tester.tap(guideTitle);
      await tester.pumpAndSettle();

      expect(animationControlFinder(), findsWidgets);
    },
  );

  testWidgets(
    'Handwriting keeps the current item when parent rebuilds with the same logical items',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      KanjiStrokeTemplateService.setDebugTemplateOverrides({});
      addTearDown(() {
        KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
      });

      final db = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = LessonRepository(db, contentDb);
      addTearDown(() async {
        await contentDb.close();
        await db.close();
      });

      const items = [
        KanjiItem(
          id: 1,
          lessonId: 1,
          character: '\u4E00',
          strokeCount: 1,
          meaning: 'mot',
          meaningEn: 'one',
          examples: [],
          jlptLevel: 'N5',
        ),
        KanjiItem(
          id: 2,
          lessonId: 1,
          character: '\u4E8C',
          strokeCount: 1,
          meaning: 'hai',
          meaningEn: 'two',
          examples: [],
          jlptLevel: 'N5',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            lessonRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: _HandwritingRebuildHost(items: items)),
        ),
      );
      await tester.pumpAndSettle();

      final canvas = find.byType(HandwritingCanvas, skipOffstage: false);
      expect(canvas, findsOneWidget);
      await tester.ensureVisible(canvas);
      await tester.pumpAndSettle();
      final rect = tester.getRect(canvas);

      final gesture = await tester.startGesture(
        rect.centerLeft + const Offset(24, 0),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveTo(rect.centerRight - const Offset(24, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      final checkButton = find
          .text(AppLanguage.en.handwritingCheckLabel, skipOffstage: false)
          .last;
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();

      final nextButton = find
          .text(AppLanguage.en.nextLabel, skipOffstage: false)
          .last;
      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(
        find.text(
          AppLanguage.en.practiceProgressLabel(2, 2),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('二', skipOffstage: false), findsWidgets);
      expect(find.text('一'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('rebuild-handwriting-host')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          AppLanguage.en.practiceProgressLabel(2, 2),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('二', skipOffstage: false), findsWidgets);
      expect(find.text('一'), findsNothing);
    },
  );

  testWidgets('Handwriting can start from a shuffled session order', (
    tester,
  ) async {
    KanjiStrokeTemplateService.setDebugTemplateOverrides({});
    addTearDown(() {
      KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
    });

    const items = [
      KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [],
        jlptLevel: 'N5',
      ),
      KanjiItem(
        id: 2,
        lessonId: 1,
        character: '\u4E8C',
        strokeCount: 1,
        meaning: 'hai',
        meaningEn: 'two',
        examples: [],
        jlptLevel: 'N5',
      ),
      KanjiItem(
        id: 3,
        lessonId: 1,
        character: '\u4E09',
        strokeCount: 1,
        meaning: 'ba',
        meaningEn: 'three',
        examples: [],
        jlptLevel: 'N5',
      ),
    ];

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HandwritingPracticeScreen(
            lessonTitle: 'Lesson 1',
            items: items,
            randomizeSessionOrder: true,
            sessionShuffleSeed: 42,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        AppLanguage.en.practiceProgressLabel(1, 3),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('三', skipOffstage: false), findsWidgets);
    expect(find.text('一'), findsNothing);
    expect(find.text('二'), findsNothing);
  });

  testWidgets(
    'Handwriting summary returns to practice hub instead of leaving a black screen',
    (tester) async {
      KanjiStrokeTemplateService.setDebugTemplateOverrides({});
      addTearDown(() {
        KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
      });

      final db = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = LessonRepository(db, contentDb);
      addTearDown(() async {
        await contentDb.close();
        await db.close();
      });

      const item = KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u4E00',
        strokeCount: 1,
        meaning: 'mot',
        meaningEn: 'one',
        examples: [],
        jlptLevel: 'N5',
      );

      final router = GoRouter(
        initialLocation: '/practice/handwriting',
        routes: [
          GoRoute(
            path: '/practice',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Practice hub'))),
          ),
          GoRoute(
            path: '/practice/handwriting',
            builder: (context, state) => const HandwritingPracticeScreen(
              lessonTitle: 'Lesson 1',
              items: [item],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            lessonRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final canvas = find.byType(HandwritingCanvas, skipOffstage: false);
      expect(canvas, findsOneWidget);
      await tester.ensureVisible(canvas);
      await tester.pumpAndSettle();
      final rect = tester.getRect(canvas);

      final gesture = await tester.startGesture(
        rect.centerLeft + const Offset(24, 0),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveTo(rect.centerRight - const Offset(24, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();
      await tester.pumpAndSettle();

      final checkButton = find
          .text(AppLanguage.en.handwritingCheckLabel, skipOffstage: false)
          .last;
      await tester.ensureVisible(checkButton);
      await tester.tap(checkButton);
      await tester.pumpAndSettle();

      final nextButton = find
          .text(AppLanguage.en.nextLabel, skipOffstage: false)
          .last;
      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text(AppLanguage.en.writeCompleteLabel), findsOneWidget);

      await tester.tap(find.text(AppLanguage.en.doneLabel));
      await tester.pumpAndSettle();

      expect(find.text('Practice hub'), findsOneWidget);
      expect(find.byType(HandwritingPracticeScreen), findsNothing);
    },
  );
}

class _HandwritingRebuildHost extends StatefulWidget {
  const _HandwritingRebuildHost({required this.items});

  final List<KanjiItem> items;

  @override
  State<_HandwritingRebuildHost> createState() =>
      _HandwritingRebuildHostState();
}

class _HandwritingRebuildHostState extends State<_HandwritingRebuildHost> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HandwritingPracticeScreen(
          lessonTitle: 'Lesson 1',
          items: List<KanjiItem>.of(widget.items),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: TextButton(
              key: const ValueKey('rebuild-handwriting-host'),
              onPressed: () {
                setState(() {});
              },
              child: const Text('rebuild'),
            ),
          ),
        ),
      ],
    );
  }
}
