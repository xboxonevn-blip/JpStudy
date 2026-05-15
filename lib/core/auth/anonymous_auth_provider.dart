import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/analytics/analytics_provider.dart';

import 'anonymous_auth_service.dart';
import 'legacy_migration_service.dart';

const legacyStorageMigrationEnabled = bool.fromEnvironment(
  'JPSTUDY_ENABLE_LEGACY_STORAGE_MIGRATION',
  defaultValue: false,
);

final legacyMigrationServiceProvider = Provider<LegacyMigrationService>((ref) {
  return LegacyMigrationService();
});

final anonymousAuthServiceProvider = Provider<AnonymousAuthService>((ref) {
  return AnonymousAuthService(
    analyticsService: ref.watch(analyticsServiceProvider),
    legacyMigrationService: ref.watch(legacyMigrationServiceProvider),
    legacyMigrationEnabled: legacyStorageMigrationEnabled,
  );
});
