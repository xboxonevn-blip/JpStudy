import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vocab_item.dart';
import '../../data/repositories/lesson_repository.dart';
import '../mistakes/repositories/mistake_repository.dart';

// Reactive count — backed by a DB stream so the badge updates as soon as a
// vocab mistake is cleared, without waiting for the next provider rebuild.
// Mirrors the pattern used by grammarGhostCountProvider.
final vocabGhostCountProvider = StreamProvider<int>((ref) {
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  return mistakeRepo.watchMistakeItemCount(type: 'vocab');
});

final vocabGhostsProvider = FutureProvider<List<VocabItem>>((ref) async {
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  // Use getTopMistakesByType (bounded + sorted) instead of getMistakesByType
  // (unbounded).  Cap at 50 so a large mistake bank doesn't load hundreds of
  // vocab items at once — the ghost review screen already limits session size.
  final mistakes = await mistakeRepo.getTopMistakesByType('vocab', limit: 50);
  if (mistakes.isEmpty) return const [];
  final ids = mistakes.map((m) => m.itemId).toList();
  return lessonRepo.fetchVocabTermsByIds(ids);
});
