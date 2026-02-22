import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const backupAutoEnabledPrefKey = 'backup.auto.enabled';
const backupAutoLastPrefKey = 'backup.auto.last';

final backupStatusProvider = StreamProvider<BackupStatus>((ref) async* {
  while (true) {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(backupAutoEnabledPrefKey) ?? false;
    final lastRaw = prefs.getString(backupAutoLastPrefKey);
    yield BackupStatus(
      enabled: enabled,
      lastBackupAt: lastRaw == null ? null : DateTime.tryParse(lastRaw),
    );
    await Future<void>.delayed(const Duration(seconds: 20));
  }
});

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
