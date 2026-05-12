import 'package:flutter_test/flutter_test.dart';

class _OfflineMutation {
  const _OfflineMutation({required this.kanjiId, required this.rating});
  final int kanjiId;
  final int rating;
}

class _OfflineHarness {
  _OfflineHarness({required List<int> cachedKanjiIds})
    : _cachedKanjiIds = cachedKanjiIds.toSet();

  final Set<int> _cachedKanjiIds;
  final List<_OfflineMutation> _queue = [];
  final Map<int, int> _remoteRatings = {};
  var online = true;

  List<int> loadKanjiData() {
    if (!online && _cachedKanjiIds.isEmpty) {
      throw StateError('No cached kanji data');
    }
    return _cachedKanjiIds.toList()..sort();
  }

  void studyOffline(int kanjiId, int rating) {
    if (!_cachedKanjiIds.contains(kanjiId)) {
      throw StateError('Kanji $kanjiId is not cached');
    }
    if (online) {
      _remoteRatings[kanjiId] = rating;
      return;
    }
    _queue.add(_OfflineMutation(kanjiId: kanjiId, rating: rating));
  }

  int get queuedMutations => _queue.length;

  Future<void> reconnectAndSync() async {
    online = true;
    final latestByKanji = <int, int>{};
    for (final mutation in _queue) {
      latestByKanji[mutation.kanjiId] = mutation.rating;
    }
    _remoteRatings.addAll(latestByKanji);
    _queue.clear();
  }

  int? remoteRatingFor(int kanjiId) => _remoteRatings[kanjiId];
}

void main() {
  test(
    'offline harness serves cached kana/kanji data and syncs queued kanji mutations',
    () async {
      final harness = _OfflineHarness(
        cachedKanjiIds: List.generate(185, (i) => i + 1),
      );

      harness.online = false;
      expect(harness.loadKanjiData(), hasLength(185));

      for (final kanjiId in [1, 2, 3, 4, 5]) {
        harness.studyOffline(kanjiId, kanjiId == 1 ? 1 : 3);
      }
      harness.studyOffline(3, 4); // conflict-free latest-write wins locally.

      expect(harness.queuedMutations, 6);
      expect(harness.remoteRatingFor(3), isNull);

      await harness.reconnectAndSync();

      expect(harness.queuedMutations, 0);
      expect(harness.remoteRatingFor(1), 1);
      expect(harness.remoteRatingFor(2), 3);
      expect(harness.remoteRatingFor(3), 4);
      expect(harness.remoteRatingFor(4), 3);
      expect(harness.remoteRatingFor(5), 3);
    },
  );
}
