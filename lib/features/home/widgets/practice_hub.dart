import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

import '../providers/dashboard_provider.dart';

class PracticeHub extends ConsumerWidget {
  const PracticeHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final mistakeCount = dashboard?.totalMistakeCount ?? 0;
    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final level = ref.watch(studyLevelProvider);

    final tiles = buildPracticeDestinations(
      language: language,
      ghostCount: ghostCount,
      mistakeCount: mistakeCount,
      dueReviewCount: totalDue,
      level: level,
      preferImmersion: totalDue == 0 && mistakeCount == 0 && ghostCount == 0,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        0,
        HomeSurface.pageHorizontalPadding,
        0,
      ),
      child: Container(
        decoration: HomeSurface.softPanel(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Color(0xFF0F766E),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language.practiceHubSubtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 1080
                      ? 3
                      : constraints.maxWidth >= 600
                      ? 2
                      : 2;
                  final aspectRatio = constraints.maxWidth < 420 ? 1.05 : 1.3;
                  return GridView.builder(
                    itemCount: tiles.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: aspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final item = tiles[index];
                      return _PracticeTile(
                        item: item,
                        onTap: () {
                          if (item.extra != null) {
                            context.push(item.route, extra: item.extra);
                          } else {
                            context.push(item.route);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({required this.item, required this.onTap});

  final PracticeDestination item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomeSurface.panelBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09283A57),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const Spacer(),
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
