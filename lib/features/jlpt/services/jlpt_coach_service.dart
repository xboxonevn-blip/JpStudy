import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/jlpt_coach_models.dart';

const _snapshotPrefsKey = 'jlpt_coach.snapshot.v1';

final jlptCoachServiceProvider = Provider<JlptCoachService>((ref) {
  return const JlptCoachService();
});

final jlptCoachSnapshotProvider = FutureProvider<JlptCoachSnapshot?>((
  ref,
) async {
  final service = ref.watch(jlptCoachServiceProvider);
  return service.loadSnapshot();
});

class JlptCoachService {
  const JlptCoachService();

  Future<JlptCoachSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotPrefsKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return JlptCoachSnapshot.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSnapshot(JlptCoachSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotPrefsKey, jsonEncode(snapshot.toJson()));
  }

  Future<JlptCoachSnapshot> saveFromSignals({
    required String source,
    required List<JlptSkillSignal> signals,
  }) async {
    final profile = buildJlptDiagnosisProfile(source: source, signals: signals);
    final plan = buildJlptSevenDayPlan(profile);
    final snapshot = JlptCoachSnapshot(profile: profile, plan: plan);
    await saveSnapshot(snapshot);
    return snapshot;
  }
}
