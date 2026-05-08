import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:jpstudy/core/platform_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/auto_cloud_upload_coordinator.dart';
import 'package:jpstudy/core/services/backup_encryption.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/services/cloud_storage_sync_service.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';

final cloudStorageSyncServiceProvider = Provider<CloudStorageSyncService>(
  (ref) => CloudStorageSyncService(),
);

const _prefAutoBackup = 'backup.auto.enabled';
const _prefAutoBackupTime = 'backup.auto.time';
const _prefAutoBackupLast = 'backup.auto.last';
const _prefAutoCloudUpload = AutoCloudUploadCoordinator.enabledPreferenceKey;
const _lastAutoBackupSentinel = Object();

final dataSettingsControllerProvider =
    NotifierProvider<DataSettingsController, DataSettingsState>(
      DataSettingsController.new,
    );

class DataSettingsState {
  const DataSettingsState({
    this.isReady = false,
    this.autoBackupEnabled = false,
    this.autoCloudUploadEnabled = true,
    this.autoBackupTime = const TimeOfDay(hour: 2, minute: 0),
    this.lastAutoBackup,
  });

  final bool isReady;
  final bool autoBackupEnabled;
  final bool autoCloudUploadEnabled;
  final TimeOfDay autoBackupTime;
  final DateTime? lastAutoBackup;

  DataSettingsState copyWith({
    bool? isReady,
    bool? autoBackupEnabled,
    bool? autoCloudUploadEnabled,
    TimeOfDay? autoBackupTime,
    Object? lastAutoBackup = _lastAutoBackupSentinel,
  }) {
    return DataSettingsState(
      isReady: isReady ?? this.isReady,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoCloudUploadEnabled:
          autoCloudUploadEnabled ?? this.autoCloudUploadEnabled,
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
  Future<void>? _initializeFuture;
  bool _disposed = false;

  @override
  DataSettingsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _initializeFuture = null;
      _autoBackupTimer?.cancel();
      _hostContext = null;
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
    final pending = _initializeFuture;
    if (pending != null) {
      await pending;
      return;
    }

    final tracked = refresh().whenComplete(() {
      _initializeFuture = null;
    });
    _initializeFuture = tracked;
    await tracked;
  }

  Future<void> refresh() async {
    final prefs = await _ensurePrefs();
    final autoBackupEnabled = prefs.getBool(_prefAutoBackup) ?? false;
    final autoCloudUploadEnabled = prefs.getBool(_prefAutoCloudUpload) ?? true;
    final autoBackupTime =
        _backupTimeFromPrefs(prefs) ?? const TimeOfDay(hour: 2, minute: 0);
    final lastRaw = prefs.getString(_prefAutoBackupLast);

    if (_disposed) {
      return;
    }
    state = state.copyWith(
      isReady: true,
      autoBackupEnabled: autoBackupEnabled,
      autoCloudUploadEnabled: autoCloudUploadEnabled,
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

  Future<void> setAutoCloudUpload(bool enabled, AppLanguage _) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_prefAutoCloudUpload, enabled);
    state = state.copyWith(autoCloudUploadEnabled: enabled, isReady: true);
  }

  Future<void> exportBackup(
    BuildContext context,
    AppLanguage language, {
    String? passphrase,
  }) async {
    final envelope = await _buildBackupEnvelope(passphrase: passphrase);
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

  Future<void> importBackup(
    BuildContext context,
    AppLanguage language, {
    Future<String?> Function()? passphrasePrompt,
  }) async {
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
      final raw = jsonDecode(content) as Map<String, dynamic>;
      Map<String, dynamic> data;
      if (BackupSyncService.isEnvelopeEncrypted(raw)) {
        if (passphrasePrompt == null) {
          if (context.mounted) {
            _showSnackBar(context, language.backupDecryptionErrorLabel);
          }
          return;
        }
        final entered = await passphrasePrompt();
        if (entered == null || entered.isEmpty || !context.mounted) {
          return;
        }
        try {
          data = await BackupSyncService.tryDecryptEnvelope(raw, entered);
        } on BackupDecryptionException {
          if (!context.mounted) return;
          _showSnackBar(context, language.backupDecryptionErrorLabel);
          return;
        }
      } else {
        data = raw;
      }
      final importPlan = await BackupSyncService.prepareImport(data);
      if (!context.mounted) {
        return;
      }

      if (importPlan.decision == BackupImportDecision.invalidChecksum) {
        _showSnackBar(context, language.backupImportError);
        return;
      }
      if (importPlan.decision == BackupImportDecision.skipOlder) {
        await _handleOlderImport(
          context,
          language,
          payload: importPlan.payload,
          incomingExportedAt: importPlan.incomingExportedAt,
          onApplied: BackupSyncService.markImportApplied,
          successMessage: language.backupImportSuccess,
        );
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
      suggestedName: 'jpstudy_linked_sync.json',
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
    AppLanguage language, {
    String? passphrase,
  }) async {
    final envelope = await _buildBackupEnvelope(passphrase: passphrase);
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
    AppLanguage language, {
    Future<String?> Function()? passphrasePrompt,
  }) async {
    var result = await CloudSyncService.prepareDownload();
    if (!context.mounted) {
      return;
    }

    if (result.decision == CloudSyncDownloadDecision.requiresPassphrase) {
      if (passphrasePrompt == null) {
        _showSnackBar(context, language.backupDecryptionErrorLabel);
        return;
      }
      final entered = await passphrasePrompt();
      if (entered == null || entered.isEmpty || !context.mounted) {
        return;
      }
      result = await CloudSyncService.prepareDownload(passphrase: entered);
      if (!context.mounted) return;
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
        if (result.payload == null) {
          return;
        }
        await _handleOlderImport(
          context,
          language,
          payload: result.payload!,
          incomingExportedAt: result.remoteExportedAt,
          onApplied: CloudSyncService.markDownloadApplied,
          successMessage: cloudSyncDownloadSuccessLabel(language),
        );
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
      case CloudSyncDownloadDecision.requiresPassphrase:
      case CloudSyncDownloadDecision.decryptionFailed:
        _showSnackBar(context, language.backupDecryptionErrorLabel);
        return;
    }
  }

  Future<void> uploadToFirebaseStorage(
    BuildContext context,
    AppLanguage language, {
    String? passphrase,
  }) async {
    final envelope = await _buildBackupEnvelope(passphrase: passphrase);
    final service = ref.read(cloudStorageSyncServiceProvider);
    final result = await service.uploadEnvelope(envelope);
    if (!context.mounted) return;
    final message = switch (result.decision) {
      CloudStorageUploadDecision.uploaded =>
        language.firebaseStorageUploadSuccessLabel,
      CloudStorageUploadDecision.notSignedIn =>
        language.firebaseStorageNotSignedInLabel,
      CloudStorageUploadDecision.writeFailed =>
        language.firebaseStorageUploadErrorLabel,
    };
    _showSnackBar(context, message);
  }

  Future<void> downloadFromFirebaseStorage(
    BuildContext context,
    AppLanguage language, {
    Future<String?> Function()? passphrasePrompt,
  }) async {
    final service = ref.read(cloudStorageSyncServiceProvider);
    var result = await service.prepareDownload();
    if (!context.mounted) return;

    if (result.decision == CloudStorageDownloadDecision.requiresPassphrase) {
      if (passphrasePrompt == null) {
        _showSnackBar(context, language.backupDecryptionErrorLabel);
        return;
      }
      final entered = await passphrasePrompt();
      if (entered == null || entered.isEmpty || !context.mounted) return;
      result = await service.prepareDownload(passphrase: entered);
      if (!context.mounted) return;
    }

    switch (result.decision) {
      case CloudStorageDownloadDecision.apply:
        final confirmed = await _confirmImport(context, language);
        if (!context.mounted || confirmed != true || result.payload == null) {
          return;
        }
        await _applyImportedPayload(
          context,
          language,
          payload: result.payload!,
          incomingExportedAt: result.remoteExportedAt,
          onApplied: BackupSyncService.markImportApplied,
          successMessage: language.firebaseStorageDownloadSuccessLabel,
        );
        return;
      case CloudStorageDownloadDecision.skipOlder:
        if (result.payload == null) {
          return;
        }
        await _handleOlderImport(
          context,
          language,
          payload: result.payload!,
          incomingExportedAt: result.remoteExportedAt,
          onApplied: BackupSyncService.markImportApplied,
          successMessage: language.firebaseStorageDownloadSuccessLabel,
        );
        return;
      case CloudStorageDownloadDecision.notSignedIn:
        _showSnackBar(context, language.firebaseStorageNotSignedInLabel);
        return;
      case CloudStorageDownloadDecision.noRemoteFile:
        _showSnackBar(context, language.firebaseStorageNoRemoteFileLabel);
        return;
      case CloudStorageDownloadDecision.invalidChecksum:
      case CloudStorageDownloadDecision.invalidFormat:
      case CloudStorageDownloadDecision.readFailed:
        _showSnackBar(context, cloudSyncDownloadErrorLabel(language));
        return;
      case CloudStorageDownloadDecision.requiresPassphrase:
      case CloudStorageDownloadDecision.decryptionFailed:
        _showSnackBar(context, language.backupDecryptionErrorLabel);
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
    if (_disposed || _dateKeyFromStored(lastRaw) == todayKey) {
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

      if (_disposed) {
        return;
      }
      state = state.copyWith(lastAutoBackup: timestamp, isReady: true);
      ref.invalidate(backupStatusProvider);
      _showSnackBar(context ?? _hostContext, language.autoBackupSuccessLabel);
    } catch (_) {
      if (_disposed) {
        return;
      }
      _showSnackBar(context ?? _hostContext, language.autoBackupErrorLabel);
    }
  }

  String cloudSyncLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file sync';
      case AppLanguage.vi:
        return 'Đồng bộ qua file liên kết';
      case AppLanguage.ja:
        return 'リンクファイル同期';
    }
  }

  String cloudSyncLoadingLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Loading linked sync status...';
      case AppLanguage.vi:
        return 'Đang tải trạng thái đồng bộ file liên kết...';
      case AppLanguage.ja:
        return 'リンクファイル同期の状態を読み込み中...';
    }
  }

  String cloudSyncNotLinkedLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'No linked file yet.';
      case AppLanguage.vi:
        return 'Chưa có file liên kết.';
      case AppLanguage.ja:
        return 'まだリンク済みファイルはありません。';
    }
  }

  String cloudSyncLinkedLabel(AppLanguage language, String fileName) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file: $fileName';
      case AppLanguage.vi:
        return 'File đã liên kết: $fileName';
      case AppLanguage.ja:
        return 'リンク済みファイル: $fileName';
    }
  }

  String cloudSyncChooseFileLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose file';
      case AppLanguage.vi:
        return 'Chọn file';
      case AppLanguage.ja:
        return 'ファイルを選ぶ';
    }
  }

  String cloudSyncCreateFileLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Create file';
      case AppLanguage.vi:
        return 'Tạo file';
      case AppLanguage.ja:
        return 'ファイルを作成';
    }
  }

  String cloudSyncUploadLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Upload snapshot';
      case AppLanguage.vi:
        return 'Tải snapshot lên';
      case AppLanguage.ja:
        return 'スナップショットをアップロード';
    }
  }

  String cloudSyncDownloadLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Download snapshot';
      case AppLanguage.vi:
        return 'Tải snapshot xuống';
      case AppLanguage.ja:
        return 'スナップショットをダウンロード';
    }
  }

  String cloudSyncUnlinkLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Remove link';
      case AppLanguage.vi:
        return 'Gỡ liên kết';
      case AppLanguage.ja:
        return 'リンクを解除';
    }
  }

  String cloudSyncCreateHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Point every device at the same JSON file inside Dropbox, Drive, Syncthing, or another shared folder.';
      case AppLanguage.vi:
        return 'Hãy trỏ mọi thiết bị tới cùng một file JSON trong Dropbox, Drive, Syncthing hoặc thư mục dùng chung.';
      case AppLanguage.ja:
        return 'すべての端末で、Dropbox・Drive・Syncthing などの共有フォルダ内にある同じJSONファイルを指定してください。';
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
        return '最終ファイル同期: $dateText${directionLabel.isEmpty ? '' : ' ($directionLabel)'}';
    }
  }

  String cloudSyncLinkedSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file updated.';
      case AppLanguage.vi:
        return 'Đã cập nhật file liên kết.';
      case AppLanguage.ja:
        return 'リンク済みファイルを更新しました。';
    }
  }

  String cloudSyncUnlinkedSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file removed.';
      case AppLanguage.vi:
        return 'Đã gỡ file liên kết.';
      case AppLanguage.ja:
        return 'リンク済みファイルを削除しました。';
    }
  }

  String cloudSyncLinkRequiredLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Choose or create a linked file first.';
      case AppLanguage.vi:
        return 'Hãy chọn hoặc tạo file liên kết trước.';
      case AppLanguage.ja:
        return '先にリンク済みファイルを選ぶか作成してください。';
    }
  }

  String cloudSyncUploadSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Uploaded backup to linked file.';
      case AppLanguage.vi:
        return 'Đã tải bản sao lưu lên file liên kết.';
      case AppLanguage.ja:
        return 'バックアップをリンク済みファイルへアップロードしました。';
    }
  }

  String cloudSyncUploadErrorLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Failed to write linked file.';
      case AppLanguage.vi:
        return 'Không ghi được file liên kết.';
      case AppLanguage.ja:
        return 'リンク済みファイルへ書き込めませんでした。';
    }
  }

  String cloudSyncDownloadSuccessLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Downloaded backup from linked file.';
      case AppLanguage.vi:
        return 'Đã tải bản sao lưu từ file liên kết.';
      case AppLanguage.ja:
        return 'リンク済みファイルからバックアップを取得しました。';
    }
  }

  String cloudSyncDownloadErrorLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file is invalid or unreadable.';
      case AppLanguage.vi:
        return 'File liên kết không hợp lệ hoặc không đọc được.';
      case AppLanguage.ja:
        return 'リンク済みファイルが無効か、読み取れません。';
    }
  }

  String cloudSyncMissingRemoteLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Linked file does not exist yet.';
      case AppLanguage.vi:
        return 'File liên kết chưa tồn tại.';
      case AppLanguage.ja:
        return 'リンク済みファイルはまだ存在しません。';
    }
  }

  String cloudSyncSkipOlderLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Skipped because the incoming file is older than local data.';
      case AppLanguage.vi:
        return 'Bỏ qua vì file sắp nhập cũ hơn dữ liệu hiện tại.';
      case AppLanguage.ja:
        return '受信ファイルがローカルデータより古いためスキップしました。';
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
    if (_disposed || !state.autoBackupEnabled) {
      return;
    }

    final now = DateTime.now();
    final next = _nextReminderTime(now, state.autoBackupTime);
    _autoBackupTimer = Timer(next.difference(now), () async {
      if (_disposed) {
        return;
      }
      await performAutoBackup(ref.read(appLanguageProvider));
      if (_disposed) {
        return;
      }
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

  Future<Map<String, dynamic>> _buildBackupEnvelope({
    String? passphrase,
  }) async {
    final repo = ref.read(lessonRepositoryProvider);
    final data = await repo.exportBackup();
    return BackupSyncService.buildExportEnvelope(data, passphrase: passphrase);
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

  Future<void> _handleOlderImport(
    BuildContext context,
    AppLanguage language, {
    required Map<String, dynamic> payload,
    required DateTime? incomingExportedAt,
    required Future<void> Function(DateTime? incomingExportedAt) onApplied,
    required String successMessage,
  }) async {
    final lastAppliedAt = await BackupSyncService.getLastAppliedAt();
    if (!context.mounted) {
      return;
    }
    final confirmed = await _confirmOlderImport(
      context,
      language,
      incomingExportedAt: incomingExportedAt,
      lastAppliedAt: lastAppliedAt,
    );
    if (!context.mounted || confirmed != true) {
      return;
    }
    final applied = await _applyImportedPayload(
      context,
      language,
      payload: payload,
      incomingExportedAt: incomingExportedAt,
      onApplied: onApplied,
      successMessage: successMessage,
      showSuccessMessage: false,
    );
    if (!context.mounted || !applied) {
      return;
    }
    _showSnackBar(context, language.olderBackupAppliedLabel);
  }

  Future<bool> _confirmOlderImport(
    BuildContext context,
    AppLanguage language, {
    required DateTime? incomingExportedAt,
    required DateTime? lastAppliedAt,
  }) async {
    final incoming = _formatImportTimestamp(
      context,
      language,
      incomingExportedAt,
    );
    final current = _formatImportTimestamp(context, language, lastAppliedAt);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(language.olderBackupTitle),
        content: Text(
          language.olderBackupBody(incoming: incoming, current: current),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.olderBackupApplyLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  String _formatImportTimestamp(
    BuildContext context,
    AppLanguage language,
    DateTime? timestamp,
  ) {
    if (timestamp == null) {
      return language.unknownTimestampLabel;
    }
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(timestamp);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(timestamp),
    );
    return '$date $time';
  }

  Future<bool> _applyImportedPayload(
    BuildContext context,
    AppLanguage language, {
    required Map<String, dynamic> payload,
    required DateTime? incomingExportedAt,
    required Future<void> Function(DateTime? incomingExportedAt) onApplied,
    required String successMessage,
    bool showSuccessMessage = true,
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
        return true;
      }
      if (showSuccessMessage) {
        _showSnackBar(context, successMessage);
      }
      return true;
    } catch (_) {
      if (!context.mounted) {
        return false;
      }
      _showSnackBar(context, language.backupImportError);
      return false;
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
