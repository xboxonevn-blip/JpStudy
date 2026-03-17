import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/providers/practice_hub_preferences_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

import '../providers/dashboard_provider.dart';

class PracticeHub extends ConsumerWidget {
  const PracticeHub({
    super.key,
    this.embedded = false,
    this.showHeader = true,
    this.showFocusHint = true,
  });

  final bool embedded;
  final bool showHeader;
  final bool showFocusHint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final mistakeCount = dashboard?.totalMistakeCount ?? 0;
    final vocabDue = dashboard?.vocabDue ?? 0;
    final grammarDue = dashboard?.grammarDue ?? 0;
    final kanjiDue = dashboard?.kanjiDue ?? 0;
    final totalDue = vocabDue + grammarDue + kanjiDue;
    final level = ref.watch(studyLevelProvider);

    final tiles = buildPracticeDestinations(
      language: language,
      ghostCount: ghostCount,
      mistakeCount: mistakeCount,
      dueReviewCount: totalDue,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
      level: level,
      preferImmersion: totalDue == 0 && mistakeCount == 0 && ghostCount == 0,
    );
    final prefs = ref.watch(practiceHubPreferencesProvider);
    final orderedTiles = applyPracticeDestinationOrder(
      rankedDestinations: tiles,
      preferredOrder: prefs.orderIds,
    );
    final displayTiles = prefs.focusModeEnabled
        ? selectFocusPracticeDestinations(rankedDestinations: tiles)
        : orderedTiles;

    final content = _PracticeHubContent(
      language: language,
      tiles: displayTiles,
      embedded: embedded,
      showHeader: showHeader,
      focusModeEnabled: prefs.focusModeEnabled,
      showFocusHint: showFocusHint,
    );

    if (embedded) {
      return content;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        0,
        HomeSurface.pageHorizontalPadding,
        0,
      ),
      child: Container(decoration: HomeSurface.softPanel(), child: content),
    );
  }
}

class _PracticeHubContent extends StatelessWidget {
  const _PracticeHubContent({
    required this.language,
    required this.tiles,
    required this.embedded,
    required this.showHeader,
    required this.focusModeEnabled,
    required this.showFocusHint,
  });

  final AppLanguage language;
  final List<PracticeDestination> tiles;
  final bool embedded;
  final bool showHeader;
  final bool focusModeEnabled;
  final bool showFocusHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        embedded ? 0 : 14,
        embedded ? 0 : 14,
        embedded ? 0 : 14,
        embedded ? 0 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (focusModeEnabled && showFocusHint) ...[
            _FocusModeHint(language: language, embedded: embedded),
            SizedBox(height: embedded ? 6 : 10),
          ],
          if (showHeader) ...[
            Row(
              children: [
                Container(
                  width: embedded ? 32 : 38,
                  height: embedded ? 32 : 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(embedded ? 10 : 12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFDCFCE7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Color(0xFF0F766E),
                    size: 18,
                  ),
                ),
                SizedBox(width: embedded ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.practiceHubTitle,
                        style: TextStyle(
                          fontSize: embedded ? 14 : 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (!embedded) ...[
                        const SizedBox(height: 2),
                        Text(
                          language.practiceHubSubtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: embedded ? 8 : 14),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              final spacing = embedded ? 8.0 : 10.0;

              if (embedded) {
                final tileWidth = crossAxisCount == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth -
                              (spacing * (crossAxisCount - 1))) /
                          crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final item in tiles)
                      SizedBox(
                        width: tileWidth,
                        child: _PracticeTile(
                          item: item,
                          compact: true,
                          onTap: () {
                            if (item.extra != null) {
                              context.push(item.route, extra: item.extra);
                            } else {
                              context.push(item.route);
                            }
                          },
                        ),
                      ),
                  ],
                );
              }

              return GridView.builder(
                itemCount: tiles.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  mainAxisExtent: 124,
                ),
                itemBuilder: (context, index) {
                  final item = tiles[index];
                  return _PracticeTile(
                    item: item,
                    compact: false,
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
    );
  }
}

class _FocusModeHint extends StatelessWidget {
  const _FocusModeHint({required this.language, required this.embedded});

  final AppLanguage language;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: embedded ? 8 : 10,
        vertical: embedded ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(embedded ? 10 : 12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_rounded,
            size: embedded ? 14 : 16,
            color: const Color(0xFFB45309),
          ),
          SizedBox(width: embedded ? 5 : 6),
          Expanded(
            child: Text(
              _focusHintLabel(language),
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: embedded ? 11 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _focusHintLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Focus mode on: showing top 3 priorities for today.';
      case AppLanguage.vi:
        return 'Đang bật Focus mode: chỉ hiển thị 3 mục ưu tiên hôm nay.';
      case AppLanguage.ja:
        return 'フォーカスモード: 今日の優先3項目のみ表示中。';
    }
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    required this.item,
    required this.onTap,
    required this.compact,
  });

  final PracticeDestination item;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(compact ? 14 : 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(compact ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(compact ? 14 : 16),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 26 : 34,
                    height: compact ? 26 : 34,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(compact ? 8 : 10),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: compact ? 15 : 20,
                    ),
                  ),
                  const Spacer(),
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 7,
                        vertical: compact ? 1.5 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 10 : 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 12.2 : 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: compact ? 1 : 2),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10.6 : 12,
                  color: const Color(0xFF64748B),
                  height: 1.15,
                ),
              ),
              if (item.estimatedMinutes != null &&
                  item.estimatedMinutes! > 0) ...[
                SizedBox(height: compact ? 2 : 4),
                Text(
                  '~${item.estimatedMinutes} min',
                  style: TextStyle(
                    fontSize: compact ? 9.8 : 11,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
