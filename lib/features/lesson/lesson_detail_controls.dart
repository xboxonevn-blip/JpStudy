part of 'lesson_detail_screen.dart';

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.language,
    required this.total,
    required this.learned,
    required this.due,
  });

  final AppLanguage language;
  final int total;
  final int learned;
  final int due;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _StatChip(label: language.statsTotalLabel, value: total.toString()),
        _StatChip(label: language.statsLearnedLabel, value: learned.toString()),
        _StatChip(label: language.statsDueLabel, value: due.toString()),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.language,
    required this.enabled,
    required this.onRate,
  });

  final AppLanguage language;
  final bool enabled;
  final ValueChanged<ConfidenceLevel>? onRate;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ConfidenceRatingWidget(
            language: language,
            onSelect: (level) => onRate?.call(level),
          )
        : const SizedBox.shrink();
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
    required this.language,
    required this.reviewed,
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  final AppLanguage language;
  final int reviewed;
  final int again;
  final int hard;
  final int good;
  final int easy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _SummaryChip(label: language.reviewedLabel, value: reviewed.toString()),
        _SummaryChip(label: language.reviewAgainLabel, value: again.toString()),
        _SummaryChip(label: language.reviewHardLabel, value: hard.toString()),
        _SummaryChip(label: language.reviewGoodLabel, value: good.toString()),
        _SummaryChip(label: language.reviewEasyLabel, value: easy.toString()),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SavedPill extends StatelessWidget {
  const _SavedPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? palette.primary.withValues(alpha: 0.1)
              : palette.elevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? palette.primary.withValues(alpha: 0.22)
                : palette.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.star : Icons.star_border,
              size: 16,
              color: active ? palette.primary : null,
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.language, required this.onSelected});

  final AppLanguage language;
  final ValueChanged<_MenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: onSelected,
      icon: const Icon(Icons.more_horiz),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.reset,
          child: Text(language.resetProgressLabel),
        ),
        PopupMenuItem(
          value: _MenuAction.report,
          child: Text(language.reportLabel),
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.language,
    required this.mode,
    required this.onModeChanged,
  });

  final AppLanguage language;
  final _LessonMode mode;
  final ValueChanged<_LessonMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<_LessonMode>(
          segments: [
            ButtonSegment(
              value: _LessonMode.flashcards,
              label: Text(language.flashcardsAction),
            ),
            ButtonSegment(
              value: _LessonMode.review,
              label: Text(language.reviewAction),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onModeChanged(selection.first);
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return palette.primary;
              }
              return palette.elevated;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return palette.ink;
            }),
            side: WidgetStateProperty.all(BorderSide(color: palette.outline)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PracticeActions extends StatelessWidget {
  const _PracticeActions({
    required this.language,
    required this.lessonId,
    required this.lessonTitle,
  });

  final AppLanguage language;
  final int lessonId;
  final String lessonTitle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _PracticeButton(
          label: language.flashcardsAction,
          onTap: () => context.openLessonLearn(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.testModeLabel,
          onTap: () => context.openLessonTest(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.writeModeLabel,
          onTap: () => context.openLessonWrite(lessonId, title: lessonTitle),
        ),
      ],
    );
  }
}

class _PracticeButton extends StatelessWidget {
  const _PracticeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.ink,
        side: BorderSide(color: palette.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

class _FlashcardControls extends StatelessWidget {
  const _FlashcardControls({
    required this.language,
    required this.isShuffle,
    required this.isAutoPlay,
    required this.onShuffle,
    required this.onAutoPlay,
    required this.onPrev,
    required this.onNext,
  });

  final AppLanguage language;
  final bool isShuffle;
  final bool isAutoPlay;
  final VoidCallback onShuffle;
  final VoidCallback onAutoPlay;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onShuffle,
            icon: Icon(
              isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
              color: isShuffle
                  ? palette.primary
                  : palette.ink.withValues(alpha: 0.55),
            ),
            tooltip: language.shuffleLabel,
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: palette.outline),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            color: palette.ink,
            tooltip: language.previousLabel,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onAutoPlay,
            icon: Icon(
              isAutoPlay ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: palette.primary,
              size: 52,
            ),
            padding: EdgeInsets.zero,
            tooltip: isAutoPlay ? language.pauseLabel : language.autoPlayLabel,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            color: palette.ink,
            tooltip: language.nextLabel,
          ),
        ],
      ),
    );
  }
}
