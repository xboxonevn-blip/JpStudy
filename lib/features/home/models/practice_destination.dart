import 'package:flutter/material.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';

class PracticeDestination {
  const PracticeDestination({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.extra,
    this.badgeCount,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final Object? extra;
  final int? badgeCount;
}

List<PracticeDestination> buildPracticeDestinations({
  required AppLanguage language,
  int ghostCount = 0,
  int mistakeCount = 0,
  int dueReviewCount = 0,
  StudyLevel? level,
  bool preferImmersion = false,
}) {
  final list = <PracticeDestination>[
    PracticeDestination(
      title: language.practiceMatchLabel,
      subtitle: language.practiceMatchSubtitle,
      icon: Icons.extension_rounded,
      color: const Color(0xFF0EA5E9),
      route: '/match',
    ),
    PracticeDestination(
      title: language.practiceGhostLabel,
      subtitle: language.practiceGhostSubtitle,
      icon: Icons.auto_fix_high_rounded,
      color: const Color(0xFFF43F5E),
      route: '/grammar-practice',
      extra: GrammarPracticeMode.ghost,
      badgeCount: ghostCount > 0 ? ghostCount : null,
    ),
    PracticeDestination(
      title: language.practiceKanjiDashLabel,
      subtitle: language.practiceKanjiDashSubtitle,
      icon: Icons.flash_on_rounded,
      color: const Color(0xFFF59E0B),
      route: '/kanji-dash',
    ),
    PracticeDestination(
      title: language.writeModeHandwritingLabel,
      subtitle: language.writeModeHandwritingSubtitle,
      icon: Icons.draw_rounded,
      color: const Color(0xFF0F766E),
      route: '/practice/handwriting',
    ),
    PracticeDestination(
      title: language.practiceExamCardLabel,
      subtitle: language.practiceExamSubtitle,
      icon: Icons.quiz_rounded,
      color: const Color(0xFF14B8A6),
      route: '/practice/mock-exam',
    ),
    PracticeDestination(
      title: language.practiceImmersionLabel,
      subtitle: language.practiceImmersionSubtitle,
      icon: Icons.newspaper_rounded,
      color: const Color(0xFF2563EB),
      route: '/immersion',
    ),
    PracticeDestination(
      title: language.practiceMistakesLabel,
      subtitle: language.practiceMistakesSubtitle,
      icon: Icons.warning_amber_rounded,
      color: const Color(0xFFDC2626),
      route: '/mistakes',
      badgeCount: mistakeCount > 0 ? mistakeCount : null,
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
      default:
        break;
    }
    return _ScoredDestination(item, score);
  }).toList()..sort((a, b) => b.score.compareTo(a.score));

  return scored.map((entry) => entry.destination).toList(growable: false);
}

class _ScoredDestination {
  const _ScoredDestination(this.destination, this.score);

  final PracticeDestination destination;
  final int score;
}
