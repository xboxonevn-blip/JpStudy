import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _practiceHubOrderPrefKey = 'home.practice_hub.order';
const _practiceHubFocusModePrefKey = 'home.practice_hub.focus_mode';

final practiceHubPreferencesProvider =
    StateNotifierProvider<
      PracticeHubPreferencesNotifier,
      PracticeHubPreferences
    >((ref) {
      return PracticeHubPreferencesNotifier()..load();
    });

class PracticeHubPreferences {
  const PracticeHubPreferences({
    required this.orderIds,
    required this.focusModeEnabled,
    required this.loaded,
  });

  const PracticeHubPreferences.initial()
    : orderIds = const <String>[],
      focusModeEnabled = true,
      loaded = false;

  final List<String> orderIds;
  final bool focusModeEnabled;
  final bool loaded;

  PracticeHubPreferences copyWith({
    List<String>? orderIds,
    bool? focusModeEnabled,
    bool? loaded,
  }) {
    return PracticeHubPreferences(
      orderIds: orderIds ?? this.orderIds,
      focusModeEnabled: focusModeEnabled ?? this.focusModeEnabled,
      loaded: loaded ?? this.loaded,
    );
  }
}

class PracticeHubPreferencesNotifier
    extends StateNotifier<PracticeHubPreferences> {
  PracticeHubPreferencesNotifier()
    : super(const PracticeHubPreferences.initial());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs.getStringList(_practiceHubOrderPrefKey) ?? const <String>[];
    final focus = prefs.getBool(_practiceHubFocusModePrefKey) ?? true;
    state = PracticeHubPreferences(
      orderIds: List<String>.unmodifiable(ids),
      focusModeEnabled: focus,
      loaded: true,
    );
  }

  Future<void> saveOrder(List<String> ids) async {
    final normalized = List<String>.unmodifiable(ids);
    state = state.copyWith(orderIds: normalized, loaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_practiceHubOrderPrefKey, normalized);
  }

  Future<void> resetOrder() async {
    state = state.copyWith(orderIds: const <String>[], loaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_practiceHubOrderPrefKey);
  }

  Future<void> setFocusMode(bool enabled) async {
    state = state.copyWith(focusModeEnabled: enabled, loaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_practiceHubFocusModePrefKey, enabled);
  }
}
