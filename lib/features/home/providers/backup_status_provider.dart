import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const backupAutoEnabledPrefKey = 'backup.auto.enabled';
const backupAutoLastPrefKey = 'backup.auto.last';

final backupStatusRefreshProvider = StateProvider<int>((ref) => 0);

final _backupStatusClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  while (true) {
    await Future<void>.delayed(const Duration(hours: 1));
    yield DateTime.now();
  }
});

final backupStatusProvider = FutureProvider<BackupStatus>((ref) async {
  ref.watch(backupStatusRefreshProvider);
  ref.watch(_backupStatusClockProvider);
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(backupAutoEnabledPrefKey) ?? false;
  final lastRaw = prefs.getString(backupAutoLastPrefKey);
  return BackupStatus(
    enabled: enabled,
    lastBackupAt: lastRaw == null ? null : DateTime.tryParse(lastRaw),
  );
});

void refreshBackupStatus(WidgetRef ref) {
  final current = ref.read(backupStatusRefreshProvider);
  ref.read(backupStatusRefreshProvider.notifier).state = current + 1;
}

class BackupStatus {
  const BackupStatus({required this.enabled, required this.lastBackupAt});

  final bool enabled;
  final DateTime? lastBackupAt;

  int? get ageInDays {
    if (lastBackupAt == null) {
      return null;
    }
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    final backupDate = DateTime(
      lastBackupAt!.year,
      lastBackupAt!.month,
      lastBackupAt!.day,
    );
    return dateOnly.difference(backupDate).inDays;
  }

  bool get isStale {
    final age = ageInDays;
    if (!enabled || age == null) {
      return true;
    }
    return age >= 2;
  }
}
