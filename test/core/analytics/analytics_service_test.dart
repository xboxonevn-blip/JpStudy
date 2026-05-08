import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final events = <String>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add(name);
  }
}

void main() {
  test('public analytics methods can be called with a fake instance', () async {
    final fake = _FakeFirebaseAnalytics();
    final service = AnalyticsService(instance: fake);

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

    expect(fake.events, hasLength(5));
  });
}
