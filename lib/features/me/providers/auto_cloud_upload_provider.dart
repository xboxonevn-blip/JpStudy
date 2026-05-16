import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/services/auto_cloud_upload_coordinator.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/services/cloud_backup_feature_flag.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';

final autoCloudUploadProvider = Provider<AutoCloudUploadCoordinator>((ref) {
  final authService = ref.watch(authServiceProvider);
  final repo = ref.watch(lessonRepositoryProvider);
  return AutoCloudUploadCoordinator(
    cloudStorageSync: ref.watch(cloudStorageSyncServiceProvider),
    envelopeBuilder: () async {
      final data = await repo.exportBackup();
      return BackupSyncService.buildExportEnvelope(data);
    },
    authState: () => authService.currentUser,
    preferences: ref.watch(sharedPreferencesProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
    cloudBackupEnabled: cloudBackupEnabled,
  );
});
