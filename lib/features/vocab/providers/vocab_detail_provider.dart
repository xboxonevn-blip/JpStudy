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

  // 1. Fetch vocab from content DB
  final vocab = await (contentDb.select(contentDb.vocab)
        ..where((t) => t.id.equals(vocabId)))
      .getSingleOrNull();
  if (vocab == null) return null;

  // 2. Fetch SRS state from app DB (linked via vocabId)
  final srsDao = SrsDao(appDb);
  final srs = await srsDao.getSrsState(vocabId);

  // 3. Extract kanji characters from the term and look them up
  final kanjiChars = _extractKanji(vocab.term);
  final kanjiList = <KanjiData>[];
  if (kanjiChars.isNotEmpty) {
    for (final char in kanjiChars) {
      final found = await (contentDb.select(contentDb.kanji)
            ..where((t) => t.character.equals(char)))
          .getSingleOrNull();
      if (found != null) kanjiList.add(found);
    }
  }

  // 4. Find related vocab (same level, first 5 excluding self)
  final related = await (contentDb.select(contentDb.vocab)
        ..where(
            (t) => t.level.equals(vocab.level) & t.id.equals(vocabId).not())
        ..limit(5))
      .get();

  return VocabDetail(
    vocab: vocab,
    srs: srs,
    kanjiList: kanjiList,
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
