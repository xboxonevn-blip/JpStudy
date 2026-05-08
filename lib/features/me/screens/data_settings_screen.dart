import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';

import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';

class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(dataSettingsControllerProvider.notifier).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final controller = ref.read(dataSettingsControllerProvider.notifier);
    final settings = ref.watch(dataSettingsControllerProvider);
    final cloudStatusAsync = ref.watch(cloudSyncStatusProvider);
    final introCard = AppFeatureCard(
      icon: Icons.storage_rounded,
      title: _title(language),
      subtitle: _subtitle(language),
      status: AppStatusChip(
        label: settings.autoBackupEnabled
            ? switch (language) {
                AppLanguage.en => 'Auto backup on',
                AppLanguage.vi => 'Đã bật tự động',
                AppLanguage.ja => '自動バックアップON',
              }
            : switch (language) {
                AppLanguage.en => 'Manual only',
                AppLanguage.vi => 'Thủ công',
                AppLanguage.ja => '手動のみ',
              },
        tone: settings.autoBackupEnabled
            ? AppStatusTone.success
            : AppStatusTone.neutral,
      ),
    );
    final autoBackupSection = _SectionCard(
      title: language.autoBackupLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: settings.autoBackupEnabled,
            onChanged: settings.isReady
                ? (value) => controller.setAutoBackup(value, language)
                : null,
            contentPadding: EdgeInsets.zero,
            title: Text(language.autoBackupLabel),
            subtitle: Text(language.autoBackupHint),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_outlined),
            title: Text(language.autoBackupTimeLabel),
            subtitle: Text(_formatTime(settings.autoBackupTime)),
            onTap: !settings.autoBackupEnabled || !settings.isReady
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.autoBackupTime,
                    );
                    if (picked != null) {
                      await controller.setAutoBackupTime(picked);
                    }
                  },
          ),
          if (settings.lastAutoBackup != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                language.autoBackupLastLabel(
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(settings.lastAutoBackup!),
                ),
                style: TextStyle(
                  color: context.appPalette.ink.withValues(alpha: 0.64),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
    final cloudSyncSection = _SectionCard(
      title: controller.cloudSyncLabel(language),
      child: cloudStatusAsync.when(
        data: (status) {
          final recommendation = _linkedSyncRecommendation(language, status);
          final linkedFileValue = status.isLinked
              ? status.target!.displayName
              : _notLinkedValue(language);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LinkedSyncNextStepCard(
                language: language,
                recommendation: recommendation,
                enabled: settings.isReady,
                onTap: settings.isReady
                    ? () => _runLinkedSyncAction(
                        recommendation.action,
                        controller: controller,
                        language: language,
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              _LinkedSyncGuideCard(
                language: language,
                status: status,
                fileHint: controller.cloudSyncCreateHint(language),
              ),
              const SizedBox(height: AppSpacing.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 760 ? 2 : 1;
                  final itemWidth =
                      (constraints.maxWidth - ((columns - 1) * AppSpacing.md)) /
                      columns;
                  return Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _LinkedSyncStatCard(
                          icon: Icons.link_rounded,
                          title: _linkedFileLabel(language),
                          value: linkedFileValue,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _LinkedSyncStatCard(
                          icon: Icons.history_rounded,
                          title: _lastSyncLabel(language),
                          value: _formatLinkedSyncMoment(
                            language,
                            timestamp: status.lastSyncedAt,
                            direction: status.lastDirection,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _LinkedSyncStatCard(
                          icon: Icons.inventory_2_outlined,
                          title: _snapshotLabel(language),
                          value: _formatRemoteSnapshot(
                            language,
                            status.lastRemoteExportedAt,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _LinkedSyncStatCard(
                          icon: Icons.cloud_done_outlined,
                          title: _syncModelLabel(language),
                          value: _fileBasedModelValue(language),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: settings.isReady
                        ? () => controller.linkExistingCloudSyncFile(
                            context,
                            language,
                          )
                        : null,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: Text(controller.cloudSyncChooseFileLabel(language)),
                  ),
                  OutlinedButton.icon(
                    onPressed: settings.isReady
                        ? () =>
                              controller.createCloudSyncFile(context, language)
                        : null,
                    icon: const Icon(Icons.note_add_outlined),
                    label: Text(controller.cloudSyncCreateFileLabel(language)),
                  ),
                  FilledButton.icon(
                    onPressed: settings.isReady && status.isLinked
                        ? () => _runUpload(
                            controller: controller,
                            language: language,
                          )
                        : null,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(controller.cloudSyncUploadLabel(language)),
                  ),
                  OutlinedButton.icon(
                    onPressed: settings.isReady && status.isLinked
                        ? () => _runDownload(
                            controller: controller,
                            language: language,
                          )
                        : null,
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: Text(controller.cloudSyncDownloadLabel(language)),
                  ),
                  if (status.isLinked)
                    OutlinedButton.icon(
                      onPressed: settings.isReady
                          ? () => controller.unlinkCloudSyncFile(
                              context,
                              language,
                            )
                          : null,
                      icon: const Icon(Icons.link_off_outlined),
                      label: Text(controller.cloudSyncUnlinkLabel(language)),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => Text(controller.cloudSyncLoadingLabel(language)),
        error: (error, stackTrace) =>
            Text(controller.cloudSyncLoadingLabel(language)),
      ),
    );
    final manualBackupSection = _SectionCard(
      title: _backupTitle(language),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.save_alt_outlined,
            title: language.backupExportLabel,
            subtitle: _exportSubtitle(language),
            onTap: settings.isReady
                ? () => _runExport(controller, language)
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionTile(
            icon: Icons.restore_outlined,
            title: language.backupImportLabel,
            subtitle: language.backupImportBody,
            onTap: settings.isReady
                ? () => _runImport(controller, language)
                : null,
          ),
        ],
      ),
    );
    final authState = ref.watch(authStateProvider);
    final user = authState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final accountSyncSection = _SectionCard(
      title: language.firebaseStorageSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user == null
                ? language.firebaseStorageNotSignedInLabel
                : language.firebaseStorageSectionSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          if (user != null) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: settings.isReady
                      ? () => _runFirebaseUpload(
                          controller: controller,
                          language: language,
                        )
                      : null,
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: Text(language.firebaseStorageUploadLabel),
                ),
                OutlinedButton.icon(
                  onPressed: settings.isReady
                      ? () => _runFirebaseDownload(
                          controller: controller,
                          language: language,
                        )
                      : null,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: Text(language.firebaseStorageDownloadLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useDesktopSplit =
                constraints.maxWidth >= AppBreakpoints.desktop;

            if (!useDesktopSplit) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  introCard,
                  if (!settings.isReady) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  autoBackupSection,
                  const SizedBox(height: AppSpacing.lg),
                  accountSyncSection,
                  const SizedBox(height: AppSpacing.lg),
                  cloudSyncSection,
                  const SizedBox(height: AppSpacing.lg),
                  manualBackupSection,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                introCard,
                if (!settings.isReady) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LinearProgressIndicator(minHeight: 3),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          autoBackupSection,
                          const SizedBox(height: AppSpacing.lg),
                          accountSyncSection,
                          const SizedBox(height: AppSpacing.lg),
                          manualBackupSection,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 6, child: cloudSyncSection),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Data controls';
      case AppLanguage.vi:
        return 'Dữ liệu và sao lưu';
      case AppLanguage.ja:
        return 'データ管理';
    }
  }

  String _subtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Auto backup, portable backups, and linked file sync live here.';
      case AppLanguage.vi:
        return 'Tự động sao lưu, backup mang đi và đồng bộ qua file liên kết nằm ở đây.';
      case AppLanguage.ja:
        return '自動バックアップ、持ち運び用バックアップ、リンクファイル同期をここで管理します。';
    }
  }

  String _backupTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Manual backup';
      case AppLanguage.vi:
        return 'Sao lưu thủ công';
      case AppLanguage.ja:
        return '手動バックアップ';
    }
  }

  String _exportSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Create a portable backup file.';
      case AppLanguage.vi:
        return 'Tạo file sao lưu để mang đi.';
      case AppLanguage.ja:
        return '持ち運べるバックアップファイルを作成します。';
    }
  }

  Future<void> _runLinkedSyncAction(
    _LinkedSyncPrimaryAction action, {
    required DataSettingsController controller,
    required AppLanguage language,
  }) async {
    switch (action) {
      case _LinkedSyncPrimaryAction.create:
        await controller.createCloudSyncFile(context, language);
        return;
      case _LinkedSyncPrimaryAction.choose:
        await controller.linkExistingCloudSyncFile(context, language);
        return;
      case _LinkedSyncPrimaryAction.upload:
        await _runUpload(controller: controller, language: language);
        return;
      case _LinkedSyncPrimaryAction.download:
        await _runDownload(controller: controller, language: language);
        return;
    }
  }

  Future<void> _runUpload({
    required DataSettingsController controller,
    required AppLanguage language,
  }) async {
    final choice = await _promptExportEncryption(language);
    if (!mounted || choice.cancelled) return;
    await controller.uploadToCloudFile(
      context,
      language,
      passphrase: choice.passphrase,
    );
  }

  Future<void> _runDownload({
    required DataSettingsController controller,
    required AppLanguage language,
  }) async {
    await controller.downloadFromCloudFile(
      context,
      language,
      passphrasePrompt: () => _promptImportPassphrase(language),
    );
  }

  Future<void> _runFirebaseUpload({
    required DataSettingsController controller,
    required AppLanguage language,
  }) async {
    final choice = await _promptExportEncryption(language);
    if (!mounted || choice.cancelled) return;
    await controller.uploadToFirebaseStorage(
      context,
      language,
      passphrase: choice.passphrase,
    );
  }

  Future<void> _runFirebaseDownload({
    required DataSettingsController controller,
    required AppLanguage language,
  }) async {
    await controller.downloadFromFirebaseStorage(
      context,
      language,
      passphrasePrompt: () => _promptImportPassphrase(language),
    );
  }

  Future<void> _runExport(
    DataSettingsController controller,
    AppLanguage language,
  ) async {
    final choice = await _promptExportEncryption(language);
    if (!mounted || choice.cancelled) return;
    await controller.exportBackup(
      context,
      language,
      passphrase: choice.passphrase,
    );
  }

  Future<void> _runImport(
    DataSettingsController controller,
    AppLanguage language,
  ) async {
    await controller.importBackup(
      context,
      language,
      passphrasePrompt: () => _promptImportPassphrase(language),
    );
  }

  Future<_ExportEncryptionChoice> _promptExportEncryption(
    AppLanguage language,
  ) async {
    final mode = await showDialog<_ExportEncryptionMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.encryptBackupPromptTitle),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_ExportEncryptionMode.cancel),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_ExportEncryptionMode.plain),
            child: Text(language.encryptNoLabel),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(_ExportEncryptionMode.encrypt),
            child: Text(language.encryptYesLabel),
          ),
        ],
      ),
    );
    if (!mounted) return const _ExportEncryptionChoice.cancelled();
    if (mode == null || mode == _ExportEncryptionMode.cancel) {
      return const _ExportEncryptionChoice.cancelled();
    }
    if (mode == _ExportEncryptionMode.plain) {
      return const _ExportEncryptionChoice.plain();
    }
    final passphrase = await _promptNewPassphrase(language);
    if (passphrase == null) {
      return const _ExportEncryptionChoice.cancelled();
    }
    return _ExportEncryptionChoice.encrypted(passphrase);
  }

  Future<String?> _promptNewPassphrase(AppLanguage language) async {
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;
    try {
      while (true) {
        final entered = await showDialog<String?>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  title: Text(language.passphraseLabel),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: passController,
                        obscureText: true,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: language.passphraseLabel,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: confirmController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: language.passphraseConfirmLabel,
                          errorText: errorText,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: Text(
                        MaterialLocalizations.of(context).cancelButtonLabel,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (passController.text.isEmpty) {
                          setStateDialog(() {
                            errorText = language.passphraseRequiredLabel;
                          });
                          return;
                        }
                        if (passController.text != confirmController.text) {
                          setStateDialog(() {
                            errorText = language.passphraseMismatchLabel;
                          });
                          return;
                        }
                        Navigator.of(context).pop(passController.text);
                      },
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
        if (!mounted) return null;
        return entered;
      }
    } finally {
      passController.dispose();
      confirmController.dispose();
    }
  }

  Future<String?> _promptImportPassphrase(AppLanguage language) async {
    final controller = TextEditingController();
    try {
      final entered = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(language.passphraseRequiredLabel),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: language.passphraseLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        ),
      );
      if (!mounted) return null;
      return entered != null && entered.isEmpty ? null : entered;
    } finally {
      controller.dispose();
    }
  }

  _LinkedSyncRecommendation _linkedSyncRecommendation(
    AppLanguage language,
    CloudSyncStatus status,
  ) {
    if (!status.isLinked) {
      return _LinkedSyncRecommendation(
        title: _nextStepTitle(language),
        headline: _linkRecommendationHeadline(language),
        subtitle: _linkRecommendationSubtitle(language),
        actionLabel: switch (language) {
          AppLanguage.en => 'Create shared file',
          AppLanguage.vi => 'Tạo file dùng chung',
          AppLanguage.ja => '共有ファイルを作成',
        },
        icon: Icons.note_add_outlined,
        tone: AppStatusTone.warning,
        action: _LinkedSyncPrimaryAction.create,
      );
    }

    if (status.lastRemoteExportedAt == null) {
      return _LinkedSyncRecommendation(
        title: _nextStepTitle(language),
        headline: _seedRecommendationHeadline(language),
        subtitle: _seedRecommendationSubtitle(language),
        actionLabel: switch (language) {
          AppLanguage.en => 'Upload first snapshot',
          AppLanguage.vi => 'Tải snapshot đầu tiên',
          AppLanguage.ja => '最初のスナップショットをアップロード',
        },
        icon: Icons.cloud_upload_outlined,
        tone: AppStatusTone.primary,
        action: _LinkedSyncPrimaryAction.upload,
      );
    }

    if (status.lastDirection == CloudSyncDirection.download) {
      return _LinkedSyncRecommendation(
        title: _nextStepTitle(language),
        headline: _uploadAgainHeadline(language),
        subtitle: _uploadAgainSubtitle(language),
        actionLabel: switch (language) {
          AppLanguage.en => 'Upload latest snapshot',
          AppLanguage.vi => 'Tải snapshot mới nhất',
          AppLanguage.ja => '最新スナップショットをアップロード',
        },
        icon: Icons.cloud_upload_outlined,
        tone: AppStatusTone.success,
        action: _LinkedSyncPrimaryAction.upload,
      );
    }

    return _LinkedSyncRecommendation(
      title: _nextStepTitle(language),
      headline: _downloadCheckHeadline(language),
      subtitle: _downloadCheckSubtitle(language),
      actionLabel: switch (language) {
        AppLanguage.en => 'Download shared snapshot',
        AppLanguage.vi => 'Tải snapshot dùng chung',
        AppLanguage.ja => '共有スナップショットをダウンロード',
      },
      icon: Icons.cloud_download_outlined,
      tone: AppStatusTone.primary,
      action: _LinkedSyncPrimaryAction.download,
    );
  }

  String _formatLinkedSyncMoment(
    AppLanguage language, {
    required DateTime? timestamp,
    required CloudSyncDirection? direction,
  }) {
    if (timestamp == null) {
      return _notYetValue(language);
    }
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(timestamp);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(timestamp),
    );
    final directionLabel = switch (direction) {
      CloudSyncDirection.upload => switch (language) {
        AppLanguage.en => 'upload',
        AppLanguage.vi => 'tải lên',
        AppLanguage.ja => 'アップロード',
      },
      CloudSyncDirection.download => switch (language) {
        AppLanguage.en => 'download',
        AppLanguage.vi => 'tải xuống',
        AppLanguage.ja => 'ダウンロード',
      },
      null => '',
    };
    if (directionLabel.isEmpty) {
      return '$date $time';
    }
    return '$date $time ($directionLabel)';
  }

  String _formatRemoteSnapshot(AppLanguage language, DateTime? timestamp) {
    if (timestamp == null) {
      return _notYetValue(language);
    }
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(timestamp);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(timestamp),
    );
    return '$date $time';
  }

  String _nextStepTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Recommended next step',
    AppLanguage.vi => 'Bước nên làm tiếp',
    AppLanguage.ja => '次にやるべきこと',
  };

  String _linkRecommendationHeadline(AppLanguage language) =>
      switch (language) {
        AppLanguage.en => 'Create or choose one shared JSON file first.',
        AppLanguage.vi => 'Hãy tạo hoặc chọn trước một file JSON dùng chung.',
        AppLanguage.ja => 'まず共有するJSONファイルを1つ作成または選択してください。',
      };

  String _linkRecommendationSubtitle(
    AppLanguage language,
  ) => switch (language) {
    AppLanguage.en =>
      'This is file-based sync, not account-based cloud sync. Every device should point to the same file.',
    AppLanguage.vi =>
      'Đây là đồng bộ qua file, không phải cloud sync theo tài khoản. Mọi thiết bị nên trỏ vào cùng một file.',
    AppLanguage.ja => 'これはアカウント同期ではなくファイル同期です。すべての端末で同じファイルを指定してください。',
  };

  String _seedRecommendationHeadline(AppLanguage language) =>
      switch (language) {
        AppLanguage.en => 'Seed the linked file from this device.',
        AppLanguage.vi =>
          'Hãy gieo dữ liệu đầu tiên từ thiết bị này vào file liên kết.',
        AppLanguage.ja => 'この端末からリンクファイルへ最初のデータを書き込みましょう。',
      };

  String _seedRecommendationSubtitle(
    AppLanguage language,
  ) => switch (language) {
    AppLanguage.en =>
      'Upload one snapshot so the shared file contains real data before another device downloads it.',
    AppLanguage.vi =>
      'Tải lên một snapshot để file dùng chung có dữ liệu thật trước khi thiết bị khác tải xuống.',
    AppLanguage.ja => '他の端末がダウンロードする前に、共有ファイルへ実データ入りのスナップショットを1回アップロードしてください。',
  };

  String _uploadAgainHeadline(AppLanguage language) => switch (language) {
    AppLanguage.en => 'This device has already pulled from the shared file.',
    AppLanguage.vi => 'Thiết bị này đã từng kéo dữ liệu từ file dùng chung.',
    AppLanguage.ja => 'この端末はすでに共有ファイルから取り込み済みです。',
  };

  String _uploadAgainSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'After new study progress on this device, upload again to refresh the shared snapshot.',
    AppLanguage.vi =>
      'Sau khi có tiến độ học mới trên thiết bị này, hãy tải lên lại để làm mới snapshot dùng chung.',
    AppLanguage.ja => 'この端末で新しい学習進捗が出たら、もう一度アップロードして共有スナップショットを更新してください。',
  };

  String _downloadCheckHeadline(AppLanguage language) => switch (language) {
    AppLanguage.en => 'A shared snapshot is already in place.',
    AppLanguage.vi => 'Một snapshot dùng chung đã sẵn sàng.',
    AppLanguage.ja => '共有スナップショットはすでに用意されています。',
  };

  String _downloadCheckSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Use download when this device needs the newest shared state before you overwrite it with another upload.',
    AppLanguage.vi =>
      'Hãy tải xuống khi thiết bị này cần trạng thái dùng chung mới nhất trước khi bạn ghi đè bằng một lần tải lên khác.',
    AppLanguage.ja => '別のアップロードで上書きする前に、この端末で最新の共有状態が必要ならダウンロードを使ってください。',
  };

  String _linkedFileLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Linked file',
    AppLanguage.vi => 'File liên kết',
    AppLanguage.ja => 'リンク済みファイル',
  };

  String _lastSyncLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Last file sync',
    AppLanguage.vi => 'Lần đồng bộ file cuối',
    AppLanguage.ja => '最終ファイル同期',
  };

  String _snapshotLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Last shared snapshot',
    AppLanguage.vi => 'Snapshot dùng chung mới nhất',
    AppLanguage.ja => '最新の共有スナップショット',
  };

  String _syncModelLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Sync model',
    AppLanguage.vi => 'Kiểu đồng bộ',
    AppLanguage.ja => '同期モデル',
  };

  String _fileBasedModelValue(AppLanguage language) => switch (language) {
    AppLanguage.en => 'File-based, manual push/pull',
    AppLanguage.vi => 'Qua file, tải lên/tải xuống thủ công',
    AppLanguage.ja => 'ファイルベース・手動プッシュ/プル',
  };

  String _notLinkedValue(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Not linked yet',
    AppLanguage.vi => 'Chưa liên kết',
    AppLanguage.ja => '未リンク',
  };

  String _notYetValue(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Not yet',
    AppLanguage.vi => 'Chưa có',
    AppLanguage.ja => 'まだありません',
  };
}

enum _LinkedSyncPrimaryAction { create, choose, upload, download }

enum _ExportEncryptionMode { plain, encrypt, cancel }

class _ExportEncryptionChoice {
  const _ExportEncryptionChoice.plain() : passphrase = null, cancelled = false;
  const _ExportEncryptionChoice.encrypted(String this.passphrase)
    : cancelled = false;
  const _ExportEncryptionChoice.cancelled()
    : passphrase = null,
      cancelled = true;

  final String? passphrase;
  final bool cancelled;
}

class _LinkedSyncRecommendation {
  const _LinkedSyncRecommendation({
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.tone,
    required this.action,
  });

  final String title;
  final String headline;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final AppStatusTone tone;
  final _LinkedSyncPrimaryAction action;
}

class _LinkedSyncNextStepCard extends StatelessWidget {
  const _LinkedSyncNextStepCard({
    required this.language,
    required this.recommendation,
    required this.enabled,
    required this.onTap,
  });

  final AppLanguage language;
  final _LinkedSyncRecommendation recommendation;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = switch (recommendation.tone) {
      AppStatusTone.primary => palette.primary,
      AppStatusTone.success => palette.success,
      AppStatusTone.warning => palette.warning,
      AppStatusTone.neutral => palette.ink.withValues(alpha: 0.72),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.12), palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title.toUpperCase(),
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recommendation.headline,
                      key: const ValueKey('linked_sync_headline'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.subtitle,
                      style: TextStyle(
                        color: palette.ink.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(recommendation.icon, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: enabled ? onTap : null,
            icon: Icon(recommendation.icon),
            label: Text(recommendation.actionLabel),
          ),
        ],
      ),
    );
  }
}

class _LinkedSyncGuideCard extends StatelessWidget {
  const _LinkedSyncGuideCard({
    required this.language,
    required this.status,
    required this.fileHint,
  });

  final AppLanguage language;
  final CloudSyncStatus status;
  final String fileHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appPalette.base,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appPalette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _guideTitle(language),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            _guideSubtitle(language),
            style: TextStyle(
              color: context.appPalette.ink.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          _GuideStep(
            done: status.isLinked,
            index: '1',
            text: _guideStepOne(language),
          ),
          const SizedBox(height: 8),
          _GuideStep(
            done: status.lastRemoteExportedAt != null,
            index: '2',
            text: _guideStepTwo(language),
          ),
          const SizedBox(height: 8),
          _GuideStep(
            done: status.lastDirection == CloudSyncDirection.download,
            index: '3',
            text: _guideStepThree(language),
          ),
          const SizedBox(height: 10),
          Text(
            fileHint,
            style: TextStyle(
              fontSize: 12,
              color: context.appPalette.ink.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _guideTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'How linked file sync works',
    AppLanguage.vi => 'Cách đồng bộ qua file liên kết hoạt động',
    AppLanguage.ja => 'リンクファイル同期の流れ',
  };

  String _guideSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'This syncs through one shared JSON file. It does not sign into a cloud account for you.',
    AppLanguage.vi =>
      'Tính năng này đồng bộ qua một file JSON dùng chung. Nó không tự đăng nhập vào tài khoản cloud thay bạn.',
    AppLanguage.ja => 'この機能は共有JSONファイルを通じて同期します。クラウドアカウントへのログイン同期ではありません。',
  };

  String _guideStepOne(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Choose or create one shared JSON file for all your devices.',
    AppLanguage.vi =>
      'Chọn hoặc tạo một file JSON dùng chung cho mọi thiết bị của bạn.',
    AppLanguage.ja => 'すべての端末で使う共有JSONファイルを1つ選ぶか作成します。',
  };

  String _guideStepTwo(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Upload from one device first so the file has a real backup snapshot.',
    AppLanguage.vi =>
      'Trước tiên hãy tải lên từ một thiết bị để file có snapshot backup thật.',
    AppLanguage.ja => 'まず1台の端末からアップロードして、ファイルに実データ入りのスナップショットを作ります。',
  };

  String _guideStepThree(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'On another device, choose the same file and download from it.',
    AppLanguage.vi =>
      'Trên thiết bị khác, hãy chọn đúng file đó rồi tải xuống từ nó.',
    AppLanguage.ja => '別の端末では同じファイルを選び、そこからダウンロードします。',
  };
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.done,
    required this.index,
    required this.text,
  });

  final bool done;
  final String index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = done ? context.appPalette.success : context.appPalette.ink;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done
                ? color.withValues(alpha: 0.14)
                : context.appPalette.outlineSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 16, color: color)
              : Text(
                  index,
                  style: TextStyle(fontWeight: FontWeight.w900, color: color),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyle(
                color: context.appPalette.ink.withValues(alpha: 0.76),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkedSyncStatCard extends StatelessWidget {
  const _LinkedSyncStatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appPalette.base,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appPalette.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.appPalette.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: context.appPalette.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appPalette.ink.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.62 : 1,
      child: AppCompactRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }
}
