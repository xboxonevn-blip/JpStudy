import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/analytics/analytics_provider.dart';

import 'anonymous_auth_service.dart';
import 'legacy_migration_service.dart';

final legacyMigrationServiceProvider = Provider<LegacyMigrationService>((ref) {
  return LegacyMigrationService();
});

final anonymousAuthServiceProvider = Provider<AnonymousAuthService>((ref) {
  return AnonymousAuthService(
    analyticsService: ref.watch(analyticsServiceProvider),
    legacyMigrationService: ref.watch(legacyMigrationServiceProvider),
  );
});
