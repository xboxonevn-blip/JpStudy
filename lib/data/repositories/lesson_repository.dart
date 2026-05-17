import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';

import 'package:jpstudy/data/db/content_database.dart'
    hide UserProgressCompanion, UserProgressData, GrammarPointData;
import 'package:jpstudy/features/grammar/models/grammar_point_data.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/seeds/grammar_seeder.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';
import 'package:jpstudy/data/utils/han_viet_lookup.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(
    ref.watch(databaseProvider),
    ref.watch(contentDatabaseProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
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
      final sourceLessonId = args.resolvedSourceLessonId;
      await repo.ensureLesson(
        lessonId: args.lessonId,
        level: args.level,
        title: args.fallbackTitle,
      );
      // Vocab and grammar seeding touch independent tables — run concurrently.
      await Future.wait([
        repo.seedTermsIfEmpty(
          args.lessonId,
          args.level,
          sourceLessonId: sourceLessonId,
        ),
        repo.seedGrammarIfEmpty(sourceLessonId, args.level),
      ]);
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

final lessonRangeTermsProvider =
    FutureProvider.family<List<UserLessonTermData>, LessonRangeTermsArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      return repo.fetchTermsForLessonRange(
        args.level,
        startLesson: args.startLesson,
        endLesson: args.endLesson,
      );
    });

final vocabSeriesTermsProvider =
    FutureProvider.family<List<UserLessonTermData>, VocabSeriesTermsArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final items = args.hasLessonRange
          ? await repo.getVocabByLevelSeriesChapterRange(
              args.level,
              series: args.series,
              startChapter: args.startLesson!,
              endChapter: args.endLesson!,
            )
          : await repo.getVocabByLevelAndSeries(args.level, args.series);
      return [
        for (var index = 0; index < items.length; index++)
          UserLessonTermData(
            id: items[index].id,
            lessonId: 0,
            term: items[index].term,
            reading: items[index].reading ?? '',
            definition: items[index].meaning,
            definitionEn: items[index].meaningEn ?? items[index].meaning,
            mnemonicVi: items[index].mnemonicVi ?? '',
            mnemonicEn: items[index].mnemonicEn ?? '',
            kanjiMeaning: items[index].kanjiMeaning ?? '',
            isStarred: false,
            isLearned: false,
            orderIndex: index,
          ),
      ];
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
    this.totalXp = 0,
  });

  final int totalReviewed;
  final int accuracy; // percentage 0–100
  final int daysStudied;
  final int totalXp;
}

final weekSummaryProvider = FutureProvider<WeekSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final historyFuture = repo.fetchReviewHistory(limit: 7);
  final attemptsFuture = repo.fetchAttemptHistory(limit: 50);
  final history = await historyFuture;
  final attempts = await attemptsFuture;
  final cutoff = DateTime.now().subtract(const Duration(days: 7));

  final totalReviewed = history.fold(0, (s, d) => s + d.reviewed);
  final totalXp = history.fold(0, (s, d) => s + d.xp);
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
    totalXp: totalXp,
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
      final sourceLessonId = args.resolvedSourceLessonId;
      await repo.seedGrammarIfEmpty(sourceLessonId, args.level);
      return repo.fetchGrammarForLevel(args.level, sourceLessonId);
    });

final lessonKanjiProvider = FutureProvider.family<List<KanjiItem>, int>((
  ref,
  lessonId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  return repo.fetchKanjiForLevel(level.shortLabel, lessonId);
});

final lessonDueKanjiProvider = FutureProvider.family<List<KanjiItem>, int>((
  ref,
  lessonId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  return repo.fetchDueKanjiForLevelAndLesson(level.shortLabel, lessonId);
});

final srsStateProvider = FutureProvider.family<SrsStateData?, int>((
  ref,
  termId,
) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getSrsState(termId);
});

class LessonTermsArgs {
  const LessonTermsArgs(
    this.lessonId,
    this.level,
    this.fallbackTitle, {
    this.sourceLessonId,
  });

  final int lessonId;
  final String level;
  final String fallbackTitle;
  final int? sourceLessonId;

  int get resolvedSourceLessonId =>
      sourceLessonId ??
      LessonRepository.curriculumSourceLessonId(level, lessonId);

  @override
  bool operator ==(Object other) {
    return other is LessonTermsArgs &&
        other.lessonId == lessonId &&
        other.level == level &&
        other.fallbackTitle == fallbackTitle &&
        other.sourceLessonId == sourceLessonId;
  }

  @override
  int get hashCode =>
      Object.hash(lessonId, level, fallbackTitle, sourceLessonId);
}

class LessonRangeTermsArgs {
  const LessonRangeTermsArgs({
    required this.level,
    required this.startLesson,
    required this.endLesson,
  });

  final String level;
  final int startLesson;
  final int endLesson;

  @override
  bool operator ==(Object other) {
    return other is LessonRangeTermsArgs &&
        other.level == level &&
        other.startLesson == startLesson &&
        other.endLesson == endLesson;
  }

  @override
  int get hashCode => Object.hash(level, startLesson, endLesson);
}

class VocabSeriesTermsArgs {
  const VocabSeriesTermsArgs({
    required this.level,
    required this.series,
    this.startLesson,
    this.endLesson,
  });

  final String level;
  final String series;
  final int? startLesson;
  final int? endLesson;

  bool get hasLessonRange => startLesson != null && endLesson != null;

  @override
  bool operator ==(Object other) {
    return other is VocabSeriesTermsArgs &&
        other.level == level &&
        other.series == series &&
        other.startLesson == startLesson &&
        other.endLesson == endLesson;
  }

  @override
  int get hashCode => Object.hash(level, series, startLesson, endLesson);
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
    required this.xp,
  });

  final DateTime day;
  final int reviewed;
  final int again;
  final int hard;
  final int good;
  final int easy;
  final int xp;
}

class ProgressSummary {
  const ProgressSummary({
    required this.totalXp,
    required this.todayXp,
    required this.streak,
    required this.longestStreak,
    required this.totalDaysStudied,
    required this.totalAttempts,
    required this.totalCorrect,
    required this.totalQuestions,
  });

  final int totalXp;
  final int todayXp;
  final int streak;
  final int longestStreak;
  final int totalDaysStudied;
  final int totalAttempts;
  final int totalCorrect;
  final int totalQuestions;
}

// Process-level caches for read-only content DB counts and item lists.
// Content DB is seeded once and never mutated at runtime, so these are safe
// to cache for the lifetime of the process.
final _vocabCountCache = <String, int>{};
final _kanjiCountCache = <String, int>{};
// Cache keyed by "$level:$series:$start:$end" — lesson-range lists never change.
final _vocabLessonRangeCache = <String, List<VocabItem>>{};
// Full level+series vocab list cache — avoids re-mapping hundreds of DB rows.
final _vocabByLevelSeriesCache = <String, List<VocabItem>>{};
// Full level kanji list cache — avoids re-fetching and re-mapping on every call.
final _kanjiByLevelCache = <String, List<KanjiItem>>{};

class LessonRepository {
  LessonRepository(
    this._db,
    this._contentDb, {
    AnalyticsService? analyticsService,
  }) : _analyticsService = analyticsService;

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final AnalyticsService? _analyticsService;
  final FsrsService _fsrsService = FsrsService();
  static const int _defaultLessonCount = 25;
  static const _upperLevelLessonOffsets = <String, int>{
    'N1': 100000,
    'N2': 200000,
    'N3': 300000,
  };
  static final _seriesNormalizeRe = RegExp(r'[^a-z0-9]+');

  static int curriculumStorageLessonId(String level, int lessonId) {
    final normalized = level.trim().toUpperCase();
    final offset = _upperLevelLessonOffsets[normalized];
    if (offset == null) {
      return lessonId;
    }
    if (lessonId > offset && lessonId <= offset + _defaultLessonCount) {
      return lessonId;
    }
    return offset + lessonId;
  }

  static int curriculumSourceLessonId(String level, int lessonId) {
    final normalized = level.trim().toUpperCase();
    final offset = _upperLevelLessonOffsets[normalized];
    if (offset == null) {
      return lessonId;
    }
    if (lessonId > offset && lessonId <= offset + _defaultLessonCount) {
      return lessonId - offset;
    }
    return lessonId;
  }

  Future<String> getLessonTitle(int lessonId, String fallback) async {
    final existing = await (_db.select(
      _db.userLesson,
    )..where((tbl) => tbl.id.equals(lessonId))).getSingleOrNull();
    if (existing == null) {
      return fallback;
    }
    if (!existing.isCustomTitle ||
        _isGeneratedLessonTitle(existing.title, lessonId: lessonId)) {
      return fallback;
    }
    return existing.title;
  }

  bool _isGeneratedLessonTitle(String title, {int? lessonId}) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return true;
    }
    final isUpperCurriculumLesson =
        lessonId != null &&
        _upperLevelLessonOffsets.values.any(
          (offset) =>
              lessonId > offset && lessonId <= offset + _defaultLessonCount,
        );
    if (isUpperCurriculumLesson &&
        RegExp(
          r'Minna\s+No?\s+Nihongo',
          caseSensitive: false,
        ).hasMatch(normalized)) {
      return true;
    }
    return RegExp(
      r'^(Minna No Nihongo|Minna no Nihongo|Lesson)\s+\d+$',
    ).hasMatch(normalized);
  }

  Future<List<UserLessonData>> getAllLessons() {
    return _db.select(_db.userLesson).get();
  }

  // Returns a map of lessonId -> {termCount, completedCount}
  Future<Map<int, LessonProgressStats>> getAllLessonProgress() async {
    // Single GROUP BY pass: COUNT(*) for total, SUM(CASE WHEN is_learned) for
    // completed — replaces two separate aggregate queries on the same table.
    final rows = await _db
        .customSelect(
          'SELECT lesson_id, '
          'COUNT(*) AS term_count, '
          'SUM(CASE WHEN is_learned THEN 1 ELSE 0 END) AS completed_count '
          'FROM user_lesson_term '
          'GROUP BY lesson_id',
          readsFrom: {_db.userLessonTerm},
        )
        .get();

    final stats = <int, LessonProgressStats>{};
    for (final row in rows) {
      final lessonId = row.read<int?>('lesson_id');
      if (lessonId == null) continue;
      stats[lessonId] = LessonProgressStats(
        termCount: row.read<int?>('term_count') ?? 0,
        completedCount: row.read<int?>('completed_count') ?? 0,
      );
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

    // Fire both aggregate queries concurrently — independent of each other.
    // Single GROUP BY pass replaces loading full term rows for counting.
    final termCountsFuture = _db
        .customSelect(
          'SELECT lesson_id, '
          'COUNT(*) AS term_count, '
          'SUM(CASE WHEN is_learned THEN 1 ELSE 0 END) AS completed_count '
          'FROM user_lesson_term '
          'WHERE lesson_id IN (${ids.map((_) => '?').join(',')}) '
          'GROUP BY lesson_id',
          variables: ids.map(Variable<int>.new).toList(),
          readsFrom: {_db.userLessonTerm},
        )
        .get();
    final dueCountsFuture = _fetchDueCounts(ids);

    final termRows = await termCountsFuture;
    final dueCounts = await dueCountsFuture;

    final counts = <int, int>{};
    final completedCounts = <int, int>{};
    for (final row in termRows) {
      final lessonId = row.read<int?>('lesson_id');
      if (lessonId == null) continue;
      counts[lessonId] = row.read<int?>('term_count') ?? 0;
      completedCounts[lessonId] = row.read<int?>('completed_count') ?? 0;
    }

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

  // Fetch Minna vocabulary for a JLPT level by default to avoid mixing tracks in legacy flows.
  Future<List<VocabItem>> getVocabByLevel(String level) {
    return getVocabByLevelAndSeries(level, 'minna');
  }

  /// COUNT(*) variant — use when only the number of terms is needed.
  /// Avoids deserializing full vocab rows. Result is cached for the process
  /// lifetime since content DB data is read-only and never changes at runtime.
  Future<int> countVocabByLevelAndSeries(String level, String series) async {
    final key = '$level:$series';
    final cached = _vocabCountCache[key];
    if (cached != null) return cached;
    final countExpr = _contentDb.vocab.id.count();
    final row =
        await (_contentDb.selectOnly(_contentDb.vocab)
              ..addColumns([countExpr])
              ..where(
                _contentDb.vocab.level.equals(level) &
                    _contentDb.vocab.series.equals(series),
              ))
            .getSingle();
    final count = row.read(countExpr) ?? 0;
    _vocabCountCache[key] = count;
    return count;
  }

  Future<List<VocabItem>> getVocabByLevelAndSeries(
    String level,
    String series,
  ) async {
    final cacheKey = '$level:$series';
    final cached = _vocabByLevelSeriesCache[cacheKey];
    if (cached != null) return cached;

    final items =
        await (_contentDb.select(_contentDb.vocab)..where(
              (tbl) => tbl.level.equals(level) & tbl.series.equals(series),
            ))
            .get();

    final result = items.map(_mapContentVocabToItem).toList();
    _vocabByLevelSeriesCache[cacheKey] = result;
    return result;
  }

  Future<List<VocabItem>> getVocabByLevelSeriesChapterRange(
    String level, {
    required String series,
    required int startChapter,
    required int endChapter,
  }) async {
    if (series != 'hajimete') {
      return getVocabByLevelAndSeries(level, series);
    }

    final catalog = await loadHajimeteChapterCatalog(level);
    final sourceVocabIds = [
      for (final chapter in catalog.chapters)
        if (chapter.chapterId >= startChapter &&
            chapter.chapterId <= endChapter)
          ...chapter.sourceVocabIds,
    ];
    if (sourceVocabIds.isEmpty) {
      return const [];
    }

    final rows =
        await (_contentDb.select(_contentDb.vocab)..where(
              (tbl) =>
                  tbl.level.equals(level) &
                  tbl.series.equals(series) &
                  tbl.sourceVocabId.isIn(sourceVocabIds),
            ))
            .get();

    final bySourceId = {
      for (final row in rows)
        if ((row.sourceVocabId ?? '').trim().isNotEmpty)
          row.sourceVocabId!.trim(): row,
    };

    return [
      for (final sourceId in sourceVocabIds)
        if (bySourceId.containsKey(sourceId))
          _mapContentVocabToItem(bySourceId[sourceId]!),
    ];
  }

  Future<List<VocabItem>> getVocabByLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
    String series = 'minna',
  }) async {
    final cacheKey = '$level:$series:$startLesson:$endLesson';
    final cached = _vocabLessonRangeCache[cacheKey];
    if (cached != null) return cached;

    final lessonTags = {
      for (var lesson = startLesson; lesson <= endLesson; lesson++)
        '${series}_$lesson',
    };

    final items =
        await (_contentDb.select(_contentDb.vocab)..where(
              (tbl) => tbl.level.equals(level) & tbl.series.equals(series),
            ))
            .get();

    final result = items
        .where((item) {
          final rawTags = item.tags;
          if (rawTags == null || rawTags.trim().isEmpty) {
            return false;
          }
          final tags = rawTags
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toSet();
          return tags.any(lessonTags.contains);
        })
        .map(_mapContentVocabToItem)
        .toList();
    _vocabLessonRangeCache[cacheKey] = result;
    return result;
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
    // Single LEFT JOIN query with LIMIT 1 — avoids fetching all lessons and
    // all lesson progress just to find the first incomplete one.
    final rows = await _db
        .customSelect(
          'SELECT ul.id '
          'FROM user_lesson ul '
          'LEFT JOIN ('
          '  SELECT lesson_id, '
          '         COUNT(*) AS term_count, '
          '         SUM(CASE WHEN is_learned THEN 1 ELSE 0 END) AS completed_count '
          '  FROM user_lesson_term '
          '  GROUP BY lesson_id'
          ') stats ON stats.lesson_id = ul.id '
          'WHERE ul.level = ? '
          '  AND (stats.term_count IS NULL '
          '       OR stats.term_count = 0 '
          '       OR stats.completed_count < stats.term_count) '
          'ORDER BY ul.id '
          'LIMIT 1',
          variables: [Variable.withString(level)],
          readsFrom: {_db.userLesson, _db.userLessonTerm},
        )
        .getSingleOrNull();
    return rows?.read<int?>('id');
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

  Future<List<UserLessonTermData>> fetchTermsForLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
  }) async {
    // Phase 1: ensure + seed each lesson sequentially (FK dependency within
    // each lesson requires ordering: ensureLesson -> seedTermsIfEmpty).
    for (int lessonId = startLesson; lessonId <= endLesson; lessonId++) {
      final storageLessonId = curriculumStorageLessonId(level, lessonId);
      final title = await getLessonTitle(storageLessonId, 'Lesson $lessonId');
      await ensureLesson(lessonId: storageLessonId, level: level, title: title);
      await seedTermsIfEmpty(storageLessonId, level, sourceLessonId: lessonId);
    }

    // Phase 2: single bulk fetch for all lesson IDs — replaces N individual
    // fetchTerms(lessonId) calls with one WHERE lessonId IN (...) query.
    final lessonIds = List.generate(
      endLesson - startLesson + 1,
      (i) => curriculumStorageLessonId(level, startLesson + i),
    );
    final terms =
        await (_db.select(_db.userLessonTerm)
              ..where(
                (tbl) =>
                    tbl.lessonId.isIn(lessonIds) &
                    tbl.term.like('%?%').not() &
                    tbl.reading.like('%?%').not(),
              )
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.lessonId),
                (tbl) => OrderingTerm(expression: tbl.orderIndex),
              ]))
            .get();
    return terms;
  }

  int hajimeteChapterLessonId(String level, int chapterId) {
    final normalized = level.trim().toUpperCase();
    final levelOffset = switch (normalized) {
      'N5' => 5000,
      'N4' => 4000,
      'N3' => 3000,
      'N2' => 2000,
      'N1' => 1000,
      _ => 0,
    };
    return -(900000 + levelOffset + chapterId);
  }

  Future<int> ensureHajimeteChapterLesson({
    required String level,
    required int chapterId,
    String? title,
  }) async {
    final lessonId = hajimeteChapterLessonId(level, chapterId);
    final chapterTitle = title?.trim().isNotEmpty == true
        ? title!.trim()
        : 'Hajimete Chapter $chapterId';
    await ensureLesson(lessonId: lessonId, level: level, title: chapterTitle);

    final existing = await fetchTerms(lessonId);
    if (existing.isNotEmpty) {
      return lessonId;
    }

    final items = await getVocabByLevelSeriesChapterRange(
      level,
      series: 'hajimete',
      startChapter: chapterId,
      endChapter: chapterId,
    );
    if (items.isEmpty) {
      return lessonId;
    }

    await _db.batch((batch) {
      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        batch.insert(
          _db.userLessonTerm,
          UserLessonTermCompanion.insert(
            lessonId: lessonId,
            term: Value(item.term),
            reading: Value(item.reading ?? ''),
            definition: Value(item.meaning),
            definitionEn: Value(item.meaningEn ?? ''),
            mnemonicVi: Value(item.mnemonicVi ?? ''),
            mnemonicEn: Value(item.mnemonicEn ?? ''),
            kanjiMeaning: Value(item.kanjiMeaning ?? ''),
            orderIndex: Value(index + 1),
          ),
        );
      }
    });

    return lessonId;
  }

  Future<List<UserLessonTermData>> fetchTermsForHajimeteChapter(
    String level, {
    required int chapterId,
    String? title,
  }) async {
    final lessonId = await ensureHajimeteChapterLesson(
      level: level,
      chapterId: chapterId,
      title: title,
    );
    final terms = await fetchTerms(lessonId);
    terms.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return terms;
  }

  Future<void> seedTermsIfEmpty(
    int lessonId,
    String currentLevelLabel, {
    int? sourceLessonId,
  }) async {
    final existing = await fetchTerms(lessonId);

    // Check if existing terms are the dummy ones and should be replaced
    final isDummy =
        existing.length == 2 &&
        existing[0].term == '見ます' &&
        existing[1].term == '探します';

    if (existing.isNotEmpty && !isDummy) {
      // Try to backfill missing English without destructive reset.
      final missingEnglish = existing.any((t) => t.definitionEn.isEmpty);
      if (!missingEnglish) {
        // All terms already have English definitions — nothing to do.
        return;
      }

      await _backfillEnglishDefinitions(
        lessonId,
        currentLevelLabel,
        existing,
        sourceLessonId: sourceLessonId,
      );

      // Re-fetch only to verify the backfill succeeded.
      final refreshed = await fetchTerms(lessonId);
      if (refreshed.isNotEmpty &&
          refreshed.every((t) => t.definitionEn.isNotEmpty)) {
        return;
      }
      // Backfill didn't fully succeed — data exists but some English still
      // missing; keep user data as-is rather than replacing.
      return;
    }

    if (isDummy) {
      // Delete dummy terms to force resync
      await (_db.delete(
        _db.userLessonTerm,
      )..where((tbl) => tbl.lessonId.equals(lessonId))).go();
    }

    final vocabList = await _fetchLessonVocabFromContent(
      sourceLessonId ?? lessonId,
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
    List<UserLessonTermData> existing, {
    int? sourceLessonId,
  }) async {
    final vocabList = await _fetchLessonVocabFromContent(
      sourceLessonId ?? lessonId,
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
    final canonicalSeries = _seriesForCanonicalLevel(dbLevel);
    final lessonTag = _lessonSeriesTag(canonicalSeries, lessonId);
    var vocabList =
        await (_contentDb.select(_contentDb.vocab)..where((tbl) {
              return tbl.level.equals(dbLevel) &
                  tbl.series.equals(canonicalSeries) &
                  tbl.term.like('%?%').not() &
                  tbl.reading.like('%?%').not() &
                  (tbl.tags.like('$lessonTag,%') |
                      tbl.tags.equals(lessonTag) |
                      tbl.tags.like('%,$lessonTag,%') |
                      tbl.tags.like('%,$lessonTag'));
            }))
            .get();

    // Fallback to offset for legacy Minna data only. Upper JLPT sources use
    // indexed ShinKanzen assets and must not borrow unrelated level rows.
    if (vocabList.isEmpty &&
        (currentLevelLabel == 'N5' || currentLevelLabel == 'N4')) {
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
      final series = (row['series'] ?? '').toString().trim().isEmpty
          ? _seriesForCanonicalLevel(currentLevelLabel.toUpperCase())
          : (row['series'] ?? '').toString().trim();
      final tagPrefix = _lessonSeriesTag(series, lessonId);
      final mergedTags = tags.isEmpty ? tagPrefix : '$tagPrefix,$tags';

      out.add(
        VocabData(
          id: syntheticId,
          term: term,
          reading: _nullableLessonText(row['reading']),
          meaning: meaningVi,
          meaningEn: _nullableLessonText(row['meaningEn']),
          kanjiMeaning: _nullableLessonText(row['kanjiMeaning']),
          series: series,
          level: currentLevelLabel.toUpperCase(),
          tags: mergedTags,
        ),
      );
    }
    return out;
  }

  String _minnaVocabAssetPath(String levelLower, String paddedLessonId) {
    final nestedPath =
        'assets/data/content/vocab/$levelLower/minna/lesson_$paddedLessonId.json';
    if (levelLower == 'n4' || levelLower == 'n5') {
      return nestedPath;
    }
    return 'assets/data/content/vocab/$levelLower/lesson_$paddedLessonId.json';
  }

  Future<String> _resolveCanonicalVocabAssetPath({
    required String levelLower,
    required int lessonId,
  }) async {
    final paddedLessonId = lessonId.toString().padLeft(2, '0');
    final shinkanzenIndexPath =
        'assets/data/content/vocab/$levelLower/ShinKanzen/index.json';

    try {
      final indexRaw = await rootBundle.loadString(shinkanzenIndexPath);
      final indexPayload = json.decode(indexRaw);
      if (indexPayload is Map) {
        final lessons = indexPayload['lessons'];
        if (lessons is List) {
          for (final rawLesson in lessons) {
            if (rawLesson is! Map) continue;
            final lesson = rawLesson.map((k, v) => MapEntry(k.toString(), v));
            final indexedLessonId =
                int.tryParse((lesson['lessonId'] ?? '').toString().trim()) ??
                -1;
            final fileName = (lesson['file'] ?? '').toString().trim();
            if (indexedLessonId == lessonId && fileName.isNotEmpty) {
              return 'assets/data/content/vocab/$levelLower/ShinKanzen/$fileName';
            }
          }
        }
      }
    } catch (_) {}

    return _minnaVocabAssetPath(levelLower, paddedLessonId);
  }

  Future<List<Map<String, dynamic>>> _loadCanonicalLessonVocabEntries({
    required String levelLower,
    required int lessonId,
  }) async {
    final path = await _resolveCanonicalVocabAssetPath(
      levelLower: levelLower,
      lessonId: lessonId,
    );

    try {
      final raw = await rootBundle.loadString(path);
      final payload = json.decode(raw);
      if (payload is! Map) return const [];
      final payloadSeries = (payload['series'] ?? '').toString().trim().isEmpty
          ? _seriesForCanonicalLevel(levelLower.toUpperCase())
          : (payload['series'] ?? '').toString().trim();
      final entries = payload['entries'];
      if (entries is! List) return const [];

      // Parse all entries synchronously, then resolve all HanViet lookups
      // concurrently with Future.wait — HanVietLookup caches after first load
      // and is concurrency-safe, so parallel resolution is correct here.
      final parsed =
          <
            ({
              String term,
              String? reading,
              String meaningVi,
              String? meaningEn,
              String? explicitHanViet,
              int order,
              dynamic tags,
            })
          >[];

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
        final term = (lemma['term'] ?? '').toString().trim();
        final meaningVi = (sense['meaningVi'] ?? '').toString().trim();
        parsed.add((
          term: term,
          reading: _nullableLessonText(lemma['reading']),
          meaningVi: meaningVi,
          meaningEn: _nullableLessonText(sense['meaningEn']),
          explicitHanViet: _nullableLessonText(labels['hanViet']),
          order: int.tryParse((entry['order'] ?? '').toString().trim()) ?? 0,
          tags: entry['tags'],
        ));
      }

      // Fire all HanVietLookup futures before any await.
      final hvFutures = [
        for (final p in parsed)
          HanVietLookup.resolve(
            term: p.term,
            explicitHanViet: p.explicitHanViet,
            explicitMeaningVi: p.meaningVi,
          ),
      ];
      final hvResults = await Future.wait(hvFutures);

      final out = <Map<String, dynamic>>[];
      for (var i = 0; i < parsed.length; i++) {
        final p = parsed[i];
        final hv = hvResults[i];
        out.add({
          'term': p.term,
          'reading': p.reading,
          'kanjiMeaning': hv.hanViet,
          'meaningVi': hv.meaningVi ?? p.meaningVi,
          'meaningEn': p.meaningEn,
          'order': p.order,
          'series': payloadSeries,
          'tags': p.tags,
        });
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  String _seriesForCanonicalLevel(String level) {
    final normalized = level.trim().toUpperCase();
    return normalized == 'N3' || normalized == 'N2' || normalized == 'N1'
        ? 'ShinKanzen'
        : 'minna';
  }

  String _lessonSeriesTag(String series, int lessonId) {
    final normalized = series.toLowerCase().replaceAll(_seriesNormalizeRe, '');
    final prefix = normalized.isEmpty ? 'lesson' : normalized;
    return '${prefix}_$lessonId';
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
      return const [];
    }

    // Single batch query for all examples — replaces N individual round-trips
    // (N+1 pattern) with 2 total DB calls regardless of lesson size.
    final pointIds = points.map((p) => p.id).toList();
    final allExamples = await (_db.select(
      _db.grammarExamples,
    )..where((tbl) => tbl.grammarId.isIn(pointIds))).get();
    final examplesByGrammarId = <int, List<GrammarExample>>{};
    for (final ex in allExamples) {
      examplesByGrammarId.putIfAbsent(ex.grammarId, () => []).add(ex);
    }

    return [
      for (final point in points)
        GrammarPointData(
          point: point,
          examples: examplesByGrammarId[point.id] ?? const [],
        ),
    ];
  }

  Future<List<GrammarPointData>> fetchGrammarForLevel(
    String level,
    int lessonId,
  ) async {
    final points =
        await (_db.select(_db.grammarPoints)..where(
              (tbl) =>
                  tbl.jlptLevel.equals(level) & tbl.lessonId.equals(lessonId),
            ))
            .get();

    if (points.isEmpty) {
      return const [];
    }

    final pointIds = points.map((p) => p.id).toList();
    final allExamples = await (_db.select(
      _db.grammarExamples,
    )..where((tbl) => tbl.grammarId.isIn(pointIds))).get();
    final examplesByGrammarId = <int, List<GrammarExample>>{};
    for (final ex in allExamples) {
      examplesByGrammarId.putIfAbsent(ex.grammarId, () => []).add(ex);
    }

    return [
      for (final point in points)
        GrammarPointData(
          point: point,
          examples: examplesByGrammarId[point.id] ?? const [],
        ),
    ];
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

    // Fetch grammar points and all their examples in two queries instead of N+1.
    final points = await (_db.select(
      _db.grammarPoints,
    )..where((tbl) => tbl.id.isIn(ghostIds))).get();

    final allExamples = await (_db.select(
      _db.grammarExamples,
    )..where((tbl) => tbl.grammarId.isIn(ghostIds))).get();

    final examplesByGrammarId = <int, List<GrammarExample>>{};
    for (final ex in allExamples) {
      examplesByGrammarId.putIfAbsent(ex.grammarId, () => []).add(ex);
    }

    return [
      for (final point in points)
        GrammarPointData(
          point: point,
          examples: examplesByGrammarId[point.id] ?? const [],
        ),
    ];
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
    final normalizedLevel = level.trim().toUpperCase();

    // If GrammarSeeder has already run at the current version, its data is
    // authoritative and up-to-date — skip the resync check entirely.
    // This also prevents the two concurrent paths (GrammarSeeder transaction
    // + seedGrammarIfEmpty) from racing on first launch.
    final prefs = await SharedPreferences.getInstance();
    final seededVersion =
        prefs.getInt(GrammarSeeder.versionKeyForLevel(normalizedLevel)) ??
        prefs.getInt(GrammarSeeder.kKeyGrammarVersion) ??
        0;
    if (seededVersion >= GrammarSeeder.kGrammarDataVersion) {
      // Data is fresh from the seeder; only do a lightweight insert if the
      // lesson has no rows at all (brand new install mid-seeder-run edge case).
      final count =
          await (_db.selectOnly(_db.grammarPoints)
                ..addColumns([_db.grammarPoints.id.count()])
                ..where(
                  _db.grammarPoints.lessonId.equals(lessonId) &
                      _db.grammarPoints.jlptLevel.equals(normalizedLevel),
                ))
              .map((row) => row.read(_db.grammarPoints.id.count()) ?? 0)
              .getSingle();
      if (count > 0) return;
    }

    // Check if grammar already exists for this lesson
    final existingPoints =
        await (_db.select(_db.grammarPoints)..where(
              (tbl) =>
                  tbl.lessonId.equals(lessonId) &
                  tbl.jlptLevel.equals(normalizedLevel),
            ))
            .get();

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
            containsVietnameseGrammarText(p.titleEn) ||
            containsVietnameseGrammarText(currentMeaningEn) ||
            containsVietnameseGrammarText(currentConnectionEn) ||
            containsVietnameseGrammarText(p.explanationEn) ||
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

    await _contentDb.ensureGrammarSeededForLevel(normalizedLevel);

    // Fetch from Content DB
    final contentPoints =
        await (_contentDb.select(_contentDb.grammarPoint)..where(
              (tbl) =>
                  tbl.lessonId.equals(lessonId) &
                  tbl.level.equals(normalizedLevel),
            ))
            .get();

    if (contentPoints.isEmpty) {
      return;
    }

    // Update in-place instead of delete+insert to preserve GrammarSrsState
    // rows (which cascade-delete when GrammarPoints rows are deleted). This
    // prevents users from losing their SRS review history on lesson re-opens.
    final existingByTitle = {for (final p in existingPoints) p.grammarPoint: p};

    // Pre-fetch ALL content examples for this lesson in one batch query.
    // This replaces N individual SELECT queries (one per grammar point).
    final contentPointIds = contentPoints.map((cp) => cp.id).toList();
    final allContentExamples = contentPointIds.isEmpty
        ? const <GrammarExampleData>[]
        : await (_contentDb.select(
            _contentDb.grammarExample,
          )..where((tbl) => tbl.grammarPointId.isIn(contentPointIds))).get();
    final contentExamplesByPointId = <int, List<GrammarExampleData>>{};
    for (final ex in allContentExamples) {
      contentExamplesByPointId.putIfAbsent(ex.grammarPointId, () => []).add(ex);
    }

    // Collect all app-side grammarIds for existing points — batch-delete their
    // examples in one DELETE...WHERE id IN (...) instead of N individual deletes.
    final existingAppIds = <int>[];
    // Accumulate all example rows to insert; flush in a single batch at the end.
    final pendingExamples = <GrammarExamplesCompanion>[];

    // Pre-compute all English fields and split into update vs insert groups so
    // that all updates (independent operations) can be sent in a single batch
    // round-trip before the sequential inserts (which need auto-generated IDs).
    final updateOps =
        <
          ({
            int existingId,
            GrammarPointsCompanion companion,
            List<GrammarExampleData> examples,
          })
        >[];
    final insertOps =
        <
          ({
            String title,
            String structure,
            String explanation,
            String? explanationEn,
            String level,
            String? storedTitleEn,
            String? storedMeaningEn,
            String? storedConnectionEn,
            List<GrammarExampleData> examples,
          })
        >[];

    for (final cp in contentPoints) {
      final englishLabel = resolveEnglishGrammarLabel(
        titleEn: cp.titleEn,
        meaningEn: cp.titleEn,
        connectionEn: cp.structureEn,
        connection: cp.structure,
        grammarPoint: cp.title,
      );
      final englishMeaning = resolveEnglishGrammarMeaning(
        meaningEn: cp.titleEn,
        titleEn: cp.titleEn,
        connectionEn: cp.structureEn,
        connection: cp.structure,
        grammarPoint: cp.title,
      );
      final englishConnection = resolveEnglishGrammarConnection(
        connectionEn: cp.structureEn,
        connection: cp.structure,
        grammarPoint: cp.title,
        titleEn: cp.titleEn,
        meaningEn: cp.titleEn,
      );
      final storedTitleEn = englishLabel == 'Target pattern'
          ? null
          : englishLabel;
      final storedMeaningEn = englishMeaning == 'Target pattern'
          ? null
          : englishMeaning;
      final storedConnectionEn = englishConnection == 'Grammar pattern'
          ? null
          : englishConnection;

      final cpExamples = contentExamplesByPointId[cp.id] ?? const [];
      final existing = existingByTitle[cp.title];
      if (existing != null) {
        existingAppIds.add(existing.id);
        updateOps.add((
          existingId: existing.id,
          companion: GrammarPointsCompanion(
            titleEn: Value(storedTitleEn),
            meaningEn: Value(storedMeaningEn),
            connectionEn: Value(storedConnectionEn),
            explanationEn: Value(cp.explanationEn),
          ),
          examples: cpExamples,
        ));
      } else {
        insertOps.add((
          title: cp.title,
          structure: cp.structure,
          explanation: cp.explanation,
          explanationEn: cp.explanationEn,
          level: cp.level,
          storedTitleEn: storedTitleEn,
          storedMeaningEn: storedMeaningEn,
          storedConnectionEn: storedConnectionEn,
          examples: cpExamples,
        ));
      }
    }

    // Phase A: Batch all updates for existing points — one DB round-trip
    // regardless of how many grammar points already exist in the lesson.
    if (updateOps.isNotEmpty) {
      await _db.batch((batch) {
        for (final op in updateOps) {
          batch.update(
            _db.grammarPoints,
            op.companion,
            where: (tbl) => tbl.id.equals(op.existingId),
          );
        }
      });
      for (final op in updateOps) {
        for (final ex in op.examples) {
          pendingExamples.add(
            GrammarExamplesCompanion.insert(
              grammarId: op.existingId,
              japanese: ex.sentence,
              translation: ex.translation,
              translationVi: Value(ex.translation),
              translationEn: Value(ex.translationEn),
            ),
          );
        }
      }
    }

    // Phase B: Sequential inserts for new grammar points — auto-generated IDs
    // are needed immediately as FK for the example rows collected below.
    for (final op in insertOps) {
      final pointId = await _db
          .into(_db.grammarPoints)
          .insert(
            GrammarPointsCompanion.insert(
              lessonId: Value(lessonId),
              grammarPoint: op.title,
              titleEn: Value(op.storedTitleEn),
              meaning: op.title,
              meaningVi: Value(op.title),
              meaningEn: Value(op.storedMeaningEn),
              connection: op.structure,
              connectionEn: Value(op.storedConnectionEn),
              explanation: op.explanation,
              explanationVi: Value(op.explanation),
              explanationEn: Value(op.explanationEn),
              jlptLevel: op.level,
              isLearned: const Value(false),
            ),
          );
      for (final ex in op.examples) {
        pendingExamples.add(
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

    // Batch delete all old examples, then batch insert all new ones.
    if (existingAppIds.isNotEmpty) {
      await (_db.delete(
        _db.grammarExamples,
      )..where((tbl) => tbl.grammarId.isIn(existingAppIds))).go();
    }
    if (pendingExamples.isNotEmpty) {
      await _db.batch((batch) {
        for (final companion in pendingExamples) {
          batch.insert(_db.grammarExamples, companion);
        }
      });
    }
  }

  Future<List<KanjiItem>> fetchKanji(int lessonId) async {
    final rows = await (_contentDb.select(
      _contentDb.kanji,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();
    return _mapKanjiRows(rows);
  }

  Future<List<KanjiItem>> fetchKanjiForLevel(String level, int lessonId) async {
    final rows =
        await (_contentDb.select(_contentDb.kanji)..where(
              (tbl) =>
                  tbl.jlptLevel.equals(level) & tbl.lessonId.equals(lessonId),
            ))
            .get();
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
    final cached = _kanjiByLevelCache[level];
    if (cached != null) return cached;

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
    final result = await _mapKanjiRows(rows);
    _kanjiByLevelCache[level] = result;
    return result;
  }

  /// Returns kanji at [level] whose SRS state is currently due (nextReviewAt <= now).
  /// Kanji with no SRS state row are excluded — they are "unseen", not "due".
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async {
    // getDueKanjiIds() fetches only kanjiId values — no extra columns transferred.
    final dueIds = await _db.kanjiSrsDao.getDueKanjiIds();
    if (dueIds.isEmpty) return const [];
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

  /// COUNT-only: total kanji at [level]. No row deserialization. Result is
  /// cached for the process lifetime since content DB is read-only.
  Future<int> countKanjiByLevel(String level) async {
    final cached = _kanjiCountCache[level];
    if (cached != null) return cached;
    final countExpr = _contentDb.kanji.id.count();
    final row =
        await (_contentDb.selectOnly(_contentDb.kanji)
              ..addColumns([countExpr])
              ..where(_contentDb.kanji.jlptLevel.equals(level)))
            .getSingle();
    final count = row.read(countExpr) ?? 0;
    _kanjiCountCache[level] = count;
    return count;
  }

  /// COUNT-only: due kanji at [level]. No KanjiItem deserialization.
  Future<int> countDueKanjiByLevel(String level) async {
    final dueIds = await _db.kanjiSrsDao.getDueKanjiIds();
    if (dueIds.isEmpty) return 0;
    final countExpr = _contentDb.kanji.id.count();
    final row =
        await (_contentDb.selectOnly(_contentDb.kanji)
              ..addColumns([countExpr])
              ..where(
                _contentDb.kanji.jlptLevel.equals(level) &
                    _contentDb.kanji.id.isIn(dueIds),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// COUNT-only: unseen kanji at [level] (no SRS row). No deserialization.
  Future<int> countUnseenKanjiByLevel(String level) async {
    final seenIds = await _db.kanjiSrsDao.getAllSeenKanjiIds();
    final countExpr = _contentDb.kanji.id.count();
    final query = _contentDb.selectOnly(_contentDb.kanji)
      ..addColumns([countExpr]);
    if (seenIds.isEmpty) {
      query.where(_contentDb.kanji.jlptLevel.equals(level));
    } else {
      query.where(
        _contentDb.kanji.jlptLevel.equals(level) &
            _contentDb.kanji.id.isNotIn(seenIds),
      );
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Returns the IDs of all kanji that have ever been seen (have an SRS row).
  Future<Set<int>> fetchSeenKanjiIds() async {
    final ids = await _db.kanjiSrsDao.getAllSeenKanjiIds();
    return ids.toSet();
  }

  /// Returns the IDs of all kanji that are currently due for review.
  Future<Set<int>> fetchDueKanjiIds() async {
    final states = await _db.kanjiSrsDao.getDueReviews();
    return states.map((s) => s.kanjiId).toSet();
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

  Future<List<KanjiItem>> fetchDueKanjiForLevelAndLesson(
    String level,
    int lessonId,
  ) async {
    final items = await fetchKanjiForLevel(level, lessonId);
    if (items.isEmpty) return [];
    final ids = items.map((item) => item.id).toList();
    final states = await _db.kanjiSrsDao.getStatesForIds(ids);
    final stateMap = {for (final state in states) state.kanjiId: state};
    final now = DateTime.now();
    return items.where((item) {
      final state = stateMap[item.id];
      return state != null && !state.nextReviewAt.isAfter(now);
    }).toList();
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
    final dueIds = await _db.kanjiSrsDao.getDueKanjiIds();
    if (dueIds.isEmpty) return null;
    // ORDER BY lesson_id + LIMIT 1 — lets the DB find the minimum lessonId
    // without fetching all matching rows into Dart for a Dart-side sort.
    final row =
        await (_contentDb.select(_contentDb.kanji)
              ..where(
                (tbl) => tbl.id.isIn(dueIds) & tbl.jlptLevel.equals(level),
              )
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.lessonId)])
              ..limit(1))
            .getSingleOrNull();
    return row?.lessonId;
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

  Future<void> saveKanjiReview({
    required int kanjiId,
    required int grade,
  }) async {
    // initializeSrsState uses INSERT OR IGNORE — safe to call unconditionally.
    // This collapses ensureKanjiSrsState (SELECT + maybe INSERT) + getSrsState
    // (SELECT) into 2 round-trips instead of 2-3.
    await _db.kanjiSrsDao.initializeSrsState(kanjiId);
    final state = await _db.kanjiSrsDao.getSrsState(kanjiId);
    if (state == null) return;

    final result = _fsrsService.review(
      grade: grade,
      stability: state.stability,
      difficulty: state.difficulty,
      lastReviewedAt: state.lastReviewedAt,
      cardState: FsrsCardState.fromDbValue(state.fsrsState),
      step: state.fsrsStep,
    );

    await _db.kanjiSrsDao.updateSrsState(
      kanjiId: kanjiId,
      stability: result.stability,
      difficulty: result.difficulty,
      lastConfidence: grade,
      nextReviewAt: result.nextReviewAt,
      fsrsState: result.cardState,
      fsrsStep: result.step,
    );

    // Achievement: kanjiMaster — fires at milestones [10, 25, 50, 100].
    // Only checked when this review crosses the Strong-tier threshold (>=21 days
    // stability), so the DB query is skipped on weaker reviews.
    if (result.stability >= 21.0) {
      const milestones = [10, 25, 50, 100];
      final masteredCount = await _db.kanjiSrsDao.getMasteredCount();
      if (milestones.contains(masteredCount)) {
        final achievementDao = AchievementDao(_db);
        final already = await achievementDao.hasAchievement(
          'kanjiMaster',
          masteredCount,
        );
        if (!already) {
          await achievementDao.addAchievement(
            AchievementsCompanion(
              type: const Value('kanjiMaster'),
              value: Value(masteredCount),
              earnedAt: Value(DateTime.now()),
              isNotified: const Value(false),
            ),
          );
        }
      }
    }
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

  /// Records one SRS review result.
  /// XP awarded per review scales with confidence so users who recall well
  /// progress faster on the leaderboard/dashboard:
  ///   Again (1) -> 2 XP  Hard (2) -> 3 XP  Good (3) -> 5 XP  Easy (4+) -> 7 XP
  /// The counter increment and XP delta are written in a single UPDATE to avoid
  /// a second round-trip and eliminate any interleave from rapid taps.
  Future<void> recordReview({required int quality}) async {
    final today = _startOfDay(DateTime.now());
    final todayRow = await _ensureProgressRow(today);
    var againDelta = 0;
    var hardDelta = 0;
    var goodDelta = 0;
    var easyDelta = 0;
    int xpDelta;
    switch (quality) {
      case 0:
      case 1:
        againDelta = 1;
        xpDelta = 2;
        break;
      case 2:
        hardDelta = 1;
        xpDelta = 3;
        break;
      case 3:
        goodDelta = 1;
        xpDelta = 5;
        break;
      case 4:
      case 5:
        easyDelta = 1;
        xpDelta = 7;
        break;
      default:
        xpDelta = 2;
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
        xp: Value(todayRow.xp + xpDelta),
        streak: Value(todayRow.streak),
      ),
    );
  }

  /// Process an SRS review for a specific term.
  ///
  /// Query path (3 round-trips, down from up to 5):
  ///   1. INSERT OR IGNORE srs_state   — ensures row exists, no-op if present
  ///   2. SELECT srs_state + UPDATE user_progress — fired concurrently (different tables)
  ///   3. UPDATE srs_state             — needs FSRS result from step 2
  Future<FsrsReviewResult?> saveTermReview({
    required int termId,
    required int quality,
  }) async {
    // Ensure row exists without a separate SELECT — INSERT OR IGNORE is a no-op
    // when the SRS state already exists, eliminating the conditional check.
    await _db.srsDao.initializeSrsState(termId);

    // Fire stats update and SRS state fetch concurrently — they touch different
    // tables (user_progress vs srs_state) and are fully independent.
    final recordFuture = recordReview(quality: quality);
    final srsState = await _db.srsDao.getSrsState(termId);
    await recordFuture;

    if (srsState == null) return null;

    final result = _fsrsService.review(
      grade: quality,
      stability: srsState.stability,
      difficulty: srsState.difficulty,
      lastReviewedAt: srsState.lastReviewedAt,
      cardState: FsrsCardState.fromDbValue(srsState.fsrsState),
      step: srsState.fsrsStep,
    );

    await _db.srsDao.updateSrsState(
      vocabId: termId,
      repetitions: srsState.repetitions + 1,
      stability: result.stability,
      difficulty: result.difficulty,
      lastConfidence: quality,
      nextReviewAt: result.nextReviewAt,
      fsrsState: result.cardState,
      fsrsStep: result.step,
    );

    await _analyticsService?.logSrsReviewCompleted(
      itemType: 'vocab',
      rating: quality,
      intervalDays: result.intervalDays,
    );

    return result;
  }

  /// Ensures an SRS state row exists for [termId].
  /// INSERT OR IGNORE is idempotent because srs_state has a UNIQUE index on
  /// vocab_id (enforced at DB level since schema v27).
  Future<void> ensureSrsStateForTerm(int termId) {
    return _db.srsDao.initializeSrsState(termId);
  }

  Future<Map<int, SrsStateData>> getSrsStatesForIds(List<int> termIds) {
    return _db.srsDao.getStatesForIds(termIds.toSet().toList());
  }

  Future<void> initializeSrsForTermIds(List<int> termIds) async {
    if (termIds.isEmpty) return;
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final termId in termIds.toSet()) {
        batch.insert(
          _db.srsState,
          SrsStateCompanion.insert(
            vocabId: termId,
            repetitions: const Value(0),
            stability: const Value(1.0),
            difficulty: const Value(5.0),
            nextReviewAt: now,
            fsrsState: Value(FsrsCardState.learning.dbValue),
            fsrsStep: const Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
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
            xp: row.xp,
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

    // Fire all four queries concurrently — none depend on each other's result.
    // On devices where Drift uses a background isolate this gives true
    // parallelism; on single-isolate setups it still amortises event-loop
    // overhead across all four round-trips.
    final todayFuture = (_db.select(
      _db.userProgress,
    )..where((tbl) => tbl.day.equals(today))).getSingleOrNull();
    final latestFuture =
        (_db.select(_db.userProgress)
              ..orderBy([
                (tbl) =>
                    OrderingTerm(expression: tbl.day, mode: OrderingMode.desc),
              ])
              ..limit(1))
            .getSingleOrNull();
    final progressAggFuture =
        (_db.selectOnly(_db.userProgress)..addColumns([
              _db.userProgress.xp.sum(),
              _db.userProgress.streak.max(),
              _db.userProgress.id.count(),
            ]))
            .getSingleOrNull();
    final attemptStatsFuture =
        (_db.selectOnly(_db.attempt)..addColumns([
              _db.attempt.id.count(),
              _db.attempt.score.sum(),
              _db.attempt.total.sum(),
            ]))
            .getSingleOrNull();

    final todayRow = await todayFuture;
    final latestRow = await latestFuture;
    final progressAgg = await progressAggFuture;
    final attemptStats = await attemptStatsFuture;

    var streak = 0;
    if (todayRow != null) {
      streak = todayRow.streak;
    } else if (latestRow != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (_isSameDay(latestRow.day, yesterday)) {
        streak = latestRow.streak;
      }
    }

    final totalXp = progressAgg?.read(_db.userProgress.xp.sum()) ?? 0;
    final longestStreak = progressAgg?.read(_db.userProgress.streak.max()) ?? 0;
    final totalDaysStudied =
        progressAgg?.read(_db.userProgress.id.count()) ?? 0;
    final totalAttempts = attemptStats?.read(_db.attempt.id.count()) ?? 0;
    final totalCorrect = attemptStats?.read(_db.attempt.score.sum()) ?? 0;
    final totalQuestions = attemptStats?.read(_db.attempt.total.sum()) ?? 0;

    return ProgressSummary(
      totalXp: totalXp,
      todayXp: todayRow?.xp ?? 0,
      streak: streak,
      longestStreak: longestStreak,
      totalDaysStudied: totalDaysStudied,
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
      if (terms.isNotEmpty) {
        // Batch all inserts — avoids N sequential round-trips inside the
        // transaction. Matches the pattern already used in appendTerms().
        await _db.batch((batch) {
          for (var i = 0; i < terms.length; i++) {
            final term = terms[i];
            batch.insert(
              _db.userLessonTerm,
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
    required int repetitions,
    required double stability,
    required double difficulty,
    required DateTime nextReviewAt,
    DateTime? lastReviewedAt,
    FsrsCardState fsrsState = FsrsCardState.learning,
    int? fsrsStep = 0,
  }) {
    return _db
        .into(_db.srsState)
        .insertOnConflictUpdate(
          SrsStateCompanion(
            vocabId: Value(termId),
            repetitions: Value(repetitions),
            stability: Value(stability),
            difficulty: Value(difficulty),
            lastReviewedAt: Value(lastReviewedAt),
            nextReviewAt: Value(nextReviewAt),
            fsrsState: Value(fsrsState.dbValue),
            fsrsStep: Value(fsrsStep),
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
            repetitions: const Value(0),
            stability: const Value(1.0),
            difficulty: const Value(5.0),
            nextReviewAt: now, // Due immediately
            fsrsState: Value(FsrsCardState.learning.dbValue),
            fsrsStep: const Value(0),
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
