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

  // Both futures start before any await — true parallel execution.
  // Use getTopMistakesByType (bounded, SQL-filtered) instead of getAllMistakes()
  // to avoid a full-table scan when the mistake bank is large.
  final dueTermsFuture = lessonRepo.fetchAllDueTerms();
  final mistakesFuture = mistakeRepo.getTopMistakesByType('vocab', limit: 40);
  final dueTerms = await dueTermsFuture;
  final mistakes = await mistakesFuture;

  final vocabMistakeIds = mistakes.map((m) => m.itemId).toSet();

  final poolIds = <int>{};

  for (final term in dueTerms.take(30)) {
    poolIds.add(term.id);
  }

  if (poolIds.length < 40 && vocabMistakeIds.isNotEmpty) {
    poolIds.addAll(vocabMistakeIds.take(40 - poolIds.length));
  }

  if (poolIds.length < 10) {
    // Use ref.read inside the conditional to avoid a Riverpod lint warning
    // about conditionally watching a provider (watch must be unconditional).
    final preview = await ref.read(vocabPreviewProvider(level).future);
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
