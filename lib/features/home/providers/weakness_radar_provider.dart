import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

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
  if (dashboard == null) {
    return const [];
  }

  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final mistakeRepo = ref.watch(mistakeRepositoryProvider);
  final recoveryPack = ref.watch(recoveryPackProvider).valueOrNull;
  final nextGrammarReview = ref.watch(nextGrammarReviewProvider).valueOrNull;
  final srsBreakdown = await ref.watch(srsRetentionProvider.future);
  final mistakes = await mistakeRepo.getAllMistakes();
  final items = <WeaknessRadarItem>[];

  if (recoveryPack != null) {
    items.add(
      WeaknessRadarItem(
        id: 'recovery_pack',
        title: _recoveryTitle(language, recoveryPack.lessonTitle),
        subtitle: _recoverySubtitle(language, recoveryPack.itemCount),
        route: '/learn/recovery-pack',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF2563EB),
        priority: 120,
      ),
    );
  }

  final vocabMistakes = mistakes.where((item) => item.type == 'vocab').toList()
    ..sort((left, right) => right.wrongCount.compareTo(left.wrongCount));
  if (vocabMistakes.isNotEmpty) {
    final ids = vocabMistakes.take(5).map((item) => item.itemId).toList();
    final vocabItems = await lessonRepo.fetchVocabTermsByIds(ids);
    if (vocabItems.isNotEmpty) {
      items.add(
        WeaknessRadarItem(
          id: 'vocab_mistakes',
          title: _vocabTitle(language, vocabItems.first.term),
          subtitle: _vocabSubtitle(language, vocabMistakes.length),
          route: '/learn/session',
          extra: LearnSessionArgs(
            items: vocabItems,
            lessonId: RecoveryPackService.recoveryLessonId,
            lessonTitle: _vocabSessionTitle(language),
            enabledTypes: const [
              QuestionType.multipleChoice,
              QuestionType.fillBlank,
            ],
          ),
          icon: Icons.translate_rounded,
          color: const Color(0xFF0F766E),
          priority: 100,
        ),
      );
    }
  }

  final grammarMistakes =
      mistakes.where((item) => item.type == 'grammar').toList()
        ..sort((left, right) => right.wrongCount.compareTo(left.wrongCount));
  if (grammarMistakes.isNotEmpty) {
    final points = await grammarRepo.fetchPointsByIds(
      grammarMistakes.take(3).map((item) => item.itemId).toList(),
    );
    if (points.isNotEmpty) {
      items.add(
        WeaknessRadarItem(
          id: 'grammar_mistakes',
          title: _grammarTitle(language, points.first.grammarPoint),
          subtitle: _grammarSubtitle(language, grammarMistakes.length),
          route: '/grammar-practice',
          extra: points.map((point) => point.id).toList(),
          icon: Icons.auto_stories_rounded,
          color: const Color(0xFF7C3AED),
          priority: 95,
        ),
      );
    }
  }

  final kanjiMistakes = mistakes.where((item) => item.type == 'kanji').toList()
    ..sort((left, right) => right.wrongCount.compareTo(left.wrongCount));
  if (kanjiMistakes.isNotEmpty) {
    final kanjiItems = await lessonRepo.fetchKanjiByIds(
      kanjiMistakes.take(5).map((item) => item.itemId).toList(),
    );
    if (kanjiItems.isNotEmpty) {
      items.add(
        WeaknessRadarItem(
          id: 'kanji_mistakes',
          title: _kanjiTitle(language, kanjiItems.first.character),
          subtitle: _kanjiSubtitle(language, kanjiMistakes.length),
          route: '/practice/handwriting',
          icon: Icons.draw_rounded,
          color: const Color(0xFFF59E0B),
          priority: 90,
        ),
      );
    }
  }

  if (items.length < 3 && srsBreakdown.learning > 0) {
    items.add(
      WeaknessRadarItem(
        id: 'fresh_cards',
        title: _retentionTitle(language),
        subtitle: _retentionSubtitle(language, srsBreakdown.learning),
        route: '/vocab/review',
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
      items.add(
        WeaknessRadarItem(
          id: 'due_reviews',
          title: _dueTitle(language, totalDue),
          subtitle: _dueSubtitle(
            language,
            dashboard: dashboard,
            nextGrammarReview: nextGrammarReview,
          ),
          route: _dueRoute(dashboard),
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

String _recoveryTitle(AppLanguage language, String lessonTitle) {
  switch (language) {
    case AppLanguage.en:
      return 'Recovery pack from $lessonTitle';
    case AppLanguage.vi:
      return 'Gói phục hồi từ $lessonTitle';
    case AppLanguage.ja:
      return 'Recovery pack from $lessonTitle';
  }
}

String _recoverySubtitle(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count weak terms are ready for a clean-up round.';
    case AppLanguage.vi:
      return '$count mục yếu đã sẵn sàng cho một lượt ôn phục hồi.';
    case AppLanguage.ja:
      return '$count weak terms are ready for a clean-up round.';
  }
}

String _vocabTitle(AppLanguage language, String term) {
  switch (language) {
    case AppLanguage.en:
      return 'Vocab slipping: $term';
    case AppLanguage.vi:
      return 'Từ vựng đang trượt: $term';
    case AppLanguage.ja:
      return 'Vocab slipping: $term';
  }
}

String _vocabSubtitle(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count saved vocab mistakes still need one more pass.';
    case AppLanguage.vi:
      return '$count lỗi từ vựng đã lưu vẫn cần thêm một lượt nữa.';
    case AppLanguage.ja:
      return '$count saved vocab mistakes still need one more pass.';
  }
}

String _vocabSessionTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Vocab Recovery';
    case AppLanguage.vi:
      return 'Phục hồi từ vựng';
    case AppLanguage.ja:
      return 'Vocab Recovery';
  }
}

String _grammarTitle(AppLanguage language, String grammarPoint) {
  switch (language) {
    case AppLanguage.en:
      return 'Grammar slipping: $grammarPoint';
    case AppLanguage.vi:
      return 'Ngữ pháp đang trượt: $grammarPoint';
    case AppLanguage.ja:
      return 'Grammar slipping: $grammarPoint';
  }
}

String _grammarSubtitle(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count grammar ghosts or mistakes are still open.';
    case AppLanguage.vi:
      return '$count mục ngữ pháp lỗi vẫn chưa được xử lý xong.';
    case AppLanguage.ja:
      return '$count grammar ghosts or mistakes are still open.';
  }
}

String _kanjiTitle(AppLanguage language, String character) {
  switch (language) {
    case AppLanguage.en:
      return 'Kanji slipping: $character';
    case AppLanguage.vi:
      return 'Kanji đang trượt: $character';
    case AppLanguage.ja:
      return 'Kanji slipping: $character';
  }
}

String _kanjiSubtitle(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count kanji mistakes are pushing handwriting practice up.';
    case AppLanguage.vi:
      return '$count lỗi kanji đang đẩy luyện viết tay lên ưu tiên.';
    case AppLanguage.ja:
      return '$count kanji mistakes are pushing handwriting practice up.';
  }
}

String _retentionTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Fresh cards still look unstable';
    case AppLanguage.vi:
      return 'Thẻ mới vẫn chưa ổn định';
    case AppLanguage.ja:
      return 'Fresh cards still look unstable';
  }
}

String _retentionSubtitle(AppLanguage language, int count) {
  switch (language) {
    case AppLanguage.en:
      return '$count vocab items are still in the fragile learning stage.';
    case AppLanguage.vi:
      return '$count từ vẫn còn ở giai đoạn dễ rơi.';
    case AppLanguage.ja:
      return '$count vocab items are still in the fragile learning stage.';
  }
}

String _dueTitle(AppLanguage language, int totalDue) {
  switch (language) {
    case AppLanguage.en:
      return '$totalDue due reviews are waiting';
    case AppLanguage.vi:
      return '$totalDue lượt ôn đang chờ';
    case AppLanguage.ja:
      return '$totalDue due reviews are waiting';
  }
}

String _dueSubtitle(
  AppLanguage language, {
  required DashboardState dashboard,
  required DateTime? nextGrammarReview,
}) {
  final grammarHint = switch (language) {
    AppLanguage.en =>
      nextGrammarReview == null ? '' : ' Grammar is cycling soon.',
    AppLanguage.vi =>
      nextGrammarReview == null ? '' : ' Ngữ pháp sắp quay lại.',
    AppLanguage.ja =>
      nextGrammarReview == null ? '' : ' Grammar is cycling soon.',
  };
  switch (language) {
    case AppLanguage.en:
      return '${dashboard.vocabDue} vocab, ${dashboard.grammarDue} grammar, ${dashboard.kanjiDue} kanji.$grammarHint';
    case AppLanguage.vi:
      return '${dashboard.vocabDue} từ, ${dashboard.grammarDue} ngữ pháp, ${dashboard.kanjiDue} kanji đã đến hạn.$grammarHint';
    case AppLanguage.ja:
      return '${dashboard.vocabDue} vocab, ${dashboard.grammarDue} grammar, ${dashboard.kanjiDue} kanji.$grammarHint';
  }
}

String _dueRoute(DashboardState dashboard) {
  if (dashboard.grammarDue >= dashboard.vocabDue &&
      dashboard.grammarDue >= dashboard.kanjiDue &&
      dashboard.grammarDue > 0) {
    return '/grammar';
  }
  if (dashboard.vocabDue >= dashboard.kanjiDue && dashboard.vocabDue > 0) {
    return '/vocab/review';
  }
  return '/kanji-dash';
}
