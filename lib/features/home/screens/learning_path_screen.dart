import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/widgets/empty_state_widget.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/models/lesson_node.dart';
import 'package:jpstudy/features/home/models/unit.dart';
import 'package:jpstudy/features/home/viewmodels/learning_path_viewmodel.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';
import 'package:jpstudy/features/home/widgets/discover_practice_panel.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/home/widgets/mini_dashboard.dart';
import 'package:jpstudy/features/home/widgets/unit_map_widget.dart';

enum _HomeMenuSection { today, path, practice }

class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  _HomeMenuSection _selectedSection = _HomeMenuSection.today;

  @override
  Widget build(BuildContext context) {
    final pathState = ref.watch(learningPathViewModelProvider);
    final selectedLevel = ref.watch(studyLevelProvider);
    final language = ref.watch(appLanguageProvider);

    return pathState.when(
      data: (allUnits) {
        final units = selectedLevel == null
            ? allUnits
            : allUnits.where((u) => u.id == selectedLevel.shortLabel).toList();

        if (units.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.school_outlined,
              title: language.noLessonsForLevelLabel,
              subtitle: language.changeLevelLabel,
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
            return JapaneseBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 68),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          HomeSurface.pageHorizontalPadding,
                          0,
                          HomeSurface.pageHorizontalPadding,
                          8,
                        ),
                        child: _HomeMenuTabs(
                          language: language,
                          selected: _selectedSection,
                          onSelected: (section) {
                            if (section == _selectedSection) {
                              return;
                            }
                            setState(() {
                              _selectedSection = section;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: isDesktop
                            ? _buildDesktopSection(context, units)
                            : _buildMobileSection(context, units),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(language.loadErrorLabel)),
    );
  }

  Widget _buildMobileSection(BuildContext context, List<Unit> units) {
    switch (_selectedSection) {
      case _HomeMenuSection.today:
        return CustomScrollView(
          slivers: const [
            SliverToBoxAdapter(child: DailySessionCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                child: MiniDashboard(),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      case _HomeMenuSection.path:
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final unit = units[index];
                return UnitMapWidget(
                  unit: unit,
                  onNodeTap: (node) => _handleNodeTap(context, node),
                );
              }, childCount: units.length),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      case _HomeMenuSection.practice:
        return CustomScrollView(
          slivers: const [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 2, bottom: 8),
                child: DiscoverPracticePanel(initiallyExpanded: true),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
    }
  }

  Widget _buildDesktopSection(BuildContext context, List<Unit> units) {
    switch (_selectedSection) {
      case _HomeMenuSection.today:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppBreakpoints.desktop),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              children: const [
                DailySessionCard(compact: true),
                SizedBox(height: 10),
                MiniDashboard(),
                SizedBox(height: 10),
                DiscoverPracticePanel(initiallyExpanded: true),
              ],
            ),
          ),
        );
      case _HomeMenuSection.path:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: _panelDecoration(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 90),
                        itemCount: units.length,
                        itemBuilder: (context, index) {
                          final unit = units[index];
                          return UnitMapWidget(
                            unit: unit,
                            onNodeTap: (node) => _handleNodeTap(context, node),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const SizedBox(
                    width: 420,
                    child: MiniDashboard(compact: true),
                  ),
                ],
              ),
            ),
          ),
        );
      case _HomeMenuSection.practice:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              children: const [DiscoverPracticePanel(initiallyExpanded: true)],
            ),
          ),
        );
    }
  }

  void _handleNodeTap(BuildContext context, LessonNode node) {
    context.push('/lesson/${node.lesson.id}');
  }

  BoxDecoration _panelDecoration() {
    return HomeSurface.softPanel(
      colors: const [Color(0xF8FFFFFF), Color(0xECF7FCFF)],
      radius: 30,
    );
  }
}

class _HomeMenuTabs extends StatelessWidget {
  const _HomeMenuTabs({
    required this.language,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage language;
  final _HomeMenuSection selected;
  final ValueChanged<_HomeMenuSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE8F8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E293B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.today_rounded,
            label: _label(language, _HomeMenuSection.today),
            selected: selected == _HomeMenuSection.today,
            onTap: () => onSelected(_HomeMenuSection.today),
          ),
          _TabButton(
            icon: Icons.route_rounded,
            label: _label(language, _HomeMenuSection.path),
            selected: selected == _HomeMenuSection.path,
            onTap: () => onSelected(_HomeMenuSection.path),
          ),
          _TabButton(
            icon: Icons.explore_rounded,
            label: _label(language, _HomeMenuSection.practice),
            selected: selected == _HomeMenuSection.practice,
            onTap: () => onSelected(_HomeMenuSection.practice),
          ),
        ],
      ),
    );
  }

  String _label(AppLanguage language, _HomeMenuSection section) {
    switch (section) {
      case _HomeMenuSection.today:
        switch (language) {
          case AppLanguage.en:
            return 'Today';
          case AppLanguage.vi:
            return 'Hôm nay';
          case AppLanguage.ja:
            return '今日';
        }
      case _HomeMenuSection.path:
        switch (language) {
          case AppLanguage.en:
            return 'Path';
          case AppLanguage.vi:
            return 'Lộ trình';
          case AppLanguage.ja:
            return 'ルート';
        }
      case _HomeMenuSection.practice:
        switch (language) {
          case AppLanguage.en:
            return 'Practice';
          case AppLanguage.vi:
            return 'Luyện tập';
          case AppLanguage.ja:
            return '練習';
        }
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? const Color(0xFF0F172A) : const Color(0xFF64748B);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE0F2FE) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? const Color(0xFFBAE6FD) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
