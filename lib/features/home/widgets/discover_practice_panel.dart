import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/practice_hub_preferences_provider.dart';
import 'package:jpstudy/features/home/widgets/ghost_review_banner.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/home/widgets/practice_hub.dart';
import 'package:jpstudy/features/test/widgets/practice_test_dashboard.dart';

class DiscoverPracticePanel extends ConsumerStatefulWidget {
  const DiscoverPracticePanel({
    super.key,
    this.initiallyExpanded = false,
    this.dense = false,
  });

  final bool initiallyExpanded;
  final bool dense;

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
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);
    final (mistakeCount, vocabDue, grammarDue, kanjiDue) = ref.watch(
      dashboardProvider.select((v) {
        final d = v.value;
        return (
          d?.totalMistakeCount ?? 0,
          d?.vocabDue ?? 0,
          d?.grammarDue ?? 0,
          d?.kanjiDue ?? 0,
        );
      }),
    );
    final totalDue = vocabDue + grammarDue + kanjiDue;
    final highlightCount = ghostCount + mistakeCount;
    final hubPrefs = ref.watch(practiceHubPreferencesProvider);

    final rankedTiles = buildPracticeDestinations(
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
    final orderedTiles = applyPracticeDestinationOrder(
      rankedDestinations: rankedTiles,
      preferredOrder: hubPrefs.orderIds,
    );
    final panelRadius = widget.dense ? 18.0 : HomeSurface.panelRadius;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.dense ? 0 : HomeSurface.pageHorizontalPadding,
        0,
        widget.dense ? 0 : HomeSurface.pageHorizontalPadding,
        0,
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: HomeSurface.softPanel(
            radius: panelRadius,
            context: context,
          ),
          child: Column(
            children: [
              InkWell(
                key: const ValueKey('discover_practice_toggle'),
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                borderRadius: BorderRadius.circular(panelRadius),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.dense ? 10 : 14,
                    widget.dense ? 10 : 14,
                    widget.dense ? 10 : 14,
                    widget.dense ? 10 : 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: widget.dense ? 28 : 36,
                        height: widget.dense ? 28 : 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.dense ? 10 : 12,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              palette.info.withValues(alpha: 0.2),
                              palette.warning.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: palette.secondary,
                          size: 17,
                        ),
                      ),
                      SizedBox(width: widget.dense ? 8 : 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              language.practiceHubTitle,
                              style: TextStyle(
                                fontSize: widget.dense ? 13.5 : 16,
                                fontWeight: FontWeight.w800,
                                color: palette.ink,
                              ),
                            ),
                            if (!widget.dense) ...[
                              Text(
                                language.practiceHubSubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: palette.ink.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: widget.dense ? 4 : 6),
                      _FocusChip(
                        enabled: hubPrefs.focusModeEnabled,
                        label: _focusChipLabel(language),
                        compact: widget.dense,
                        onTap: () {
                          ref
                              .read(practiceHubPreferencesProvider.notifier)
                              .setFocusMode(!hubPrefs.focusModeEnabled);
                        },
                      ),
                      SizedBox(width: widget.dense ? 2 : 4),
                      IconButton(
                        tooltip: _reorderTooltipLabel(language),
                        onPressed: orderedTiles.isEmpty
                            ? null
                            : () => _showReorderSheet(
                                language: language,
                                orderedTiles: orderedTiles,
                              ),
                        icon: Icon(
                          Icons.drag_indicator_rounded,
                          size: widget.dense ? 18 : 20,
                        ),
                        color: palette.ink.withValues(alpha: 0.7),
                        style: IconButton.styleFrom(
                          minimumSize: Size(
                            widget.dense ? 28 : 34,
                            widget.dense ? 28 : 34,
                          ),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              widget.dense ? 8 : 10,
                            ),
                            side: BorderSide(color: palette.outline),
                          ),
                          backgroundColor: palette.elevated,
                        ),
                      ),
                      if (highlightCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: palette.error,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$highlightCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.dense ? 10 : 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: widget.dense ? 6 : 8),
                      ],
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: reducedMotionDuration(
                          context,
                          const Duration(milliseconds: 160),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: palette.ink.withValues(alpha: 0.7),
                          size: widget.dense ? 18 : 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                key: const ValueKey('discover_practice_body'),
                duration: reducedMotionDuration(
                  context,
                  const Duration(milliseconds: 180),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: SizedBox(height: widget.dense ? 2 : 4),
                secondChild: Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.dense ? 10 : 14,
                    0,
                    widget.dense ? 10 : 14,
                    widget.dense ? 10 : 10,
                  ),
                  child: const Column(
                    children: [
                      GhostReviewBanner(embedded: true),
                      SizedBox(height: 2),
                      PracticeTestDashboard(embedded: true),
                      SizedBox(height: 6),
                      PracticeHub(
                        embedded: true,
                        showHeader: false,
                        showFocusHint: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReorderSheet({
    required AppLanguage language,
    required List<PracticeDestination> orderedTiles,
  }) async {
    final editing = List<PracticeDestination>.from(orderedTiles);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final palette = context.appPalette;
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.74,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _reorderTitle(language),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _reorderSubtitle(language),
                                  style: TextStyle(
                                    color: palette.ink.withValues(alpha: 0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .read(practiceHubPreferencesProvider.notifier)
                                  .resetOrder();
                            },
                            child: Text(_resetLabel(language)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: editing.length,
                        onReorder: (oldIndex, newIndex) {
                          setModalState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final moved = editing.removeAt(oldIndex);
                            editing.insert(newIndex, moved);
                          });
                          ref
                              .read(practiceHubPreferencesProvider.notifier)
                              .saveOrder(
                                editing.map((item) => item.id).toList(),
                              );
                        },
                        itemBuilder: (context, index) {
                          final item = editing[index];
                          return ListTile(
                            key: ValueKey('practice_reorder_${item.id}'),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: item.color.withValues(
                                alpha: 0.14,
                              ),
                              child: Icon(
                                item.icon,
                                size: 16,
                                color: item.color,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.drag_handle_rounded),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _focusChipLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Focus 3';
      case AppLanguage.vi:
        return 'Ưu tiên 3';
      case AppLanguage.ja:
        return '優先3';
    }
  }

  String _reorderTooltipLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Reorder cards';
      case AppLanguage.vi:
        return 'Sắp xếp thẻ';
      case AppLanguage.ja:
        return 'カード並び替え';
    }
  }

  String _reorderTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Reorder cards';
      case AppLanguage.vi:
        return 'Sắp xếp thẻ luyện tập';
      case AppLanguage.ja:
        return '練習カードの並び替え';
    }
  }

  String _reorderSubtitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Drag to reorder cards.';
      case AppLanguage.vi:
        return 'Kéo thả để đổi thứ tự thẻ luyện tập nhanh.';
      case AppLanguage.ja:
        return 'ドラッグでクイック練習カードの順序を変更できます。';
    }
  }

  String _resetLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Reset';
      case AppLanguage.vi:
        return 'Đặt lại';
      case AppLanguage.ja:
        return 'リセット';
    }
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.enabled,
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final bool enabled;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? palette.warning.withValues(alpha: 0.18)
              : palette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: enabled ? palette.warning : palette.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_rounded,
              size: compact ? 11 : 13,
              color: enabled
                  ? palette.warning
                  : palette.ink.withValues(alpha: 0.55),
            ),
            if (!compact) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: enabled
                      ? palette.warning
                      : palette.ink.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


