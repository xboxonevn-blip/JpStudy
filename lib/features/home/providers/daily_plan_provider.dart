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

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum PlanStepType { vocabReview, grammarReview, kanjiReview, mistakeFix, newVocab, newGrammar, newKanji }

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
  });

  final List<PlanStep> steps;
  final int totalMinutes;
  final int totalItems;

  /// Indices of steps already completed today (persisted separately).
  final Set<int> completedSteps;

  int get remainingMinutes {
    int sum = 0;
    for (int i = 0; i < steps.length; i++) {
      if (!completedSteps.contains(i)) sum += steps[i].estimatedMinutes;
    }
    return sum;
  }

  double get progress =>
      steps.isEmpty ? 0 : completedSteps.length / steps.length;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final dailyPlanProvider = FutureProvider<DailyPlan>((ref) async {
  final db = ref.watch(databaseProvider);
  final dashboard = ref.watch(dashboardProvider).valueOrNull;
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;

  if (dashboard == null) {
    return const DailyPlan(
      steps: [],
      totalMinutes: 0,
      totalItems: 0,
      completedSteps: {},
    );
  }

  // Fetch critical (low-stability) counts for prioritization.
  final allVocab = await db.select(db.srsState).get();
  final allGrammar = await db.select(db.grammarSrsState).get();
  final allKanji = await db.select(db.kanjiSrsState).get();

  int criticalVocab = 0, criticalGrammar = 0, criticalKanji = 0;
  for (final s in allVocab) {
    if (s.stability < 1.0 &&
        s.nextReviewAt.isBefore(DateTime.now())) {
      criticalVocab++;
    }
  }
  for (final s in allGrammar) {
    if (s.stability < 1.0 &&
        s.nextReviewAt.isBefore(DateTime.now())) {
      criticalGrammar++;
    }
  }
  for (final s in allKanji) {
    if (s.stability < 1.0 &&
        s.nextReviewAt.isBefore(DateTime.now())) {
      criticalKanji++;
    }
  }

  final steps = <PlanStep>[];

  // ── Priority 1: Fix mistakes ──────────────────────────────────
  if (dashboard.totalMistakeCount > 0) {
    final count = dashboard.totalMistakeCount.clamp(1, 10);
    steps.add(PlanStep(
      type: PlanStepType.mistakeFix,
      count: count,
      estimatedMinutes: (count * 1.5).ceil(),
      route: '/mistakes',
      urgency: 2,
    ));
  }

  // ── Priority 2: Critical SRS reviews (stability < 1.0) ───────
  if (criticalVocab > 0) {
    final count = criticalVocab.clamp(1, 20);
    steps.add(PlanStep(
      type: PlanStepType.vocabReview,
      count: count,
      estimatedMinutes: (count * 0.5).ceil(),
      route: '/vocab/review',
      extra: VocabReviewArgs(
        source: 'daily_plan_critical',
        levelCode: level.shortLabel,
        title: language.vocabReviewTitle(level.shortLabel),
        subtitle: _planSubtitle(
          language,
          en: 'Critical vocab due now',
          vi: 'Từ vựng quan trọng cần ôn ngay',
          ja: '重要な語彙レビューを優先',
        ),
      ),
      urgency: 2,
    ));
  }
  if (criticalGrammar > 0) {
    final count = criticalGrammar.clamp(1, 10);
    steps.add(PlanStep(
      type: PlanStepType.grammarReview,
      count: count,
      estimatedMinutes: (count * 1.2).ceil(),
      route: '/grammar-practice',
      urgency: 2,
    ));
  }
  if (criticalKanji > 0) {
    final count = criticalKanji.clamp(1, 10);
    steps.add(PlanStep(
      type: PlanStepType.kanjiReview,
      count: count,
      estimatedMinutes: (count * 1.0).ceil(),
      route: '/kanji/practice',
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.both,
        levelCode: level.shortLabel,
        source: 'daily_plan_critical',
      ),
      urgency: 2,
    ));
  }

  // ── Priority 3: Regular due reviews ───────────────────────────
  final remainingVocab = dashboard.vocabDue - criticalVocab;
  if (remainingVocab > 0) {
    final count = remainingVocab.clamp(1, 30);
    steps.add(PlanStep(
      type: PlanStepType.vocabReview,
      count: count,
      estimatedMinutes: (count * 0.4).ceil(),
      route: '/vocab/review',
      extra: VocabReviewArgs(
        source: 'daily_plan_due',
        levelCode: level.shortLabel,
        title: language.vocabReviewTitle(level.shortLabel),
        subtitle: _planSubtitle(
          language,
          en: 'Due vocab queue for today',
          vi: 'Hàng đợi từ vựng đến hạn hôm nay',
          ja: '今日の語彙レビュー',
        ),
      ),
      urgency: 1,
    ));
  }
  final remainingGrammar = dashboard.grammarDue - criticalGrammar;
  if (remainingGrammar > 0) {
    final count = remainingGrammar.clamp(1, 15);
    steps.add(PlanStep(
      type: PlanStepType.grammarReview,
      count: count,
      estimatedMinutes: (count * 1.0).ceil(),
      route: '/grammar-practice',
      urgency: 1,
    ));
  }
  final remainingKanji = dashboard.kanjiDue - criticalKanji;
  if (remainingKanji > 0) {
    final count = remainingKanji.clamp(1, 15);
    steps.add(PlanStep(
      type: PlanStepType.kanjiReview,
      count: count,
      estimatedMinutes: (count * 0.8).ceil(),
      route: '/kanji/practice',
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.both,
        levelCode: level.shortLabel,
        source: 'daily_plan_due',
      ),
      urgency: 1,
    ));
  }

  // ── Priority 4: New content (if reviews are manageable) ───────
  final totalDue = dashboard.vocabDue + dashboard.grammarDue + dashboard.kanjiDue;
  if (totalDue < 40) {
    steps.add(const PlanStep(
      type: PlanStepType.newVocab,
      count: 5,
      estimatedMinutes: 5,
      route: '/library',
      urgency: 0,
    ));
  }

  // Sort by urgency (highest first).
  steps.sort((a, b) => b.urgency.compareTo(a.urgency));

  int totalMinutes = 0;
  int totalItems = 0;
  for (final s in steps) {
    totalMinutes += s.estimatedMinutes;
    totalItems += s.count;
  }

  return DailyPlan(
    steps: steps,
    totalMinutes: totalMinutes,
    totalItems: totalItems,
    completedSteps: const {},
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
