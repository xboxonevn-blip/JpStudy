import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              HomeSurface.pageHorizontalPadding,
              16,
              HomeSurface.pageHorizontalPadding,
              96,
            ),
            children: [
              Container(
                decoration: HomeSurface.softPanel(
                  colors: const [Color(0xFFF8FCFF), Color(0xFFF8FAFC)],
                  radius: 28,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(language),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(language),
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              if (!settings.isReady) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(minHeight: 3),
              ],
              const SizedBox(height: 16),
              _SectionCard(
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
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          language.autoBackupLastLabel(
                            MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(settings.lastAutoBackup!),
                          ),
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: controller.cloudSyncLabel(language),
                child: cloudStatusAsync.when(
                  data: (status) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.cloud_sync_outlined),
                        title: Text(controller.cloudSyncLabel(language)),
                        subtitle: Text(
                          controller.cloudSyncStatusSubtitle(
                            context,
                            language,
                            status,
                          ),
                        ),
                      ),
                      Text(
                        controller.cloudSyncCreateHint(language),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: settings.isReady
                                ? () => controller.linkExistingCloudSyncFile(
                                    context,
                                    language,
                                  )
                                : null,
                            icon: const Icon(Icons.folder_open_outlined),
                            label: Text(
                              controller.cloudSyncChooseFileLabel(language),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: settings.isReady
                                ? () => controller.createCloudSyncFile(
                                    context,
                                    language,
                                  )
                                : null,
                            icon: const Icon(Icons.note_add_outlined),
                            label: Text(
                              controller.cloudSyncCreateFileLabel(language),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: settings.isReady && status.isLinked
                                ? () => controller.uploadToCloudFile(
                                    context,
                                    language,
                                  )
                                : null,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: Text(
                              controller.cloudSyncUploadLabel(language),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: settings.isReady && status.isLinked
                                ? () => controller.downloadFromCloudFile(
                                    context,
                                    language,
                                  )
                                : null,
                            icon: const Icon(Icons.cloud_download_outlined),
                            label: Text(
                              controller.cloudSyncDownloadLabel(language),
                            ),
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
                              label: Text(
                                controller.cloudSyncUnlinkLabel(language),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  loading: () =>
                      Text(controller.cloudSyncLoadingLabel(language)),
                  error: (error, stackTrace) =>
                      Text(controller.cloudSyncLoadingLabel(language)),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: _backupTitle(language),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.save_alt_outlined,
                      title: language.backupExportLabel,
                      subtitle: _exportSubtitle(language),
                      onTap: settings.isReady
                          ? () => controller.exportBackup(context, language)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon: Icons.restore_outlined,
                      title: language.backupImportLabel,
                      subtitle: language.backupImportBody,
                      onTap: settings.isReady
                          ? () => controller.importBackup(context, language)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        return 'Data controls';
    }
  }

  String _subtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Auto backup, import/export, and linked sync files live here.';
      case AppLanguage.vi:
        return 'Tự động sao lưu, nhập/xuất và file đồng bộ liên kết nằm ở đây.';
      case AppLanguage.ja:
        return 'Auto backup, import/export, and linked sync files live here.';
    }
  }

  String _backupTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Manual backup';
      case AppLanguage.vi:
        return 'Sao lưu thủ công';
      case AppLanguage.ja:
        return 'Manual backup';
    }
  }

  String _exportSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Create a portable backup file.';
      case AppLanguage.vi:
        return 'Tạo file sao lưu để mang đi.';
      case AppLanguage.ja:
        return 'Create a portable backup file.';
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
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
    return Material(
      color: context.appPalette.base,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.appPalette.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.appPalette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appPalette.ink.withValues(alpha: 0.66),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
