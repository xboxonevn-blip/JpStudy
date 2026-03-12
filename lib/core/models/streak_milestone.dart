import 'package:flutter/material.dart';

class StreakMilestone {
  const StreakMilestone({
    required this.threshold,
    required this.label,
    required this.emoji,
    required this.color,
    required this.bonusXp,
  });

  final int threshold;
  final String label;
  final String emoji;
  final Color color;
  final int bonusXp;

  static const milestones = [
    StreakMilestone(
      threshold: 7,
      label: 'Bronze',
      emoji: '\u{1F949}',
      color: Color(0xFFCD7F32),
      bonusXp: 35,
    ),
    StreakMilestone(
      threshold: 14,
      label: 'Silver',
      emoji: '\u{1F948}',
      color: Color(0xFFC0C0C0),
      bonusXp: 70,
    ),
    StreakMilestone(
      threshold: 30,
      label: 'Gold',
      emoji: '\u{1F947}',
      color: Color(0xFFFFD700),
      bonusXp: 150,
    ),
    StreakMilestone(
      threshold: 60,
      label: 'Diamond',
      emoji: '\u{1F48E}',
      color: Color(0xFF60A5FA),
      bonusXp: 300,
    ),
    StreakMilestone(
      threshold: 100,
      label: 'Crown',
      emoji: '\u{1F451}',
      color: Color(0xFFFBBF24),
      bonusXp: 500,
    ),
  ];

  /// Returns the highest milestone achieved for the given streak count.
  static StreakMilestone? forStreak(int streak) {
    StreakMilestone? best;
    for (final m in milestones) {
      if (streak >= m.threshold) {
        best = m;
      }
    }
    return best;
  }

  /// Returns the next milestone to aim for, or null if all achieved.
  static StreakMilestone? nextMilestone(int streak) {
    for (final m in milestones) {
      if (streak < m.threshold) {
        return m;
      }
    }
    return null;
  }
}
