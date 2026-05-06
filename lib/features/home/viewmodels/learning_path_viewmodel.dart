import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../data/db/app_database.dart';
import '../models/unit.dart';
import '../models/lesson_node.dart';

final learningPathViewModelProvider =
    NotifierProvider<LearningPathViewModel, AsyncValue<List<Unit>>>(
      LearningPathViewModel.new,
    );

class LearningPathViewModel extends Notifier<AsyncValue<List<Unit>>> {
  late final LessonRepository _repo;

  @override
  AsyncValue<List<Unit>> build() {
    _repo = ref.watch(lessonRepositoryProvider);
    loadPath();
    return const AsyncValue.loading();
  }

  Future<void> loadPath() async {
    try {
      // Both queries are independent — fire in parallel.
      final lessonsFuture = _repo.getAllLessons();
      final statsFuture = _repo.getAllLessonProgress();
      final lessons = await lessonsFuture;
      final statsMap = await statsFuture;

      // Group lessons by JLPT level.
      final grouped = <String, List<UserLessonData>>{};
      for (final lesson in lessons) {
        grouped.putIfAbsent(lesson.level, () => []).add(lesson);
      }

      // Canonical JLPT order so units always display N5 → N1.
      const levelOrder = ['N5', 'N4', 'N3', 'N2', 'N1'];
      const levelColors = {
        'N5': Color(0xFFEC4899), // pink
        'N4': Color(0xFFF97316), // orange
        'N3': Color(0xFF14B8A6), // teal
        'N2': Color(0xFF6366F1), // indigo
        'N1': Color(0xFFEF4444), // red
      };
      const levelDescriptions = {
        'N5': 'Beginner Japanese',
        'N4': 'Elementary Japanese',
        'N3': 'Intermediate Japanese',
        'N2': 'Upper-Intermediate Japanese',
        'N1': 'Advanced Japanese',
      };

      // Process groups in canonical order; unknown levels appended at end.
      final sortedLevels = grouped.keys.toList()
        ..sort((a, b) {
          final ia = levelOrder.indexOf(a);
          final ib = levelOrder.indexOf(b);
          return (ia == -1 ? 999 : ia).compareTo(ib == -1 ? 999 : ib);
        });

      final units = <Unit>[];

      for (final level in sortedLevels) {
        final levelLessons = grouped[level]!
          ..sort((a, b) => a.id.compareTo(b.id));

        final nodes = <LessonNode>[];

        for (final lesson in levelLessons) {
          final stats = statsMap[lesson.id];
          final isCompleted =
              stats != null &&
              stats.termCount > 0 &&
              stats.completedCount == stats.termCount;

          nodes.add(
            LessonNode(
              lesson: lesson,
              status: isCompleted ? LessonStatus.completed : LessonStatus.available,
              stars: isCompleted ? 3 : 0,
              progress: (stats == null || stats.termCount == 0)
                  ? 0.0
                  : stats.completedCount / stats.termCount,
            ),
          );
        }

        units.add(
          Unit(
            id: level,
            title: 'Level $level',
            description: levelDescriptions[level] ?? 'Japanese $level',
            nodes: nodes,
            color: levelColors[level] ?? Colors.blue,
          ),
        );
      }

      state = AsyncValue.data(units);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
