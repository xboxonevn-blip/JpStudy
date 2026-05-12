import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:jpstudy/core/services/recovery_pack_service.dart';

final recoveryPackRefreshProvider = StateProvider<int>((ref) => 0);

final recoveryPackProvider = FutureProvider<RecoveryPack?>((ref) async {
  ref.watch(recoveryPackRefreshProvider);
  return RecoveryPackService.load();
});

void refreshRecoveryPack(WidgetRef ref) {
  final current = ref.read(recoveryPackRefreshProvider);
  ref.read(recoveryPackRefreshProvider.notifier).state = current + 1;
}
