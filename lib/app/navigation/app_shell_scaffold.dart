import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/layout/app_responsive_frame.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/global_top_bar.dart';

enum NavigationGroup { learning, progress, other, footer }

const double _sidebarItemHeight = 44;
const double _sidebarFooterItemHeight = 36;
const double _sidebarGroupHeaderHeight = 18;
const double _sidebarGroupGap = 12;
const double _sidebarFooterDividerHeight = 13;

@visibleForTesting
const double sidebarItemHeightForTesting = _sidebarItemHeight;

@visibleForTesting
const double sidebarFooterItemHeightForTesting = _sidebarFooterItemHeight;

@visibleForTesting
const double sidebarEstimatedContentHeightForTesting =
    (_sidebarGroupHeaderHeight * 3) +
    (_sidebarItemHeight * 9) +
    (_sidebarGroupGap * 2) +
    _sidebarFooterDividerHeight +
    _sidebarFooterItemHeight;

class AppShellScaffold extends ConsumerWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final allItems = _buildItems(language);
    final items = [
      for (final branchIndex in visibleShellBranchIndicesForLevel(level))
        allItems[branchIndex],
    ];
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
                              language: language,
                              items: items,
                              currentIndex: navigationShell.currentIndex,
                              onTap: (index) => _goToBranch(context, index),
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

        final bottomBranchIndices = bottomShellBranchIndicesForLevel(level);
        final bottomItems = [
          for (final branchIndex in bottomBranchIndices) allItems[branchIndex],
        ];
        final bottomSelected = bottomItems.indexWhere(
          (item) => item.branchIndex == navigationShell.currentIndex,
        );
        final selectedIndex = bottomSelected == -1
            ? bottomItems.length
            : bottomSelected;

        final viewport = MediaQuery.sizeOf(context);
        return SizedBox(
          width: viewport.width,
          height: viewport.height,
          child: ColoredBox(
            color: palette.bg,
            child: Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        navigationShell,
                        Positioned(
                          left: 0,
                          top: 0,
                          child: _SemanticNavigationLandmarks(items: items),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: _MobileNavigationBar(
                      language: language,
                      bottomItems: bottomItems,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        if (index < bottomItems.length) {
                          _goToBranch(context, bottomItems[index].branchIndex);
                          return;
                        }
                        _showMoreSheet(context, items, bottomBranchIndices);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreSheet(
    BuildContext context,
    List<_ShellItem> items,
    List<int> bottomBranchIndices,
  ) {
    final moreItems = items
        .where((item) => !bottomBranchIndices.contains(item.branchIndex))
        .toList(growable: false);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.appPalette.base,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: moreItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = moreItems[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                leading: Icon(item.selectedIcon),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _goToBranch(context, item.branchIndex);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _goToBranch(BuildContext context, int index) {
    final location = _branchInitialLocations[index];
    navigationShell.goBranch(index, initialLocation: true);
    GoRouter.of(context).go(location);
  }

  List<_ShellItem> _buildItems(AppLanguage language) {
    return [
      _ShellItem(
        branchIndex: 0,
        group: NavigationGroup.learning,
        label: _kanji(language),
        icon: Icons.grid_view_outlined,
        selectedIcon: Icons.grid_view_rounded,
      ),
      _ShellItem(
        branchIndex: 1,
        group: NavigationGroup.learning,
        label: _foundations(language),
        icon: Icons.spa_outlined,
        selectedIcon: Icons.spa_rounded,
      ),
      _ShellItem(
        branchIndex: 2,
        group: NavigationGroup.learning,
        label: _vocab(language),
        icon: Icons.translate_outlined,
        selectedIcon: Icons.translate_rounded,
      ),
      _ShellItem(
        branchIndex: 3,
        group: NavigationGroup.learning,
        label: _grammar(language),
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree_rounded,
      ),
      _ShellItem(
        branchIndex: 4,
        group: NavigationGroup.progress,
        label: _roadmap(language),
        icon: Icons.route_outlined,
        selectedIcon: Icons.route_rounded,
      ),
      _ShellItem(
        branchIndex: 5,
        group: NavigationGroup.progress,
        label: _memory(language),
        icon: Icons.psychology_alt_outlined,
        selectedIcon: Icons.psychology_alt_rounded,
      ),
      _ShellItem(
        branchIndex: 6,
        group: NavigationGroup.progress,
        label: _active(language),
        icon: Icons.bolt_outlined,
        selectedIcon: Icons.bolt_rounded,
      ),
      _ShellItem(
        branchIndex: 7,
        group: NavigationGroup.other,
        label: _exam(language),
        icon: Icons.fact_check_outlined,
        selectedIcon: Icons.fact_check_rounded,
      ),
      _ShellItem(
        branchIndex: 8,
        group: NavigationGroup.other,
        label: _leaderboard(language),
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events_rounded,
      ),
      _ShellItem(
        branchIndex: 9,
        group: NavigationGroup.footer,
        label: _upgrade(language),
        icon: Icons.diamond_outlined,
        selectedIcon: Icons.diamond_rounded,
      ),
      _ShellItem(
        branchIndex: 10,
        group: NavigationGroup.other,
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
    return SizedBox(
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
    required this.language,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final AppLanguage language;
  final List<_ShellItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final bodyGroups = [
      NavigationGroup.learning,
      NavigationGroup.progress,
      NavigationGroup.other,
    ];
    final footerItems = items
        .where((item) => item.group == NavigationGroup.footer)
        .toList(growable: false);

    return Container(
      width: 176,
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
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: palette.primary.withValues(alpha: 0.12),
                  ),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: palette.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'JpStudy',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              children: [
                for (final group in bodyGroups) ...[
                  if (items.any((item) => item.group == group)) ...[
                    _NavigationGroupHeader(
                      label: _navigationGroupLabel(language, group),
                    ),
                    for (final item in items.where(
                      (item) => item.group == group,
                    ))
                      _SidebarItem(
                        item: item,
                        selected: item.branchIndex == currentIndex,
                        onTap: () => onTap(item.branchIndex),
                      ),
                    if (group != NavigationGroup.other)
                      const SizedBox(height: _sidebarGroupGap),
                  ],
                ],
              ],
            ),
          ),
          if (footerItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Divider(
                height: _sidebarFooterDividerHeight,
                color: palette.outline,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 12),
              child: Column(
                children: [
                  for (final item in footerItems)
                    _SidebarItem(
                      item: item,
                      selected: item.branchIndex == currentIndex,
                      onTap: () => onTap(item.branchIndex),
                      height: _sidebarFooterItemHeight,
                      compact: true,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationGroupHeader extends StatelessWidget {
  const _NavigationGroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Semantics(
      label: label,
      header: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: _sidebarGroupHeaderHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.ink.withValues(alpha: 0.50),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.height = _sidebarItemHeight,
    this.compact = false,
  });

  final _ShellItem item;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final textStyle = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.labelMedium;
    final foreground = selected
        ? palette.primary
        : palette.ink.withValues(alpha: compact ? 0.62 : 0.74);

    return Tooltip(
      message: item.label,
      waitDuration: const Duration(milliseconds: 350),
      child: Semantics(
        label: item.label,
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ExcludeSemantics(
            child: AnimatedContainer(
              duration: reducedMotionDuration(
                context,
                const Duration(milliseconds: 160),
              ),
              height: height,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
              decoration: BoxDecoration(
                color: selected
                    ? palette.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? palette.primary.withValues(alpha: 0.24)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: compact ? 18 : 20,
                    color: foreground,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

String _navigationGroupLabel(AppLanguage language, NavigationGroup group) {
  return switch (group) {
    NavigationGroup.learning => language.navGroupLearning,
    NavigationGroup.progress => language.navGroupProgress,
    NavigationGroup.other => language.navGroupOther,
    NavigationGroup.footer => '',
  };
}

class _ShellItem {
  const _ShellItem({
    required this.branchIndex,
    required this.group,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final int branchIndex;
  final NavigationGroup group;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

@visibleForTesting
NavigationGroup navigationGroupForShellBranch(int branchIndex) {
  return switch (branchIndex) {
    0 || 1 || 2 || 3 => NavigationGroup.learning,
    4 || 5 || 6 => NavigationGroup.progress,
    7 || 8 || 10 => NavigationGroup.other,
    9 => NavigationGroup.footer,
    _ => throw RangeError.index(branchIndex, _branchInitialLocations),
  };
}

@visibleForTesting
List<int> visibleShellBranchIndicesForLevel(StudyLevel? level) {
  final allBranches = List<int>.generate(
    _branchInitialLocations.length,
    (i) => i,
  );
  if (level == null || level == StudyLevel.n5) {
    return List<int>.unmodifiable(allBranches);
  }
  return List<int>.unmodifiable(
    allBranches.where((branchIndex) => branchIndex != 1),
  );
}

@visibleForTesting
List<int> bottomShellBranchIndicesForLevel(StudyLevel? level) {
  if (level == null || level == StudyLevel.n5) {
    return const [4, 1, 0, 7];
  }
  return const [4, 0, 7];
}

const _branchInitialLocations = <String>[
  AppRoutePath.kanji,
  AppRoutePath.foundations,
  AppRoutePath.vocab,
  AppRoutePath.grammar,
  AppRoutePath.home,
  AppRoutePath.memory,
  AppRoutePath.active,
  AppRoutePath.examCenter,
  AppRoutePath.leaderboard,
  AppRoutePath.premium,
  AppRoutePath.community,
];
