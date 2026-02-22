import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/ghost_review_banner.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/home/widgets/practice_hub.dart';
import 'package:jpstudy/features/test/widgets/practice_test_dashboard.dart';

class DiscoverPracticePanel extends ConsumerStatefulWidget {
  const DiscoverPracticePanel({super.key, this.initiallyExpanded = false});

  final bool initiallyExpanded;

  @override
  ConsumerState<DiscoverPracticePanel> createState() =>
      _DiscoverPracticePanelState();
}

class _DiscoverPracticePanelState extends ConsumerState<DiscoverPracticePanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final mistakeCount =
        ref.watch(dashboardProvider).valueOrNull?.totalMistakeCount ?? 0;
    final highlightCount = ghostCount + mistakeCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        0,
        HomeSurface.pageHorizontalPadding,
        0,
      ),
      child: Container(
        decoration: HomeSurface.softPanel(),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              borderRadius: BorderRadius.circular(HomeSurface.panelRadius),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F2FE), Color(0xFFFFEDD5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        color: Color(0xFF0F766E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.practiceHubTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            language.practiceHubSubtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (highlightCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$highlightCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 4),
              secondChild: const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    GhostReviewBanner(),
                    SizedBox(height: 8),
                    PracticeTestDashboard(),
                    SizedBox(height: 4),
                    PracticeHub(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
