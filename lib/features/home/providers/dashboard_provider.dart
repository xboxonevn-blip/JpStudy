import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
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
  List<UserMistake>? cachedMistakes;
  var isComputing = false;
  var hasPendingRefresh = false;
  var isDisposed = false;

  Future<void> emitSnapshot() async {
    if (isDisposed) {
      return;
    }
    if (isComputing) {
      hasPendingRefresh = true;
      return;
    }
    isComputing = true;
    try {
      final progress = await lessonRepo.fetchProgressSummary();
      final vocabDueCount = (await srsDao.getDueReviews()).length;
      final grammarDueCount = (await grammarDao.getDueReviews()).length;
      final kanjiDueCount = (await kanjiSrsDao.getDueReviews()).length;
      final mistakes = cachedMistakes ?? await mistakeRepo.getAllMistakes();

      var vocabMistakeCount = 0;
      var grammarMistakeCount = 0;
      var kanjiMistakeCount = 0;
      for (final mistake in mistakes) {
        if (mistake.type == 'vocab') {
          vocabMistakeCount += 1;
        } else if (mistake.type == 'grammar') {
          grammarMistakeCount += 1;
        } else if (mistake.type == 'kanji') {
          kanjiMistakeCount += 1;
        }
      }

      final next = DashboardState(
        streak: progress.streak,
        todayXp: progress.todayXp,
        vocabDue: vocabDueCount,
        grammarDue: grammarDueCount,
        kanjiDue: kanjiDueCount,
        vocabMistakeCount: vocabMistakeCount,
        grammarMistakeCount: grammarMistakeCount,
        kanjiMistakeCount: kanjiMistakeCount,
        totalMistakeCount: mistakes.length,
      );

      if (next != lastState && !controller.isClosed) {
        lastState = next;
        controller.add(next);
      }
    } catch (error, stackTrace) {
      if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    } finally {
      isComputing = false;
      if (hasPendingRefresh) {
        hasPendingRefresh = false;
        unawaited(emitSnapshot());
      }
    }
  }

  subscriptions.add(
    srsDao.watchDueReviewCount().listen((_) {
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    grammarDao.watchDueReviewCount().listen((_) {
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    kanjiSrsDao.watchDueReviewCount().listen((_) {
      unawaited(emitSnapshot());
    }),
  );
  subscriptions.add(
    mistakeRepo.watchAllMistakes().listen((items) {
      cachedMistakes = items;
      unawaited(emitSnapshot());
    }),
  );

  // Time-based tick keeps due counts accurate when no DB writes happen.
  minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
    unawaited(emitSnapshot());
  });

  unawaited(emitSnapshot());

  ref.onDispose(() {
    isDisposed = true;
    minuteTicker?.cancel();
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(controller.close());
  });

  return controller.stream;
});

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
