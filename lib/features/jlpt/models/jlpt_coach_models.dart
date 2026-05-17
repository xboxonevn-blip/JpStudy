import 'dart:math';

import 'package:jpstudy/data/db/app_database.dart';

/// High-level skill buckets used for JLPT coaching and 7-day planning.
enum JlptSkillArea { vocabulary, grammar, kanji, reading }

extension JlptSkillAreaX on JlptSkillArea {
  String get key {
    switch (this) {
      case JlptSkillArea.vocabulary:
        return 'vocabulary';
      case JlptSkillArea.grammar:
        return 'grammar';
      case JlptSkillArea.kanji:
        return 'kanji';
      case JlptSkillArea.reading:
        return 'reading';
    }
  }

  static JlptSkillArea? fromKey(String raw) {
    for (final area in JlptSkillArea.values) {
      if (area.key == raw) {
        return area;
      }
    }
    return null;
  }
}

class JlptSkillSignal {
  const JlptSkillSignal({
    required this.area,
    required this.correct,
    this.weight = 1,
  });

  final JlptSkillArea area;
  final bool correct;
  final int weight;
}

class JlptAreaStat {
  const JlptAreaStat({
    required this.area,
    required this.correct,
    required this.total,
  });

  final JlptSkillArea area;
  final int correct;
  final int total;

  double get accuracy => total <= 0 ? 0 : correct / total;

  Map<String, dynamic> toJson() {
    return {'area': area.key, 'correct': correct, 'total': total};
  }

  static JlptAreaStat? fromJson(Map<String, dynamic> json) {
    final area = JlptSkillAreaX.fromKey(json['area'] as String? ?? '');
    if (area == null) {
      return null;
    }
    return JlptAreaStat(
      area: area,
      correct: json['correct'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class JlptDiagnosisProfile {
  const JlptDiagnosisProfile({
    required this.generatedAt,
    required this.source,
    required this.stats,
  });

  final DateTime generatedAt;
  final String source;
  final Map<JlptSkillArea, JlptAreaStat> stats;

  double get overallAccuracy {
    var total = 0;
    var correct = 0;
    for (final stat in stats.values) {
      total += stat.total;
      correct += stat.correct;
    }
    if (total <= 0) {
      return 0;
    }
    return correct / total;
  }

  JlptAreaStat statFor(JlptSkillArea area) {
    return stats[area] ?? JlptAreaStat(area: area, correct: 0, total: 0);
  }

  List<JlptAreaStat> weakestFirst() {
    final list = JlptSkillArea.values.map(statFor).toList(growable: false);
    list.sort((a, b) {
      final accCompare = a.accuracy.compareTo(b.accuracy);
      if (accCompare != 0) {
        return accCompare;
      }
      return a.total.compareTo(b.total);
    });
    return list;
  }

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'source': source,
      'stats': stats.values.map((entry) => entry.toJson()).toList(),
    };
  }

  static JlptDiagnosisProfile? fromJson(Map<String, dynamic> json) {
    final rawStats = json['stats'];
    if (rawStats is! List) {
      return null;
    }

    final parsed = <JlptSkillArea, JlptAreaStat>{};
    for (final entry in rawStats) {
      if (entry is! Map) {
        continue;
      }
      final stat = JlptAreaStat.fromJson(Map<String, dynamic>.from(entry));
      if (stat == null) {
        continue;
      }
      parsed[stat.area] = stat;
    }

    for (final area in JlptSkillArea.values) {
      parsed.putIfAbsent(
        area,
        () => JlptAreaStat(area: area, correct: 0, total: 0),
      );
    }

    return JlptDiagnosisProfile(
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      source: json['source'] as String? ?? '',
      stats: parsed,
    );
  }
}

class JlptPlanItem {
  const JlptPlanItem({
    required this.dayOffset,
    required this.area,
    required this.minutes,
    required this.focus,
    required this.action,
  });

  final int dayOffset;
  final JlptSkillArea area;
  final int minutes;
  final String focus;
  final String action;

  Map<String, dynamic> toJson() {
    return {
      'dayOffset': dayOffset,
      'area': area.key,
      'minutes': minutes,
      'focus': focus,
      'action': action,
    };
  }

  static JlptPlanItem? fromJson(Map<String, dynamic> json) {
    final area = JlptSkillAreaX.fromKey(json['area'] as String? ?? '');
    if (area == null) {
      return null;
    }
    return JlptPlanItem(
      dayOffset: json['dayOffset'] as int? ?? 0,
      area: area,
      minutes: json['minutes'] as int? ?? 0,
      focus: json['focus'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }
}

class JlptSevenDayPlan {
  const JlptSevenDayPlan({required this.startDate, required this.items});

  final DateTime startDate;
  final List<JlptPlanItem> items;

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'items': items.map((entry) => entry.toJson()).toList(),
    };
  }

  static JlptSevenDayPlan? fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = rawItems
        .whereType<Map>()
        .map((entry) => JlptPlanItem.fromJson(Map<String, dynamic>.from(entry)))
        .whereType<JlptPlanItem>()
        .toList(growable: false);

    return JlptSevenDayPlan(
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      items: items,
    );
  }
}

class JlptCoachSnapshot {
  const JlptCoachSnapshot({required this.profile, required this.plan});

  final JlptDiagnosisProfile profile;
  final JlptSevenDayPlan plan;

  Map<String, dynamic> toJson() {
    return {'profile': profile.toJson(), 'plan': plan.toJson()};
  }

  static JlptCoachSnapshot? fromJson(Map<String, dynamic> json) {
    final rawProfile = json['profile'];
    final rawPlan = json['plan'];
    if (rawProfile is! Map || rawPlan is! Map) {
      return null;
    }
    final profile = JlptDiagnosisProfile.fromJson(
      Map<String, dynamic>.from(rawProfile),
    );
    final plan = JlptSevenDayPlan.fromJson(Map<String, dynamic>.from(rawPlan));
    if (profile == null || plan == null) {
      return null;
    }
    return JlptCoachSnapshot(profile: profile, plan: plan);
  }
}

class MistakeDueBuckets {
  const MistakeDueBuckets({
    required this.due1d,
    required this.due3d,
    required this.due7d,
    required this.notDue,
  });

  final int due1d;
  final int due3d;
  final int due7d;
  final int notDue;

  int get totalDue => due1d + due3d + due7d;
}

/// Returns due counts for 1-3-7 revision checkpoints based on last mistake time.
MistakeDueBuckets computeMistakeDueBuckets(
  List<UserMistake> mistakes,
  DateTime now,
) {
  var due1d = 0;
  var due3d = 0;
  var due7d = 0;
  var notDue = 0;

  for (final mistake in mistakes) {
    final age = now.difference(mistake.lastMistakeAt);
    if (age.inHours < 24) {
      notDue += 1;
      continue;
    }
    if (age.inHours < 72) {
      due1d += 1;
      continue;
    }
    if (age.inHours < 24 * 7) {
      due3d += 1;
      continue;
    }
    due7d += 1;
  }

  return MistakeDueBuckets(
    due1d: due1d,
    due3d: due3d,
    due7d: due7d,
    notDue: notDue,
  );
}

JlptDiagnosisProfile buildJlptDiagnosisProfile({
  required String source,
  required Iterable<JlptSkillSignal> signals,
  DateTime? now,
}) {
  final totalByArea = <JlptSkillArea, int>{};
  final correctByArea = <JlptSkillArea, int>{};

  for (final signal in signals) {
    final weight = max(1, signal.weight);
    totalByArea.update(
      signal.area,
      (value) => value + weight,
      ifAbsent: () => weight,
    );
    if (signal.correct) {
      correctByArea.update(
        signal.area,
        (value) => value + weight,
        ifAbsent: () => weight,
      );
    }
  }

  final stats = <JlptSkillArea, JlptAreaStat>{};
  for (final area in JlptSkillArea.values) {
    final total = totalByArea[area] ?? 0;
    final correct = min(correctByArea[area] ?? 0, total);
    stats[area] = JlptAreaStat(area: area, correct: correct, total: total);
  }

  return JlptDiagnosisProfile(
    generatedAt: now ?? DateTime.now(),
    source: source,
    stats: stats,
  );
}

JlptDiagnosisProfile mergeJlptDiagnosisProfiles({
  required String source,
  JlptDiagnosisProfile? existing,
  required Iterable<JlptSkillSignal> signals,
  DateTime? now,
}) {
  final incoming = buildJlptDiagnosisProfile(
    source: source,
    signals: signals,
    now: now,
  );

  if (existing == null) {
    return incoming;
  }

  final merged = <JlptSkillArea, JlptAreaStat>{};
  for (final area in JlptSkillArea.values) {
    final previous = existing.statFor(area);
    final next = incoming.statFor(area);
    merged[area] = JlptAreaStat(
      area: area,
      correct: previous.correct + next.correct,
      total: previous.total + next.total,
    );
  }

  return JlptDiagnosisProfile(
    generatedAt: now ?? DateTime.now(),
    source: source,
    stats: merged,
  );
}

JlptSevenDayPlan buildJlptSevenDayPlan(JlptDiagnosisProfile profile) {
  final weakAreas = profile.weakestFirst().map((entry) => entry.area).toList();
  final weakest = weakAreas.isNotEmpty ? weakAreas[0] : JlptSkillArea.reading;
  final second = weakAreas.length > 1 ? weakAreas[1] : JlptSkillArea.vocabulary;
  final third = weakAreas.length > 2 ? weakAreas[2] : JlptSkillArea.grammar;

  final items = <JlptPlanItem>[
    JlptPlanItem(
      dayOffset: 0,
      area: weakest,
      minutes: 30,
      focus: 'Reset weak zone',
      action: 'Review mistake notebook + quick practice.',
    ),
    JlptPlanItem(
      dayOffset: 1,
      area: second,
      minutes: 25,
      focus: 'Accuracy build',
      action: 'Untimed practice, then 10-minute timed check.',
    ),
    JlptPlanItem(
      dayOffset: 2,
      area: weakest,
      minutes: 30,
      focus: 'Speed + memory',
      action: '1-3-7 due mistakes + fast response round.',
    ),
    JlptPlanItem(
      dayOffset: 3,
      area: third,
      minutes: 25,
      focus: 'Coverage balance',
      action: 'Fill weakest patterns and keep notes concise.',
    ),
    JlptPlanItem(
      dayOffset: 4,
      area: second,
      minutes: 30,
      focus: 'Timed consolidation',
      action: 'Section simulation under real time pressure.',
    ),
    JlptPlanItem(
      dayOffset: 5,
      area: weakest,
      minutes: 35,
      focus: 'Recovery checkpoint',
      action: 'Retest failed items and compare with Day 1.',
    ),
    JlptPlanItem(
      dayOffset: 6,
      area: JlptSkillArea.reading,
      minutes: 40,
      focus: 'Mini mock + review',
      action: 'Run a short mock, analyze weak tags, adjust next week.',
    ),
  ];

  return JlptSevenDayPlan(startDate: DateTime.now(), items: items);
}
