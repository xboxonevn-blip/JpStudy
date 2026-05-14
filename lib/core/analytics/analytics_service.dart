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

  Future<void> logOnboardingCompleted({
    required String level,
    required String goal,
  }) {
    return _logEvent('onboarding_completed', {'level': level, 'goal': goal});
  }

  Future<void> logCloudUpload(String trigger) {
    return _logEvent('cloud_upload', {'trigger': trigger});
  }

  Future<void> logCloudDownload() {
    return _logEvent('cloud_download');
  }

  Future<void> logSrsReviewCompleted({
    required String itemType,
    required int rating,
    String level = 'unknown',
    double? intervalDays,
  }) {
    final parameters = <String, Object>{
      'item_type': itemType,
      'rating': rating,
      'level': level,
    };
    if (intervalDays != null) {
      parameters['interval_days'] = intervalDays;
    }
    return _logEvent('srs_review_completed', parameters);
  }

  Future<void> logN5MicroQuizCompleted({
    required int correctCount,
    required int totalCount,
  }) {
    final accuracy = totalCount <= 0 ? 0.0 : correctCount / totalCount;
    return _logEvent('n5_micro_quiz_completed', {
      'correct_count': correctCount,
      'total_count': totalCount,
      'accuracy': accuracy,
    });
  }

  Future<void> logSessionQualityRated({
    required String mode,
    required int rating,
  }) {
    return _logEvent('session_quality_rated', {'mode': mode, 'rating': rating});
  }

  Future<void> identifyUser({
    required String userId,
    required String authType,
  }) async {
    if (!_enabled) return;
    try {
      final analytics = _analytics ?? FirebaseAnalytics.instance;
      await analytics.setUserId(id: userId);
      await analytics.setUserProperty(name: 'auth_type', value: authType);
    } catch (_) {
      // Analytics identity must never interrupt study/auth/sync flows.
    }
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
