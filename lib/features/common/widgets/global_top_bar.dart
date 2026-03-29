import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

class GlobalTopBar extends ConsumerWidget {
  const GlobalTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final currentLang = ref.watch(appLanguageProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < AppBreakpoints.tablet;
        final horizontalPadding = compact ? 12.0 : AppSpacing.lg;
        final controlGap = compact ? 8.0 : 16.0;
        final showMascot = constraints.maxWidth >= 420;

        return Container(
          height: compact ? 56 : 60,
          decoration: BoxDecoration(
            color: palette.bg,
            border: Border(bottom: BorderSide(color: palette.outline)),
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 6 : 8,
                          vertical: compact ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '漢字',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: compact ? 14 : 16,
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 8),
                      Flexible(
                        child: Text(
                          'JP Study',
                          overflow: TextOverflow.ellipsis,
                          style: (compact
                                  ? Theme.of(context).textTheme.titleMedium
                                  : Theme.of(context).textTheme.titleLarge)
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: palette.ink,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ),
                      if (showMascot) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.cruelty_free,
                          color: palette.ink,
                          size: compact ? 20 : 24,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: compact ? 8 : 12),
              _LanguagePicker(currentLang: currentLang, compact: compact),
              SizedBox(width: controlGap),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                color: palette.ink,
                tooltip: _notificationsTooltip(currentLang),
                visualDensity:
                    compact ? VisualDensity.compact : VisualDensity.standard,
                onPressed: () {},
              ),
              SizedBox(width: controlGap),
              const _UserMenu(),
            ],
          ),
        );
      },
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.currentLang, required this.compact});

  final AppLanguage currentLang;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;

    Widget flagIcon(AppLanguage lang) {
      switch (lang) {
        case AppLanguage.vi:
          return const Text('🇻🇳', style: TextStyle(fontSize: 16));
        case AppLanguage.en:
          return const Text('🇺🇸', style: TextStyle(fontSize: 16));
        case AppLanguage.ja:
          return const Text('🇯🇵', style: TextStyle(fontSize: 16));
      }
    }

    return PopupMenuButton<AppLanguage>(
      position: PopupMenuPosition.under,
      color: palette.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: _languageTooltip(currentLang),
      onSelected: (lang) => ref.read(appLanguageProvider.notifier).state = lang,
      itemBuilder: (context) => AppLanguage.values.map((lang) {
        return PopupMenuItem<AppLanguage>(
          value: lang,
          child: Row(
            children: [
              flagIcon(lang),
              const SizedBox(width: 12),
              Text(
                lang.label,
                style: TextStyle(
                  color: palette.ink,
                  fontWeight: currentLang == lang
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            flagIcon(currentLang),
            SizedBox(width: compact ? 4 : 6),
            Text(
              currentLang.shortCode,
              style: TextStyle(
                color: palette.ink,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserMenu extends StatelessWidget {
  const _UserMenu();

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      color: palette.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tooltip: _profileTooltip(Localizations.localeOf(context).languageCode),
      offset: const Offset(0, 8),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoài Chung Lu Nguyen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: palette.ink,
                  fontSize: 16,
                ),
              ),
              Text(
                'chung.phukiengiabuon@gmail.com',
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: palette.outlineSoft),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'premium',
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: palette.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _premiumMenuLabel(Localizations.localeOf(context).languageCode),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'invite',
          child: Row(
            children: [
              Icon(Icons.people_outline_rounded, color: palette.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _inviteMenuLabel(Localizations.localeOf(context).languageCode),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.ink),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: palette.ink.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _settingsMenuLabel(Localizations.localeOf(context).languageCode),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.ink),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: palette.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _logoutMenuLabel(Localizations.localeOf(context).languageCode),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.error),
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'premium') context.push('/premium');
        if (val == 'settings') context.go('/me');
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.purple,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'H',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

String _notificationsTooltip(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Notifications',
      AppLanguage.vi => 'Thông báo',
      AppLanguage.ja => '通知',
    };

String _languageTooltip(AppLanguage language) => switch (language) {
      AppLanguage.en => 'Choose language',
      AppLanguage.vi => 'Chọn ngôn ngữ',
      AppLanguage.ja => '言語を選択',
    };

String _profileTooltip(String languageCode) => switch (languageCode) {
      'en' => 'Profile',
      'ja' => 'プロフィール',
      _ => 'Hồ sơ',
    };

String _premiumMenuLabel(String languageCode) => switch (languageCode) {
      'en' => 'Upgrade to Premium',
      'ja' => 'Premiumにアップグレード',
      _ => 'Nâng cấp Premium',
    };

String _inviteMenuLabel(String languageCode) => switch (languageCode) {
      'en' => 'Invite friends',
      'ja' => '友達を招待',
      _ => 'Giới thiệu bạn bè',
    };

String _settingsMenuLabel(String languageCode) => switch (languageCode) {
      'en' => 'Settings',
      'ja' => '設定',
      _ => 'Cài đặt',
    };

String _logoutMenuLabel(String languageCode) => switch (languageCode) {
      'en' => 'Log out',
      'ja' => 'ログアウト',
      _ => 'Đăng xuất',
    };
