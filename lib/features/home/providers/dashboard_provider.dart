import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database_provider.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../mistakes/repositories/mistake_repository.dart';

final dashboardProvider = StreamProvider.autoDispose<DashboardState>((ref) {
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final db = ref.watch(databaseProvider);
  final srsDao = db.srsDao;
  final grammarDao = db.grammarDao;
  final kanjiSrsDao = db.kanjiSrsDao;
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);

  final controller = StreamController<DashboardState>();
  final subscriptions = <StreamSubscription<dynamic>>[];
  Timer? minuteTicker;

  DashboardState? lastState;
  ({int vocab, int grammar, int kanji, int total})? cachedMistakeCounts;
  var isComputing = false;
  var hasPendingRefresh = false;
  var isDisposed = false;

  bool canEmit() => !isDisposed && !controller.isClosed;

  Future<void> emitSnapshot() async {
    if (!canEmit()) {
      return;
    }
    if (isComputing) {
      hasPendingRefresh = true;
      return;
    }
    isComputing = true;
    try {
      final progressFuture = lessonRepo.fetchProgressSummary();
      final vocabCountFuture = srsDao.getDueReviewCount();
      final grammarCountFuture = grammarDao.getDueReviewCount();
      final kanjiCountFuture = kanjiSrsDao.getDueReviewCount();
      // Only fetch mistake counts if the stream hasn't pushed them yet.
      // getMistakeCounts() runs a 3-row GROUP BY query instead of loading the
      // full UserMistake table — avoids N rows × full columns on every refresh.
      final mistakeCountsFuture = cachedMistakeCounts != null
          ? null
          : mistakeRepo.getMistakeCounts();

      final progress = await progressFuture;
      final vocabDueCount = await vocabCountFuture;
      final grammarDueCount = await grammarCountFuture;
      final kanjiDueCount = await kanjiCountFuture;
      final mc = cachedMistakeCounts ?? await mistakeCountsFuture!;
      if (!canEmit()) {
        return;
      }

      final next = DashboardState(
        streak: progress.streak,
        todayXp: progress.todayXp,
        vocabDue: vocabDueCount,
        grammarDue: grammarDueCount,
        kanjiDue: kanjiDueCount,
        vocabMistakeCount: mc.vocab,
        grammarMistakeCount: mc.grammar,
        kanjiMistakeCount: mc.kanji,
        totalMistakeCount: mc.total,
      );

      if (next != lastState && !controller.isClosed) {
        lastState = next;
        controller.add(next);
      }
    } catch (error, stackTrace) {
      if (canEmit()) {
        controller.addError(error, stackTrace);
      }
    } finally {
      isComputing = false;
      if (canEmit() && hasPendingRefresh) {
        hasPendingRefresh = false;
        unawaited(emitSnapshot());
      }
    }
  }

  subscriptions.add(
    srsDao.watchDueReviewCount().listen((_) {
      if (isDisposed) {
        return;
      }
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    grammarDao.watchDueReviewCount().listen((_) {
      if (isDisposed) {
        return;
      }
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    kanjiSrsDao.watchDueReviewCount().listen((_) {
      if (isDisposed) {
        return;
      }
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    mistakeRepo.watchMistakeCounts().listen((counts) {
      if (isDisposed) {
        return;
      }
      cachedMistakeCounts = counts;
      unawaited(emitSnapshot());
    }),
  );

  // Time-based tick keeps due counts accurate when no DB writes happen.
  minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
    unawaited(emitSnapshot());
  });

  void stopTicker() {
    minuteTicker?.cancel();
    minuteTicker = null;
  }

  void startTicker() {
    if (isDisposed) {
      return;
    }
    // Guard: never double-create the timer.
    minuteTicker ??= Timer.periodic(const Duration(minutes: 1), (_) {
      unawaited(emitSnapshot());
    });
  }

  // Refresh immediately when the app returns to foreground so due counts
  // reflect items that became due while the app was backgrounded.
  // Pause the minute ticker when hidden/backgrounded to save battery —
  // the onResume callback will restart it.
  final lifecycleListener = AppLifecycleListener(
    onResume: () {
      if (isDisposed) {
        return;
      }
      startTicker();
      unawaited(emitSnapshot());
    },
    onHide: stopTicker,
    onPause: stopTicker,
  );

  unawaited(emitSnapshot());

  ref.onDispose(() {
    isDisposed = true;
    minuteTicker?.cancel();
    lifecycleListener.dispose();
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(controller.close());
  });

  return controller.stream;
}, retry: (retryCount, error) => null);

class DashboardState {
  const DashboardState({
    required this.streak,
    required this.todayXp,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
    required this.vocabMistakeCount,
    required this.grammarMistakeCount,
    required this.kanjiMistakeCount,
    required this.totalMistakeCount,
  });

  final int streak;
  final int todayXp;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;
  final int vocabMistakeCount;
  final int grammarMistakeCount;
  final int kanjiMistakeCount;
  final int totalMistakeCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DashboardState &&
        other.streak == streak &&
        other.todayXp == todayXp &&
        other.vocabDue == vocabDue &&
        other.grammarDue == grammarDue &&
        other.kanjiDue == kanjiDue &&
        other.vocabMistakeCount == vocabMistakeCount &&
        other.grammarMistakeCount == grammarMistakeCount &&
        other.kanjiMistakeCount == kanjiMistakeCount &&
        other.totalMistakeCount == totalMistakeCount;
  }

  @override
  int get hashCode => Object.hash(
    streak,
    todayXp,
    vocabDue,
    grammarDue,
    kanjiDue,
    vocabMistakeCount,
    grammarMistakeCount,
    kanjiMistakeCount,
    totalMistakeCount,
  );
}
