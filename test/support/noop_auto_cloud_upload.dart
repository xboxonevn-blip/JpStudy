import 'package:jpstudy/core/services/auto_cloud_upload_coordinator.dart';
import 'package:jpstudy/core/services/cloud_storage_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AutoCloudUploadCoordinator noopAutoCloudUpload(SharedPreferences preferences) {
  return AutoCloudUploadCoordinator(
    cloudStorageSync: _NoopCloudStorageSyncService(),
    envelopeBuilder: () async => const <String, dynamic>{},
    authState: () => null,
    preferences: preferences,
  );
}

class _NoopCloudStorageSyncService implements CloudStorageSyncService {
  @override
  Future<CloudStorageUploadResult> uploadEnvelope(
    Map<String, dynamic> envelope,
  ) async {
    return const CloudStorageUploadResult(
      decision: CloudStorageUploadDecision.notSignedIn,
    );
  }

  @override
  Future<CloudStorageDownloadResult> prepareDownload({
    String? passphrase,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<CloudStorageDeleteResult> deleteRemoteBackup() async {
    throw UnimplementedError();
  }
}
