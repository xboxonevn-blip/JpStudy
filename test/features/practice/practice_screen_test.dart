import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';

const _kDashboard = DashboardState(
  streak: 3,
  todayXp: 10,
  vocabDue: 5,
  grammarDue: 2,
  kanjiDue: 1,
  vocabMistakeCount: 1,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 1,
);

Widget _buildScreen({
  DashboardState dashboard = _kDashboard,
  ContinueAction? continueAction,
  List<WeaknessRadarItem> weaknessItems = const [],
  int grammarGhostCount = 0,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      dashboardProvider.overrideWith((ref) => Stream.value(dashboard)),
      continueActionProvider.overrideWith(
        (ref) async =>
            continueAction ??
            const ContinueAction(
              type: ContinueActionType.grammarReview,
              label: 'Review grammar',
              count: 2,
              data: [11, 12],
            ),
      ),
      weaknessRadarProvider.overrideWith((ref) async => weaknessItems),
      grammarGhostCountProvider.overrideWith((ref) async* {
        yield grammarGhostCount;
      }),
    ],
    child: const MaterialApp(home: PracticeScreen()),
  );
}

void main() {
  group('PracticeScreen — rendering', () {
    testWidgets('shows app bar with Practice title', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Study'), findsOneWidget);
    });

    testWidgets('shows search icon button', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('renders practice destination tiles', (tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show standard practice destinations
      expect(find.text(AppLanguage.en.practiceMatchLabel), findsWidgets);
    });

    testWidgets('shows a session plan instead of a generic goals grid', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Today plan'), findsOneWidget);
      expect(find.text('Run Recall Sprint first'), findsWidgets);
      expect(find.text('Clear the grammar queue'), findsAtLeastNWidgets(1));
      expect(find.text('Focus tools'), findsOneWidget);
    });

    testWidgets('surfaces grammar ghost repair when no due queue is waiting', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildScreen(
          dashboard: const DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
          continueAction: const ContinueAction(
            type: ContinueActionType.practiceMixed,
            label: 'Practice',
          ),
          grammarGhostCount: 3,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repair grammar ghosts'), findsWidgets);
      expect(find.text('Queue and repair'), findsOneWidget);
    });

    testWidgets('renders with zero-due dashboard', (tester) async {
      await tester.pumpWidget(
        _buildScreen(
          dashboard: const DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
          continueAction: const ContinueAction(
            type: ContinueActionType.nextLesson,
            label: 'Lesson 12',
            data: 12,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Screen renders without error
      expect(find.byType(PracticeScreen), findsOneWidget);
    });

    testWidgets('session step CTA keeps a 44px touch target', (tester) async {
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      final cta = find.byKey(
        const ValueKey('practice_session_step_cta_grammar_due'),
      );
      await tester.ensureVisible(cta);
      final size = tester.getSize(cta);
      expect(size.width, greaterThanOrEqualTo(AppTouchTargets.min));
      expect(size.height, greaterThanOrEqualTo(AppTouchTargets.min));
    });
  });
}
