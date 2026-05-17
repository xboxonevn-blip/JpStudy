part of 'lesson_detail_screen.dart';

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.language,
    required this.termsAsync,
    required this.term,
    required this.showHints,
    required this.compactHint,
    required this.isFlipped,
    required this.trackProgress,
    required this.isStarred,
    required this.isLearned,
    required this.onShowHintsChanged,
    required this.onFlip,
    required this.onStar,
    required this.onLearned,
    this.onEdit,
    this.onStartLearning,
    this.emptyLabel,
  });

  final AppLanguage language;
  final AsyncValue<List<UserLessonTermData>> termsAsync;
  final UserLessonTermData? term;
  final bool showHints;
  final bool compactHint;
  final bool isFlipped;
  final bool trackProgress;
  final bool isStarred;
  final bool isLearned;
  final ValueChanged<bool> onShowHintsChanged;
  final VoidCallback? onFlip;
  final VoidCallback? onEdit;
  final VoidCallback? onStar;
  final VoidCallback? onLearned;
  final VoidCallback? onStartLearning;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(language.showHintsLabel),
                    const SizedBox(width: 8),
                    Switch(value: showHints, onChanged: onShowHintsChanged),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onLearned != null)
                      IconButton(
                        onPressed: onLearned,
                        icon: Icon(
                          isLearned
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: isLearned
                              ? palette.success
                              : palette.ink.withValues(alpha: 0.4),
                        ),
                        tooltip: language.learnedLabel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppTouchTargets.min,
                          minHeight: AppTouchTargets.min,
                        ),
                      ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onStar,
                      icon: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isStarred
                            ? palette.warning
                            : palette.ink.withValues(alpha: 0.4),
                        size: 26,
                      ),
                      tooltip: language.starLabel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: AppTouchTargets.min,
                        minHeight: AppTouchTargets.min,
                      ),
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: palette.ink.withValues(alpha: 0.55),
                          size: 22,
                        ),
                        tooltip: language.editLabel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppTouchTargets.min,
                          minHeight: AppTouchTargets.min,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onFlip,
                child: _CardContent(
                  language: language,
                  termsAsync: termsAsync,
                  term: term,
                  showHints: showHints,
                  compactHint: compactHint,
                  isFlipped: isFlipped,
                  emptyLabel: emptyLabel,
                  onStartLearning: onStartLearning,
                ),
              ),
            ),
          ),
          if (trackProgress) _ShortcutBar(language: language),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  static final _whitespaceRe = RegExp(r'\s+');

  const _CardContent({
    required this.language,
    required this.termsAsync,
    required this.term,
    required this.showHints,
    required this.compactHint,
    required this.isFlipped,
    required this.emptyLabel,
    this.onStartLearning,
  });

  final AppLanguage language;
  final AsyncValue<List<UserLessonTermData>> termsAsync;
  final UserLessonTermData? term;
  final bool showHints;
  final bool compactHint;
  final bool isFlipped;
  final String? emptyLabel;
  final VoidCallback? onStartLearning;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    if (termsAsync.isLoading) {
      return const CircularProgressIndicator();
    }
    if (termsAsync.hasError) {
      return Text(language.loadErrorLabel);
    }
    final resolvedTerm = term;
    if (resolvedTerm == null) {
      if (onStartLearning != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emptyLabel ?? '',
              style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStartLearning,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(language.startLearningLabel),
            ),
          ],
        );
      }
      final label = emptyLabel;
      if (label == null || label.isEmpty) {
        return const SizedBox.shrink();
      }
      return Text(
        label,
        style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
        textAlign: TextAlign.center,
      );
    }

    final showBack = isFlipped && resolvedTerm.definition.trim().isNotEmpty;
    final hintMeaning = switch (language) {
      AppLanguage.en => resolvedTerm.definitionEn,
      AppLanguage.vi => resolvedTerm.definition,
      AppLanguage.ja => resolvedTerm.definition,
    };
    final frontHint = compactHint
        ? _compactHint(hintMeaning, resolvedTerm.id)
        : hintMeaning;
    final showReading = shouldShowReading(
      term: resolvedTerm.term,
      reading: resolvedTerm.reading,
    );

    final front = _CardFace(
      key: const ValueKey(false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language.termLabel,
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resolvedTerm.term,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
            textAlign: TextAlign.center,
          ),
          if (showReading) ...[
            const SizedBox(height: 20),
            Text(
              language.readingLabel,
              style: TextStyle(
                fontSize: 12,
                color: palette.ink.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resolvedTerm.reading.trim(),
              style: TextStyle(
                fontSize: 18,
                color: palette.ink.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showHints && frontHint.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              language.meaningLabel,
              style: TextStyle(
                fontSize: 12,
                color: palette.ink.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              frontHint,
              style: TextStyle(
                fontSize: 16,
                color: palette.ink.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    final backMeaning = hintMeaning;

    final backContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          language == AppLanguage.en
              ? language.meaningEnLabel
              : language.meaningLabel,
          style: TextStyle(
            fontSize: 12,
            color: palette.ink.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          backMeaning.trim().isEmpty ? '-' : backMeaning,
          style: TextStyle(fontSize: 18, color: palette.ink),
          textAlign: TextAlign.center,
        ),
        if (language == AppLanguage.vi &&
            resolvedTerm.kanjiMeaning.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            language.kanjiMeaningLabel,
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resolvedTerm.kanjiMeaning,
            style: TextStyle(
              fontSize: 16,
              color: palette.ink.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final back = _CardFace(key: const ValueKey(true), child: backContent);

    return AnimatedSwitcher(
      duration: reducedMotionDuration(
        context,
        const Duration(milliseconds: 320),
      ),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isUnder = child?.key != ValueKey(showBack);
            var value = rotate.value;
            if (isUnder) {
              value = min(rotate.value, pi / 2);
            }
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [...previousChildren, ?currentChild],
        );
      },
      child: showBack ? back : front,
    );
  }

  String _compactHint(String meaning, int seed) {
    final clean = meaning.replaceAll('\n', ' ').trim();
    if (clean.isEmpty) return '';
    final compact = clean.replaceAll(_whitespaceRe, '');
    if (compact.isEmpty) return '';

    var take = compact.length <= 2 ? compact.length : (seed.abs() % 2) + 2;
    if (take > compact.length) take = compact.length;
    final maxStart = compact.length - take;
    final start = maxStart <= 0 ? 0 : ((seed.abs() ~/ 11) % (maxStart + 1));
    return compact.substring(start, start + take);
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ShortcutBar extends StatelessWidget {
  const _ShortcutBar({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.keyboard, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            language.shortcutLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              language.shortcutInstruction,
              style: TextStyle(color: palette.ink.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
