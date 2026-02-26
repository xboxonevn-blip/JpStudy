import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vocab_item.dart';
import '../../data/repositories/lesson_repository.dart';
import '../mistakes/repositories/mistake_repository.dart';

final vocabGhostCountProvider = FutureProvider<int>((ref) async {
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final mistakes = await mistakeRepo.getMistakesByType('vocab');
  return mistakes.length;
});

final vocabGhostsProvider = FutureProvider<List<VocabItem>>((ref) async {
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final mistakes = await mistakeRepo.getMistakesByType('vocab');
  final ids = mistakes.map((m) => m.itemId).toList();
  return lessonRepo.fetchVocabTermsByIds(ids);
});
