import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/home/weakness_radar_copy.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_priority.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

class WeaknessRadarItem {
  const WeaknessRadarItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
    this.extra,
    this.priority = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final Object? extra;
  final int priority;
}

final weaknessRadarProvider = FutureProvider<List<WeaknessRadarItem>>((
  ref,
) async {
  final dashboard = ref.watch(dashboardProvider).valueOrNull;
  final language = ref.watch(appLanguageProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  if (dashboard == null) {
    return const [];
  }

  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final recoveryPack = ref.watch(recoveryPackProvider).valueOrNull;
  final nextGrammarReview = ref.watch(nextGrammarReviewProvider).valueOrNull;
  final now = DateTime.now();

  // Fetch per-type top-N mistakes in parallel — each query is bounded by LIMIT
  // and filtered by type in SQL, avoiding a full-table scan from getAllMistakes().
  // Over-fetch slightly (×2) so after the priority filter we still have candidates.
  final srsBreakdownFuture = ref.watch(srsRetentionProvider.future);
  final vocabMistakesFuture = mistakeRepo.getTopMistakesByType('vocab', limit: 20);
  final grammarMistakesFuture = mistakeRepo.getTopMistakesByType('grammar', limit: 10);
  final kanjiMistakesFuture = mistakeRepo.getTopMistakesByType('kanji', limit: 20);

  final srsBreakdown = await srsBreakdownFuture;
  final vocabMistakesRaw = await vocabMistakesFuture;
  final grammarMistakesRaw = await grammarMistakesFuture;
  final kanjiMistakesRaw = await kanjiMistakesFuture;

  final items = <WeaknessRadarItem>[];

  if (recoveryPack != null) {
    items.add(
      WeaknessRadarItem(
        id: 'recovery_pack',
        title: weaknessRecoveryTitle(language, recoveryPack.lessonTitle),
        subtitle: weaknessRecoverySubtitle(language, recoveryPack.itemCount),
        route: '/learn/recovery-pack',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF2563EB),
        priority: 120,
      ),
    );
  }

  // Pre-compute each mistake's priority once (Schwartzian transform) so the
  // sort comparator doesn't call calculateMistakePriority twice per comparison.
  List<({UserMistake mistake, int priority})> scoredAndSorted(
    List<UserMistake> raw,
  ) {
    final scored = raw
        .map((m) => (mistake: m, priority: calculateMistakePriority(m, now)))
        .toList();
    scored.sort((l, r) => r.priority.compareTo(l.priority));
    return scored;
  }

  final vocabScored = scoredAndSorted(vocabMistakesRaw);
  final grammarScored = scoredAndSorted(grammarMistakesRaw);
  final kanjiScored = scoredAndSorted(kanjiMistakesRaw);

  final dueMistakesVocab = vocabScored
      .where((s) => s.priority > 0)
      .toList(growable: false);
  final dueMistakesGrammar = grammarScored
      .where((s) => s.priority > 0)
      .toList(growable: false);
  final dueMistakesKanji = kanjiScored
      .where((s) => s.priority > 0)
      .toList(growable: false);

  // Fire all three DB look-ups in parallel — each method fast-returns [] when
  // the ID list is empty, so no unnecessary round-trips are made.
  final vocabFuture = lessonRepo.fetchVocabTermsByIds(
    dueMistakesVocab.take(5).map((s) => s.mistake.itemId).toList(),
  );
  final grammarFuture = grammarRepo.fetchPointsByIds(
    dueMistakesGrammar.take(3).map((s) => s.mistake.itemId).toList(),
  );
  final kanjiFuture = lessonRepo.fetchKanjiByIds(
    dueMistakesKanji.take(5).map((s) => s.mistake.itemId).toList(),
  );
  final vocabItems = await vocabFuture;
  final grammarPoints = await grammarFuture;
  final kanjiItems = await kanjiFuture;

  if (vocabItems.isNotEmpty) {
    final lead = dueMistakesVocab.first;
    items.add(
      WeaknessRadarItem(
        id: 'vocab_mistakes',
        title: weaknessVocabTitle(language, vocabItems.first.term),
        subtitle: weaknessVocabSubtitle(
          language,
          dueMistakesVocab.length,
          _dueCheckpointShortLabel(language, lead.mistake.lastMistakeAt, now),
        ),
        route: '/learn/session',
        extra: LearnSessionArgs(
          items: vocabItems,
          lessonId: RecoveryPackService.recoveryLessonId,
          lessonTitle: weaknessVocabSessionTitle(language),
          enabledTypes: const [
            QuestionType.multipleChoice,
            QuestionType.fillBlank,
          ],
        ),
        icon: Icons.translate_rounded,
        color: const Color(0xFF0F766E),
        priority: 80 + lead.priority,
      ),
    );
  }

  if (grammarPoints.isNotEmpty) {
    final lead = dueMistakesGrammar.first;
    items.add(
      WeaknessRadarItem(
        id: 'grammar_mistakes',
        title: weaknessGrammarTitle(language, grammarPoints.first.grammarPoint),
        subtitle: weaknessGrammarSubtitle(
          language,
          dueMistakesGrammar.length,
          _dueCheckpointShortLabel(language, lead.mistake.lastMistakeAt, now),
        ),
        route: '/grammar-practice',
        extra: grammarPoints.map((point) => point.id).toList(),
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF7C3AED),
        priority: 75 + lead.priority,
      ),
    );
  }

  if (kanjiItems.isNotEmpty) {
    final lead = dueMistakesKanji.first;
    items.add(
      WeaknessRadarItem(
        id: 'kanji_mistakes',
        title: weaknessKanjiTitle(language, kanjiItems.first.character),
        subtitle: weaknessKanjiSubtitle(
          language,
          dueMistakesKanji.length,
          _dueCheckpointShortLabel(language, lead.mistake.lastMistakeAt, now),
        ),
        route: '/kanji/practice',
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.write,
          levelCode: level.shortLabel,
          source: 'weakness_radar',
          kanjiIds: kanjiItems.map((item) => item.id).toList(growable: false),
          preferredKanjiId: kanjiItems.first.id,
        ),
        icon: Icons.draw_rounded,
        color: const Color(0xFFF59E0B),
        priority: 70 + lead.priority,
      ),
    );
  }

  if (items.length < 3 && srsBreakdown.learning > 0) {
    items.add(
      WeaknessRadarItem(
        id: 'fresh_cards',
        title: weaknessRetentionTitle(language),
        subtitle: weaknessRetentionSubtitle(language, srsBreakdown.learning),
        route: '/vocab/review',
        extra: VocabReviewArgs(
          source: 'weakness_radar',
          levelCode: level.shortLabel,
          title: language.vocabReviewTitle(level.shortLabel),
          subtitle: _planHint(
            language,
            en: 'Fresh vocab still needs review',
            vi: 'Nhóm từ mới vẫn cần ôn tiếp',
            ja: '新しい語彙をもう一度固める',
          ),
        ),
        icon: Icons.schedule_rounded,
        color: const Color(0xFFDC2626),
        priority: 70,
      ),
    );
  }

  if (items.length < 3) {
    final totalDue =
        dashboard.vocabDue + dashboard.grammarDue + dashboard.kanjiDue;
    if (totalDue > 0) {
      final dueRoute = _dueRouteSpec(
        language: language,
        level: level,
        dashboard: dashboard,
      );
      items.add(
        WeaknessRadarItem(
          id: 'due_reviews',
          title: weaknessDueTitle(language, totalDue),
          subtitle: weaknessDueSubtitle(
            language,
            dashboard: dashboard,
            nextGrammarReview: nextGrammarReview,
          ),
          route: dueRoute.route,
          extra: dueRoute.extra,
          icon: Icons.history_edu_rounded,
          color: const Color(0xFF1D4ED8),
          priority: 60,
        ),
      );
    }
  }

  items.sort((left, right) => right.priority.compareTo(left.priority));
  return items.take(3).toList(growable: false);
});

class _WeaknessRouteSpec {
  const _WeaknessRouteSpec({required this.route, this.extra});

  final String route;
  final Object? extra;
}

String _dueCheckpointShortLabel(
  AppLanguage language,
  DateTime lastMistakeAt,
  DateTime now,
) {
  return weaknessDueCheckpointShortLabel(language, now.difference(lastMistakeAt));
}

_WeaknessRouteSpec _dueRouteSpec({
  required AppLanguage language,
  required StudyLevel level,
  required DashboardState dashboard,
}) {
  if (dashboard.grammarDue >= dashboard.vocabDue &&
      dashboard.grammarDue >= dashboard.kanjiDue &&
      dashboard.grammarDue > 0) {
    return const _WeaknessRouteSpec(route: '/grammar');
  }
  if (dashboard.vocabDue >= dashboard.kanjiDue && dashboard.vocabDue > 0) {
    return _WeaknessRouteSpec(
      route: '/vocab/review',
      extra: VocabReviewArgs(
        source: 'weakness_radar',
        levelCode: level.shortLabel,
        title: language.vocabReviewTitle(level.shortLabel),
        subtitle: _planHint(
          language,
          en: 'Due vocab queue from radar',
          vi: 'Hàng đợi từ vựng đến hạn từ radar',
          ja: 'レーダーから開く語彙レビュー',
        ),
      ),
    );
  }
  return _WeaknessRouteSpec(
    route: '/kanji/practice',
    extra: KanjiPracticeArgs(
      mode: KanjiPracticeMode.both,
      levelCode: level.shortLabel,
      source: 'weakness_radar',
    ),
  );
}

String _planHint(
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
