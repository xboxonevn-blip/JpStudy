import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/study_hub/providers/study_hub_board_provider.dart';

void main() {
  group('buildStudyHubDecksBoard', () {
    test('prioritizes due lessons and splits completed decks', () {
      final board = buildStudyHubDecksBoard([
        LessonMeta(
          id: 2,
          level: 'n5',
          title: 'Lesson 2',
          isCustomTitle: false,
          tags: '',
          termCount: 20,
          completedCount: 20,
          dueCount: 0,
          updatedAt: DateTime(2026, 3, 1),
        ),
        LessonMeta(
          id: 3,
          level: 'n5',
          title: 'Lesson 3',
          isCustomTitle: false,
          tags: '',
          termCount: 20,
          completedCount: 6,
          dueCount: 5,
          updatedAt: DateTime(2026, 3, 2),
        ),
        LessonMeta(
          id: 1,
          level: 'n5',
          title: 'Lesson 1',
          isCustomTitle: false,
          tags: '',
          termCount: 20,
          completedCount: 10,
          dueCount: 0,
          updatedAt: DateTime(2026, 3, 3),
        ),
      ]);

      expect(board.nextUp?.id, 3);
      expect(board.activeDecks.map((deck) => deck.id), [1]);
      expect(board.completedDecks.map((deck) => deck.id), [2]);
    });
  });
}
