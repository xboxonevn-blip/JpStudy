import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

final gameVocabPoolProvider = FutureProvider.autoDispose<List<VocabItem>>((ref) async {
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final level = ref.watch(studyLevelProvider)?.shortLabel ?? 'N5';

  final dueTerms = await lessonRepo.fetchAllDueTerms();
  final mistakes = await mistakeRepo.getAllMistakes();

  final vocabMistakeIds = mistakes
      .where((m) => m.type == 'vocab')
      .map((m) => m.itemId)
      .toSet();

  final poolIds = <int>{};

  for (final term in dueTerms.take(30)) {
    poolIds.add(term.id);
  }

  if (poolIds.length < 40 && vocabMistakeIds.isNotEmpty) {
    poolIds.addAll(vocabMistakeIds.take(40 - poolIds.length));
  }

  if (poolIds.length < 10) {
    final preview = await ref.watch(vocabPreviewProvider(level).future);
    return preview
        .map(
          (p) => VocabItem(
            id: p.id,
            term: p.term,
            reading: p.reading ?? '',
            meaning: p.meaning,
            meaningEn: p.meaningEn,
            level: p.level,
          ),
        )
        .toList(growable: false);
  }

  final items = await lessonRepo.fetchVocabTermsByIds(poolIds.toList());
  items.shuffle();
  return items;
});
