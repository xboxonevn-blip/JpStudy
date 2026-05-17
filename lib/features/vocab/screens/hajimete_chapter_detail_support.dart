import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/vocab/vocab_content_timeout.dart';

class HajimeteChapterDetailArgs {
  const HajimeteChapterDetailArgs({
    required this.levelCode,
    required this.chapterId,
    required this.laneTitle,
  });

  final String levelCode;
  final int chapterId;
  final String laneTitle;

  @override
  bool operator ==(Object other) {
    return other is HajimeteChapterDetailArgs &&
        other.levelCode == levelCode &&
        other.chapterId == chapterId &&
        other.laneTitle == laneTitle;
  }

  @override
  int get hashCode => Object.hash(levelCode, chapterId, laneTitle);
}

final hajimeteChapterDetailProvider =
    FutureProvider.family<HajimeteChapterDetail?, HajimeteChapterDetailArgs>((
      ref,
      args,
    ) {
      return withVocabContentTimeout(
        loadHajimeteChapterDetail(args.levelCode, args.chapterId),
        ref: ref,
      );
    });

final hajimeteChapterItemsProvider =
    FutureProvider.family<List<VocabItem>, HajimeteChapterDetailArgs>((
      ref,
      args,
    ) {
      final repo = ref.watch(lessonRepositoryProvider);
      return withVocabContentTimeout(
        repo.getVocabByLevelSeriesChapterRange(
          args.levelCode,
          series: 'hajimete',
          startChapter: args.chapterId,
          endChapter: args.chapterId,
        ),
        ref: ref,
      );
    });

final hajimeteChapterDueItemsProvider =
    FutureProvider.family<List<VocabItem>, HajimeteChapterDetailArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final items = await ref.watch(hajimeteChapterItemsProvider(args).future);
      final states = await withVocabContentTimeout(
        repo.getSrsStatesForIds(items.map((item) => item.id).toList()),
        ref: ref,
      );
      final now = DateTime.now();
      return items.where((item) {
        final state = states[item.id];
        return state != null && !state.nextReviewAt.isAfter(now);
      }).toList();
    });

final hajimeteChapterSrsStatesProvider =
    FutureProvider.family<Map<int, SrsStateData>, HajimeteChapterDetailArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final items = await ref.watch(hajimeteChapterItemsProvider(args).future);
      return withVocabContentTimeout(
        repo.getSrsStatesForIds(items.map((item) => item.id).toList()),
        ref: ref,
      );
    });

final hajimeteChapterUserTermsProvider =
    FutureProvider.family<List<UserLessonTermData>, HajimeteChapterDetailArgs>((
      ref,
      args,
    ) {
      final repo = ref.watch(lessonRepositoryProvider);
      return withVocabContentTimeout(
        repo.fetchTermsForHajimeteChapter(
          args.levelCode,
          chapterId: args.chapterId,
          title: args.laneTitle,
        ),
        ref: ref,
      );
    });

final hajimeteKanjiChapterProvider =
    FutureProvider.family<
      HajimeteKanjiChapterDetail?,
      HajimeteChapterDetailArgs
    >((ref, args) {
      return withVocabContentTimeout(
        loadHajimeteKanjiChapterDetail(args.levelCode, args.chapterId),
        ref: ref,
      );
    });

Map<int, UserLessonTermData> mapHajimeteUserTermsByItemId(
  List<VocabItem> items,
  List<UserLessonTermData> userTerms,
) {
  final lookup = <String, UserLessonTermData>{
    for (final term in userTerms) userTermIdentityKey(term): term,
  };
  final result = <int, UserLessonTermData>{};
  for (final item in items) {
    final match = lookup[vocabIdentityKey(item)];
    if (match != null) {
      result[item.id] = match;
    }
  }
  return result;
}

String vocabIdentityKey(VocabItem item) {
  return [
    normalizeHajimeteKeyPart(item.term),
    normalizeHajimeteKeyPart(item.reading ?? ''),
    normalizeHajimeteKeyPart(item.meaning),
  ].join('|');
}

String userTermIdentityKey(UserLessonTermData term) {
  return [
    normalizeHajimeteKeyPart(term.term),
    normalizeHajimeteKeyPart(term.reading),
    normalizeHajimeteKeyPart(term.definition),
  ].join('|');
}

final _whitespaceRe = RegExp(r'\s+');

String normalizeHajimeteKeyPart(String value) {
  return value.trim().replaceAll(_whitespaceRe, ' ').toLowerCase();
}

double? hajimeteRetrievabilityForItem(
  VocabItem item,
  Map<int, SrsStateData> srsStates,
) {
  final state = srsStates[item.id];
  if (state == null) {
    return null;
  }
  final fsrs = FsrsService();
  return fsrs.retrievability(
    stability: state.stability,
    lastReviewedAt: state.lastReviewedAt,
  );
}
