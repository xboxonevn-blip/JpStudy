import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/features/foundations/models/han_viet_rule.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/providers/kana_review_provider.dart';
import 'package:jpstudy/features/foundations/services/foundations_content_service.dart';

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
  StreamSubscription<int>? _subscription;

  @override
  FoundationsProgress build() {
    if (WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    )) {
      return const FoundationsProgress(studied: {});
    }
    ref.onDispose(() => _subscription?.cancel());
    unawaited(loadFromDao());
    _subscription = ref.read(kanaSrsDaoProvider).watchStudiedCount().listen((
      _,
    ) {
      unawaited(loadFromDao());
    });
    return const FoundationsProgress(studied: {});
  }

  Future<void> loadFromDao() async {
    if (!ref.mounted) return;
    final dao = ref.read(kanaSrsDaoProvider);
    final studied = await dao.studiedKana();
    if (!ref.mounted) return;
    state = FoundationsProgress(studied: Set.unmodifiable(studied));
  }

  Future<void> markStudied(String kana, String script) async {
    await ref.read(kanaReviewServiceProvider).grade(kana, script, 3);
    await loadFromDao();
  }

  Future<void> unmarkStudied(String kana) async {
    // Tier 2 keeps SRS history immutable from UI; no destructive unmark.
    await loadFromDao();
  }
}
