import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final items = _buildItems(language);
    final palette = context.appPalette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= AppBreakpoints.desktop;
        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => _goToBranch(index),
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.85,
                  backgroundColor: palette.base,
                  indicatorColor: palette.primary.withValues(alpha: 0.12),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: palette.heroGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'JpStudy',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                VerticalDivider(width: 1, color: palette.outline),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.outline)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x102C3F59),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => _goToBranch(index),
              height: 72,
              backgroundColor: palette.base,
              indicatorColor: palette.primary.withValues(alpha: 0.12),
              destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: item.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<_ShellItem> _buildItems(AppLanguage language) {
    return [
      _ShellItem(
        label: _homeLabel(language),
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      _ShellItem(
        label: _studyLabel(language),
        icon: Icons.play_lesson_outlined,
        selectedIcon: Icons.play_lesson_rounded,
      ),
      _ShellItem(
        label: _libraryLabel(language),
        icon: Icons.layers_outlined,
        selectedIcon: Icons.layers_rounded,
      ),
      _ShellItem(
        label: _meLabel(language),
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];
  }

  String _homeLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Home';
      case AppLanguage.vi:
        return 'Trang chủ';
      case AppLanguage.ja:
        return 'ホーム';
    }
  }

  String _studyLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Study';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学習';
    }
  }

  String _libraryLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'Thư viện';
      case AppLanguage.ja:
        return 'ライブラリ';
    }
  }

  String _meLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Me';
      case AppLanguage.vi:
        return 'Tôi';
      case AppLanguage.ja:
        return '自分';
    }
  }
}

class _ShellItem {
  const _ShellItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
