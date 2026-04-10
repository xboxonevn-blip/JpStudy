import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/library/models/library_roadmap.dart';

void main() {
  test('prioritizes the most urgent due lesson in the roadmap board', () {
    final board = buildLibraryRoadmapBoard(
      language: AppLanguage.en,
      level: StudyLevel.n5,
      fallbackLessonId: 1,
      lessons: const [
        LessonMeta(
          id: 1,
          level: 'N5',
          title: 'Lesson 1',
          isCustomTitle: false,
          tags: '',
          termCount: 20,
          completedCount: 8,
          dueCount: 2,
          updatedAt: null,
        ),
        LessonMeta(
          id: 2,
          level: 'N5',
          title: 'Lesson 2',
          isCustomTitle: false,
          tags: '',
          termCount: 18,
          completedCount: 9,
          dueCount: 5,
          updatedAt: null,
        ),
        LessonMeta(
          id: 3,
          level: 'N5',
          title: 'Lesson 3',
          isCustomTitle: false,
          tags: '',
          termCount: 15,
          completedCount: 0,
          dueCount: 0,
          updatedAt: null,
        ),
      ],
    );

    expect(board.headline, 'Stabilize the lesson queue first');
    expect(board.primaryAction.route, AppRouteLocation.lessonDetail(2));
    expect(board.primaryAction.badge, '5 due');
    expect(board.stats[1].value, '2');
    expect(board.quickActions.last.route, AppRoutePath.search);
  });

  test(
    'falls back to the first lesson when the level has no tracked lessons',
    () {
      final board = buildLibraryRoadmapBoard(
        language: AppLanguage.en,
        level: StudyLevel.n4,
        fallbackLessonId: 26,
        lessons: const [],
      );

      expect(board.headline, 'Start building the level map');
      expect(board.primaryAction.route, AppRouteLocation.lessonDetail(26));
      expect(board.primaryAction.ctaLabel, 'Open first lesson');
      expect(board.quickActions, hasLength(1));
      expect(board.quickActions.single.route, AppRoutePath.search);
      expect(board.stats[0].value, '0%');
    },
  );
}
