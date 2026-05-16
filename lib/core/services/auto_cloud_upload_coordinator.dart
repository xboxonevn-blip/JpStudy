import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/services/cloud_storage_sync_service.dart';
import 'package:jpstudy/core/services/cloud_backup_feature_flag.dart'
    as cloud_backup_flags;

typedef BackupEnvelopeBuilder = Future<Map<String, dynamic>> Function();
typedef AuthStateReader = AuthUser? Function();
typedef Clock = DateTime Function();

class AutoCloudUploadCoordinator {
  AutoCloudUploadCoordinator({
    required this.cloudStorageSync,
    required this.envelopeBuilder,
    required this.authState,
    required this.preferences,
    this.analyticsService,
    this.minimumInterval = const Duration(minutes: 5),
    this.clock = DateTime.now,
    this.cloudBackupEnabled = cloud_backup_flags.cloudBackupEnabled,
  });

  static const enabledPreferenceKey = 'backup.cloud.autoUpload.enabled';
  static const lastUploadPreferenceKey = 'backup.cloud.lastAutoUploadAt';

  final CloudStorageSyncService cloudStorageSync;
  final BackupEnvelopeBuilder envelopeBuilder;
  final AuthStateReader authState;
  final SharedPreferences preferences;
  final AnalyticsService? analyticsService;
  final Duration minimumInterval;
  final Clock clock;
  final bool cloudBackupEnabled;

  Future<String>? _inFlight;

  Future<String> maybeUpload() {
    final active = _inFlight;
    if (active != null) {
      return active;
    }
    final upload = _maybeUpload().whenComplete(() {
      _inFlight = null;
    });
    _inFlight = upload;
    return upload;
  }

  Future<String> _maybeUpload() async {
    try {
      if (!cloudBackupEnabled) {
        return 'disabled';
      }
      if (authState() == null) {
        return 'notSignedIn';
      }
      if (!(preferences.getBool(enabledPreferenceKey) ?? true)) {
        return 'disabled';
      }

      final now = clock();
      final lastRaw = preferences.getString(lastUploadPreferenceKey);
      final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
      if (last != null && now.difference(last) < minimumInterval) {
        return 'tooSoon';
      }

      final envelope = await envelopeBuilder();
      final result = await cloudStorageSync.uploadEnvelope(envelope);
      switch (result.decision) {
        case CloudStorageUploadDecision.uploaded:
          await preferences.setString(
            lastUploadPreferenceKey,
            now.toIso8601String(),
          );
          await analyticsService?.logCloudUpload('auto');
          return 'uploaded';
        case CloudStorageUploadDecision.disabled:
          return 'disabled';
        case CloudStorageUploadDecision.notSignedIn:
          return 'notSignedIn';
        case CloudStorageUploadDecision.emailNotVerified:
          return 'notSignedIn';
        case CloudStorageUploadDecision.payloadTooLarge:
          debugPrint('Auto cloud upload failed: payloadTooLarge');
          return 'failed';
        case CloudStorageUploadDecision.writeFailed:
          debugPrint('Auto cloud upload failed: writeFailed');
          return 'failed';
      }
    } catch (error, stackTrace) {
      debugPrint('Auto cloud upload failed: $error\n$stackTrace');
      return 'failed';
    }
  }
}
