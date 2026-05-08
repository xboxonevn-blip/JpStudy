import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/features/foundations/models/han_viet_rule.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/services/foundations_content_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const foundationsKanaTotal = 208;
const foundationsStudiedPrefsKey = 'foundations.kana.studied';

final foundationsContentServiceProvider = Provider<FoundationsContentService>(
  (ref) => FoundationsContentService(),
);

final kanaChartProvider = FutureProvider<KanaChart>((ref) {
  return ref.watch(foundationsContentServiceProvider).loadKanaChart();
});

final hanVietRulesProvider = FutureProvider<HanVietRuleSet>((ref) {
  return ref.watch(foundationsContentServiceProvider).loadHanVietRules();
});

final foundationsProgressProvider =
    NotifierProvider<FoundationsProgressController, FoundationsProgress>(
      FoundationsProgressController.new,
    );

class FoundationsProgress {
  const FoundationsProgress({required this.studied});

  final Set<String> studied;

  int get studiedCount => studied.length;

  double get percentComplete => studiedCount / foundationsKanaTotal;

  bool isStudied(String kana) => studied.contains(kana);

  FoundationsProgress copyWith({Set<String>? studied}) {
    return FoundationsProgress(
      studied: Set.unmodifiable(studied ?? this.studied),
    );
  }
}

class FoundationsProgressController extends Notifier<FoundationsProgress> {
  @override
  FoundationsProgress build() {
    unawaited(loadFromPrefs());
    return const FoundationsProgress(studied: {});
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(foundationsStudiedPrefsKey) ?? const [];
    state = FoundationsProgress(studied: Set.unmodifiable(stored));
  }

  Future<void> markStudied(String kana) async {
    final next = {...state.studied, kana};
    state = FoundationsProgress(studied: Set.unmodifiable(next));
    await _save(next);
  }

  Future<void> unmarkStudied(String kana) async {
    final next = {...state.studied}..remove(kana);
    state = FoundationsProgress(studied: Set.unmodifiable(next));
    await _save(next);
  }

  Future<void> _save(Set<String> studied) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = studied.toList()..sort();
    await prefs.setStringList(foundationsStudiedPrefsKey, sorted);
  }
}
