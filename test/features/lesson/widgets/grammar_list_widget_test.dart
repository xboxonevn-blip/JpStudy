import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/models/grammar_point_data.dart';
import 'package:jpstudy/features/lesson/widgets/grammar_list_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kLessonId = 42;
const _kLevel = 'N5';

// LessonTermsArgs.== matches on (lessonId, level, fallbackTitle).
final _kArgs = LessonTermsArgs(_kLessonId, _kLevel, '');

// GrammarPoint is a Drift DataClass → const constructor available.
const _kPoint = GrammarPoint(
  id: 1,
  lessonId: _kLessonId,
  grammarPoint: 'て形',
  titleEn: 'te-form',
  meaning: 'Hình thức て',
  meaningVi: 'Dạng て',
  meaningEn: 'te-form of verb',
  connection: 'Verb[て形]',
  explanation: 'Used to connect actions.',
  jlptLevel: 'N5',
  isLearned: false,
);

const _kPointLearned = GrammarPoint(
  id: 2,
  lessonId: _kLessonId,
  grammarPoint: 'ている',
  titleEn: 'te-iru',
  meaning: 'Hành động đang xảy ra',
  meaningVi: 'Đang làm gì đó',
  meaningEn: 'ongoing action / state',
  connection: 'Verb[て形]+いる',
  explanation: 'Indicates an ongoing action or current state.',
  jlptLevel: 'N5',
  isLearned: true,
);

// GrammarPointData has NO const constructor (plain class).
final _kData1 = GrammarPointData(point: _kPoint, examples: []);
final _kDataLearned = GrammarPointData(point: _kPointLearned, examples: []);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  AppLanguage language = AppLanguage.en,
  List<GrammarPointData>? items,
  Object? error,
  int dueCount = 0,
  int ghostCount = 0,
}) {
  return ProviderScope(
    overrides: [
      lessonGrammarProvider(_kArgs).overrideWith((_) async {
        if (error != null) throw error;
        return items ?? [_kData1];
      }),
      grammarDueCountProvider.overrideWith((_) async => dueCount),
      grammarGhostCountProvider.overrideWith((_) => Stream.value(ghostCount)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: GrammarListWidget(
          lessonId: _kLessonId,
          level: _kLevel,
          language: language,
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// GrammarListWidget contains Column > Expanded(ListView) which needs a tall
// viewport. 420×900 gives plenty of room for header + card list.
void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('GrammarListWidget – async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (tester) async {
      _largeViewport(tester);
      final completer = Completer<List<GrammarPointData>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonGrammarProvider(_kArgs).overrideWith(
              (_) => completer.future,
            ),
            grammarDueCountProvider.overrideWith((_) async => 0),
            grammarGhostCountProvider.overrideWith((_) => Stream.value(0)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: GrammarListWidget(
                lessonId: _kLessonId,
                level: _kLevel,
                language: AppLanguage.en,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('shows empty-state text when list is empty', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness(items: []));
      await _pump(tester);

      expect(find.text('No grammar data available.'), findsOneWidget);
    });

    testWidgets('VI locale shows Vietnamese empty text', (tester) async {
      await tester.pumpWidget(
        _buildHarness(language: AppLanguage.vi, items: []),
      );
      await _pump(tester);

      expect(find.text('Chưa có dữ liệu ngữ pháp.'), findsOneWidget);
    });

    testWidgets('error state shows error message', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _buildHarness(error: Exception('load failed')),
      );
      await _pump(tester);

      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  group('GrammarListWidget – header rendering', () {
    testWidgets('renders "Grammar Learning Hub" header title', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('Grammar Learning Hub'), findsOneWidget);
    });

    testWidgets('renders mastered/total chip', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // 0 of 1 points learned → 'Mastered 0/1'
      expect(find.text('Mastered 0/1'), findsOneWidget);
    });

    testWidgets('dueCount chip reflects overridden dueCount', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness(dueCount: 3));
      await _pump(tester);

      expect(find.text('Due 3'), findsOneWidget);
    });

    testWidgets('VI locale shows Vietnamese header title', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness(language: AppLanguage.vi));
      await _pump(tester);

      expect(find.text('Khu vực học Ngữ pháp'), findsOneWidget);
    });

    testWidgets('Learn/Drill/Quiz mode segments are all visible',
        (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Drill'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);
    });

    testWidgets('initial mode is Learn — shows Start Learn Flow button',
        (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('Start Learn Flow (25)'), findsOneWidget);
    });

    testWidgets('tapping Drill segment switches to drill action buttons',
        (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // Learn mode is active — drill buttons absent
      expect(find.text('Sentence + Transform'), findsNothing);

      await tester.tap(find.text('Drill'));
      await tester.pumpAndSettle();

      // Drill mode now active
      expect(find.text('Sentence + Transform'), findsOneWidget);
      // Learn flow button gone
      expect(find.text('Start Learn Flow (25)'), findsNothing);
    });
  });

  group('GrammarListWidget – grammar point cards', () {
    testWidgets('renders grammarPoint text in card', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // 'て形' appears in collapsed row; AnimatedCrossFade also builds
      // expanded body — use findsWidgets
      expect(find.text('て形'), findsWidgets);
    });

    testWidgets('EN locale shows meaningEn in card', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      // normalizeGrammarTitleEn('te-form of verb') = 'te-form of verb'
      expect(find.text('te-form of verb'), findsWidgets);
    });

    testWidgets('VI locale shows meaningVi in card', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness(language: AppLanguage.vi));
      await _pump(tester);

      expect(find.text('Dạng て'), findsWidgets);
    });

    testWidgets('JLPT level pill visible in card', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('N5'), findsWidgets);
    });

    testWidgets('unlearned point shows Learning status pill', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      expect(find.text('Learning'), findsWidgets);
    });

    testWidgets('mastered point shows Mastered status pill', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(_buildHarness(items: [_kDataLearned]));
      await _pump(tester);

      expect(find.text('Mastered'), findsWidgets);
      // Mastered 1/1 chip in header
      expect(find.text('Mastered 1/1'), findsOneWidget);
    });
  });
}
