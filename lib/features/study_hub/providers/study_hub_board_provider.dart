import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

class StudyHubLessonDeck {
  const StudyHubLessonDeck({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.dueCount,
    required this.isFinished,
  });

  final int id;
  final String title;
  final int progressPercent;
  final int dueCount;
  final bool isFinished;
}

class StudyHubDecksBoard {
  const StudyHubDecksBoard({
    required this.nextUp,
    required this.activeDecks,
    required this.completedDecks,
  });

  final StudyHubLessonDeck? nextUp;
  final List<StudyHubLessonDeck> activeDecks;
  final List<StudyHubLessonDeck> completedDecks;
}

final studyHubDecksProvider = FutureProvider.autoDispose<StudyHubDecksBoard>((ref) async {
  final level = ref.watch(studyLevelProvider)?.name ?? 'n5';
  final lessonRepo = ref.watch(lessonRepositoryProvider);

  final meta = await lessonRepo.fetchLessonMeta(level);
  return buildStudyHubDecksBoard(meta);
});

StudyHubDecksBoard buildStudyHubDecksBoard(List<LessonMeta> meta) {
  if (meta.isEmpty) {
    return const StudyHubDecksBoard(
      nextUp: null,
      activeDecks: [],
      completedDecks: [],
    );
  }

  final decks = meta.map((m) {
    final progress = m.termCount > 0 ? ((m.completedCount / m.termCount) * 100).round() : 0;
    return StudyHubLessonDeck(
      id: m.id,
      title: m.title,
      progressPercent: progress,
      dueCount: m.dueCount,
      isFinished: progress >= 100 && m.dueCount == 0,
    );
  }).where((d) => d.progressPercent > 0 || d.dueCount > 0).toList();

  decks.sort((a, b) {
    // Priority: due items first, then incomplete ones by ID
    if (a.dueCount > 0 && b.dueCount == 0) return -1;
    if (b.dueCount > 0 && a.dueCount == 0) return 1;
    if (a.dueCount > 0 && b.dueCount > 0) return b.dueCount.compareTo(a.dueCount);
    
    if (!a.isFinished && b.isFinished) return -1;
    if (a.isFinished && !b.isFinished) return 1;

    return a.id.compareTo(b.id);
  });

  final nextUp = decks.isNotEmpty && (!decks.first.isFinished || decks.first.dueCount > 0) ? decks.first : null;
  final activeDecks = decks.where((d) => !d.isFinished && d.id != nextUp?.id).toList();
  final completedDecks = decks.where((d) => d.isFinished && d.id != nextUp?.id).toList();

  return StudyHubDecksBoard(
    nextUp: nextUp,
    activeDecks: activeDecks,
    completedDecks: completedDecks,
  );
}
