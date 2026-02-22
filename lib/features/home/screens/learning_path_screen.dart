import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
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

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pathState = ref.watch(learningPathViewModelProvider);
    final selectedLevel = ref.watch(studyLevelProvider);
    final language = ref.watch(appLanguageProvider);

    return pathState.when(
      data: (allUnits) {
        final units = selectedLevel == null
            ? allUnits
            : allUnits.where((u) => u.id == selectedLevel.shortLabel).toList();

        if (units.isEmpty) {
          return Center(child: Text(language.noLessonsForLevelLabel));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            return JapaneseBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 68),
                  child: isDesktop
                      ? _buildDesktopLayout(context, units)
                      : _buildMobileLayout(context, units),
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

  Widget _buildMobileLayout(BuildContext context, List<Unit> units) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: DailySessionCard()),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
            child: MiniDashboard(),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final unit = units[index];
            return UnitMapWidget(
              unit: unit,
              onNodeTap: (node) => _handleNodeTap(context, node),
            );
          }, childCount: units.length),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: DiscoverPracticePanel(),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<Unit> units) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              const DailySessionCard(compact: true),
              const SizedBox(height: 8),
              const MiniDashboard(),
              const SizedBox(height: 10),
              Expanded(
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
                              onNodeTap: (node) =>
                                  _handleNodeTap(context, node),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 420,
                      child: DecoratedBox(
                        decoration: _panelDecoration(),
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 90),
                          children: [
                            DiscoverPracticePanel(initiallyExpanded: true),
                          ],
                        ),
                      ),
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
