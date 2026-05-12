import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecoveryPack {
  const RecoveryPack({
    required this.source,
    required this.lessonTitle,
    required this.termIds,
    required this.createdAt,
  });

  final String source;
  final String lessonTitle;
  final List<int> termIds;
  final DateTime createdAt;

  int get itemCount => termIds.length;

  bool get isFresh =>
      createdAt.isAfter(DateTime.now().subtract(const Duration(days: 2)));

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'lessonTitle': lessonTitle,
      'termIds': termIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static RecoveryPack? fromJson(Map<String, dynamic> json) {
    final rawIds = json['termIds'];
    if (rawIds is! List) {
      return null;
    }

    final ids = rawIds.whereType<num>().map((value) => value.toInt()).toList();
    if (ids.isEmpty) {
      return null;
    }

    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (createdAt == null) {
      return null;
    }

    return RecoveryPack(
      source: json['source']?.toString() ?? 'exam',
      lessonTitle: json['lessonTitle']?.toString() ?? 'Recovery Pack',
      termIds: List<int>.unmodifiable(ids),
      createdAt: createdAt,
    );
  }
}

class RecoveryPackService {
  const RecoveryPackService._();

  static const String recoveryLessonTitle = 'Recovery Pack';
  static const int recoveryLessonId = -9901;
  static const _prefRecoveryPack = 'coach.recovery_pack';

  static Future<void> saveExamPack({
    required String lessonTitle,
    required List<int> termIds,
  }) async {
    final ids = termIds.toSet().toList()..sort();
    if (ids.isEmpty) {
      await clear();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final payload = RecoveryPack(
      source: 'mock_exam',
      lessonTitle: lessonTitle.trim().isEmpty
          ? recoveryLessonTitle
          : lessonTitle,
      termIds: ids,
      createdAt: DateTime.now(),
    );
    await prefs.setString(_prefRecoveryPack, jsonEncode(payload.toJson()));
  }

  static Future<RecoveryPack?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefRecoveryPack);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final pack = RecoveryPack.fromJson(Map<String, dynamic>.from(decoded));
      if (pack == null) {
        return null;
      }
      if (!pack.isFresh) {
        await clear();
        return null;
      }
      return pack;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRecoveryPack);
  }
}
