import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class VocabDetail {
  const VocabDetail({
    required this.vocab,
    this.srs,
    this.kanjiList = const [],
    this.relatedVocab = const [],
  });

  final VocabData vocab;
  final SrsStateData? srs;
  final List<KanjiData> kanjiList;
  final List<VocabData> relatedVocab;

  String get srsStageLabel {
    if (srs == null) return 'unstudied';
    final s = srs!.stability;
    if (s < 1.0) return 'learning';
    if (s < 21.0) return 'young';
    return 'mature';
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final vocabDetailProvider =
    FutureProvider.family<VocabDetail?, int>((ref, vocabId) async {
  final contentDb = ref.watch(contentDatabaseProvider);
  final appDb = ref.watch(databaseProvider);

  // 1. Fetch vocab first (needed to know level + term for downstream queries)
  final vocab = await (contentDb.select(contentDb.vocab)
        ..where((t) => t.id.equals(vocabId)))
      .getSingleOrNull();
  if (vocab == null) return null;

  // 2–4. Fire SRS state, kanji batch lookup, and related vocab concurrently —
  //      all three are independent once we have the vocab row.
  final srsDao = SrsDao(appDb);
  final kanjiChars = _extractKanji(vocab.term);

  final srsFuture = srsDao.getSrsState(vocabId);
  final kanjiFuture = kanjiChars.isNotEmpty
      ? (contentDb.select(contentDb.kanji)
              ..where((t) => t.character.isIn(kanjiChars)))
          .get()
      : Future.value(const <KanjiData>[]);
  final relatedFuture = (contentDb.select(contentDb.vocab)
        ..where(
          (t) => t.level.equals(vocab.level) & t.id.equals(vocabId).not(),
        )
        ..limit(5))
      .get();

  final srs = await srsFuture;
  final kanjiList = await kanjiFuture;
  final related = await relatedFuture;

  // Preserve kanji order matching the term's character order.
  final kanjiByChar = {for (final k in kanjiList) k.character: k};
  final orderedKanji = [
    for (final char in kanjiChars)
      if (kanjiByChar[char] != null) kanjiByChar[char]!,
  ];

  return VocabDetail(
    vocab: vocab,
    srs: srs,
    kanjiList: orderedKanji,
    relatedVocab: related,
  );
});

/// Extracts unique CJK Unified Ideograph characters from a string.
List<String> _extractKanji(String text) {
  final result = <String>[];
  final seen = <String>{};
  for (final rune in text.runes) {
    // CJK Unified Ideographs: U+4E00 – U+9FFF
    if (rune >= 0x4E00 && rune <= 0x9FFF) {
      final char = String.fromCharCode(rune);
      if (seen.add(char)) {
        result.add(char);
      }
    }
  }
  return result;
}
