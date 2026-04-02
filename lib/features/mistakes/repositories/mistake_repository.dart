import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/daos/mistake_dao.dart';
import '../../../data/models/mistake_context.dart';

final mistakeRepositoryProvider = Provider<MistakeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MistakeRepository(db.mistakeDao);
});

final mistakesByTypeProvider = FutureProvider.family<List<UserMistake>, String>(
  (ref, type) async {
    final repo = ref.watch(mistakeRepositoryProvider);
    return repo.getMistakesByType(type);
  },
);

class MistakeRepository {
  final MistakeDao _dao;

  MistakeRepository(this._dao);

  Stream<int> watchTotalMistakes() {
    return _dao.watchTotalMistakes();
  }

  Stream<int> watchVocabMistakeItemCount() {
    return _dao.watchMistakeItemCount(type: 'vocab');
  }

  Future<void> addMistake({
    required String type,
    required int itemId,
    MistakeContext? context,
  }) async {
    await _dao.addMistake(
      type,
      itemId,
      prompt: context?.prompt,
      correctAnswer: context?.correctAnswer,
      userAnswer: context?.userAnswer,
      source: context?.source,
      extraJson: context?.extraJson,
    );
  }

  Future<void> removeMistake({
    required String type,
    required int itemId,
  }) async {
    await _dao.removeMistake(type, itemId);
  }

  Future<void> markCorrect({required String type, required int itemId}) async {
    await _dao.markCorrect(type, itemId);
  }

  Future<List<UserMistake>> getMistakesByType(String type) {
    return _dao.getMistakesByType(type);
  }

  Future<int> getMistakeCountByType(String type) {
    return _dao.getMistakeCountByType(type);
  }

  Future<List<UserMistake>> getAllMistakes() {
    return _dao.getAllMistakes();
  }

  /// Returns the top [limit] highest-priority mistakes for [type].
  /// Much cheaper than [getAllMistakes] + Dart-side filtering when the
  /// caller only needs a small slice of the mistake bank.
  Future<List<UserMistake>> getTopMistakesByType(
    String type, {
    int limit = 10,
  }) {
    return _dao.getTopMistakesByType(type, limit: limit);
  }

  Stream<List<UserMistake>> watchAllMistakes({int? limit, int? offset}) {
    return _dao.watchAllMistakes(limit: limit, offset: offset);
  }

  /// Stream of mistake counts grouped by type — (vocab, grammar, kanji, total).
  /// Uses a GROUP BY query; only 3 rows are transferred regardless of deck size.
  Stream<({int vocab, int grammar, int kanji, int total})> watchMistakeCounts() {
    return _dao.watchMistakeCounts();
  }

  /// One-shot variant of [watchMistakeCounts].
  Future<({int vocab, int grammar, int kanji, int total})> getMistakeCounts() {
    return _dao.getMistakeCounts();
  }
}
