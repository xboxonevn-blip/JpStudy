import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/weekly_challenge.dart';

const _prefKey = 'challenge.history';
const _maxHistory = 12;

class ChallengeHistoryEntry {
  const ChallengeHistoryEntry({
    required this.weekId,
    required this.type,
    required this.target,
    required this.current,
    required this.completed,
  });

  final String weekId;
  final ChallengeType type;
  final int target;
  final int current;
  final bool completed;

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
    'weekId': weekId,
    'type': type.name,
    'target': target,
    'current': current,
    'completed': completed,
  };

  factory ChallengeHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ChallengeHistoryEntry(
      weekId: json['weekId'] as String,
      type: ChallengeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ChallengeType.reviewCount,
      ),
      target: json['target'] as int,
      current: json['current'] as int,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

final challengeHistoryProvider =
    FutureProvider.autoDispose<List<ChallengeHistoryEntry>>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      return _loadHistory(prefs);
    });

List<ChallengeHistoryEntry> _loadHistory(SharedPreferences prefs) {
  final raw = prefs.getString(_prefKey);
  if (raw == null) return [];
  try {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ChallengeHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Archives a completed challenge week into history.
/// Called when a new week is detected and the previous week should be saved.
Future<void> archiveChallenge(WeeklyChallenge challenge) async {
  final prefs = await SharedPreferences.getInstance();
  final history = _loadHistory(prefs);

  // Don't duplicate.
  if (history.any((e) => e.weekId == challenge.id)) return;

  final entry = ChallengeHistoryEntry(
    weekId: challenge.id,
    type: challenge.type,
    target: challenge.target,
    current: challenge.current,
    completed: challenge.isComplete,
  );

  history.insert(0, entry);

  // Trim to max.
  final trimmed = history.take(_maxHistory).toList();
  await prefs.setString(
    _prefKey,
    jsonEncode(trimmed.map((e) => e.toJson()).toList()),
  );
}
