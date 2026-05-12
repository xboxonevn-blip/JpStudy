import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/home/models/lesson_node.dart';
import 'package:jpstudy/features/home/widgets/lesson_node_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// Title starts with 'Lesson ' — triggers _localizedLessonTitle rewrite.
const _kLesson = UserLessonData(
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

// Custom title that does NOT start with 'Lesson ' — returned verbatim.
const _kCustomLesson = UserLessonData(
  id: 2,
  level: 'N5',
  title: 'Greetings & Introductions',
  description: '',
  tags: '',
  isPublic: true,
  isCustomTitle: true,
  learnTermLimit: 10,
  testQuestionLimit: 10,
  matchPairLimit: 5,
);

final _kAvailableNode = LessonNode(
  lesson: _kLesson,
  status: LessonStatus.available,
  progress: 0.4, // 40 %
);

final _kLockedNode = LessonNode(lesson: _kLesson, status: LessonStatus.locked);

final _kCompletedNode = LessonNode(
  lesson: _kLesson,
  status: LessonStatus.completed,
  stars: 3,
  progress: 1.0,
);

final _kCustomNode = LessonNode(
  lesson: _kCustomLesson,
  status: LessonStatus.available,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  required LessonNode node,
  AppLanguage language = AppLanguage.en,
  bool isPrimaryActive = false,
  VoidCallback? onTap,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: LessonNodeWidget(
            node: node,
            size: 160,
            isPrimaryActive: isPrimaryActive,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );
}

// Use explicit pump steps instead of pumpAndSettle when isPrimaryActive=true
// because the pulse AnimationController runs repeat(reverse:true) — infinite
// loop that would cause pumpAndSettle() to timeout.
Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LessonNodeWidget – active node (isPrimaryActive=true)', () {
    testWidgets('renders localized title "Lesson 1" for EN', (tester) async {
      await tester.pumpWidget(
        _buildHarness(node: _kAvailableNode, isPrimaryActive: true),
      );
      await _pump(tester);

      // _localizedLessonTitle rewrites 'Lesson 1' → 'Lesson 1' (EN lessonLabel)
      expect(find.text('Lesson 1'), findsOneWidget);
    });

    testWidgets('renders progress percentage and track-progress label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(node: _kAvailableNode, isPrimaryActive: true),
      );
      await _pump(tester);

      // progress=0.4 → '40%'
      expect(find.text('40%'), findsOneWidget);
      // trackProgressLabel.toUpperCase()
      expect(find.text('TRACK PROGRESS'), findsOneWidget);
    });

    testWidgets('renders description subtitle when non-empty', (tester) async {
      await tester.pumpWidget(
        _buildHarness(node: _kAvailableNode, isPrimaryActive: true),
      );
      await _pump(tester);

      expect(find.text('Basic greetings'), findsOneWidget);
    });

    testWidgets('custom title (no Lesson prefix) is returned verbatim', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(node: _kCustomNode, isPrimaryActive: true),
      );
      await _pump(tester);

      expect(find.text('Greetings & Introductions'), findsOneWidget);
    });

    testWidgets('VI locale rewrites title to "Bài 1"', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          node: _kAvailableNode,
          language: AppLanguage.vi,
          isPrimaryActive: true,
        ),
      );
      await _pump(tester);

      expect(find.text('Bài 1'), findsOneWidget);
    });

    testWidgets('VI locale shows Vietnamese track-progress label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          node: _kAvailableNode,
          language: AppLanguage.vi,
          isPrimaryActive: true,
        ),
      );
      await _pump(tester);

      // 'Theo dõi tiến độ'.toUpperCase()
      expect(find.text('THEO DÕI TIẾN ĐỘ'), findsOneWidget);
    });

    testWidgets('JA locale rewrites title to "レッスン 1"', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          node: _kAvailableNode,
          language: AppLanguage.ja,
          isPrimaryActive: true,
        ),
      );
      await _pump(tester);

      expect(find.text('レッスン 1'), findsOneWidget);
    });

    testWidgets('100% progress shows "100%"', (tester) async {
      await tester.pumpWidget(
        _buildHarness(node: _kCompletedNode, isPrimaryActive: true),
      );
      await _pump(tester);

      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('LessonNodeWidget – regular node (isPrimaryActive=false)', () {
    testWidgets('available node shows play-arrow icon', (tester) async {
      await tester.pumpWidget(_buildHarness(node: _kAvailableNode));
      await _pump(tester);

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('completed node shows check icon', (tester) async {
      await tester.pumpWidget(_buildHarness(node: _kCompletedNode));
      await _pump(tester);

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('locked node shows lock icon', (tester) async {
      await tester.pumpWidget(_buildHarness(node: _kLockedNode));
      await _pump(tester);

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });
  });

  group('LessonNodeWidget – tap behaviour', () {
    testWidgets('available node fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildHarness(node: _kAvailableNode, onTap: () => tapped = true),
      );
      await _pump(tester);

      await tester.tap(find.byType(GestureDetector));
      await _pump(tester);

      expect(tapped, isTrue);
    });

    testWidgets('locked node does NOT fire onTap even when provided', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _buildHarness(node: _kLockedNode, onTap: () => tapped = true),
      );
      await _pump(tester);

      await tester.tap(find.byType(GestureDetector));
      await _pump(tester);

      // _canTap = !isLocked && onTap != null → false when locked
      expect(tapped, isFalse);
    });

    testWidgets('available node with onTap=null does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness(node: _kAvailableNode));
      await _pump(tester);

      await expectLater(() async {
        await tester.tap(find.byType(GestureDetector));
        await _pump(tester);
      }, returnsNormally);
    });
  });
}
