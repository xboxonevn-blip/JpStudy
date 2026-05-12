import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/services/cloud_sync_service.dart';

final cloudSyncStatusRefreshProvider = StateProvider<int>((ref) => 0);

final cloudSyncStatusProvider = FutureProvider<CloudSyncStatus>((ref) async {
  ref.watch(cloudSyncStatusRefreshProvider);
  return CloudSyncService.loadStatus();
});

void refreshCloudSyncStatus(WidgetRef ref) {
  final current = ref.read(cloudSyncStatusRefreshProvider);
  ref.read(cloudSyncStatusRefreshProvider.notifier).state = current + 1;
}
