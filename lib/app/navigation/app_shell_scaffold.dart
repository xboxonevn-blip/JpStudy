import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/layout/app_responsive_frame.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/global_top_bar.dart';

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
        final useSidebar = constraints.maxWidth >= AppBreakpoints.desktop;
        if (useSidebar) {
          return Scaffold(
            backgroundColor: palette.bg,
            body: SafeArea(
              child: Column(
                children: [
                  const GlobalTopBar(),
                  _SemanticNavigationLandmarks(items: items),
                  Expanded(
                    child: AppResponsiveFrame(
                      maxWidth: AppResponsiveMetrics.shellMaxWidth(
                        constraints.maxWidth,
                      ),
                      desktopHorizontalPadding: AppResponsiveMetrics.pageGutter(
                        constraints.maxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                        child: Row(
                          children: [
                            _Sidebar(
                              items: items,
                              currentIndex: navigationShell.currentIndex,
                              onTap: _goToBranch,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _ShellBody(
                                navigationShell: navigationShell,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final bottomItems = [items[4], items[1], items[0], items[7]];
        final bottomSelected = switch (navigationShell.currentIndex) {
          4 => 0,
          1 => 1,
          0 => 2,
          7 => 3,
          _ => 4,
        };

        return Scaffold(
          backgroundColor: palette.bg,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                navigationShell,
                _SemanticNavigationLandmarks(items: items),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: _MobileNavigationBar(
                language: language,
                bottomItems: bottomItems,
                selectedIndex: bottomSelected,
                onDestinationSelected: (index) {
                  if (index < 4) {
                    final branch = const [4, 1, 0, 7][index];
                    _goToBranch(branch);
                    return;
                  }
                  _showMoreSheet(context, items);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMoreSheet(BuildContext context, List<_ShellItem> items) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appPalette.base,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length - 5,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final branchIndex = [2, 3, 6, 8, 9, 10][index];
              final item = items[branchIndex];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                leading: Icon(item.selectedIcon),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _goToBranch(branchIndex);
                },
              );
            },
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
        label: _kanji(language),
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
      ),
      _ShellItem(
        label: _foundations(language),
        icon: Icons.spa_outlined,
        selectedIcon: Icons.spa_rounded,
      ),
      _ShellItem(
        label: _vocab(language),
        icon: Icons.translate_outlined,
        selectedIcon: Icons.translate_rounded,
      ),
      _ShellItem(
        label: _grammar(language),
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree_rounded,
      ),
      _ShellItem(
        label: _roadmap(language),
        icon: Icons.route_outlined,
        selectedIcon: Icons.route_rounded,
      ),
      _ShellItem(
        label: _memory(language),
        icon: Icons.psychology_alt_outlined,
        selectedIcon: Icons.psychology_alt_rounded,
      ),
      _ShellItem(
        label: _active(language),
        icon: Icons.bolt_outlined,
        selectedIcon: Icons.bolt_rounded,
      ),
      _ShellItem(
        label: _exam(language),
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check_rounded,
      ),
      _ShellItem(
        label: _leaderboard(language),
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events_rounded,
      ),
      _ShellItem(
        label: _upgrade(language),
        icon: Icons.diamond_outlined,
        selectedIcon: Icons.diamond_rounded,
      ),
      _ShellItem(
        label: _community(language),
        icon: Icons.forum_outlined,
        selectedIcon: Icons.forum_rounded,
      ),
    ];
  }
}

class _SemanticNavigationLandmarks extends StatelessWidget {
  const _SemanticNavigationLandmarks({required this.items});

  final List<_ShellItem> items;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: SizedBox(
        width: 1,
        height: items.length.toDouble().clamp(1, 100),
        child: Column(
          children: [
            for (final item in items)
              Semantics(
                label: item.label,
                button: true,
                child: const SizedBox(width: 1, height: 1),
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileNavigationBar extends StatelessWidget {
  const _MobileNavigationBar({
    required this.language,
    required this.bottomItems,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final AppLanguage language;
  final List<_ShellItem> bottomItems;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppResponsiveFrame(
      maxWidth: 980,
      minHorizontalPadding: 12,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.elevated, palette.base],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: palette.outline),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          height: 82,
          backgroundColor: Colors.transparent,
          indicatorColor: palette.primary.withValues(alpha: 0.14),
          destinations: [
            for (final item in bottomItems)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
            NavigationDestination(
              icon: const Icon(Icons.dashboard_customize_outlined),
              selectedIcon: const Icon(Icons.dashboard_customize_rounded),
              label: _moreLabel(language),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_ShellItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: 158,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.elevated, palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [palette.primary, palette.secondary],
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
                  'JpStudy\n日本語',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final selected = index == currentIndex;
                final item = items[index];
                return Semantics(
                  label: item.label,
                  button: true,
                  selected: selected,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onTap(index),
                    child: ExcludeSemantics(
                      child: AnimatedContainer(
                        duration: reducedMotionDuration(
                          context,
                          const Duration(milliseconds: 180),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? palette.primary.withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? palette.primary.withValues(alpha: 0.28)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              selected ? item.selectedIcon : item.icon,
                              color: selected
                                  ? palette.primary
                                  : palette.ink.withValues(alpha: 0.72),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? palette.primary
                                        : palette.ink.withValues(alpha: 0.72),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.elevated.withValues(alpha: 0.92),
            palette.base.withValues(alpha: 0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.10),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: ColoredBox(color: palette.bg, child: navigationShell),
      ),
    );
  }
}

String _kanji(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Kanji',
  AppLanguage.vi => 'H\u00e1n t\u1ef1',
  AppLanguage.ja => '\u6f22\u5b57',
};
String _foundations(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Kana',
  AppLanguage.vi => 'Kana',
  AppLanguage.ja => '\u304b\u306a',
};
String _vocab(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Vocab',
  AppLanguage.vi => 'T\u1eeb v\u1ef1ng',
  AppLanguage.ja => '\u8a9e\u5f59',
};
String _grammar(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Grammar',
  AppLanguage.vi => 'Ng\u1eef ph\u00e1p',
  AppLanguage.ja => '\u6587\u6cd5',
};
String _roadmap(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Roadmap',
  AppLanguage.vi => 'L\u1ed9 tr\u00ecnh',
  AppLanguage.ja => '\u30ed\u30fc\u30c9\u30de\u30c3\u30d7',
};
String _memory(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Memory',
  AppLanguage.vi => 'Ghi nh\u1edb',
  AppLanguage.ja => '\u8a18\u61b6',
};
String _active(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Active',
  AppLanguage.vi => 'Ch\u1ee7 \u0111\u1ed9ng',
  AppLanguage.ja => '\u30a2\u30af\u30c6\u30a3\u30d6',
};
String _exam(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Exams',
  AppLanguage.vi => 'Đề thi',
  AppLanguage.ja => '試験',
};
String _leaderboard(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ranks',
  AppLanguage.vi => 'Xếp hạng',
  AppLanguage.ja => 'ランキング',
};
String _upgrade(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Upgrade',
  AppLanguage.vi => 'Nâng cấp',
  AppLanguage.ja => 'アップグレード',
};
String _community(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Community',
  AppLanguage.vi => 'Cộng đồng',
  AppLanguage.ja => 'コミュニティ',
};
String _moreLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'More',
  AppLanguage.vi => 'Thêm',
  AppLanguage.ja => 'その他',
};

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
