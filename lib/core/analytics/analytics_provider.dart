import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_consent_provider.dart';
import 'analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final consent = ref.watch(analyticsConsentProvider);
  return AnalyticsService(enabled: consent.isGranted && !consent.doNotTrack);
});
