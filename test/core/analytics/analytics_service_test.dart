import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final events = <String>[];
  final params = <Map<String, Object>?>[];
  String? userId;
  final userProperties = <String, String?>{};

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add(name);
    params.add(parameters);
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    userId = id;
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) async {
    userProperties[name] = value;
  }
}

void main() {
  test('public analytics methods can be called with a fake instance', () async {
    final fake = _FakeFirebaseAnalytics();
    final service = AnalyticsService(instance: fake, enabled: true);

    await service.logSessionStart('learn');
    await service.logSessionComplete(
      'learn',
      xpGained: 12,
      correctCount: 4,
      totalCount: 5,
    );
    await service.logSignIn('google');
    await service.logCloudUpload('auto');
    await service.logCloudDownload();
    await service.logOnboardingCompleted(level: 'N5', goal: 'jlpt');
    await service.logSrsReviewCompleted(
      itemType: 'vocab',
      rating: 3,
      intervalDays: 2.5,
    );
    await service.logN5MicroQuizCompleted(correctCount: 7, totalCount: 10);
    await service.logSessionQualityRated(mode: 'review', rating: 4);

    expect(fake.events, hasLength(9));
    expect(fake.events, contains('onboarding_completed'));
    final onboardingIndex = fake.events.indexOf('onboarding_completed');
    expect(fake.params[onboardingIndex], {'level': 'N5', 'goal': 'jlpt'});
    expect(fake.events, contains('srs_review_completed'));
    expect(fake.events, contains('n5_micro_quiz_completed'));
    expect(fake.events, contains('session_quality_rated'));
    expect(fake.params.last, {'mode': 'review', 'rating': 4});
  });

  test('identifies user id and auth type after consent', () async {
    final fake = _FakeFirebaseAnalytics();
    final service = AnalyticsService(instance: fake, enabled: true);

    await service.identifyUser(userId: 'anon-1', authType: 'anonymous');

    expect(fake.userId, 'anon-1');
    expect(fake.userProperties['auth_type'], 'anonymous');
  });

  test('does not log before consent', () async {
    final fake = _FakeFirebaseAnalytics();
    final service = AnalyticsService(instance: fake);

    await service.logSessionStart('learn');
    await service.identifyUser(userId: 'anon-1', authType: 'anonymous');

    expect(fake.events, isEmpty);
    expect(fake.userId, isNull);
    expect(fake.userProperties, isEmpty);
  });
}
