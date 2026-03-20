import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/immersion_article.dart';
import 'shared_reading_library.dart';

class ImmersionService {
  ImmersionService({
    SharedReadingLibrary sharedReadingLibrary = const SharedReadingLibrary(),
  }) : _sharedReadingLibrary = sharedReadingLibrary;

  static const _readStatusKey = 'immersion_read_ids';
  static const _quizHistoryKey = 'immersion_quiz_history_v1';

  final SharedReadingLibrary _sharedReadingLibrary;

  Future<List<ImmersionArticle>> loadReadingBank() async {
    return _sharedReadingLibrary.loadImmersionArticles();
  }

  Future<List<ImmersionArticle>> loadLocalSamples() async {
    return loadReadingBank();
  }

  Future<Set<String>> getReadArticleIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readStatusKey) ?? [];
    return list.toSet();
  }

  Future<void> markArticleAsRead(String id, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_readStatusKey) ?? []).toSet();
    if (isRead) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(_readStatusKey, ids.toList());
  }

  Future<List<ImmersionQuizAttempt>> getQuizHistory(
    String articleId, {
    int limit = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizHistoryKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const [];
      }
      final listRaw = decoded[articleId];
      if (listRaw is! List) {
        return const [];
      }
      return listRaw
          .whereType<Map>()
          .map((item) => ImmersionQuizAttempt.fromJson(item))
          .where((attempt) => attempt.total > 0)
          .take(limit)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveQuizAttempt({
    required String articleId,
    required int correct,
    required int total,
    int keep = 20,
  }) async {
    if (total <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quizHistoryKey);
    final payload = <String, dynamic>{};
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          payload.addAll(decoded.map((key, value) => MapEntry('$key', value)));
        }
      } catch (_) {
        payload.clear();
      }
    }

    final historyRaw = payload[articleId];
    final history = <Map<String, dynamic>>[];
    if (historyRaw is List) {
      for (final entry in historyRaw) {
        if (entry is Map) {
          history.add(entry.map((key, value) => MapEntry('$key', value)));
        }
      }
    }

    history.insert(0, {
      'correct': correct,
      'total': total,
      'attemptedAt': DateTime.now().toIso8601String(),
    });
    if (history.length > keep) {
      history.removeRange(keep, history.length);
    }
    payload[articleId] = history;

    await prefs.setString(_quizHistoryKey, jsonEncode(payload));
  }
}

class ImmersionQuizAttempt {
  const ImmersionQuizAttempt({
    required this.correct,
    required this.total,
    required this.attemptedAt,
  });

  final int correct;
  final int total;
  final DateTime attemptedAt;

  factory ImmersionQuizAttempt.fromJson(Map<dynamic, dynamic> json) {
    final correct = int.tryParse('${json['correct'] ?? 0}') ?? 0;
    final total = int.tryParse('${json['total'] ?? 0}') ?? 0;
    final attemptedAt =
        DateTime.tryParse('${json['attemptedAt'] ?? ''}') ?? DateTime.now();
    return ImmersionQuizAttempt(
      correct: correct,
      total: total,
      attemptedAt: attemptedAt,
    );
  }
}
