import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';

const _prefAutoBackup = 'backup.auto.enabled';
const _prefAutoBackupTime = 'backup.auto.time';
const _prefAutoBackupLast = 'backup.auto.last';
const _lastAutoBackupSentinel = Object();

final dataSettingsControllerProvider =
    NotifierProvider<DataSettingsController, DataSettingsState>(
      DataSettingsController.new,
    );

class DataSettingsState {
  const DataSettingsState({
    this.isReady = false,
    this.autoBackupEnabled = false,
    this.autoBackupTime = const TimeOfDay(hour: 2, minute: 0),
    this.lastAutoBackup,
  });

  final bool isReady;
  final bool autoBackupEnabled;
  final TimeOfDay autoBackupTime;
  final DateTime? lastAutoBackup;

  DataSettingsState copyWith({
    bool? isReady,
    bool? autoBackupEnabled,
    TimeOfDay? autoBackupTime,
    Object? lastAutoBackup = _lastAutoBackupSentinel,
  }) {
    return DataSettingsState(
      isReady: isReady ?? this.isReady,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupTime: autoBackupTime ?? this.autoBackupTime,
      lastAutoBackup: lastAutoBackup == _lastAutoBackupSentinel
          ? this.lastAutoBackup
          : lastAutoBackup as DateTime?,
    );
  }
}

class DataSettingsController extends Notifier<DataSettingsState> {
  Timer? _autoBackupTimer;
  SharedPreferences? _prefs;
  BuildContext? _hostContext;

  @override
  DataSettingsState build() {
    ref.onDispose(() {
      _autoBackupTimer?.cancel();
    });
    return const DataSettingsState();
  }

  void bindHostContext(BuildContext context) {
    _hostContext = context;
    if (!state.isReady) {
      unawaited(initialize(hostContext: context));
    }
  }

  void unbindHostContext(BuildContext context) {
    if (_hostContext == context) {
      _hostContext = null;
    }
  }

  Future<void> initialize({BuildContext? hostContext}) async {
    if (hostContext != null) {
      _hostContext = hostContext;
    }
    if (state.isReady) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final prefs = await _ensurePrefs();
    final autoBackupEnabled = prefs.getBool(_prefAutoBackup) ?? false;
    final autoBackupTime =
        _backupTimeFromPrefs(prefs) ?? const TimeOfDay(hour: 2, minute: 0);
    final lastRaw = prefs.getString(_prefAutoBackupLast);

    state = state.copyWith(
      isReady: true,
      autoBackupEnabled: autoBackupEnabled,
      autoBackupTime: autoBackupTime,
      lastAutoBackup: lastRaw == null ? null : DateTime.tryParse(lastRaw),
    );
    _syncSchedules();
  }

  Future<void> setAutoBackup(bool enabled, AppLanguage language) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_prefAutoBackup, enabled);
    state = state.copyWith(autoBackupEnabled: enabled, isReady: true);

    if (enabled) {
      await performAutoBackup(language);
      _scheduleAutoBackup();
    } else {
      _autoBackupTimer?.cancel();
    }
    ref.invalidate(backupStatusProvider);
  }

  Future<void> setAutoBackupTime(TimeOfDay time) async {
    final prefs = await _ensurePrefs();
    await _saveBackupTime(prefs, time);
    state = state.copyWith(autoBackupTime: time, isReady: true);
    if (state.autoBackupEnabled) {
      _scheduleAutoBackup();
    }
  }

  Future<void> exportBackup(BuildContext context, AppLanguage language) async {
    final envelope = await _buildBackupEnvelope();
    final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
    final location = await getSaveLocation(
      suggestedName: 'jpstudy_backup.json',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null) {
      return;
    }

    try {
      await File(location.path).writeAsString(jsonText, flush: true);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, language.backupExportSuccess);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, language.backupExportError);
    }
  }

  Future<void> importBackup(BuildContext context, AppLanguage language) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null || !context.mounted) {
      return;
    }

    final shouldImport = await _confirmImport(context, language);
    if (shouldImport != true) {
      return;
    }

    try {
      final content = await File(file.path).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final importPlan = await BackupSyncService.prepareImport(data);
      if (!context.mounted) {
        return;
      }

      if (importPlan.decision == BackupImportDecision.invalidChecksum) {
        _showSnackBar(context, language.backupImportError);
        return;
      }
      if (importPlan.decision == BackupImportDecision.skipOlder) {
        _showSnackBar(context, cloudSyncSkipOlderLabel(language));
        return;
      }

      await _applyImportedPayload(
        context,
        language,
        payload: importPlan.payload,
        incomingExportedAt: importPlan.incomingExportedAt,
        onApplied: BackupSyncService.markImportApplied,
        successMessage: language.backupImportSuccess,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, language.backupImportError);
    }
  }

  Future<void> linkExistingCloudSyncFile(
    BuildContext context,
    AppLanguage language,
  ) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) {
      return;
    }
    await CloudSyncService.linkTarget(
      path: file.path,
      displayName: p.basename(file.path),
    );
    ref.invalidate(cloudSyncStatusProvider);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, cloudSyncLinkedSuccessLabel(language));
  }

  Future<void> createCloudSyncFile(
    BuildContext context,
    AppLanguage language,
  ) async {
    final location = await getSaveLocation(
      suggestedName: 'jpstudy_cloud_sync.json',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null) {
      return;
    }

    await CloudSyncService.linkTarget(
      path: location.path,
      displayName: p.basename(location.path),
    );
    ref.invalidate(cloudSyncStatusProvider);
    if (!context.mounted) {
      return;
    }
    await uploadToCloudFile(context, language);
  }

  Future<void> unlinkCloudSyncFile(
    BuildContext context,
    AppLanguage language,
  ) async {
    await CloudSyncService.unlinkTarget();
    ref.invalidate(cloudSyncStatusProvider);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, cloudSyncUnlinkedSuccessLabel(language));
  }

  Future<void> uploadToCloudFile(
    BuildContext context,
    AppLanguage language,
  ) async {
    final envelope = await _buildBackupEnvelope();
    final result = await CloudSyncService.uploadEnvelope(envelope);
    ref.invalidate(cloudSyncStatusProvider);

    final message = switch (result.decision) {
      CloudSyncUploadDecision.uploaded => cloudSyncUploadSuccessLabel(language),
      CloudSyncUploadDecision.missingTarget => cloudSyncLinkRequiredLabel(
        language,
      ),
      CloudSyncUploadDecision.writeFailed => cloudSyncUploadErrorLabel(
        language,
      ),
    };
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, message);
  }

  Future<void> downloadFromCloudFile(
    BuildContext context,
    AppLanguage language,
  ) async {
    final result = await CloudSyncService.prepareDownload();
    if (!context.mounted) {
      return;
    }

    switch (result.decision) {
      case CloudSyncDownloadDecision.apply:
        final confirmed = await _confirmImport(context, language);
        if (!context.mounted || confirmed != true || result.payload == null) {
          return;
        }
        await _applyImportedPayload(
          context,
          language,
          payload: result.payload!,
          incomingExportedAt: result.remoteExportedAt,
          onApplied: CloudSyncService.markDownloadApplied,
          successMessage: cloudSyncDownloadSuccessLabel(language),
        );
        return;
      case CloudSyncDownloadDecision.skipOlder:
        _showSnackBar(context, cloudSyncSkipOlderLabel(language));
        return;
      case CloudSyncDownloadDecision.invalidChecksum:
      case CloudSyncDownloadDecision.invalidFormat:
      case CloudSyncDownloadDecision.readFailed:
        _showSnackBar(context, cloudSyncDownloadErrorLabel(language));
        return;
      case CloudSyncDownloadDecision.missingTarget:
        _showSnackBar(context, cloudSyncLinkRequiredLabel(language));
        return;
      case CloudSyncDownloadDecision.missingRemoteFile:
        _showSnackBar(context, cloudSyncMissingRemoteLabel(language));
        return;
    }
  }

  Future<void> performAutoBackup(
    AppLanguage language, {
    BuildContext? context,
  }) async {
    final prefs = await _ensurePrefs();
    final todayKey = _dateKey(DateTime.now());
    final lastRaw = prefs.getString(_prefAutoBackupLast);
    if (_dateKeyFromStored(lastRaw) == todayKey) {
      return;
    }

    try {
      final repo = ref.read(lessonRepositoryProvider);
      final data = await repo.exportBackup();
      final envelope = await BackupSyncService.buildExportEnvelope(data);
      final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
      final backupDir = await _ensureBackupDir();
      final timestamp = DateTime.now();
      final fileName =
          'jpstudy_auto_backup_${timestamp.toIso8601String().replaceAll(':', '-')}.json';
      final file = File(p.join(backupDir.path, fileName));
      await file.writeAsString(jsonText, flush: true);
      await prefs.setString(_prefAutoBackupLast, timestamp.toIso8601String());
      await _cleanupOldBackups(backupDir, keep: 7);

      state = state.copyWith(lastAutoBackup: timestamp, isReady: true);
      ref.invalidate(backupStatusProvider);
      _showSnackBar(context ?? _hostContext, language.autoBackupSuccessLabel);
    } catch (_) {
      _showSnackBar(context ?? _hostContext, language.autoBackupErrorLabel);
    }
  }

  String cloudSyncLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked sync file';
      case AppLanguage.vi:
        return 'File đồng bộ liên kết';
      case AppLanguage.ja:
        return 'Linked sync file';
    }
  }

  String cloudSyncLoadingLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Loading linked file status...';
      case AppLanguage.vi:
        return 'Đang tải trạng thái file liên kết...';
      case AppLanguage.ja:
        return 'Loading linked file status...';
    }
  }

  String cloudSyncNotLinkedLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No linked sync file yet.';
      case AppLanguage.vi:
        return 'Chưa liên kết file đồng bộ nào.';
      case AppLanguage.ja:
        return 'No linked sync file yet.';
    }
  }

  String cloudSyncLinkedLabel(AppLanguage language, String fileName) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file: $fileName';
      case AppLanguage.vi:
        return 'File đã liên kết: $fileName';
      case AppLanguage.ja:
        return 'Linked file: $fileName';
    }
  }

  String cloudSyncChooseFileLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose existing file';
      case AppLanguage.vi:
        return 'Chọn file có sẵn';
      case AppLanguage.ja:
        return 'Choose existing file';
    }
  }

  String cloudSyncCreateFileLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Create new file';
      case AppLanguage.vi:
        return 'Tạo file mới';
      case AppLanguage.ja:
        return 'Create new file';
    }
  }

  String cloudSyncUploadLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Upload to linked file';
      case AppLanguage.vi:
        return 'Tải lên file liên kết';
      case AppLanguage.ja:
        return 'Upload to linked file';
    }
  }

  String cloudSyncDownloadLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Download from linked file';
      case AppLanguage.vi:
        return 'Tải xuống từ file liên kết';
      case AppLanguage.ja:
        return 'Download from linked file';
    }
  }

  String cloudSyncUnlinkLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Remove linked file';
      case AppLanguage.vi:
        return 'Gỡ liên kết file';
      case AppLanguage.ja:
        return 'Remove linked file';
    }
  }

  String cloudSyncCreateHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Point this at a JSON file inside Dropbox, Drive, Syncthing, or another synced folder.';
      case AppLanguage.vi:
        return 'Hãy trỏ tới một file JSON trong Dropbox, Drive, Syncthing hoặc thư mục đang được đồng bộ.';
      case AppLanguage.ja:
        return 'Point this at a JSON file inside Dropbox, Drive, Syncthing, or another synced folder.';
    }
  }

  String cloudSyncStatusSubtitle(
    BuildContext context,
    AppLanguage language,
    CloudSyncStatus status,
  ) {
    if (!status.isLinked) {
      return cloudSyncNotLinkedLabel(language);
    }
    if (status.lastSyncedAt == null) {
      return cloudSyncLinkedLabel(language, status.target!.displayName);
    }

    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(status.lastSyncedAt!);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(status.lastSyncedAt!),
    );
    return '${status.target!.displayName} - ${cloudSyncLastSyncedLabel(language, '$date $time', status.lastDirection)}';
  }

  String cloudSyncLastSyncedLabel(
    AppLanguage language,
    String dateText,
    CloudSyncDirection? direction,
  ) {
    final directionLabel = _cloudSyncDirectionLabel(language, direction);
    switch (language) {
      case AppLanguage.en:
        return 'Last file sync: $dateText${directionLabel.isEmpty ? '' : ' ($directionLabel)'}';
      case AppLanguage.vi:
        return 'Lần đồng bộ file cuối: $dateText${directionLabel.isEmpty ? '' : ' ($directionLabel)'}';
      case AppLanguage.ja:
        return 'Last file sync: $dateText${directionLabel.isEmpty ? '' : ' ($directionLabel)'}';
    }
  }

  String cloudSyncLinkedSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked sync file updated.';
      case AppLanguage.vi:
        return 'Đã cập nhật file đồng bộ liên kết.';
      case AppLanguage.ja:
        return 'Linked sync file updated.';
    }
  }

  String cloudSyncUnlinkedSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked sync file removed.';
      case AppLanguage.vi:
        return 'Đã gỡ file đồng bộ liên kết.';
      case AppLanguage.ja:
        return 'Linked sync file removed.';
    }
  }

  String cloudSyncLinkRequiredLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose or create a linked sync file first.';
      case AppLanguage.vi:
        return 'Hãy chọn hoặc tạo file đồng bộ liên kết trước.';
      case AppLanguage.ja:
        return 'Choose or create a linked sync file first.';
    }
  }

  String cloudSyncUploadSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Uploaded backup to linked sync file.';
      case AppLanguage.vi:
        return 'Đã tải bản sao lưu lên file đồng bộ liên kết.';
      case AppLanguage.ja:
        return 'Uploaded backup to linked sync file.';
    }
  }

  String cloudSyncUploadErrorLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Failed to write linked sync file.';
      case AppLanguage.vi:
        return 'Không ghi được file đồng bộ liên kết.';
      case AppLanguage.ja:
        return 'Failed to write linked sync file.';
    }
  }

  String cloudSyncDownloadSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Downloaded backup from linked sync file.';
      case AppLanguage.vi:
        return 'Đã tải bản sao lưu từ file đồng bộ liên kết.';
      case AppLanguage.ja:
        return 'Downloaded backup from linked sync file.';
    }
  }

  String cloudSyncDownloadErrorLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked sync file is invalid or unreadable.';
      case AppLanguage.vi:
        return 'File đồng bộ liên kết không hợp lệ hoặc không đọc được.';
      case AppLanguage.ja:
        return 'Linked sync file is invalid or unreadable.';
    }
  }

  String cloudSyncMissingRemoteLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked sync file does not exist yet.';
      case AppLanguage.vi:
        return 'File đồng bộ liên kết chưa tồn tại.';
      case AppLanguage.ja:
        return 'Linked sync file does not exist yet.';
    }
  }

  String cloudSyncSkipOlderLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Skipped because the incoming file is older than local data.';
      case AppLanguage.vi:
        return 'Bỏ qua vì file sắp nhập cũ hơn dữ liệu hiện tại.';
      case AppLanguage.ja:
        return 'Skipped because the incoming file is older than local data.';
    }
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  void _syncSchedules() {
    if (state.autoBackupEnabled) {
      _scheduleAutoBackup();
    } else {
      _autoBackupTimer?.cancel();
    }
  }

  void _scheduleAutoBackup() {
    _autoBackupTimer?.cancel();
    if (!state.autoBackupEnabled) {
      return;
    }

    final now = DateTime.now();
    final next = _nextReminderTime(now, state.autoBackupTime);
    _autoBackupTimer = Timer(next.difference(now), () async {
      await performAutoBackup(ref.read(appLanguageProvider));
      _scheduleAutoBackup();
    });
  }

  DateTime _nextReminderTime(DateTime now, TimeOfDay time) {
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<Map<String, dynamic>> _buildBackupEnvelope() async {
    final repo = ref.read(lessonRepositoryProvider);
    final data = await repo.exportBackup();
    return BackupSyncService.buildExportEnvelope(data);
  }

  Future<bool?> _confirmImport(
    BuildContext context,
    AppLanguage language,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.backupImportTitle),
        content: Text(language.backupImportBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.backupImportConfirmLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _applyImportedPayload(
    BuildContext context,
    AppLanguage language, {
    required Map<String, dynamic> payload,
    required DateTime? incomingExportedAt,
    required Future<void> Function(DateTime? incomingExportedAt) onApplied,
    required String successMessage,
  }) async {
    try {
      final repo = ref.read(lessonRepositoryProvider);
      await _savePreImportSafetySnapshot(repo);
      await repo.importBackup(payload);
      await onApplied(incomingExportedAt);
      await refresh();
      ref.invalidate(backupStatusProvider);
      ref.invalidate(cloudSyncStatusProvider);
      ref.invalidate(lessonMetaProvider);
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, successMessage);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, language.backupImportError);
    }
  }

  Future<void> _savePreImportSafetySnapshot(LessonRepository repo) async {
    final snapshot = await repo.exportBackup();
    final envelope = await BackupSyncService.buildExportEnvelope(snapshot);
    final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
    final backupDir = await _ensureBackupDir();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(
      p.join(backupDir.path, 'jpstudy_pre_import_$timestamp.json'),
    );
    await file.writeAsString(jsonText, flush: true);
    await _cleanupOldBackups(backupDir, keep: 10);
  }

  Future<Directory> _ensureBackupDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'backups'));
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }

  Future<void> _cleanupOldBackups(Directory backupDir, {int keep = 7}) async {
    final files =
        backupDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort(
            (left, right) =>
                right.lastModifiedSync().compareTo(left.lastModifiedSync()),
          );
    if (files.length <= keep) {
      return;
    }
    for (final file in files.sublist(keep)) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  TimeOfDay? _backupTimeFromPrefs(SharedPreferences prefs) {
    final stored = prefs.getString(_prefAutoBackupTime);
    if (stored == null || stored.isEmpty) {
      return null;
    }
    final parts = stored.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _saveBackupTime(SharedPreferences prefs, TimeOfDay time) async {
    final value =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_prefAutoBackupTime, value);
  }

  String _dateKey(DateTime time) {
    return '${time.year.toString().padLeft(4, '0')}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')}';
  }

  String? _dateKeyFromStored(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return _dateKey(parsed);
    }
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  String _cloudSyncDirectionLabel(
    AppLanguage language,
    CloudSyncDirection? direction,
  ) {
    if (direction == null) {
      return '';
    }
    switch (direction) {
      case CloudSyncDirection.upload:
        switch (language) {
          case AppLanguage.en:
            return 'upload';
          case AppLanguage.vi:
            return 'tải lên';
          case AppLanguage.ja:
            return 'upload';
        }
      case CloudSyncDirection.download:
        switch (language) {
          case AppLanguage.en:
            return 'download';
          case AppLanguage.vi:
            return 'tải xuống';
          case AppLanguage.ja:
            return 'download';
        }
    }
  }

  void _showSnackBar(BuildContext? context, String message) {
    if (context == null || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
