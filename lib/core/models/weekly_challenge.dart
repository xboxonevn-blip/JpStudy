enum ChallengeType {
  reviewCount,
  accuracy,
  streakDays,
  xpTarget,
  lessonCount,
}

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.type,
    required this.target,
    required this.current,
    required this.weekStart,
    this.completed = false,
    this.bonusAwarded = false,
  });

  final String id;
  final ChallengeType type;
  final int target;
  final int current;
  final DateTime weekStart;
  final bool completed;
  final bool bonusAwarded;

  bool get isComplete => current >= target;
  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  int get daysLeft {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final remaining = weekEnd.difference(DateTime.now()).inDays;
    return remaining.clamp(0, 7);
  }

  WeeklyChallenge copyWith({
    int? current,
    bool? completed,
    bool? bonusAwarded,
  }) {
    return WeeklyChallenge(
      id: id,
      type: type,
      target: target,
      current: current ?? this.current,
      weekStart: weekStart,
      completed: completed ?? this.completed,
      bonusAwarded: bonusAwarded ?? this.bonusAwarded,
    );
  }

  static const bonusXp = 50;

  /// Target values per challenge type, scaled by week rotation.
  static WeeklyChallenge generate(DateTime now) {
    final weekNumber = _isoWeekNumber(now);
    final typeIndex = weekNumber % ChallengeType.values.length;
    final type = ChallengeType.values[typeIndex];
    final weekStart = _startOfWeek(now);
    final id = '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';

    final target = switch (type) {
      ChallengeType.reviewCount => const [50, 75, 100][weekNumber % 3],
      ChallengeType.accuracy => const [75, 80, 85][weekNumber % 3],
      ChallengeType.streakDays => const [5, 6, 7][weekNumber % 3],
      ChallengeType.xpTarget => const [200, 300, 500][weekNumber % 3],
      ChallengeType.lessonCount => const [2, 3, 5][weekNumber % 3],
    };

    return WeeklyChallenge(
      id: id,
      type: type,
      target: target,
      current: 0,
      weekStart: weekStart,
    );
  }

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  static DateTime _startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }
}
