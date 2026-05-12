import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jpstudy/core/analytics/do_not_track.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const prefAnalyticsConsent = 'analytics.consent';

final analyticsConsentProvider =
    StateNotifierProvider<AnalyticsConsentController, AnalyticsConsentState>((
      ref,
    ) {
      final preferences = ref.watch(sharedPreferencesProvider);
      return AnalyticsConsentController(preferences)..applyCollectionState();
    });

class AnalyticsConsentState {
  const AnalyticsConsentState({
    required this.isGranted,
    required this.shouldShowBanner,
    required this.doNotTrack,
  });

  final bool isGranted;
  final bool shouldShowBanner;
  final bool doNotTrack;
}

class AnalyticsConsentController extends StateNotifier<AnalyticsConsentState> {
  AnalyticsConsentController(this._preferences)
    : super(_initialState(_preferences));

  final SharedPreferences _preferences;

  Future<void> grant() async {
    await _preferences.setBool(prefAnalyticsConsent, true);
    state = AnalyticsConsentState(
      isGranted: true,
      shouldShowBanner: false,
      doNotTrack: state.doNotTrack,
    );
    await applyCollectionState();
  }

  Future<void> deny() async {
    await _preferences.setBool(prefAnalyticsConsent, false);
    state = AnalyticsConsentState(
      isGranted: false,
      shouldShowBanner: false,
      doNotTrack: state.doNotTrack,
    );
    await applyCollectionState();
  }

  Future<void> applyCollectionState() async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        state.isGranted && !state.doNotTrack,
      );
    } catch (_) {
      // Consent gating must never block app startup.
    }
  }

  static AnalyticsConsentState _initialState(SharedPreferences preferences) {
    final doNotTrack = isDoNotTrackEnabled();
    final stored = preferences.getBool(prefAnalyticsConsent);
    if (doNotTrack) {
      return const AnalyticsConsentState(
        isGranted: false,
        shouldShowBanner: false,
        doNotTrack: true,
      );
    }
    return AnalyticsConsentState(
      isGranted: stored ?? false,
      shouldShowBanner: stored == null,
      doNotTrack: false,
    );
  }
}
