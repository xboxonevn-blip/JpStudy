import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? instance, bool enabled = false})
    : _analytics = instance,
      _enabled = enabled;

  final FirebaseAnalytics? _analytics;
  final bool _enabled;

  Future<void> logSessionStart(String mode) {
    return _logEvent('study_session_start', {'mode': mode});
  }

  Future<void> logSessionComplete(
    String mode, {
    required int xpGained,
    required int correctCount,
    required int totalCount,
  }) {
    return _logEvent('study_session_complete', {
      'mode': mode,
      'xp_gained': xpGained,
      'correct_count': correctCount,
      'total_count': totalCount,
    });
  }

  Future<void> logSignIn(String provider) {
    return _logEvent('auth_sign_in', {'provider': provider});
  }

  Future<void> logCloudUpload(String trigger) {
    return _logEvent('cloud_upload', {'trigger': trigger});
  }

  Future<void> logCloudDownload() {
    return _logEvent('cloud_download');
  }

  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    if (!_enabled) return;
    try {
      final analytics = _analytics ?? FirebaseAnalytics.instance;
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Analytics must never interrupt study/auth/sync flows.
    }
  }
}
