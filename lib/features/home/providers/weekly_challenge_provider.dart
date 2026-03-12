import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/weekly_challenge.dart';
import '../../../data/repositories/lesson_repository.dart';
import 'challenge_history_provider.dart';
import 'dashboard_provider.dart';

const _prefKey = 'weekly.challenge';

final weeklyChallengeProvider =
    FutureProvider.autoDispose<WeeklyChallenge>((ref) async {
  // React to dashboard and week summary changes.
  final dashboard = ref.watch(dashboardProvider).valueOrNull;
  final weekSummary = ref.watch(weekSummaryProvider).valueOrNull;

  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final challenge = WeeklyChallenge.generate(now);

  // Archive previous week(s) if transitioning.
  await _archivePreviousWeeks(prefs, challenge.id);

  // Load or initialize stored state.
  final raw = prefs.getString('$_prefKey.${challenge.id}');
  bool bonusAwarded = false;
  if (raw != null) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      bonusAwarded = map['bonusAwarded'] as bool? ?? false;
    } catch (_) {
      // Corrupted data — reset.
    }
  }

  // Compute current progress from live data.
  final current = _computeProgress(
    challenge.type,
    weekSummary: weekSummary,
    dashboard: dashboard,
  );

  final updated = challenge.copyWith(
    current: current,
    completed: current >= challenge.target,
    bonusAwarded: bonusAwarded,
  );

  // Award bonus XP on first completion.
  if (updated.isComplete && !bonusAwarded) {
    final repo = ref.read(lessonRepositoryProvider);
    await repo.recordStudyActivity(xpDelta: WeeklyChallenge.bonusXp);
    await _persist(prefs, challenge.id, current, true);
    return updated.copyWith(bonusAwarded: true);
  }

  // Persist state (including current progress for history archiving).
  await _persist(prefs, challenge.id, current, bonusAwarded);

  return updated;
});

Future<void> _persist(
  SharedPreferences prefs,
  String weekId,
  int current,
  bool bonusAwarded,
) async {
  await prefs.setString(
    '$_prefKey.$weekId',
    jsonEncode({
      'bonusAwarded': bonusAwarded,
      'current': current,
    }),
  );
}

/// Archive any previous week's challenge data before switching to a new week.
Future<void> _archivePreviousWeeks(
  SharedPreferences prefs,
  String currentWeekId,
) async {
  final keys = prefs
      .getKeys()
      .where(
        (k) => k.startsWith('$_prefKey.') && !k.endsWith(currentWeekId),
      )
      .toList();

  for (final key in keys) {
    final weekId = key.replaceFirst('$_prefKey.', '');
    final raw = prefs.getString(key);
    if (raw == null) {
      await prefs.remove(key);
      continue;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final storedCurrent = map['current'] as int? ?? 0;

      // Reconstruct challenge from weekId to get type/target.
      final match = RegExp(r'(\d{4})-W(\d{2})').firstMatch(weekId);
      if (match != null) {
        final year = int.parse(match.group(1)!);
        final week = int.parse(match.group(2)!);
        // Approximate a date in that ISO week.
        final jan4 = DateTime(year, 1, 4);
        final monday = jan4.subtract(Duration(days: jan4.weekday - 1));
        final weekStart = monday.add(Duration(days: (week - 1) * 7));
        final oldChallenge = WeeklyChallenge.generate(weekStart);

        await archiveChallenge(
          oldChallenge.copyWith(current: storedCurrent),
        );
      }
    } catch (_) {
      // Ignore corrupted entries.
    }

    await prefs.remove(key);
  }
}

int _computeProgress(
  ChallengeType type, {
  WeekSummary? weekSummary,
  DashboardState? dashboard,
}) {
  switch (type) {
    case ChallengeType.reviewCount:
      return weekSummary?.totalReviewed ?? 0;
    case ChallengeType.accuracy:
      return weekSummary?.accuracy ?? 0;
    case ChallengeType.streakDays:
      return weekSummary?.daysStudied ?? 0;
    case ChallengeType.xpTarget:
      return dashboard?.todayXp ?? 0; // Simplified: shows today's XP progress
    case ChallengeType.lessonCount:
      // Use daysStudied as proxy — each study day ≈ 1 lesson.
      return weekSummary?.daysStudied ?? 0;
  }
}
