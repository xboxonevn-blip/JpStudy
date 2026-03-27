import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/practice/providers/practice_session_board_provider.dart';

void main() {
  group('buildPracticeSessionBoard', () {
    test('prefers Recall Sprint when multiple due queues are active', () {
      final board = buildPracticeSessionBoard(
        language: AppLanguage.en,
        level: StudyLevel.n5,
        dashboard: const DashboardState(
          streak: 0,
          todayXp: 0,
          vocabDue: 3,
          grammarDue: 2,
          kanjiDue: 1,
          vocabMistakeCount: 0,
          grammarMistakeCount: 0,
          kanjiMistakeCount: 0,
          totalMistakeCount: 0,
        ),
        continueAction: const ContinueAction(
          type: ContinueActionType.grammarReview,
          label: 'Review grammar',
          count: 2,
          data: [1, 2],
        ),
      );

      expect(board.primaryAction.route, '/practice/recall-sprint');
      expect(board.steps[1].route, '/grammar-practice');
      expect(board.headline, 'Protect the review queue first');
    });

    test('promotes grammar ghost repair when due queue is clear', () {
      final board = buildPracticeSessionBoard(
        language: AppLanguage.en,
        level: StudyLevel.n5,
        dashboard: const DashboardState(
          streak: 0,
          todayXp: 0,
          vocabDue: 0,
          grammarDue: 0,
          kanjiDue: 0,
          vocabMistakeCount: 0,
          grammarMistakeCount: 0,
          kanjiMistakeCount: 0,
          totalMistakeCount: 1,
        ),
        continueAction: const ContinueAction(
          type: ContinueActionType.practiceMixed,
          label: 'Practice',
        ),
        grammarGhostCount: 2,
      );

      expect(board.primaryAction.route, '/grammar-practice');
      expect(board.primaryAction.extra, GrammarPracticeMode.ghost);
      expect(board.repairCount, 3);
      expect(board.headline, 'Repair the weak spots while they are fresh');
    });

    test('follows a specific weakness radar item before generic deepening', () {
      final board = buildPracticeSessionBoard(
        language: AppLanguage.en,
        level: StudyLevel.n4,
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
        weaknessItems: const [
          WeaknessRadarItem(
            id: 'recovery_pack',
            title: 'Recovery pack from Lesson 5',
            subtitle: '4 weak terms are ready for a clean-up round.',
            route: '/learn/recovery-pack',
            icon: IconData(0xe3c9, fontFamily: 'MaterialIcons'),
            color: Color(0xFF2563EB),
          ),
        ],
      );

      expect(board.primaryAction.route, '/learn/recovery-pack');
      expect(board.steps.map((item) => item.route), contains('/lesson/12'));
      expect(board.steps.map((item) => item.route), contains('/jlpt/coach'));
    });
  });
}
