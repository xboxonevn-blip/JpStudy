import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum PlanStepType {
  vocabReview,
  grammarReview,
  kanjiReview,
  mistakeFix,
  newVocab,
  newGrammar,
  newKanji,
}

class PlanStep {
  const PlanStep({
    required this.type,
    required this.count,
    required this.estimatedMinutes,
    required this.route,
    this.extra,
    this.urgency = 0,
  });

  final PlanStepType type;
  final int count;
  final int estimatedMinutes;
  final String route;
  final Object? extra;

  /// 0 = low, 1 = medium, 2 = high (overdue/mistakes).
  final int urgency;
}

class DailyPlan {
  const DailyPlan({
    required this.steps,
    required this.totalMinutes,
    required this.totalItems,
    required this.completedSteps,
    this.originalStepCount,
  });

  final List<PlanStep> steps;
  final int totalMinutes;
  final int totalItems;

  /// Indices of steps already completed today (persisted separately).
  final Set<int> completedSteps;

  /// Step count when the plan was first built today (saved to SharedPreferences).
  /// Used to compute [progress] accurately as steps get completed and disappear.
  final int? originalStepCount;

  int get remainingMinutes {
    int sum = 0;
    for (int i = 0; i < steps.length; i++) {
      if (!completedSteps.contains(i)) sum += steps[i].estimatedMinutes;
    }
    return sum;
  }

  /// Fraction of the original plan that has been completed.
  /// Uses [originalStepCount] so the bar moves as tasks are finished
  /// (and disappear from [steps]) throughout the day.
  double get progress {
    final original = originalStepCount;
    if (original == null || original == 0) {
      return steps.isEmpty ? 0 : completedSteps.length / steps.length;
    }
    return (1.0 - steps.length / original).clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final dailyPlanProvider = FutureProvider<DailyPlan>((ref) async {
  final db = ref.watch(databaseProvider);
  final dashboardData = ref.watch(
    dashboardProvider.select((v) {
      final d = v.valueOrNull;
      if (d == null) return null;
      return (
        totalMistakeCount: d.totalMistakeCount,
        vocabDue: d.vocabDue,
        grammarDue: d.grammarDue,
        kanjiDue: d.kanjiDue,
      );
    }),
  );
  if (dashboardData == null) {
    return const DailyPlan(
      steps: [],
      totalMinutes: 0,
      totalItems: 0,
      completedSteps: {},
    );
  }
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

  // Fire all three critical-count queries in parallel — each runs a targeted
  // COUNT(*) with WHERE stability < 1.0 AND nextReviewAt <= now, avoiding
  // the cost of fetching every SRS row just to count a subset.
  final criticalVocabFuture = db.srsDao.getCriticalDueCount();
  final criticalGrammarFuture = db.grammarDao.getCriticalDueCount();
  final criticalKanjiFuture = db.kanjiSrsDao.getCriticalDueCount();
  final criticalVocab = await criticalVocabFuture;
  final criticalGrammar = await criticalGrammarFuture;
  final criticalKanji = await criticalKanjiFuture;

  final steps = <PlanStep>[];

  // ── Priority 1: Fix mistakes ──────────────────────────────────
  if (dashboardData.totalMistakeCount > 0) {
    final count = dashboardData.totalMistakeCount.clamp(1, 10).toInt();
    steps.add(
      PlanStep(
        type: PlanStepType.mistakeFix,
        count: count,
        estimatedMinutes: (count * 1.5).ceil(),
        route: AppRoutePath.mistakes,
        urgency: 2,
      ),
    );
  }

  // ── Priority 2: Critical SRS reviews (stability < 1.0) ───────
  if (criticalVocab > 0) {
    final count = criticalVocab.clamp(1, 20).toInt();
    final args = VocabReviewArgs(
      source: 'daily_plan_critical',
      levelCode: level.shortLabel,
      title: language.vocabReviewTitle(level.shortLabel),
      subtitle: _planSubtitle(
        language,
        en: 'Critical vocab due now',
        vi: 'T??? v???ng quan tr???ng c???n ??n ngay',
        ja: '????????????????????????????????????',
      ),
    );
    steps.add(
      PlanStep(
        type: PlanStepType.vocabReview,
        count: count,
        estimatedMinutes: (count * 0.5).ceil(),
        route: AppRouteLocation.vocabReview(args: args),
        extra: args,
        urgency: 2,
      ),
    );
  }
  if (criticalGrammar > 0) {
    final count = criticalGrammar.clamp(1, 10).toInt();
    steps.add(
      PlanStep(
        type: PlanStepType.grammarReview,
        count: count,
        estimatedMinutes: (count * 1.2).ceil(),
        route: AppRoutePath.grammarPractice,
        urgency: 2,
      ),
    );
  }
  if (criticalKanji > 0) {
    final count = criticalKanji.clamp(1, 10).toInt();
    steps.add(
      PlanStep(
        type: PlanStepType.kanjiReview,
        count: count,
        estimatedMinutes: (count * 1.0).ceil(),
        route: AppRoutePath.kanjiPractice,
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          levelCode: level.shortLabel,
          source: 'daily_plan_critical',
        ),
        urgency: 2,
      ),
    );
  }

  // ── Priority 3: Regular due reviews ───────────────────────────
  final remainingVocab = dashboardData.vocabDue - criticalVocab;
  if (remainingVocab > 0) {
    final count = remainingVocab.clamp(1, 30).toInt();
    final args = VocabReviewArgs(
      source: 'daily_plan_due',
      levelCode: level.shortLabel,
      title: language.vocabReviewTitle(level.shortLabel),
      subtitle: _planSubtitle(
        language,
        en: 'Due vocab queue for today',
        vi: 'H??ng ?????i t??? v???ng ?????n h???n h??m nay',
        ja: '???????????????????????????',
      ),
    );
    steps.add(
      PlanStep(
        type: PlanStepType.vocabReview,
        count: count,
        estimatedMinutes: (count * 0.4).ceil(),
        route: AppRouteLocation.vocabReview(args: args),
        extra: args,
        urgency: 1,
      ),
    );
  }
  final remainingGrammar = dashboardData.grammarDue - criticalGrammar;
  if (remainingGrammar > 0) {
    final count = remainingGrammar.clamp(1, 15).toInt();
    steps.add(
      PlanStep(
        type: PlanStepType.grammarReview,
        count: count,
        estimatedMinutes: (count * 1.0).ceil(),
        route: AppRoutePath.grammarPractice,
        urgency: 1,
      ),
    );
  }
  final remainingKanji = dashboardData.kanjiDue - criticalKanji;
  if (remainingKanji > 0) {
    final count = remainingKanji.clamp(1, 15).toInt();
    steps.add(
      PlanStep(
        type: PlanStepType.kanjiReview,
        count: count,
        estimatedMinutes: (count * 0.8).ceil(),
        route: AppRoutePath.kanjiPractice,
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          levelCode: level.shortLabel,
          source: 'daily_plan_due',
        ),
        urgency: 1,
      ),
    );
  }

  // ── Priority 4: New content (if reviews are manageable) ───────
  // Only offer new-content steps when the review queue isn't overloaded, so
  // learners clear debt before acquiring more items.
  final totalDue =
      dashboardData.vocabDue + dashboardData.grammarDue + dashboardData.kanjiDue;
  if (totalDue < 40) {
    steps.add(
      PlanStep(
        type: PlanStepType.newVocab,
        count: 5,
        estimatedMinutes: 5,
        route: AppRoutePath.library,
        urgency: 0,
      ),
    );
    // Suggest exploring new grammar only when vocab debt is light — grammar
    // takes longer per item so we keep the batch smaller.
    if (dashboardData.grammarDue == 0) {
      steps.add(
        const PlanStep(
          type: PlanStepType.newGrammar,
          count: 3,
          estimatedMinutes: 5,
          route: AppRoutePath.grammar,
          urgency: 0,
        ),
      );
    }
    // Suggest new kanji when the kanji queue is clear — kanji acquisition
    // without review debt creates compounding retention debt quickly.
    if (dashboardData.kanjiDue == 0) {
      steps.add(
        PlanStep(
          type: PlanStepType.newKanji,
          count: 3,
          estimatedMinutes: 4,
          route: AppRoutePath.kanji,
          extra: KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            levelCode: level.shortLabel,
            source: 'daily_plan_new',
          ),
          urgency: 0,
        ),
      );
    }
  }

  // Sort by urgency (highest first).
  steps.sort((a, b) => b.urgency.compareTo(a.urgency));

  int totalMinutes = 0;
  int totalItems = 0;
  for (final s in steps) {
    totalMinutes += s.estimatedMinutes;
    totalItems += s.count;
  }

  // ── Snapshot original step count for the day ─────────────────
  // On first build today, save the count so subsequent rebuilds
  // (triggered as tasks are completed and steps shrink) can compute
  // progress = 1 - currentSteps / originalCount.
  const planDateKey = 'daily.plan.date';
  const planOriginalCountKey = 'daily.plan.originalCount';
  final now = DateTime.now();
  final todayKey =
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
  final prefs = await SharedPreferences.getInstance();
  int originalStepCount;
  if (prefs.getString(planDateKey) == todayKey) {
    originalStepCount = prefs.getInt(planOriginalCountKey) ?? steps.length;
  } else {
    originalStepCount = steps.length;
    if (steps.isNotEmpty) {
      await prefs.setString(planDateKey, todayKey);
      await prefs.setInt(planOriginalCountKey, steps.length);
    }
  }

  return DailyPlan(
    steps: steps,
    totalMinutes: totalMinutes,
    totalItems: totalItems,
    completedSteps: const {},
    originalStepCount: originalStepCount,
  );
});

String _planSubtitle(
  AppLanguage language, {
  required String en,
  required String vi,
  required String ja,
}) {
  switch (language) {
    case AppLanguage.en:
      return en;
    case AppLanguage.vi:
      return vi;
    case AppLanguage.ja:
      return ja;
  }
}
