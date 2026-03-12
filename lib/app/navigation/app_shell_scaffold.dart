import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final items = _buildItems(language);

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
                  backgroundColor: const Color(0xFFF8FBFF),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE0F2FE), Color(0xFFFDE68A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'JpStudy',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
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
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFDCE8F8))),
              boxShadow: [
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
              backgroundColor: const Color(0xFFFDFEFF),
              indicatorColor: const Color(0xFFDFF3FF),
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
        label: _todayLabel(language),
        icon: Icons.today_outlined,
        selectedIcon: Icons.today_rounded,
      ),
      _ShellItem(
        label: _practiceLabel(language),
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
      ),
      _ShellItem(
        label: _libraryLabel(language),
        icon: Icons.layers_outlined,
        selectedIcon: Icons.layers_rounded,
      ),
      _ShellItem(
        label: _progressLabel(language),
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights_rounded,
      ),
      _ShellItem(
        label: _meLabel(language),
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];
  }

  String _todayLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Today';
      case AppLanguage.vi:
        return 'Hôm nay';
      case AppLanguage.ja:
        return 'Today';
    }
  }

  String _practiceLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Practice';
      case AppLanguage.vi:
        return 'Luyện';
      case AppLanguage.ja:
        return 'Practice';
    }
  }

  String _libraryLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Library';
      case AppLanguage.vi:
        return 'Thư viện';
      case AppLanguage.ja:
        return 'Library';
    }
  }

  String _progressLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Progress';
      case AppLanguage.vi:
        return 'Tiến độ';
      case AppLanguage.ja:
        return 'Progress';
    }
  }

  String _meLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Me';
      case AppLanguage.vi:
        return 'Tôi';
      case AppLanguage.ja:
        return 'Me';
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
