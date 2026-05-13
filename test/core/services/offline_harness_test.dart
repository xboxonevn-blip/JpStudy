import 'package:flutter_test/flutter_test.dart';

class _OfflineMutation {
  const _OfflineMutation({
    required this.itemType,
    required this.itemId,
    required this.rating,
  });

  final String itemType;
  final int itemId;
  final int rating;
}

class _OfflineHarness {
  _OfflineHarness({
    required List<int> cachedKanjiIds,
    required List<int> cachedVocabIds,
  }) : _cachedKanjiIds = cachedKanjiIds.toSet(),
       _cachedVocabIds = cachedVocabIds.toSet();

  final Set<int> _cachedKanjiIds;
  final Set<int> _cachedVocabIds;
  final List<_OfflineMutation> _queue = [];
  final Map<String, int> _remoteRatings = {};
  var online = true;

  List<int> loadKanjiData() {
    if (!online && _cachedKanjiIds.isEmpty) {
      throw StateError('No cached kanji data');
    }
    return _cachedKanjiIds.toList()..sort();
  }

  List<int> loadVocabData() {
    if (!online && _cachedVocabIds.isEmpty) {
      throw StateError('No cached vocab data');
    }
    return _cachedVocabIds.toList()..sort();
  }

  void studyOffline(String itemType, int itemId, int rating) {
    final cache = itemType == 'vocab' ? _cachedVocabIds : _cachedKanjiIds;
    if (!cache.contains(itemId)) {
      throw StateError('$itemType $itemId is not cached');
    }
    final key = '$itemType:$itemId';
    if (online) {
      _remoteRatings[key] = rating;
      return;
    }
    _queue.add(
      _OfflineMutation(itemType: itemType, itemId: itemId, rating: rating),
    );
  }

  int get queuedMutations => _queue.length;

  Future<void> reconnectAndSync() async {
    online = true;
    final latestByItem = <String, int>{};
    for (final mutation in _queue) {
      latestByItem['${mutation.itemType}:${mutation.itemId}'] = mutation.rating;
    }
    _remoteRatings.addAll(latestByItem);
    _queue.clear();
  }

  int? remoteRatingFor(String itemType, int itemId) {
    return _remoteRatings['$itemType:$itemId'];
  }
}

void main() {
  test(
    'offline harness serves cached kana/kanji/vocab data and syncs queued mutations',
    () async {
      final harness = _OfflineHarness(
        cachedKanjiIds: List.generate(185, (i) => i + 1),
        cachedVocabIds: List.generate(200, (i) => i + 1),
      );

      harness.online = false;
      expect(harness.loadKanjiData(), hasLength(185));
      expect(harness.loadVocabData(), hasLength(200));

      for (final kanjiId in [1, 2, 3, 4, 5]) {
        harness.studyOffline('kanji', kanjiId, kanjiId == 1 ? 1 : 3);
      }
      harness.studyOffline('kanji', 3, 4);
      for (final vocabId in [1, 2, 3, 4, 5]) {
        harness.studyOffline('vocab', vocabId, vocabId <= 2 ? 1 : 3);
      }

      expect(harness.queuedMutations, 11);
      expect(harness.remoteRatingFor('kanji', 3), isNull);
      expect(harness.remoteRatingFor('vocab', 3), isNull);

      await harness.reconnectAndSync();

      expect(harness.queuedMutations, 0);
      expect(harness.remoteRatingFor('kanji', 1), 1);
      expect(harness.remoteRatingFor('kanji', 2), 3);
      expect(harness.remoteRatingFor('kanji', 3), 4);
      expect(harness.remoteRatingFor('kanji', 4), 3);
      expect(harness.remoteRatingFor('kanji', 5), 3);
      expect(harness.remoteRatingFor('vocab', 1), 1);
      expect(harness.remoteRatingFor('vocab', 2), 1);
      expect(harness.remoteRatingFor('vocab', 3), 3);
      expect(harness.remoteRatingFor('vocab', 4), 3);
      expect(harness.remoteRatingFor('vocab', 5), 3);
    },
  );
}
