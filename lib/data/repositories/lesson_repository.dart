import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';

import 'package:jpstudy/data/db/content_database.dart'
    hide UserProgressCompanion, UserProgressData;
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(
    ref.watch(databaseProvider),
    ref.watch(contentDatabaseProvider),
  );
});

final lessonTitleProvider = FutureProvider.family<String, LessonTitleArgs>((
  ref,
  args,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessonTitle(args.lessonId, args.fallback);
});

final lessonTermsProvider =
    FutureProvider.family<List<UserLessonTermData>, LessonTermsArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      await repo.ensureLesson(
        lessonId: args.lessonId,
        level: args.level,
        title: args.fallbackTitle,
      );
      await repo.seedTermsIfEmpty(args.lessonId, args.level);
      await repo.seedGrammarIfEmpty(args.lessonId, args.level);
      return repo.fetchTerms(args.lessonId);
    });

final lessonMetaProvider = FutureProvider.family<List<LessonMeta>, String>((
  ref,
  level,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchLessonMeta(level);
});

final lessonDueTermsProvider =
    FutureProvider.family<List<UserLessonTermData>, int>((ref, lessonId) async {
      final repo = ref.watch(lessonRepositoryProvider);
      return repo.fetchDueTerms(lessonId);
    });

final allDueTermsProvider = FutureProvider<List<UserLessonTermData>>((
  ref,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchAllDueTerms();
});

/// Returns the nearest future vocab review date, refreshing whenever SRS state changes.
final nextVocabReviewProvider = StreamProvider.autoDispose<DateTime?>((
  ref,
) async* {
  final db = ref.watch(databaseProvider);
  await for (final _ in db.srsDao.watchDueReviewCount()) {
    yield await db.srsDao.getNextScheduledReview();
  }
});

/// Returns the nearest future kanji review date, refreshing whenever kanji SRS state changes.
final nextKanjiReviewProvider = StreamProvider.autoDispose<DateTime?>((
  ref,
) async* {
  final db = ref.watch(databaseProvider);
  await for (final _ in db.kanjiSrsDao.watchDueReviewCount()) {
    yield await db.kanjiSrsDao.getNextScheduledReview();
  }
});

final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchProgressSummary();
});

final lessonPracticeSettingsProvider =
    FutureProvider.family<LessonPracticeSettings, int>((ref, lessonId) async {
      final repo = ref.watch(lessonRepositoryProvider);
      return repo.fetchLessonPracticeSettings(lessonId);
    });

final reviewHistoryProvider = FutureProvider<List<ReviewDaySummary>>((
  ref,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchReviewHistory();
});

final activityCalendarProvider = FutureProvider<List<ReviewDaySummary>>((
  ref,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchReviewHistory(limit: 112);
});

final attemptHistoryProvider = FutureProvider<List<AttemptSummary>>((
  ref,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchAttemptHistory();
});

final srsRetentionProvider = FutureProvider<SrsStageBreakdown>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.srsDao.getStageBreakdown();
});

class WeekSummary {
  const WeekSummary({
    required this.totalReviewed,
    required this.accuracy,
    required this.daysStudied,
  });

  final int totalReviewed;
  final int accuracy; // percentage 0–100
  final int daysStudied;
}

final weekSummaryProvider = FutureProvider<WeekSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final history = await repo.fetchReviewHistory(limit: 7);
  final attempts = await repo.fetchAttemptHistory(limit: 50);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));

  final totalReviewed = history.fold(0, (s, d) => s + d.reviewed);
  final daysStudied = history.where((d) => d.reviewed > 0).length;

  final weekAttempts = attempts
      .where((a) => a.startedAt.isAfter(cutoff))
      .toList();
  final totalCorrect = weekAttempts.fold(0, (s, a) => s + a.score);
  final totalQ = weekAttempts.fold(0, (s, a) => s + a.total);
  final accuracy = totalQ == 0 ? 0 : (totalCorrect / totalQ * 100).round();

  return WeekSummary(
    totalReviewed: totalReviewed,
    accuracy: accuracy,
    daysStudied: daysStudied,
  );
});

class LessonTitleArgs {
  const LessonTitleArgs(this.lessonId, this.fallback);

  final int lessonId;
  final String fallback;

  @override
  bool operator ==(Object other) {
    return other is LessonTitleArgs &&
        other.lessonId == lessonId &&
        other.fallback == fallback;
  }

  @override
  int get hashCode => Object.hash(lessonId, fallback);
}

final lessonGrammarProvider =
    FutureProvider.family<List<GrammarPointData>, LessonTermsArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      // Ensure grammar is seeded before fetching
      await repo.seedGrammarIfEmpty(args.lessonId, args.level);
      return repo.fetchGrammar(args.lessonId);
    });

final lessonKanjiProvider = FutureProvider.family<List<KanjiItem>, int>((
  ref,
  lessonId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchKanji(lessonId);
});

final lessonDueKanjiProvider = FutureProvider.family<List<KanjiItem>, int>((
  ref,
  lessonId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchDueKanji(lessonId);
});

final srsStateProvider = FutureProvider.family<SrsStateData?, int>((
  ref,
  termId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getSrsState(termId);
});

final grammarGhostsProvider = FutureProvider<List<GrammarPointData>>((
  ref,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchGrammarGhosts();
});

class GrammarPointData {
  const GrammarPointData({required this.point, required this.examples});

  final GrammarPoint point;
  final List<GrammarExample> examples;
}

class LessonTermsArgs {
  const LessonTermsArgs(this.lessonId, this.level, this.fallbackTitle);

  final int lessonId;
  final String level;
  final String fallbackTitle;

  @override
  bool operator ==(Object other) {
    return other is LessonTermsArgs &&
        other.lessonId == lessonId &&
        other.level == level &&
        other.fallbackTitle == fallbackTitle;
  }

  @override
  int get hashCode => Object.hash(lessonId, level, fallbackTitle);
}

class LessonMeta {
  const LessonMeta({
    required this.id,
    required this.level,
    required this.title,
    required this.isCustomTitle,
    required this.tags,
    required this.termCount,
    required this.completedCount,
    required this.dueCount,
    required this.updatedAt,
  });

  final int id;
  final String level;
  final String title;
  final bool isCustomTitle;
  final String tags;
  final int termCount;
  final int completedCount;
  final int dueCount;
  final DateTime? updatedAt;
}

class LessonPracticeSettings {
  const LessonPracticeSettings({
    required this.learnTermLimit,
    required this.testQuestionLimit,
    required this.matchPairLimit,
  });

  static const LessonPracticeSettings defaults = LessonPracticeSettings(
    learnTermLimit: 0,
    testQuestionLimit: 12,
    matchPairLimit: 8,
  );

  final int learnTermLimit;
  final int testQuestionLimit;
  final int matchPairLimit;
}

class LessonTermDraft {
  const LessonTermDraft({
    required this.term,
    required this.reading,
    required this.definition,
    required this.kanjiMeaning,
  });

  final String term;
  final String reading;
  final String definition;
  final String kanjiMeaning;
}

class AttemptAnswerDraft {
  const AttemptAnswerDraft({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  final int questionId;
  final int selectedIndex;
  final bool isCorrect;
}

class AttemptSummary {
  const AttemptSummary({
    required this.id,
    required this.mode,
    required this.level,
    required this.startedAt,
    required this.finishedAt,
    required this.score,
    required this.total,
  });

  final int id;
  final String mode;
  final String level;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int score;
  final int total;

  Duration? get duration => finishedAt?.difference(startedAt);
}

class ReviewDaySummary {
  const ReviewDaySummary({
    required this.day,
    required this.reviewed,
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  final DateTime day;
  final int reviewed;
  final int again;
  final int hard;
  final int good;
  final int easy;
}

class ProgressSummary {
  const ProgressSummary({
    required this.totalXp,
    required this.todayXp,
    required this.streak,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  final int totalXp;
  final int todayXp;
  final int streak;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
}

class LessonRepository {
  LessonRepository(this._db, this._contentDb);

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final FsrsService _fsrsService = FsrsService();
  static const int _defaultLessonCount = 25;

  Future<String> getLessonTitle(int lessonId, String fallback) async {
    final existing = await (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).getSingleOrNull();
    if (existing == null) {
      return fallback;
    }
    return existing.isCustomTitle ? existing.title : fallback;
  }

  Future<List<UserLessonData>> getAllLessons() {
    return _db.select(_db.userLesson).get();
  }

  // Returns a map of lessonId -> {termCount, completedCount}
  Future<Map<int, LessonProgressStats>> getAllLessonProgress() async {
    final termCounts =
        await (_db.selectOnly(_db.userLessonTerm)
              ..addColumns([
                _db.userLessonTerm.lessonId,
                _db.userLessonTerm.id.count(),
              ])
              ..groupBy([_db.userLessonTerm.lessonId]))
            .get();

    final completedCounts =
        await (_db.selectOnly(_db.userLessonTerm)
              ..addColumns([
                _db.userLessonTerm.lessonId,
                _db.userLessonTerm.id.count(),
              ])
              ..where(_db.userLessonTerm.isLearned.equals(true))
              ..groupBy([_db.userLessonTerm.lessonId]))
            .get();

    final stats = <int, LessonProgressStats>{};

    for (final row in termCounts) {
      final lessonId = row.read(_db.userLessonTerm.lessonId);
      final count = row.read(_db.userLessonTerm.id.count()) ?? 0;
      if (lessonId != null) {
        stats[lessonId] = LessonProgressStats(
          termCount: count,
          completedCount: 0,
        );
      }
    }

    for (final row in completedCounts) {
      final lessonId = row.read(_db.userLessonTerm.lessonId);
      final count = row.read(_db.userLessonTerm.id.count()) ?? 0;
      if (lessonId != null) {
        if (stats.containsKey(lessonId)) {
          stats[lessonId] = stats[lessonId]!.copyWith(completedCount: count);
        } else {
          // Should not happen usually as learned implies existing
          stats[lessonId] = LessonProgressStats(
            termCount: 0,
            completedCount: count,
          );
        }
      }
    }

    return stats;
  }

  Future<LessonPracticeSettings> fetchLessonPracticeSettings(
    int lessonId,
  ) async {
    final existing = await (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).getSingleOrNull();
    if (existing == null) {
      return LessonPracticeSettings.defaults;
    }
    return LessonPracticeSettings(
      learnTermLimit: existing.learnTermLimit,
      testQuestionLimit: existing.testQuestionLimit,
      matchPairLimit: existing.matchPairLimit,
    );
  }

  Future<UserLessonData> ensureLesson({
    required int lessonId,
    required String level,
    required String title,
  }) async {
    final existing = await (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }
    await _db
        .into(_db.userLesson)
        .insert(
          UserLessonCompanion.insert(
            id: Value(lessonId),
            level: level,
            title: title,
            description: const Value(''),
            isPublic: const Value(true),
            isCustomTitle: const Value(false),
            learnTermLimit: Value(
              LessonPracticeSettings.defaults.learnTermLimit,
            ),
            testQuestionLimit: Value(
              LessonPracticeSettings.defaults.testQuestionLimit,
            ),
            matchPairLimit: Value(
              LessonPracticeSettings.defaults.matchPairLimit,
            ),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).getSingle();
  }

  Future<List<LessonMeta>> fetchLessonMeta(String level) async {
    final lessons = await (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.level.equals(level))).get();
    if (lessons.isEmpty) {
      return const [];
    }
    final ids = lessons.map((lesson) => lesson.id).toList();
    final terms = await (_db.select(
      _db.userLessonTerm,
    )..where((tbl) => tbl.lessonId.isIn(ids))).get();
    final counts = <int, int>{};
    final completedCounts = <int, int>{};
    for (final term in terms) {
      counts.update(term.lessonId, (value) => value + 1, ifAbsent: () => 1);
      if (term.isLearned) {
        completedCounts.update(
          term.lessonId,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final dueCounts = await _fetchDueCounts(ids);
    return lessons
        .map(
          (lesson) => LessonMeta(
            id: lesson.id,
            level: lesson.level,
            title: lesson.title,
            isCustomTitle: lesson.isCustomTitle,
            tags: lesson.tags,
            termCount: counts[lesson.id] ?? 0,
            completedCount: completedCounts[lesson.id] ?? 0,
            dueCount: dueCounts[lesson.id] ?? 0,
            updatedAt: lesson.updatedAt,
          ),
        )
        .toList();
  }

  // Fetch all vocabulary for a specific JLPT level from ContentDatabase
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    final items = await (_contentDb.select(
      _contentDb.vocab,
    )..where((tbl) => tbl.level.equals(level))).get();

    return items.map(_mapContentVocabToItem).toList();
  }

  Future<List<VocabItem>> fetchContentVocabByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await (_contentDb.select(
      _contentDb.vocab,
    )..where((tbl) => tbl.id.isIn(ids))).get();
    return rows.map(_mapContentVocabToItem).toList();
  }

  /// Fetch VocabItems by IDs: user lesson terms first, fallback to content DB.
  Future<List<VocabItem>> fetchVocabTermsByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final query = _db.select(_db.userLessonTerm).join([
      leftOuterJoin(
        _db.userLesson,
        _db.userLesson.id.equalsExp(_db.userLessonTerm.lessonId),
      ),
    ])..where(_db.userLessonTerm.id.isIn(ids));
    final rows = await query.get();
    final found = rows.map((row) {
      final t = row.readTable(_db.userLessonTerm);
      final lesson = row.readTableOrNull(_db.userLesson);
      return VocabItem(
        id: t.id,
        term: t.term,
        reading: t.reading,
        meaning: t.definition,
        meaningEn: t.definitionEn,
        level: lesson?.level ?? 'N5',
      );
    }).toList();
    final foundIds = found.map((v) => v.id).toSet();
    final missingIds = ids.where((id) => !foundIds.contains(id)).toList();
    if (missingIds.isNotEmpty) {
      final contentItems = await fetchContentVocabByIds(missingIds);
      found.addAll(contentItems);
    }
    return found;
  }

  VocabItem _mapContentVocabToItem(VocabData item) {
    return VocabItem(
      id: item.id,
      term: item.term,
      reading: item.reading ?? '',
      meaning: item.meaning,
      meaningEn: item.meaningEn,
      kanjiMeaning: item.kanjiMeaning,
      level: item.level,
      tags: item.tags?.split(','),
    );
  }

  Future<Map<int, int>> _fetchDueCounts(List<int> lessonIds) async {
    if (lessonIds.isEmpty) {
      return const {};
    }
    final now = DateTime.now();
    final query = _db.select(_db.userLessonTerm).join([
      innerJoin(
        _db.srsState,
        _db.srsState.vocabId.equalsExp(_db.userLessonTerm.id),
      ),
    ]);
    query
      ..where(_db.userLessonTerm.lessonId.isIn(lessonIds))
      ..where(_db.srsState.nextReviewAt.isSmallerOrEqualValue(now));
    final rows = await query.get();
    final counts = <int, int>{};
    for (final row in rows) {
      final term = row.readTable(_db.userLessonTerm);
      counts.update(term.lessonId, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<int?> findNextToStudyLesson(String level) async {
    final lessons =
        await (_db.select(_db.userLesson)
              ..where((tbl) => tbl.level.equals(level))
              ..orderBy([(t) => OrderingTerm(expression: t.id)]))
            .get();

    if (lessons.isEmpty) return null;

    final stats = await getAllLessonProgress();

    for (final lesson in lessons) {
      final stat = stats[lesson.id];
      // If no stats (no terms yet) or not fully completed, this is the next one
      if (stat == null ||
          stat.termCount == 0 ||
          stat.completedCount < stat.termCount) {
        return lesson.id;
      }
    }
    return null; // All completed
  }

  Future<int> nextLessonId() async {
    final maxId =
        await (_db.selectOnly(_db.userLesson)
              ..addColumns([_db.userLesson.id])
              ..orderBy([
                OrderingTerm(
                  expression: _db.userLesson.id,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    final currentMax = maxId?.read(_db.userLesson.id) ?? 0;
    final base = currentMax < _defaultLessonCount
        ? _defaultLessonCount
        : currentMax;
    return base + 1;
  }

  Future<int> createLesson({
    required String level,
    required String title,
    required bool isPublic,
    required bool isCustomTitle,
  }) async {
    final nextId = await nextLessonId();
    await _db
        .into(_db.userLesson)
        .insert(
          UserLessonCompanion.insert(
            id: Value(nextId),
            level: level,
            title: title,
            description: const Value(''),
            isPublic: Value(isPublic),
            isCustomTitle: Value(isCustomTitle),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return nextId;
  }

  Future<List<UserLessonTermData>> fetchTerms(int lessonId) {
    return (_db.select(_db.userLessonTerm)
          ..where(
            (tbl) =>
                tbl.lessonId.equals(lessonId) &
                tbl.term.like('%?%').not() &
                tbl.reading.like('%?%').not(),
          )
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.orderIndex)]))
        .get();
  }

  Future<void> seedTermsIfEmpty(int lessonId, String currentLevelLabel) async {
    final existing = await fetchTerms(lessonId);

    // Check if existing terms are the dummy ones and should be replaced
    final isDummy =
        existing.length == 2 &&
        existing[0].term == '見ます' &&
        existing[1].term == '探します';

    if (existing.isNotEmpty && !isDummy) {
      // Try to backfill missing English without destructive reset.
      final missingEnglish = existing.any((t) => t.definitionEn.isEmpty);
      if (missingEnglish) {
        await _backfillEnglishDefinitions(
          lessonId,
          currentLevelLabel,
          existing,
        );
      }

      final refreshed = await fetchTerms(lessonId);
      if (refreshed.isNotEmpty &&
          refreshed.every((t) => t.definitionEn.isNotEmpty)) {
        return;
      }
    }

    if (existing.isNotEmpty && !isDummy) {
      // Data exists but still missing English; keep user data as-is.
      return;
    }

    if (isDummy) {
      // Delete dummy terms to force resync
      await (_db.delete(
        _db.userLessonTerm,
      )..where((tbl) => tbl.lessonId.equals(lessonId))).go();
    }

    final vocabList = await _fetchLessonVocabFromContent(
      lessonId,
      currentLevelLabel,
    );
    if (vocabList.isEmpty) {
      return;
    }

    // Insert into UserLessonTerm
    await _db.batch((batch) {
      for (var i = 0; i < vocabList.length; i++) {
        final v = vocabList[i];
        batch.insert(
          _db.userLessonTerm,
          UserLessonTermCompanion.insert(
            lessonId: lessonId,
            term: Value(v.term),
            reading: Value(v.reading ?? ''),
            definition: Value(v.meaning),
            definitionEn: Value(v.meaningEn ?? ''),
            mnemonicVi: const Value(''),
            mnemonicEn: const Value(''),
            orderIndex: Value(i + 1),
          ),
        );
      }
    });
  }

  Future<void> _backfillEnglishDefinitions(
    int lessonId,
    String currentLevelLabel,
    List<UserLessonTermData> existing,
  ) async {
    final vocabList = await _fetchLessonVocabFromContent(
      lessonId,
      currentLevelLabel,
    );
    if (vocabList.isEmpty) {
      return;
    }

    final vocabMap = <String, String>{};
    final termOnlyMap = <String, String>{};
    final termConflicts = <String>{};
    for (final v in vocabList) {
      final meaningEn = v.meaningEn?.trim() ?? '';
      if (meaningEn.isEmpty) continue;
      vocabMap[_vocabKey(v.term, v.reading)] = meaningEn;
      final termKey = v.term.trim();
      if (termKey.isEmpty) continue;
      if (termOnlyMap.containsKey(termKey) &&
          termOnlyMap[termKey] != meaningEn) {
        termConflicts.add(termKey);
        termOnlyMap.remove(termKey);
      } else if (!termConflicts.contains(termKey)) {
        termOnlyMap[termKey] = meaningEn;
      }
    }

    if (vocabMap.isEmpty) {
      return;
    }

    await _db.batch((batch) {
      for (final term in existing) {
        if (term.definitionEn.isNotEmpty) continue;
        final key = _vocabKey(term.term, term.reading);
        var meaningEn = vocabMap[key];
        if ((meaningEn == null || meaningEn.isEmpty) &&
            term.reading.trim().isEmpty) {
          meaningEn = termOnlyMap[term.term.trim()];
        }
        if (meaningEn == null || meaningEn.isEmpty) continue;
        batch.update(
          _db.userLessonTerm,
          UserLessonTermCompanion(definitionEn: Value(meaningEn)),
          where: (tbl) => tbl.id.equals(term.id),
        );
      }
    });
  }

  Future<List<VocabData>> _fetchLessonVocabFromContent(
    int lessonId,
    String currentLevelLabel,
  ) async {
    final dbLevel = currentLevelLabel; // e.g. "N5", "N4"
    final idStr = lessonId.toString();
    var vocabList =
        await (_contentDb.select(_contentDb.vocab)..where((tbl) {
              return tbl.level.equals(dbLevel) &
                  tbl.term.like('%?%').not() &
                  tbl.reading.like('%?%').not() &
                  (tbl.tags.like('minna_$idStr,%') |
                      tbl.tags.equals('minna_$idStr') |
                      tbl.tags.like('%,minna_$idStr,%') |
                      tbl.tags.like('%,minna_$idStr'));
            }))
            .get();

    // Fallback to offset if tag lookup failed (e.g. old data or manual lessons)
    if (vocabList.isEmpty) {
      int limit = 50;
      int offset = 0;

      if (currentLevelLabel == 'N5') {
        offset = (lessonId - 1) * 35;
      } else if (currentLevelLabel == 'N4') {
        offset = (lessonId - 26) * 35;
      }
      if (offset < 0) offset = 0;

      vocabList =
          await (_contentDb.select(_contentDb.vocab)
                ..where(
                  (tbl) =>
                      tbl.level.equals(dbLevel) &
                      tbl.term.like('%?%').not() &
                      tbl.reading.like('%?%').not(),
                )
                ..limit(limit, offset: offset))
              .get();
    }

    // Keep lesson order stable: if lesson JSON exists, sort by map.json order.
    final levelLower = currentLevelLabel.toLowerCase();
    final orderIndexByKey = await _loadLessonVocabOrderIndex(
      levelLower: levelLower,
      lessonId: lessonId,
    );
    if (orderIndexByKey.isNotEmpty) {
      vocabList.sort((a, b) {
        final aKey = _vocabKeyWithMeaning(a.term, a.reading, a.meaning);
        final bKey = _vocabKeyWithMeaning(b.term, b.reading, b.meaning);
        final ai = orderIndexByKey[aKey] ?? 1 << 30;
        final bi = orderIndexByKey[bKey] ?? 1 << 30;
        if (ai != bi) return ai.compareTo(bi);
        // Stable fallback for any items not present in the map.
        return a.id.compareTo(b.id);
      });
    }

    // Last-resort fallback: load directly from lesson assets so Flashcards
    // still work even when Content DB is stale/missing.
    if (vocabList.isEmpty) {
      final assetRows = await _loadLessonVocabRowsFromAssets(
        lessonId: lessonId,
        currentLevelLabel: currentLevelLabel,
      );
      if (assetRows.isNotEmpty) {
        return assetRows;
      }
    }

    return vocabList;
  }

  String _vocabKey(String term, String? reading) {
    final termValue = term.trim();
    final readingValue = (reading ?? '').trim();
    return '$termValue|$readingValue';
  }

  String _vocabKeyWithMeaning(String term, String? reading, String meaning) {
    final termValue = term.trim();
    final readingValue = (reading ?? '').trim();
    final meaningValue = meaning.trim();
    return '$termValue|$readingValue|$meaningValue';
  }

  Future<Map<String, int>> _loadLessonVocabOrderIndex({
    required String levelLower,
    required int lessonId,
  }) async {
    final canonicalRows = await _loadCanonicalLessonVocabEntries(
      levelLower: levelLower,
      lessonId: lessonId,
    );
    if (canonicalRows.isEmpty) {
      return const {};
    }

    final result = <String, int>{};
    for (final row in canonicalRows) {
      final term = (row['term'] ?? '').toString();
      final reading = (row['reading'] ?? '').toString();
      final meaning = (row['meaningVi'] ?? '').toString();
      final order = row['order'] as int? ?? 0;
      if (term.trim().isEmpty || meaning.trim().isEmpty || order <= 0) {
        continue;
      }
      result[_vocabKeyWithMeaning(term, reading, meaning)] = order;
    }
    return result;
  }

  Future<List<VocabData>> _loadLessonVocabRowsFromAssets({
    required int lessonId,
    required String currentLevelLabel,
  }) async {
    final levelLower = currentLevelLabel.toLowerCase().trim();
    final canonicalRows = await _loadCanonicalLessonVocabEntries(
      levelLower: levelLower,
      lessonId: lessonId,
    );
    if (canonicalRows.isEmpty) {
      return const [];
    }

    final out = <VocabData>[];
    var syntheticId = -(lessonId * 10000);
    for (final row in canonicalRows) {
      final term = (row['term'] ?? '').toString().trim();
      final meaningVi = (row['meaningVi'] ?? '').toString().trim();
      if (term.isEmpty || meaningVi.isEmpty) continue;

      syntheticId -= 1;
      final tags = row['tags'] is List
          ? (row['tags'] as List)
                .map((tag) => tag.toString().trim())
                .where((tag) => tag.isNotEmpty)
                .join(',')
          : '';
      final mergedTags = tags.isEmpty
          ? 'minna_$lessonId'
          : 'minna_$lessonId,$tags';

      out.add(
        VocabData(
          id: syntheticId,
          term: term,
          reading: _nullableLessonText(row['reading']),
          meaning: meaningVi,
          meaningEn: _nullableLessonText(row['meaningEn']),
          kanjiMeaning: _nullableLessonText(row['kanjiMeaning']),
          level: currentLevelLabel.toUpperCase(),
          tags: mergedTags,
        ),
      );
    }
    return out;
  }

  Future<List<Map<String, dynamic>>> _loadCanonicalLessonVocabEntries({
    required String levelLower,
    required int lessonId,
  }) async {
    final paddedLessonId = lessonId.toString().padLeft(2, '0');
    final path =
        'assets/data/content/vocab/$levelLower/lesson_$paddedLessonId.json';

    try {
      final raw = await rootBundle.loadString(path);
      final payload = json.decode(raw);
      if (payload is! Map) return const [];
      final entries = payload['entries'];
      if (entries is! List) return const [];

      final out = <Map<String, dynamic>>[];
      for (final rawEntry in entries) {
        if (rawEntry is! Map) continue;
        final entry = rawEntry.map((k, v) => MapEntry(k.toString(), v));
        final lemmaRaw = entry['lemma'];
        final senseRaw = entry['sense'];
        if (lemmaRaw is! Map || senseRaw is! Map) continue;
        final lemma = lemmaRaw.map((k, v) => MapEntry(k.toString(), v));
        final sense = senseRaw.map((k, v) => MapEntry(k.toString(), v));
        final labelsRaw = lemma['labels'];
        final labels = labelsRaw is Map
            ? labelsRaw.map((k, v) => MapEntry(k.toString(), v))
            : const <String, dynamic>{};

        out.add({
          'term': (lemma['term'] ?? '').toString().trim(),
          'reading': _nullableLessonText(lemma['reading']),
          'kanjiMeaning': _nullableLessonText(labels['hanViet']),
          'meaningVi': (sense['meaningVi'] ?? '').toString().trim(),
          'meaningEn': _nullableLessonText(sense['meaningEn']),
          'order': int.tryParse((entry['order'] ?? '').toString().trim()) ?? 0,
          'tags': entry['tags'],
        });
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  String? _nullableLessonText(Object? value) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? null : text;
  }

  Future<List<GrammarPointData>> fetchGrammar(int lessonId) async {
    final points = await (_db.select(
      _db.grammarPoints,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();

    if (points.isEmpty) {
      return [];
    }

    final result = <GrammarPointData>[];
    for (final point in points) {
      final examples = await (_db.select(
        _db.grammarExamples,
      )..where((tbl) => tbl.grammarId.equals(point.id))).get();
      result.add(GrammarPointData(point: point, examples: examples));
    }
    return result;
  }

  /// Fetch grammar points that have been answered incorrectly in attempts (Ghosts)
  /// Logic: Find unique questionIds from AttemptAnswer where isCorrect = false
  /// and Attempt.mode contains 'grammar'.
  Future<List<GrammarPointData>> fetchGrammarGhosts() async {
    // Join AttemptAnswer -> Attempt to filter by mode
    final query = _db.select(_db.attemptAnswer).join([
      innerJoin(
        _db.attempt,
        _db.attempt.id.equalsExp(_db.attemptAnswer.attemptId),
      ),
    ]);

    query.where(_db.attemptAnswer.isCorrect.not());
    query.where(_db.attempt.mode.like('%grammar%'));

    // Get distinct question IDs (Grammar IDs)
    final rows = await query.get();
    final ghostIds = rows
        .map((row) => row.readTable(_db.attemptAnswer).questionId)
        .toSet() // Deduplicate
        .toList();

    if (ghostIds.isEmpty) {
      return [];
    }

    // Fetch full grammar data for these IDs
    final points = await (_db.select(
      _db.grammarPoints,
    )..where((tbl) => tbl.id.isIn(ghostIds))).get();

    final result = <GrammarPointData>[];
    for (final point in points) {
      final examples = await (_db.select(
        _db.grammarExamples,
      )..where((tbl) => tbl.grammarId.equals(point.id))).get();
      result.add(GrammarPointData(point: point, examples: examples));
    }
    return result;
  }

  /// Remove a grammar point from ghosts by deleting its incorrect attempt records
  Future<void> markGrammarAsMastered(int grammarId) async {
    await (_db.delete(_db.attemptAnswer)
          ..where((tbl) => tbl.questionId.equals(grammarId))
          ..where((tbl) => tbl.isCorrect.not())
          ..where(
            (tbl) => tbl.attemptId.isInQuery(
              _db.selectOnly(_db.attempt)
                ..addColumns([_db.attempt.id])
                ..where(_db.attempt.mode.like('%grammar%')),
            ),
          ))
        .go();
  }

  Future<List<GrammarPoint>> fetchRandomGrammarPoints(
    String level,
    int limit, {
    List<int>? excludeIds,
  }) async {
    final query = _db.select(_db.grammarPoints)
      ..where((tbl) => tbl.jlptLevel.equals(level));

    if (excludeIds != null && excludeIds.isNotEmpty) {
      query.where((tbl) => tbl.id.isNotIn(excludeIds));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: const CustomExpression('RANDOM()')),
    ]);
    query.limit(limit);

    return query.get();
  }

  Future<void> seedGrammarIfEmpty(int lessonId, String level) async {
    // Check if grammar already exists for this lesson
    final existingPoints = await (_db.select(
      _db.grammarPoints,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();

    // Check if resync needed: Either empty or missing English explanations
    bool needsResync = existingPoints.isEmpty;
    if (!needsResync && existingPoints.isNotEmpty) {
      // Check if any point is missing English explanation or title
      needsResync = existingPoints.any((p) {
        final currentMeaningEn = (p.meaningEn ?? p.titleEn ?? '').trim();
        final currentConnectionEn = (p.connectionEn ?? '').trim();
        return p.explanationEn == null ||
            p.explanationEn!.isEmpty ||
            p.titleEn == null ||
            p.titleEn!.isEmpty ||
            (currentMeaningEn.isNotEmpty &&
                normalizeGrammarTitleEn(currentMeaningEn) !=
                    currentMeaningEn) ||
            (currentConnectionEn.isNotEmpty &&
                normalizeGrammarStructureEn(currentConnectionEn) !=
                    currentConnectionEn);
      });
    }

    if (!needsResync) {
      return;
    }

    // Fetch from Content DB
    final contentPoints = await (_contentDb.select(
      _contentDb.grammarPoint,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();

    if (contentPoints.isEmpty) {
      return;
    }

    // Update in-place instead of delete+insert to preserve GrammarSrsState
    // rows (which cascade-delete when GrammarPoints rows are deleted). This
    // prevents users from losing their SRS review history on lesson re-opens.
    final existingByTitle = {for (final p in existingPoints) p.grammarPoint: p};

    for (final cp in contentPoints) {
      final titleEn = normalizeGrammarTitleEn(cp.titleEn);
      final structureEn = normalizeGrammarStructureEn(cp.structureEn);

      final existing = existingByTitle[cp.title];
      if (existing != null) {
        // UPDATE English fields in-place — row id and SRS state unchanged
        await (_db.update(
          _db.grammarPoints,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          GrammarPointsCompanion(
            titleEn: Value(titleEn.isEmpty ? null : titleEn),
            meaningEn: Value(titleEn.isEmpty ? cp.title : titleEn),
            connectionEn: Value(structureEn.isEmpty ? null : structureEn),
            explanationEn: Value(cp.explanationEn),
          ),
        );

        // Refresh examples (safe: examples don't carry SRS state)
        await (_db.delete(
          _db.grammarExamples,
        )..where((tbl) => tbl.grammarId.equals(existing.id))).go();

        final examples = await (_contentDb.select(
          _contentDb.grammarExample,
        )..where((tbl) => tbl.grammarPointId.equals(cp.id))).get();

        for (final ex in examples) {
          await _db
              .into(_db.grammarExamples)
              .insert(
                GrammarExamplesCompanion.insert(
                  grammarId: existing.id,
                  japanese: ex.sentence,
                  translation: ex.translation,
                  translationVi: Value(ex.translation),
                  translationEn: Value(ex.translationEn),
                ),
              );
        }
      } else {
        // INSERT new grammar point not previously in the app DB
        final pointId = await _db
            .into(_db.grammarPoints)
            .insert(
              GrammarPointsCompanion.insert(
                lessonId: Value(lessonId),
                grammarPoint: cp.title,
                titleEn: Value(titleEn.isEmpty ? null : titleEn),
                meaning: cp.title,
                meaningVi: Value(cp.title),
                meaningEn: Value(titleEn.isEmpty ? cp.title : titleEn),
                connection: cp.structure,
                connectionEn: Value(structureEn.isEmpty ? null : structureEn),
                explanation: cp.explanation,
                explanationVi: Value(cp.explanation),
                explanationEn: Value(cp.explanationEn),
                jlptLevel: cp.level,
                isLearned: const Value(false),
              ),
            );

        final examples = await (_contentDb.select(
          _contentDb.grammarExample,
        )..where((tbl) => tbl.grammarPointId.equals(cp.id))).get();

        for (final ex in examples) {
          await _db
              .into(_db.grammarExamples)
              .insert(
                GrammarExamplesCompanion.insert(
                  grammarId: pointId,
                  japanese: ex.sentence,
                  translation: ex.translation,
                  translationVi: Value(ex.translation),
                  translationEn: Value(ex.translationEn),
                ),
              );
        }
      }
    }
  }

  Future<List<KanjiItem>> fetchKanji(int lessonId) async {
    final rows = await (_contentDb.select(
      _contentDb.kanji,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();
    return _mapKanjiRows(rows);
  }

  Future<List<KanjiItem>> fetchKanjiByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (_contentDb.select(
      _contentDb.kanji,
    )..where((tbl) => tbl.id.isIn(ids))).get();
    return _mapKanjiRows(rows);
  }

  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async {
    final rows =
        await (_contentDb.select(_contentDb.kanji)..where((tbl) {
              return tbl.jlptLevel.equals(level);
            }))
            .get();
    rows.sort((a, b) {
      final byLesson = a.lessonId.compareTo(b.lessonId);
      if (byLesson != 0) return byLesson;
      return a.id.compareTo(b.id);
    });
    return _mapKanjiRows(rows);
  }

  /// Returns kanji at [level] whose SRS state is currently due (nextReviewAt <= now).
  /// Kanji with no SRS state row are excluded — they are "unseen", not "due".
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async {
    final dueStates = await _db.kanjiSrsDao.getDueReviews();
    if (dueStates.isEmpty) return const [];

    final dueIds = dueStates.map((s) => s.kanjiId).toList();
    final rows =
        await (_contentDb.select(_contentDb.kanji)
              ..where(
                (tbl) => tbl.jlptLevel.equals(level) & tbl.id.isIn(dueIds),
              )
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.lessonId),
                (tbl) => OrderingTerm.asc(tbl.id),
              ]))
            .get();

    return _mapKanjiRows(rows);
  }

  /// Returns up to [limit] kanji at [level] that have never been practiced
  /// (no row exists in KanjiSrsState for them), ordered by lesson then id.
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async {
    final seenIds = await _db.kanjiSrsDao.getAllSeenKanjiIds();

    final query = _contentDb.select(_contentDb.kanji)
      ..where((tbl) {
        final byLevel = tbl.jlptLevel.equals(level);
        if (seenIds.isEmpty) return byLevel;
        return byLevel & tbl.id.isNotIn(seenIds);
      })
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.lessonId),
        (tbl) => OrderingTerm.asc(tbl.id),
      ])
      ..limit(limit);

    final rows = await query.get();
    return _mapKanjiRows(rows);
  }

  Future<List<KanjiItem>> _mapKanjiRows(List<KanjiData> rows) async {
    if (rows.isEmpty) return const [];

    final sourceSenseIds = <String>{};
    final sourceVocabIds = <String>{};
    final parsed = <({KanjiData row, List<KanjiExample> examples})>[];

    for (final row in rows) {
      final examples = _decodeKanjiExamples(row.examplesJson);
      for (final ex in examples) {
        final senseId = ex.sourceSenseId?.trim();
        final vocabId = ex.sourceVocabId?.trim();
        if (senseId != null && senseId.isNotEmpty) {
          sourceSenseIds.add(senseId);
        }
        if (vocabId != null && vocabId.isNotEmpty) {
          sourceVocabIds.add(vocabId);
        }
      }
      parsed.add((row: row, examples: examples));
    }

    final linkedVocabBySenseId = <String, VocabData>{};
    final linkedVocabByVocabId = <String, VocabData>{};

    if (sourceSenseIds.isNotEmpty || sourceVocabIds.isNotEmpty) {
      final query = _contentDb.select(_contentDb.vocab);
      if (sourceSenseIds.isNotEmpty && sourceVocabIds.isNotEmpty) {
        query.where(
          (tbl) =>
              tbl.sourceSenseId.isIn(sourceSenseIds.toList()) |
              tbl.sourceVocabId.isIn(sourceVocabIds.toList()),
        );
      } else if (sourceSenseIds.isNotEmpty) {
        query.where((tbl) => tbl.sourceSenseId.isIn(sourceSenseIds.toList()));
      } else {
        query.where((tbl) => tbl.sourceVocabId.isIn(sourceVocabIds.toList()));
      }

      final linkedRows = await query.get();
      for (final vocab in linkedRows) {
        final senseId = vocab.sourceSenseId?.trim();
        final vocabId = vocab.sourceVocabId?.trim();
        if (senseId != null && senseId.isNotEmpty) {
          linkedVocabBySenseId.putIfAbsent(senseId, () => vocab);
        }
        if (vocabId != null && vocabId.isNotEmpty) {
          linkedVocabByVocabId.putIfAbsent(vocabId, () => vocab);
        }
      }
    }

    return parsed.map((entry) {
      final row = entry.row;
      final examples = entry.examples
          .map(
            (example) => _resolveKanjiExampleFromVocab(
              example: example,
              linkedVocabBySenseId: linkedVocabBySenseId,
              linkedVocabByVocabId: linkedVocabByVocabId,
            ),
          )
          .toList();

      return KanjiItem(
        id: row.id,
        lessonId: row.lessonId,
        character: row.character,
        strokeCount: row.strokeCount,
        onyomi: row.onyomi,
        kunyomi: row.kunyomi,
        meaning: row.meaning,
        meaningEn: row.meaningEn,
        mnemonicVi: row.mnemonicVi,
        mnemonicEn: row.mnemonicEn,
        decomposition: _decodeKanjiDecomposition(row.decompositionJson),
        examples: examples,
        jlptLevel: row.jlptLevel,
      );
    }).toList();
  }

  KanjiDecomposition? _decodeKanjiDecomposition(String? rawJson) {
    final text = rawJson?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }

    dynamic decoded;
    try {
      decoded = json.decode(text);
    } catch (_) {
      return null;
    }

    if (decoded is Map<String, dynamic>) {
      final decomposition = KanjiDecomposition.fromJson(decoded);
      return decomposition.hasContent ? decomposition : null;
    }
    if (decoded is Map) {
      final normalized = decoded.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final decomposition = KanjiDecomposition.fromJson(normalized);
      return decomposition.hasContent ? decomposition : null;
    }
    return null;
  }

  List<KanjiExample> _decodeKanjiExamples(String examplesJson) {
    dynamic decoded;
    try {
      decoded = json.decode(examplesJson);
    } catch (_) {
      return const [];
    }

    if (decoded is! List) return const [];
    return decoded
        .whereType<dynamic>()
        .map((item) {
          if (item is Map<String, dynamic>) {
            return KanjiExample.fromJson(item);
          }
          if (item is Map) {
            final normalized = item.map(
              (key, value) => MapEntry(key.toString(), value),
            );
            return KanjiExample.fromJson(normalized);
          }
          return const KanjiExample();
        })
        .where((example) => _isUsableKanjiExample(example))
        .toList();
  }

  bool _isUsableKanjiExample(KanjiExample example) {
    return example.word.trim().isNotEmpty ||
        example.reading.trim().isNotEmpty ||
        example.meaning.trim().isNotEmpty ||
        example.hasSourceRef;
  }

  KanjiExample _resolveKanjiExampleFromVocab({
    required KanjiExample example,
    required Map<String, VocabData> linkedVocabBySenseId,
    required Map<String, VocabData> linkedVocabByVocabId,
  }) {
    VocabData? linked;
    final senseId = example.sourceSenseId?.trim();
    if (senseId != null && senseId.isNotEmpty) {
      linked = linkedVocabBySenseId[senseId];
    }

    final vocabId = example.sourceVocabId?.trim();
    if (linked == null && vocabId != null && vocabId.isNotEmpty) {
      linked = linkedVocabByVocabId[vocabId];
    }

    if (linked == null) {
      return example;
    }

    final word = linked.term.trim().isEmpty ? example.word : linked.term;
    final reading = (linked.reading ?? '').trim().isEmpty
        ? example.reading
        : linked.reading!;
    final meaning = linked.meaning.trim().isEmpty
        ? example.meaning
        : linked.meaning;
    final meaningEn = (linked.meaningEn ?? '').trim().isEmpty
        ? example.meaningEn
        : linked.meaningEn;

    return example.resolvedWith(
      word: word,
      reading: reading,
      meaning: meaning,
      meaningEn: meaningEn,
    );
  }

  Future<List<KanjiItem>> fetchDueKanji(int lessonId) async {
    final items = await fetchKanji(lessonId);
    if (items.isEmpty) return [];
    final ids = items.map((item) => item.id).toList();
    final states = await _db.kanjiSrsDao.getStatesForIds(ids);
    final stateMap = {for (final state in states) state.kanjiId: state};
    final now = DateTime.now();
    return items.where((item) {
      final state = stateMap[item.id];
      if (state == null) return true;
      return !state.nextReviewAt.isAfter(now);
    }).toList();
  }

  Future<int?> findFirstLessonWithDueKanji(String level) async {
    final dueStates = await _db.kanjiSrsDao.getDueReviews();
    if (dueStates.isEmpty) return null;

    final dueIds = dueStates.map((state) => state.kanjiId).toList();
    final rows =
        await (_contentDb.select(_contentDb.kanji)..where((tbl) {
              return tbl.id.isIn(dueIds) & tbl.jlptLevel.equals(level);
            }))
            .get();
    if (rows.isEmpty) return null;

    rows.sort((a, b) => a.lessonId.compareTo(b.lessonId));
    return rows.first.lessonId;
  }

  Future<KanjiSrsStateData?> getKanjiSrsState(int kanjiId) {
    return _db.kanjiSrsDao.getSrsState(kanjiId);
  }

  Future<Map<int, KanjiSrsStateData>> getKanjiSrsStatesForIds(
    List<int> kanjiIds,
  ) async {
    final states = await _db.kanjiSrsDao.getStatesForIds(kanjiIds);
    return {for (final state in states) state.kanjiId: state};
  }

  Future<void> ensureKanjiSrsState(int kanjiId) async {
    final existing = await _db.kanjiSrsDao.getSrsState(kanjiId);
    if (existing == null) {
      await _db.kanjiSrsDao.initializeSrsState(kanjiId);
    }
  }

  Future<void> saveKanjiReview({
    required int kanjiId,
    required int grade,
  }) async {
    await ensureKanjiSrsState(kanjiId);
    final state = await _db.kanjiSrsDao.getSrsState(kanjiId);
    if (state == null) return;

    final result = _fsrsService.review(
      grade: grade,
      stability: state.stability,
      difficulty: state.difficulty,
      lastReviewedAt: state.lastReviewedAt,
    );

    await _db.kanjiSrsDao.updateSrsState(
      kanjiId: kanjiId,
      stability: result.stability,
      difficulty: result.difficulty,
      lastConfidence: grade,
      nextReviewAt: result.nextReviewAt,
    );
  }

  Future<void> updateLessonTitle(
    int lessonId,
    String title, {
    bool isCustomTitle = true,
  }) {
    return (_db.update(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).write(
      UserLessonCompanion(
        title: Value(title),
        isCustomTitle: Value(isCustomTitle),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateLessonDescription(int lessonId, String description) {
    return (_db.update(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).write(
      UserLessonCompanion(
        description: Value(description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateLessonTags(int lessonId, String tags) {
    return (_db.update(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).write(
      UserLessonCompanion(tags: Value(tags), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> updateLessonPublic(int lessonId, bool isPublic) {
    return (_db.update(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).write(
      UserLessonCompanion(
        isPublic: Value(isPublic),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateLessonPracticeSettings(
    int lessonId, {
    int? learnTermLimit,
    int? testQuestionLimit,
    int? matchPairLimit,
  }) {
    return (_db.update(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).write(
      UserLessonCompanion(
        learnTermLimit: learnTermLimit == null
            ? const Value.absent()
            : Value(learnTermLimit),
        testQuestionLimit: testQuestionLimit == null
            ? const Value.absent()
            : Value(testQuestionLimit),
        matchPairLimit: matchPairLimit == null
            ? const Value.absent()
            : Value(matchPairLimit),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> addTerm(
    int lessonId, {
    String? term,
    String? reading,
    String? definition,
    String? definitionEn,
    String? kanjiMeaning,
  }) async {
    final maxOrder =
        await (_db.selectOnly(_db.userLessonTerm)
              ..addColumns([_db.userLessonTerm.orderIndex])
              ..where(_db.userLessonTerm.lessonId.equals(lessonId))
              ..orderBy([
                OrderingTerm(
                  expression: _db.userLessonTerm.orderIndex,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    final nextOrder = (maxOrder?.read(_db.userLessonTerm.orderIndex) ?? 0) + 1;
    final termId = await _db
        .into(_db.userLessonTerm)
        .insert(
          UserLessonTermCompanion.insert(
            lessonId: lessonId,
            orderIndex: Value(nextOrder),
            term: term == null ? const Value.absent() : Value(term),
            reading: reading == null ? const Value.absent() : Value(reading),
            definition: definition == null
                ? const Value.absent()
                : Value(definition),
            definitionEn: definitionEn == null
                ? const Value.absent()
                : Value(definitionEn),
            kanjiMeaning: kanjiMeaning == null
                ? const Value.absent()
                : Value(kanjiMeaning),
          ),
        );
    await _touchLesson(lessonId);
    return termId;
  }

  Future<UserLessonTermData?> findTermInLesson(
    int lessonId,
    String term,
    String? reading,
  ) {
    final normalizedReading = (reading ?? '').trim();
    return (_db.select(_db.userLessonTerm)
          ..where((tbl) => tbl.lessonId.equals(lessonId))
          ..where((tbl) => tbl.term.equals(term))
          ..where((tbl) => tbl.reading.equals(normalizedReading)))
        .getSingleOrNull();
  }

  /// Resolve a content vocab id to the seeded user term id used by SRS.
  /// Returns null when the vocab item has not been seeded yet.
  Future<int?> resolveUserTermIdForContentVocabId(int contentVocabId) async {
    final source = await (_contentDb.select(
      _contentDb.vocab,
    )..where((tbl) => tbl.id.equals(contentVocabId))).getSingleOrNull();
    if (source == null) {
      return null;
    }

    return _resolveUserTermId(
      term: source.term,
      reading: source.reading,
      meaningVi: source.meaning,
      meaningEn: source.meaningEn,
      level: source.level,
    );
  }

  Future<int?> _resolveUserTermId({
    required String term,
    String? reading,
    String? meaningVi,
    String? meaningEn,
    String? level,
  }) async {
    final normalizedTerm = term.trim();
    if (normalizedTerm.isEmpty) {
      return null;
    }

    final normalizedReading = (reading ?? '').trim();
    final normalizedMeaningVi = (meaningVi ?? '').trim();
    final normalizedMeaningEn = (meaningEn ?? '').trim();
    final normalizedLevel = (level ?? '').trim().toUpperCase();

    Future<List<UserLessonTermData>> queryCandidates({
      required bool strictReading,
      required bool filterByLevel,
    }) async {
      final query = _db.select(_db.userLessonTerm).join([
        innerJoin(
          _db.userLesson,
          _db.userLesson.id.equalsExp(_db.userLessonTerm.lessonId),
        ),
      ]);

      query.where(_db.userLessonTerm.term.equals(normalizedTerm));
      if (strictReading) {
        query.where(_db.userLessonTerm.reading.equals(normalizedReading));
      }
      if (filterByLevel && normalizedLevel.isNotEmpty) {
        query.where(_db.userLesson.level.equals(normalizedLevel));
      }

      query.orderBy([
        OrderingTerm(expression: _db.userLesson.id),
        OrderingTerm(expression: _db.userLessonTerm.orderIndex),
      ]);

      final rows = await query.get();
      return rows.map((row) => row.readTable(_db.userLessonTerm)).toList();
    }

    var candidates = await queryCandidates(
      strictReading: true,
      filterByLevel: true,
    );

    if (candidates.isEmpty) {
      candidates = await queryCandidates(
        strictReading: true,
        filterByLevel: false,
      );
    }

    if (candidates.isEmpty && normalizedReading.isNotEmpty) {
      candidates = await queryCandidates(
        strictReading: false,
        filterByLevel: true,
      );
    }

    if (candidates.isEmpty && normalizedReading.isNotEmpty) {
      candidates = await queryCandidates(
        strictReading: false,
        filterByLevel: false,
      );
    }

    if (candidates.isEmpty) {
      return null;
    }

    if (normalizedMeaningVi.isNotEmpty) {
      final viMatch = candidates
          .where((item) => item.definition.trim() == normalizedMeaningVi)
          .toList();
      if (viMatch.isNotEmpty) {
        return viMatch.first.id;
      }
    }

    if (normalizedMeaningEn.isNotEmpty) {
      final enMatch = candidates
          .where((item) => item.definitionEn.trim() == normalizedMeaningEn)
          .toList();
      if (enMatch.isNotEmpty) {
        return enMatch.first.id;
      }
    }

    return candidates.first.id;
  }

  Future<void> updateTerm(
    int termId, {
    int? lessonId,
    String? term,
    String? reading,
    String? definition,
    String? definitionEn,
    String? kanjiMeaning,
  }) {
    final update =
        (_db.update(
          _db.userLessonTerm,
        )..where((tbl) => tbl.id.equals(termId))).write(
          UserLessonTermCompanion(
            term: term == null ? const Value.absent() : Value(term),
            reading: reading == null ? const Value.absent() : Value(reading),
            definition: definition == null
                ? const Value.absent()
                : Value(definition),
            definitionEn: definitionEn == null
                ? const Value.absent()
                : Value(definitionEn),
            kanjiMeaning: kanjiMeaning == null
                ? const Value.absent()
                : Value(kanjiMeaning),
          ),
        );
    if (lessonId == null) {
      return update;
    }
    return update.then((_) => _touchLesson(lessonId));
  }

  Future<void> updateTermStar(
    int termId, {
    required bool isStarred,
    int? lessonId,
  }) {
    final update =
        (_db.update(_db.userLessonTerm)..where((tbl) => tbl.id.equals(termId)))
            .write(UserLessonTermCompanion(isStarred: Value(isStarred)));
    if (lessonId == null) {
      return update;
    }
    return update.then((_) => _touchLesson(lessonId));
  }

  Future<void> updateTermLearned(
    int termId, {
    required bool isLearned,
    int? lessonId,
  }) {
    final update =
        (_db.update(_db.userLessonTerm)..where((tbl) => tbl.id.equals(termId)))
            .write(UserLessonTermCompanion(isLearned: Value(isLearned)));
    if (lessonId == null) {
      return update;
    }
    return update.then((_) => _touchLesson(lessonId));
  }

  Future<void> setStarredForLesson(int lessonId, bool isStarred) async {
    await (_db.update(_db.userLessonTerm)
          ..where((tbl) => tbl.lessonId.equals(lessonId)))
        .write(UserLessonTermCompanion(isStarred: Value(isStarred)));
    await _touchLesson(lessonId);
  }

  Future<void> resetLessonProgress(int lessonId) async {
    final ids =
        await (_db.selectOnly(_db.userLessonTerm)
              ..addColumns([_db.userLessonTerm.id])
              ..where(_db.userLessonTerm.lessonId.equals(lessonId)))
            .map((row) => row.read(_db.userLessonTerm.id)!)
            .get();
    if (ids.isEmpty) {
      return;
    }
    await _db.transaction(() async {
      await (_db.update(_db.userLessonTerm)
            ..where((tbl) => tbl.lessonId.equals(lessonId)))
          .write(const UserLessonTermCompanion(isLearned: Value(false)));
      await (_db.delete(
        _db.srsState,
      )..where((tbl) => tbl.vocabId.isIn(ids))).go();
    });
    await _touchLesson(lessonId);
  }

  Future<UserProgressData> _ensureProgressRow(DateTime day) async {
    final existing = await (_db.select(
      _db.userProgress,
    )..where((tbl) => tbl.day.equals(day))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }
    final yesterday = day.subtract(const Duration(days: 1));
    final yesterdayRow = await (_db.select(
      _db.userProgress,
    )..where((tbl) => tbl.day.equals(yesterday))).getSingleOrNull();
    final nextStreak = yesterdayRow == null ? 1 : yesterdayRow.streak + 1;
    final id = await _db
        .into(_db.userProgress)
        .insert(
          UserProgressCompanion.insert(
            day: day,
            xp: const Value(0),
            streak: Value(nextStreak),
            reviewedCount: const Value(0),
            reviewAgainCount: const Value(0),
            reviewHardCount: const Value(0),
            reviewGoodCount: const Value(0),
            reviewEasyCount: const Value(0),
          ),
        );
    return (_db.select(
      _db.userProgress,
    )..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<void> recordStudyActivity({required int xpDelta}) async {
    if (xpDelta <= 0) {
      return;
    }
    final today = _startOfDay(DateTime.now());
    final todayRow = await _ensureProgressRow(today);
    await (_db.update(
      _db.userProgress,
    )..where((tbl) => tbl.id.equals(todayRow.id))).write(
      UserProgressCompanion(
        xp: Value(todayRow.xp + xpDelta),
        streak: Value(todayRow.streak),
      ),
    );
  }

  Future<void> recordReview({required int quality}) async {
    final today = _startOfDay(DateTime.now());
    final todayRow = await _ensureProgressRow(today);
    var againDelta = 0;
    var hardDelta = 0;
    var goodDelta = 0;
    var easyDelta = 0;
    switch (quality) {
      case 0:
      case 1:
        againDelta = 1;
        break;
      case 2:
        hardDelta = 1;
        break;
      case 3:
        goodDelta = 1;
        break;
      case 4:
      case 5:
        easyDelta = 1;
        break;
    }
    await (_db.update(
      _db.userProgress,
    )..where((tbl) => tbl.id.equals(todayRow.id))).write(
      UserProgressCompanion(
        reviewedCount: Value(todayRow.reviewedCount + 1),
        reviewAgainCount: Value(todayRow.reviewAgainCount + againDelta),
        reviewHardCount: Value(todayRow.reviewHardCount + hardDelta),
        reviewGoodCount: Value(todayRow.reviewGoodCount + goodDelta),
        reviewEasyCount: Value(todayRow.reviewEasyCount + easyDelta),
        streak: Value(todayRow.streak),
      ),
    );
  }

  /// Process an SRS review for a specific term
  Future<FsrsReviewResult?> saveTermReview({
    required int termId,
    required int quality,
  }) async {
    // 1. Update Global Stats
    await recordReview(quality: quality);

    // 2. Get current SRS state
    var srsState = await _db.srsDao.getSrsState(termId);

    // Initialize if missing
    if (srsState == null) {
      await _db.srsDao.initializeSrsState(termId);
      srsState = await _db.srsDao.getSrsState(termId);
    }

    if (srsState == null) return null;

    final result = _fsrsService.review(
      grade: quality,
      stability: srsState.stability,
      difficulty: srsState.difficulty,
      lastReviewedAt: srsState.lastReviewedAt,
    );

    // 4. Update SRS state
    await _db.srsDao.updateSrsState(
      vocabId: termId,
      box: srsState.box,
      repetitions: srsState.repetitions + 1,
      ease: srsState.ease,
      stability: result.stability,
      difficulty: result.difficulty,
      lastConfidence: quality,
      nextReviewAt: result.nextReviewAt,
    );

    return result;
  }

  Future<void> ensureSrsStateForTerm(int termId) async {
    final existing = await _db.srsDao.getSrsState(termId);
    if (existing == null) {
      await _db.srsDao.initializeSrsState(termId);
    }
  }

  Future<int> recordAttempt({
    required String mode,
    required String level,
    required DateTime startedAt,
    required DateTime finishedAt,
    required int score,
    required int total,
    List<AttemptAnswerDraft> answers = const [],
  }) async {
    return _db.transaction(() async {
      final attemptId = await _db
          .into(_db.attempt)
          .insert(
            AttemptCompanion.insert(
              mode: mode,
              level: level,
              startedAt: startedAt,
              finishedAt: Value(finishedAt),
              score: Value(score),
              total: Value(total),
            ),
          );
      if (answers.isNotEmpty) {
        await _db.batch((batch) {
          for (final answer in answers) {
            batch.insert(
              _db.attemptAnswer,
              AttemptAnswerCompanion.insert(
                attemptId: attemptId,
                questionId: answer.questionId,
                selectedIndex: answer.selectedIndex,
                isCorrect: answer.isCorrect,
              ),
            );
          }
        });
      }
      return attemptId;
    });
  }

  Future<List<ReviewDaySummary>> fetchReviewHistory({int limit = 30}) async {
    final rows =
        await (_db.select(_db.userProgress)
              ..where((tbl) => tbl.reviewedCount.isBiggerThanValue(0))
              ..orderBy([
                (tbl) =>
                    OrderingTerm(expression: tbl.day, mode: OrderingMode.desc),
              ])
              ..limit(limit))
            .get();
    return rows
        .map(
          (row) => ReviewDaySummary(
            day: row.day,
            reviewed: row.reviewedCount,
            again: row.reviewAgainCount,
            hard: row.reviewHardCount,
            good: row.reviewGoodCount,
            easy: row.reviewEasyCount,
          ),
        )
        .toList();
  }

  Future<List<AttemptSummary>> fetchAttemptHistory({int limit = 50}) async {
    final rows =
        await (_db.select(_db.attempt)
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.startedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();
    return rows
        .map(
          (row) => AttemptSummary(
            id: row.id,
            mode: row.mode,
            level: row.level,
            startedAt: row.startedAt,
            finishedAt: row.finishedAt,
            score: row.score ?? 0,
            total: row.total ?? 0,
          ),
        )
        .toList();
  }

  Future<ProgressSummary> fetchProgressSummary() async {
    final today = _startOfDay(DateTime.now());
    final todayRow = await (_db.select(
      _db.userProgress,
    )..where((tbl) => tbl.day.equals(today))).getSingleOrNull();
    final latestRow =
        await (_db.select(_db.userProgress)
              ..orderBy([
                (tbl) =>
                    OrderingTerm(expression: tbl.day, mode: OrderingMode.desc),
              ])
              ..limit(1))
            .getSingleOrNull();

    var streak = 0;
    if (todayRow != null) {
      streak = todayRow.streak;
    } else if (latestRow != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_isSameDay(latestRow.day, yesterday)) {
        streak = latestRow.streak;
      }
    }

    final totalXpRow = await (_db.selectOnly(
      _db.userProgress,
    )..addColumns([_db.userProgress.xp.sum()])).getSingleOrNull();
    final totalXp = totalXpRow?.read(_db.userProgress.xp.sum()) ?? 0;

    final attemptStats =
        await (_db.selectOnly(_db.attempt)..addColumns([
              _db.attempt.id.count(),
              _db.attempt.score.sum(),
              _db.attempt.total.sum(),
            ]))
            .getSingleOrNull();
    final totalAttempts = attemptStats?.read(_db.attempt.id.count()) ?? 0;
    final totalCorrect = attemptStats?.read(_db.attempt.score.sum()) ?? 0;
    final totalQuestions = attemptStats?.read(_db.attempt.total.sum()) ?? 0;

    return ProgressSummary(
      totalXp: totalXp,
      todayXp: todayRow?.xp ?? 0,
      streak: streak,
      totalAttempts: totalAttempts,
      totalCorrect: totalCorrect,
      totalQuestions: totalQuestions,
    );
  }

  DateTime _startOfDay(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> deleteTerm(int termId, {int? lessonId}) {
    final delete = (_db.delete(
      _db.userLessonTerm,
    )..where((tbl) => tbl.id.equals(termId))).go();
    if (lessonId == null) {
      return delete;
    }
    return delete.then((_) => _touchLesson(lessonId));
  }

  Future<void> updateTermOrder(int lessonId, List<int> orderedIds) async {
    await _db.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        batch.update(
          _db.userLessonTerm,
          UserLessonTermCompanion(orderIndex: Value(i + 1)),
          where: (tbl) => tbl.id.equals(orderedIds[i]),
        );
      }
    });
    await _touchLesson(lessonId);
  }

  Future<void> replaceTerms(int lessonId, List<LessonTermDraft> terms) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.userLessonTerm,
      )..where((tbl) => tbl.lessonId.equals(lessonId))).go();
      for (var i = 0; i < terms.length; i++) {
        final term = terms[i];
        await _db
            .into(_db.userLessonTerm)
            .insert(
              UserLessonTermCompanion.insert(
                lessonId: lessonId,
                orderIndex: Value(i + 1),
                term: Value(term.term),
                reading: Value(term.reading),
                definition: Value(term.definition),
                kanjiMeaning: Value(term.kanjiMeaning),
              ),
            );
      }
    });
    await _touchLesson(lessonId);
  }

  Future<void> appendTerms(int lessonId, List<LessonTermDraft> terms) async {
    if (terms.isEmpty) {
      return;
    }
    final maxOrder =
        await (_db.selectOnly(_db.userLessonTerm)
              ..addColumns([_db.userLessonTerm.orderIndex])
              ..where(_db.userLessonTerm.lessonId.equals(lessonId))
              ..orderBy([
                OrderingTerm(
                  expression: _db.userLessonTerm.orderIndex,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    var nextOrder = (maxOrder?.read(_db.userLessonTerm.orderIndex) ?? 0) + 1;
    await _db.batch((batch) {
      for (final term in terms) {
        batch.insert(
          _db.userLessonTerm,
          UserLessonTermCompanion.insert(
            lessonId: lessonId,
            orderIndex: Value(nextOrder),
            term: Value(term.term),
            reading: Value(term.reading),
            definition: Value(term.definition),
            kanjiMeaning: Value(term.kanjiMeaning),
          ),
        );
        nextOrder += 1;
      }
    });
    await _touchLesson(lessonId);
  }

  Future<List<UserLessonTermData>> fetchDueTerms(int lessonId) {
    final now = DateTime.now();
    final query = _db.select(_db.userLessonTerm).join([
      innerJoin(
        _db.srsState,
        _db.srsState.vocabId.equalsExp(_db.userLessonTerm.id),
      ),
    ]);
    query
      ..where(_db.userLessonTerm.lessonId.equals(lessonId))
      ..where(_db.userLessonTerm.term.like('%?%').not())
      ..where(_db.userLessonTerm.reading.like('%?%').not())
      ..where(_db.srsState.nextReviewAt.isSmallerOrEqualValue(now))
      ..orderBy([OrderingTerm(expression: _db.userLessonTerm.orderIndex)]);
    return query.map((row) => row.readTable(_db.userLessonTerm)).get();
  }

  Future<List<UserLessonTermData>> fetchAllDueTerms() {
    final now = DateTime.now();
    final query = _db.select(_db.userLessonTerm).join([
      innerJoin(
        _db.srsState,
        _db.srsState.vocabId.equalsExp(_db.userLessonTerm.id),
      ),
    ]);
    query
      ..where(_db.userLessonTerm.term.like('%?%').not())
      ..where(_db.userLessonTerm.reading.like('%?%').not())
      ..where(_db.srsState.nextReviewAt.isSmallerOrEqualValue(now))
      ..orderBy([OrderingTerm(expression: _db.srsState.nextReviewAt)]);
    return query.map((row) => row.readTable(_db.userLessonTerm)).get();
  }

  Future<SrsStateData?> getSrsState(int termId) {
    return (_db.select(
      _db.srsState,
    )..where((tbl) => tbl.vocabId.equals(termId))).getSingleOrNull();
  }

  Future<void> upsertSrsState({
    required int termId,
    required int box,
    required int repetitions,
    required double ease,
    required double stability,
    required double difficulty,
    required DateTime nextReviewAt,
    required DateTime lastReviewedAt,
  }) {
    return _db
        .into(_db.srsState)
        .insertOnConflictUpdate(
          SrsStateCompanion(
            vocabId: Value(termId),
            box: Value(box),
            repetitions: Value(repetitions),
            ease: Value(ease),
            stability: Value(stability),
            difficulty: Value(difficulty),
            lastReviewedAt: Value(lastReviewedAt),
            nextReviewAt: Value(nextReviewAt),
          ),
        );
  }

  Future<void> deleteSrsState(int termId) {
    return (_db.delete(
      _db.srsState,
    )..where((tbl) => tbl.vocabId.equals(termId))).go();
  }

  Future<Map<String, dynamic>> exportBackup() async {
    final lessons = await _db.select(_db.userLesson).get();
    final terms = await _db.select(_db.userLessonTerm).get();
    final srs = await _db.select(_db.srsState).get();
    final grammarSrs = await _db.select(_db.grammarSrsState).get();
    final kanjiSrs = await _db.select(_db.kanjiSrsState).get();
    final mistakes = await _db.select(_db.userMistakes).get();
    final progress = await _db.select(_db.userProgress).get();
    final attempts = await _db.select(_db.attempt).get();
    final attemptAnswers = await _db.select(_db.attemptAnswer).get();
    final learnSessions = await _db.select(_db.learnSessions).get();
    final learnAnswers = await _db.select(_db.learnAnswers).get();
    final testSessions = await _db.select(_db.testSessions).get();
    final testAnswers = await _db.select(_db.testAnswers).get();
    final achievements = await _db.select(_db.achievements).get();
    final flashcardSettings = await _db.select(_db.flashcardSettings).get();
    final learnSettings = await _db.select(_db.learnSettings).get();
    final testSettings = await _db.select(_db.testSettings).get();

    return {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'terms': terms.map((term) => term.toJson()).toList(),
      'srs': srs.map((state) => state.toJson()).toList(),
      'grammarSrs': grammarSrs.map((state) => state.toJson()).toList(),
      'kanjiSrs': kanjiSrs.map((state) => state.toJson()).toList(),
      'mistakes': mistakes.map((item) => item.toJson()).toList(),
      'progress': progress.map((item) => item.toJson()).toList(),
      'attempts': attempts.map((item) => item.toJson()).toList(),
      'attemptAnswers': attemptAnswers.map((item) => item.toJson()).toList(),
      'learnSessions': learnSessions.map((item) => item.toJson()).toList(),
      'learnAnswers': learnAnswers.map((item) => item.toJson()).toList(),
      'testSessions': testSessions.map((item) => item.toJson()).toList(),
      'testAnswers': testAnswers.map((item) => item.toJson()).toList(),
      'achievements': achievements.map((item) => item.toJson()).toList(),
      'flashcardSettings': flashcardSettings
          .map((item) => item.toJson())
          .toList(),
      'learnSettings': learnSettings.map((item) => item.toJson()).toList(),
      'testSettings': testSettings.map((item) => item.toJson()).toList(),
    };
  }

  Future<void> importBackup(Map<String, dynamic> data) async {
    final lessonsRaw = data['lessons'] as List<dynamic>? ?? const [];
    final termsRaw = data['terms'] as List<dynamic>? ?? const [];
    final srsRaw = data['srs'] as List<dynamic>? ?? const [];
    final grammarSrsRaw = data['grammarSrs'] as List<dynamic>? ?? const [];
    final kanjiSrsRaw = data['kanjiSrs'] as List<dynamic>? ?? const [];
    final mistakesRaw = data['mistakes'] as List<dynamic>? ?? const [];
    final progressRaw = data['progress'] as List<dynamic>? ?? const [];
    final attemptsRaw = data['attempts'] as List<dynamic>? ?? const [];
    final attemptAnswersRaw =
        data['attemptAnswers'] as List<dynamic>? ?? const [];
    final learnSessionsRaw =
        data['learnSessions'] as List<dynamic>? ?? const [];
    final learnAnswersRaw = data['learnAnswers'] as List<dynamic>? ?? const [];
    final testSessionsRaw = data['testSessions'] as List<dynamic>? ?? const [];
    final testAnswersRaw = data['testAnswers'] as List<dynamic>? ?? const [];
    final achievementsRaw = data['achievements'] as List<dynamic>? ?? const [];
    final flashcardSettingsRaw =
        data['flashcardSettings'] as List<dynamic>? ?? const [];
    final learnSettingsRaw =
        data['learnSettings'] as List<dynamic>? ?? const [];
    final testSettingsRaw = data['testSettings'] as List<dynamic>? ?? const [];

    final lessons = lessonsRaw
        .whereType<Map<String, dynamic>>()
        .map(UserLessonData.fromJson)
        .toList();
    final terms = termsRaw
        .whereType<Map<String, dynamic>>()
        .map(UserLessonTermData.fromJson)
        .toList();
    final srs = srsRaw
        .whereType<Map<String, dynamic>>()
        .map(SrsStateData.fromJson)
        .toList();
    final grammarSrs = grammarSrsRaw
        .whereType<Map<String, dynamic>>()
        .map(GrammarSrsStateData.fromJson)
        .toList();
    final kanjiSrs = kanjiSrsRaw
        .whereType<Map<String, dynamic>>()
        .map(KanjiSrsStateData.fromJson)
        .toList();
    final mistakes = mistakesRaw
        .whereType<Map<String, dynamic>>()
        .map(UserMistake.fromJson)
        .toList();
    final progress = progressRaw
        .whereType<Map<String, dynamic>>()
        .map(UserProgressData.fromJson)
        .toList();
    final attempts = attemptsRaw
        .whereType<Map<String, dynamic>>()
        .map(AttemptData.fromJson)
        .toList();
    final attemptAnswers = attemptAnswersRaw
        .whereType<Map<String, dynamic>>()
        .map(AttemptAnswerData.fromJson)
        .toList();
    final learnSessions = learnSessionsRaw
        .whereType<Map<String, dynamic>>()
        .map(LearnSession.fromJson)
        .toList();
    final learnAnswers = learnAnswersRaw
        .whereType<Map<String, dynamic>>()
        .map(LearnAnswer.fromJson)
        .toList();
    final testSessions = testSessionsRaw
        .whereType<Map<String, dynamic>>()
        .map(TestSession.fromJson)
        .toList();
    final testAnswers = testAnswersRaw
        .whereType<Map<String, dynamic>>()
        .map(TestAnswer.fromJson)
        .toList();
    final achievements = achievementsRaw
        .whereType<Map<String, dynamic>>()
        .map(Achievement.fromJson)
        .toList();
    final flashcardSettings = flashcardSettingsRaw
        .whereType<Map<String, dynamic>>()
        .map(FlashcardSetting.fromJson)
        .toList();
    final learnSettings = learnSettingsRaw
        .whereType<Map<String, dynamic>>()
        .map(LearnSetting.fromJson)
        .toList();
    final testSettings = testSettingsRaw
        .whereType<Map<String, dynamic>>()
        .map(TestSetting.fromJson)
        .toList();

    await _db.transaction(() async {
      await _db.delete(_db.attemptAnswer).go();
      await _db.delete(_db.attempt).go();
      await _db.delete(_db.learnAnswers).go();
      await _db.delete(_db.learnSessions).go();
      await _db.delete(_db.testAnswers).go();
      await _db.delete(_db.testSessions).go();
      await _db.delete(_db.achievements).go();
      await _db.delete(_db.flashcardSettings).go();
      await _db.delete(_db.learnSettings).go();
      await _db.delete(_db.testSettings).go();
      await _db.delete(_db.userMistakes).go();
      await _db.delete(_db.kanjiSrsState).go();
      await _db.delete(_db.grammarSrsState).go();
      await _db.delete(_db.srsState).go();
      await _db.delete(_db.userProgress).go();
      await _db.delete(_db.userLessonTerm).go();
      await _db.delete(_db.userLesson).go();

      await _db.batch((batch) {
        for (final lesson in lessons) {
          batch.insert(
            _db.userLesson,
            lesson.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final term in terms) {
          batch.insert(
            _db.userLessonTerm,
            term.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final state in srs) {
          batch.insert(
            _db.srsState,
            state.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final state in grammarSrs) {
          batch.insert(
            _db.grammarSrsState,
            state.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final state in kanjiSrs) {
          batch.insert(
            _db.kanjiSrsState,
            state.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in mistakes) {
          batch.insert(
            _db.userMistakes,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in progress) {
          batch.insert(
            _db.userProgress,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in attempts) {
          batch.insert(
            _db.attempt,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in attemptAnswers) {
          batch.insert(
            _db.attemptAnswer,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in learnSessions) {
          batch.insert(
            _db.learnSessions,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in learnAnswers) {
          batch.insert(
            _db.learnAnswers,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in testSessions) {
          batch.insert(
            _db.testSessions,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in testAnswers) {
          batch.insert(
            _db.testAnswers,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in achievements) {
          batch.insert(
            _db.achievements,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in flashcardSettings) {
          batch.insert(
            _db.flashcardSettings,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in learnSettings) {
          batch.insert(
            _db.learnSettings,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
        for (final item in testSettings) {
          batch.insert(
            _db.testSettings,
            item.toCompanion(true),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    });
  }

  /// Initialize SRS state for ALL terms in a lesson (Start Learning Feature)
  /// This makes all terms in the lesson immediately available for review
  Future<void> initializeLessonSrs(int lessonId) async {
    final terms = await fetchTerms(lessonId);
    if (terms.isEmpty) return;

    final now = DateTime.now();
    // Schedule all terms for immediate review (nextReviewAt = now)
    await _db.batch((batch) {
      for (final term in terms) {
        // Use insertOrReplace to avoid duplicates
        batch.insert(
          _db.srsState,
          SrsStateCompanion.insert(
            vocabId: term.id,
            box: const Value(1),
            repetitions: const Value(0),
            ease: const Value(2.5),
            stability: const Value(1.0),
            difficulty: const Value(5.0),
            lastReviewedAt: Value(now),
            nextReviewAt: now, // Due immediately
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    // Also mark all terms as "learned" (started)
    await (_db.update(_db.userLessonTerm)
          ..where((tbl) => tbl.lessonId.equals(lessonId)))
        .write(const UserLessonTermCompanion(isLearned: Value(true)));
  }

  Future<void> _touchLesson(int lessonId) {
    return (_db.update(_db.userLesson)..where((tbl) => tbl.id.equals(lessonId)))
        .write(UserLessonCompanion(updatedAt: Value(DateTime.now())));
  }
}

class LessonProgressStats {
  const LessonProgressStats({
    required this.termCount,
    required this.completedCount,
  });

  final int termCount;
  final int completedCount;

  LessonProgressStats copyWith({int? termCount, int? completedCount}) {
    return LessonProgressStats(
      termCount: termCount ?? this.termCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}
