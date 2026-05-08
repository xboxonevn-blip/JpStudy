import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/auth/widgets/login_dialog.dart';

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
                  onTap: () => context.openHome(),
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
                          gradient: LinearGradient(
                            colors: [palette.primary, palette.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.14),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          '漢字',
                          style: TextStyle(
                            color: palette.bg,
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
                          style:
                              (compact
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
                          color: palette.secondary,
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
              Container(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  color: palette.elevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: palette.outlineSoft),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: palette.ink,
                  tooltip: _notificationsTooltip(currentLang),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: compact ? 36 : 40,
                    height: compact ? 36 : 40,
                  ),
                  visualDensity: compact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: controlGap),
              _UserMenu(language: currentLang, compact: compact),
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
          color: palette.elevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: palette.outlineSoft),
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

class _UserMenu extends ConsumerWidget {
  const _UserMenu({required this.language, required this.compact});

  final AppLanguage language;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email ?? _profileName(language));
    final subtitle = user == null
        ? _profileSubtitle(language)
        : (user.email ?? language.signedInAsLabel);

    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      color: palette.elevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tooltip: _profileTooltip(language),
      offset: const Offset(0, 8),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: palette.ink,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
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
                  _premiumMenuLabel(language),
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
                  _inviteMenuLabel(language),
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
                  _settingsMenuLabel(language),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.ink),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: user == null ? 'signin' : 'logout',
          child: Row(
            children: [
              Icon(
                user == null ? Icons.login_rounded : Icons.logout_rounded,
                color: user == null ? palette.info : palette.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user == null
                      ? language.loginSubmitLabel
                      : _logoutMenuLabel(language),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: user == null ? palette.info : palette.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'premium') context.openPremium();
        if (val == 'settings') context.openMe();
        if (val == 'signin') LoginDialog.show(context);
        if (val == 'logout') ref.read(authServiceProvider).signOut();
      },
      child: _Avatar(palette: palette, compact: compact, user: user),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.palette,
    required this.compact,
    required this.user,
  });

  final AppThemePalette palette;
  final bool compact;
  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 38.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.accent, palette.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: palette.outlineSoft),
        image: (user?.photoUrl?.isNotEmpty ?? false)
            ? DecorationImage(
                image: NetworkImage(user!.photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: (user?.photoUrl?.isNotEmpty ?? false)
          ? const SizedBox.shrink()
          : Text(
              user?.initialsForAvatar ?? 'J',
              style: TextStyle(
                color: palette.bg,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 16 : 18,
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

String _profileTooltip(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Profile',
  AppLanguage.vi => 'Hồ sơ',
  AppLanguage.ja => 'プロフィール',
};

String _profileName(AppLanguage language) => switch (language) {
  AppLanguage.en => 'JP Study learner',
  AppLanguage.vi => 'Người học JP Study',
  AppLanguage.ja => 'JP Study 学習者',
};

String _profileSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Local study profile',
  AppLanguage.vi => 'Hồ sơ học tập cục bộ',
  AppLanguage.ja => 'ローカル学習プロフィール',
};

String _premiumMenuLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Upgrade to Premium',
  AppLanguage.vi => 'Nâng cấp Premium',
  AppLanguage.ja => 'Premiumにアップグレード',
};

String _inviteMenuLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Invite friends',
  AppLanguage.vi => 'Giới thiệu bạn bè',
  AppLanguage.ja => '友達を招待',
};

String _settingsMenuLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Settings',
  AppLanguage.vi => 'Cài đặt',
  AppLanguage.ja => '設定',
};

String _logoutMenuLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Log out',
  AppLanguage.vi => 'Đăng xuất',
  AppLanguage.ja => 'ログアウト',
};
