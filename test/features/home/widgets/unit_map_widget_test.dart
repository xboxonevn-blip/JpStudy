import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/home/models/lesson_node.dart';
import 'package:jpstudy/features/home/models/unit.dart';
import 'package:jpstudy/features/home/widgets/lesson_node_widget.dart';
import 'package:jpstudy/features/home/widgets/unit_map_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// UserLessonData is a Drift DataClass → const constructor available.
const _kLesson1 = UserLessonData(
  id: 1,
  level: 'N5',
  title: 'Lesson 1',
  description: 'Basic greetings',
  tags: '',
  isPublic: true,
  isCustomTitle: false,
  learnTermLimit: 10,
  testQuestionLimit: 10,
  matchPairLimit: 5,
);

const _kLesson2 = UserLessonData(
  id: 2,
  level: 'N5',
  title: 'Lesson 2',
  description: 'Numbers',
  tags: '',
  isPublic: true,
  isCustomTitle: false,
  learnTermLimit: 10,
  testQuestionLimit: 10,
  matchPairLimit: 5,
);

// A completed node → isLocked=false, isCompleted=true
// A locked node    → isLocked=true,  isCompleted=false
//
// Arrangement: [completed, locked] ensures _findActiveNodeIndex() returns -1:
//   • indexWhere(!isCompleted && !isLocked) → -1  (no available nodes)
//   • nodes.first.isLocked  → false  (first is completed, not locked)
//   • nodes.last.isCompleted → false (last is locked, not completed)
//   → activeIndex stays -1 → MascotRive NOT rendered (safe for tests).
final _kCompletedNode = LessonNode(
  lesson: _kLesson1,
  status: LessonStatus.completed,
  progress: 1.0,
);
final _kLockedNode = LessonNode(
  lesson: _kLesson2,
  status: LessonStatus.locked,
);

Unit _kUnit({String title = 'Level 1'}) => Unit(
  id: 'u1',
  title: title,
  description: 'Test unit',
  nodes: [_kCompletedNode, _kLockedNode],
  color: const Color(0xFF4C8DFF),
);

Unit _kEmptyUnit() => const Unit(
  id: 'u0',
  title: 'Intro',
  description: '',
  nodes: [],
  color: Color(0xFF4C8DFF),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  required Unit unit,
  AppLanguage language = AppLanguage.en,
  void Function(LessonNode)? onNodeTap,
}) {
  return ProviderScope(
    overrides: [appLanguageProvider.overrideWith((ref) => language)],
    child: MaterialApp(
      home: Scaffold(
        body: UnitMapWidget(
          unit: unit,
          onNodeTap: onNodeTap ?? (_) {},
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('UnitMapWidget – unit header', () {
    testWidgets('renders "Level N" title for EN locale', (tester) async {
      await tester.pumpWidget(_buildHarness(unit: _kUnit()));
      await _pump(tester);

      // title 'Level 1' → _buildUnitHeader: starts with 'Level ' → rewritten
      // EN: '${language.levelLabel} 1' = 'Level 1' (same as raw)
      expect(find.text('Level 1'), findsOneWidget);
    });

    testWidgets('VI locale rewrites "Level N" title', (tester) async {
      await tester.pumpWidget(
        _buildHarness(unit: _kUnit(), language: AppLanguage.vi),
      );
      await _pump(tester);

      // VI levelLabel = 'Cấp độ' → 'Cấp độ 1'
      expect(find.text('Cấp độ 1'), findsOneWidget);
    });

    testWidgets('JA locale rewrites "Level N" title', (tester) async {
      await tester.pumpWidget(
        _buildHarness(unit: _kUnit(), language: AppLanguage.ja),
      );
      await _pump(tester);

      // JA levelLabel = 'レベル' → 'レベル 1'
      expect(find.text('レベル 1'), findsOneWidget);
    });

    testWidgets('custom title (no Level prefix) is rendered verbatim',
        (tester) async {
      await tester.pumpWidget(
        _buildHarness(unit: _kUnit(title: 'Greetings Chapter')),
      );
      await _pump(tester);

      expect(find.text('Greetings Chapter'), findsOneWidget);
    });

    testWidgets('flag icon always rendered in header', (tester) async {
      await tester.pumpWidget(_buildHarness(unit: _kUnit()));
      await _pump(tester);

      expect(find.byIcon(Icons.flag_rounded), findsOneWidget);
    });
  });

  group('UnitMapWidget – node rendering', () {
    testWidgets('renders one LessonNodeWidget per node', (tester) async {
      await tester.pumpWidget(_buildHarness(unit: _kUnit()));
      await _pump(tester);

      expect(find.byType(LessonNodeWidget), findsNWidgets(2));
    });

    testWidgets('empty nodes list renders header without node widgets',
        (tester) async {
      await tester.pumpWidget(_buildHarness(unit: _kEmptyUnit()));
      await _pump(tester);

      // Header still rendered
      expect(find.text('Intro'), findsOneWidget);
      // No lesson node widgets
      expect(find.byType(LessonNodeWidget), findsNothing);
    });

    testWidgets('lesson labels shown beside each regular node', (tester) async {
      await tester.pumpWidget(_buildHarness(unit: _kUnit()));
      await _pump(tester);

      // _localizedLessonTitle: 'Lesson 1' → 'Lesson 1' (EN)
      // _localizedLessonTitle: 'Lesson 2' → 'Lesson 2' (EN)
      // Both nodes are regular (activeIndex=-1) → both show _LessonLabel
      expect(find.text('Lesson 1'), findsOneWidget);
      expect(find.text('Lesson 2'), findsOneWidget);
    });

    testWidgets('lesson labels use localized title for VI locale',
        (tester) async {
      await tester.pumpWidget(
        _buildHarness(unit: _kUnit(), language: AppLanguage.vi),
      );
      await _pump(tester);

      // VI lessonLabel = 'Bài' → 'Bài 1', 'Bài 2'
      expect(find.text('Bài 1'), findsOneWidget);
      expect(find.text('Bài 2'), findsOneWidget);
    });
  });

  group('UnitMapWidget – node tap', () {
    testWidgets('tapping a completed (unlocked) node fires onNodeTap',
        (tester) async {
      LessonNode? tappedNode;
      await tester.pumpWidget(
        _buildHarness(
          unit: _kUnit(),
          onNodeTap: (node) => tappedNode = node,
        ),
      );
      await _pump(tester);

      // Tap the first GestureDetector (belongs to the completed node at index 0)
      await tester.tap(find.byType(GestureDetector).first);
      await _pump(tester);

      expect(tappedNode, isNotNull);
      expect(tappedNode!.lesson.id, equals(1)); // _kLesson1
    });
  });
}
