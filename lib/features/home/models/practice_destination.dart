import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';

class PracticeDestination {
  const PracticeDestination({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.extra,
    this.badgeCount,
    this.estimatedMinutes,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final Object? extra;
  final int? badgeCount;
  final int? estimatedMinutes;
}

List<PracticeDestination> buildPracticeDestinations({
  required AppLanguage language,
  int ghostCount = 0,
  int mistakeCount = 0,
  int dueReviewCount = 0,
  int vocabDue = 0,
  int grammarDue = 0,
  int kanjiDue = 0,
  StudyLevel? level,
  bool preferImmersion = false,
}) {
  final selectedLevel = level ?? StudyLevel.n5;

  final list = <PracticeDestination>[
    PracticeDestination(
      id: 'jlpt_coach',
      title: _jlptCoachTitle(language),
      subtitle: _jlptCoachSubtitle(language),
      icon: Icons.school_rounded,
      color: const Color(0xFF17324D),
      route: AppRoutePath.jlptCoach,
    ),
    PracticeDestination(
      id: 'match',
      title: language.practiceMatchLabel,
      subtitle: language.practiceMatchSubtitle,
      icon: Icons.extension_rounded,
      color: const Color(0xFF0EA5E9),
      route: AppRoutePath.match,
      estimatedMinutes: vocabDue > 0 ? (vocabDue * 8 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'ghost',
      title: language.practiceGhostLabel,
      subtitle: language.practiceGhostSubtitle,
      icon: Icons.auto_fix_high_rounded,
      color: const Color(0xFFF43F5E),
      route: AppRoutePath.grammarPractice,
      extra: GrammarPracticeMode.ghost,
      badgeCount: ghostCount > 0 ? ghostCount : null,
      estimatedMinutes: ghostCount > 0 ? (ghostCount * 12 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'recall_sprint',
      title: language.practiceRecallSprintLabel,
      subtitle: language.practiceRecallSprintSubtitle,
      icon: Icons.bolt_rounded,
      color: const Color(0xFF7C3AED),
      route: AppRoutePath.practiceRecallSprint,
      badgeCount: dueReviewCount > 0 ? dueReviewCount : null,
      estimatedMinutes: dueReviewCount > 0
          ? (dueReviewCount * 6 / 60).ceil()
          : 5,
    ),
    PracticeDestination(
      id: 'kanji_dash',
      title: language.practiceKanjiDashLabel,
      subtitle: language.practiceKanjiDashSubtitle,
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFF59E0B),
      route: AppRoutePath.kanji,
      estimatedMinutes: kanjiDue > 0 ? (kanjiDue * 6 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'handwriting',
      title: language.writeModeHandwritingLabel,
      subtitle: language.writeModeHandwritingSubtitle,
      icon: Icons.draw_rounded,
      color: const Color(0xFF0F766E),
      route: AppRoutePath.kanjiPractice,
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.write,
        levelCode: selectedLevel.shortLabel,
        source: 'practice_hub',
      ),
    ),
    PracticeDestination(
      id: 'kanji_reading',
      title: language.practiceKanjiReadingLabel,
      subtitle: language.practiceKanjiReadingSubtitle,
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF7C3AED),
      route: AppRoutePath.kanjiPractice,
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.read,
        levelCode: selectedLevel.shortLabel,
        source: 'practice_hub',
      ),
      estimatedMinutes: kanjiDue > 0 ? (kanjiDue * 6 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'immersion',
      title: language.practiceImmersionLabel,
      subtitle: language.practiceImmersionSubtitle,
      icon: Icons.newspaper_rounded,
      color: const Color(0xFF2563EB),
      route: AppRoutePath.immersion,
    ),
    PracticeDestination(
      id: 'mistakes',
      title: language.practiceMistakesLabel,
      subtitle: language.practiceMistakesSubtitle,
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFDC2626),
      route: AppRoutePath.mistakes,
      badgeCount: mistakeCount > 0 ? mistakeCount : null,
      estimatedMinutes: mistakeCount > 0
          ? (mistakeCount * 12 / 60).ceil()
          : null,
    ),
  ];

  final visible = list;

  final scored = visible.map((item) {
    var score = 10;
    switch (item.id) {
      case 'ghost':
        score += ghostCount * 4;
        break;
      case 'mistakes':
        score += mistakeCount * 3;
        break;
      case 'recall_sprint':
        score += dueReviewCount * 5;
        score += vocabDue + grammarDue + kanjiDue;
        if (dueReviewCount > 0) {
          score += 10;
        }
        break;
      case 'immersion':
        score += preferImmersion ? 10 : 0;
        if (dueReviewCount == 0 && mistakeCount == 0 && ghostCount == 0) {
          score += 8;
        }
        break;
      case 'handwriting':
        if (level == StudyLevel.n5 || level == StudyLevel.n4) {
          score += 4;
        }
        break;
      case 'kanji_dash':
        if (dueReviewCount > 0) {
          score += 3;
        }
        break;
      case 'jlpt_coach':
        if (dueReviewCount == 0) {
          score += 4;
        }
        if (mistakeCount > 0 || ghostCount > 0) {
          score += 5;
        }
        break;
      default:
        break;
    }
    return (item, score);
  }).toList()..sort((a, b) => b.$2.compareTo(a.$2));

  return scored.map((entry) => entry.$1).toList(growable: false);
}

List<PracticeDestination> applyPracticeDestinationOrder({
  required List<PracticeDestination> rankedDestinations,
  required List<String> preferredOrder,
}) {
  if (preferredOrder.isEmpty) {
    return rankedDestinations;
  }

  final byId = {for (final item in rankedDestinations) item.id: item};
  final ordered = <PracticeDestination>[];
  for (final id in preferredOrder) {
    final item = byId.remove(id);
    if (item != null) {
      ordered.add(item);
    }
  }
  ordered.addAll(byId.values);
  return List<PracticeDestination>.unmodifiable(ordered);
}

List<PracticeDestination> selectFocusPracticeDestinations({
  required List<PracticeDestination> rankedDestinations,
  int limit = 3,
}) {
  if (rankedDestinations.length <= limit) {
    return rankedDestinations;
  }

  final urgent = rankedDestinations
      .where((item) => (item.badgeCount ?? 0) > 0 || _isFocusDestination(item))
      .toList(growable: false);

  final picked = <PracticeDestination>[];
  final pickedIds = <String>{};
  for (final item in urgent) {
    if (!pickedIds.add(item.id)) continue;
    picked.add(item);
    if (picked.length == limit) {
      return List<PracticeDestination>.unmodifiable(picked);
    }
  }

  for (final item in rankedDestinations) {
    if (!pickedIds.add(item.id)) continue;
    picked.add(item);
    if (picked.length == limit) break;
  }
  return List<PracticeDestination>.unmodifiable(picked);
}

bool _isFocusDestination(PracticeDestination destination) {
  return destination.id == 'ghost' ||
      destination.id == 'mistakes' ||
      destination.id == 'handwriting' ||
      destination.id == 'immersion';
}

String _jlptCoachTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'JLPT Prep';
    case AppLanguage.vi:
      return 'Ôn thi JLPT';
    case AppLanguage.ja:
      return 'JLPT試験対策';
  }
}

String _jlptCoachSubtitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Full mock, quick mock, reading drills, diagnosis, 7-day plan.';
    case AppLanguage.vi:
      return 'Thi thử đầy đủ, kiểm tra nhanh, đọc hiểu, chẩn đoán, kế hoạch 7 ngày.';
    case AppLanguage.ja:
      return 'フル模試、クイック模試、読解、診断、7日プラン。';
  }
}

