import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';

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
  final list = <PracticeDestination>[
    PracticeDestination(
      id: 'jlpt_coach',
      title: _jlptCoachTitle(language),
      subtitle: _jlptCoachSubtitle(language),
      icon: Icons.school_rounded,
      color: const Color(0xFF2563EB),
      route: '/jlpt/coach',
    ),
    PracticeDestination(
      id: 'match',
      title: language.practiceMatchLabel,
      subtitle: language.practiceMatchSubtitle,
      icon: Icons.extension_rounded,
      color: const Color(0xFF0EA5E9),
      route: '/match',
      estimatedMinutes: vocabDue > 0 ? (vocabDue * 8 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'ghost',
      title: language.practiceGhostLabel,
      subtitle: language.practiceGhostSubtitle,
      icon: Icons.auto_fix_high_rounded,
      color: const Color(0xFFF43F5E),
      route: '/grammar-practice',
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
      route: '/practice/recall-sprint',
      badgeCount: dueReviewCount > 0 ? dueReviewCount : null,
      estimatedMinutes: dueReviewCount > 0 ? (dueReviewCount * 6 / 60).ceil() : 5,
    ),
    PracticeDestination(
      id: 'kanji_dash',
      title: language.practiceKanjiDashLabel,
      subtitle: language.practiceKanjiDashSubtitle,
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFF59E0B),
      route: '/kanji-dash',
      estimatedMinutes: kanjiDue > 0 ? (kanjiDue * 6 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'handwriting',
      title: language.writeModeHandwritingLabel,
      subtitle: language.writeModeHandwritingSubtitle,
      icon: Icons.draw_rounded,
      color: const Color(0xFF0F766E),
      route: '/practice/handwriting',
    ),
    PracticeDestination(
      id: 'kanji_reading',
      title: language.practiceKanjiReadingLabel,
      subtitle: language.practiceKanjiReadingSubtitle,
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF7C3AED),
      route: '/practice/kanji-reading',
      estimatedMinutes: kanjiDue > 0 ? (kanjiDue * 6 / 60).ceil() : null,
    ),
    PracticeDestination(
      id: 'mock_exam',
      title: language.practiceExamCardLabel,
      subtitle: language.practiceExamSubtitle,
      icon: Icons.quiz_rounded,
      color: const Color(0xFF14B8A6),
      route: '/practice/mock-exam',
    ),
    PracticeDestination(
      id: 'immersion',
      title: language.practiceImmersionLabel,
      subtitle: language.practiceImmersionSubtitle,
      icon: Icons.newspaper_rounded,
      color: const Color(0xFF2563EB),
      route: '/immersion',
    ),
    PracticeDestination(
      id: 'mistakes',
      title: language.practiceMistakesLabel,
      subtitle: language.practiceMistakesSubtitle,
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFDC2626),
      route: '/mistakes',
      badgeCount: mistakeCount > 0 ? mistakeCount : null,
      estimatedMinutes: mistakeCount > 0
          ? (mistakeCount * 12 / 60).ceil()
          : null,
    ),
  ];

  final visible = list.where((item) {
    // Mock exam currently ships for N5/N4 flows; hide from N3 quick panel.
    if (item.route == '/practice/mock-exam' && level == StudyLevel.n3) {
      return false;
    }
    return true;
  });

  final scored = visible.map((item) {
    var score = 10;
    switch (item.route) {
      case '/grammar-practice':
        score += ghostCount * 4;
        break;
      case '/mistakes':
        score += mistakeCount * 3;
        break;
      case '/practice/recall-sprint':
        score += dueReviewCount * 5;
        score += vocabDue + grammarDue + kanjiDue;
        if (dueReviewCount > 0) {
          score += 10;
        }
        break;
      case '/immersion':
        score += preferImmersion ? 10 : 0;
        if (dueReviewCount == 0 && mistakeCount == 0 && ghostCount == 0) {
          score += 8;
        }
        break;
      case '/practice/handwriting':
        if (level == StudyLevel.n5 || level == StudyLevel.n4) {
          score += 4;
        }
        break;
      case '/kanji-dash':
        if (dueReviewCount > 0) {
          score += 3;
        }
        break;
      case '/practice/mock-exam':
        if (dueReviewCount == 0) {
          score += 2;
        }
        break;
      case '/jlpt/coach':
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
    return _ScoredDestination(item, score);
  }).toList()..sort((a, b) => b.score.compareTo(a.score));

  return scored.map((entry) => entry.destination).toList(growable: false);
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
      .where((item) => (item.badgeCount ?? 0) > 0 || _isFocusRoute(item.route))
      .toList(growable: false);

  final picked = <PracticeDestination>[];
  for (final item in urgent) {
    if (picked.any((entry) => entry.id == item.id)) {
      continue;
    }
    picked.add(item);
    if (picked.length == limit) {
      return List<PracticeDestination>.unmodifiable(picked);
    }
  }

  for (final item in rankedDestinations) {
    if (picked.any((entry) => entry.id == item.id)) {
      continue;
    }
    picked.add(item);
    if (picked.length == limit) {
      break;
    }
  }
  return List<PracticeDestination>.unmodifiable(picked);
}

bool _isFocusRoute(String route) {
  return route == '/grammar-practice' ||
      route == '/mistakes' ||
      route == '/practice/handwriting' ||
      route == '/immersion';
}

String _jlptCoachTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'JLPT Coach';
    case AppLanguage.vi:
      return 'Trợ lý JLPT';
    case AppLanguage.ja:
      return 'JLPTã‚³ãƒ¼ãƒ';
  }
}

String _jlptCoachSubtitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Reading, mock exam, diagnosis, 7-day plan.';
    case AppLanguage.vi:
      return 'Đọc hiểu, mock exam, chẩn đoán, kế hoạch 7 ngày.';
    case AppLanguage.ja:
      return '読解、模試、診断、7日プラン。';
  }
}

class _ScoredDestination {
  const _ScoredDestination(this.destination, this.score);

  final PracticeDestination destination;
  final int score;
}
