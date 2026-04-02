import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../providers/vocab_home_provider.dart';
import '../../progress/providers/review_forecast_provider.dart';
import '../../flashcards/widgets/enhanced_flashcard.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import '../../../shared/widgets/confidence_rating.dart';

class VocabGhostReviewScreen extends ConsumerStatefulWidget {
  final List<VocabItem> items;

  const VocabGhostReviewScreen({super.key, required this.items});

  @override
  ConsumerState<VocabGhostReviewScreen> createState() =>
      _VocabGhostReviewScreenState();
}

class _VocabGhostReviewScreenState
    extends ConsumerState<VocabGhostReviewScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;

  VocabItem get _currentItem => widget.items[_currentIndex];
  bool get _isLast => _currentIndex >= widget.items.length - 1;

  void _handleFlip() => setState(() => _isFlipped = true);

  Future<void> _handleRating(ConfidenceLevel level) async {
    final lessonRepo = ref.read(lessonRepositoryProvider);
    await lessonRepo.saveTermReview(
      termId: _currentItem.id,
      quality: level.value,
    );
    final repo = ref.read(mistakeRepositoryProvider);
    if (level == ConfidenceLevel.good || level == ConfidenceLevel.easy) {
      await repo.markCorrect(type: 'vocab', itemId: _currentItem.id);
    }
    setState(() {
      switch (level) {
        case ConfidenceLevel.again:
          _againCount++;
        case ConfidenceLevel.hard:
          _hardCount++;
        case ConfidenceLevel.good:
          _goodCount++;
        case ConfidenceLevel.easy:
          _easyCount++;
      }
    });
    _advance();
  }

  void _advance() {
    if (_isLast) {
      _showSummary();
      return;
    }
    setState(() {
      _currentIndex++;
      _isFlipped = false;
    });
  }

  void _showHint(BuildContext context) {
    final language = ref.read(appLanguageProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  language.mnemonicHintLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentItem.displayMnemonic(language)!.trim(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSummary() {
    ref.invalidate(allDueTermsProvider);
    ref.invalidate(vocabHomeSectionProvider);
    ref.invalidate(reviewForecastProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SummaryDialog(
        total: widget.items.length,
        againCount: _againCount,
        hardCount: _hardCount,
        goodCount: _goodCount,
        easyCount: _easyCount,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final theme = Theme.of(context);

    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(language.reviewVocabLabel)),
        body: Center(child: Text(language.reviewEmptyLabel)),
      );
    }

    final progress = (_currentIndex + 1) / widget.items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(language.reviewVocabLabel),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_currentIndex + 1} / ${widget.items.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EnhancedFlashcard(
                key: ValueKey(_currentItem.id),
                item: _currentItem,
                showTermFirst: true,
                language: language,
                onFlip: _handleFlip,
              ),
            ),
          ),
          if (!_isFlipped)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.touch_app_rounded),
                        label: Text(language.tapCardToRevealLabel),
                      ),
                    ),
                  ),
                  if ((_currentItem.displayMnemonic(language)?.trim().isNotEmpty ??
                      false)) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _showHint(context),
                        icon: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber,
                        ),
                        label: Text(
                          language.mnemonicHintLabel,
                          style: const TextStyle(color: Colors.amber),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amber),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ConfidenceRatingWidget(
                language: language,
                onSelect: _handleRating,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryDialog extends ConsumerWidget {
  const _SummaryDialog({
    required this.total,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
    required this.onDone,
  });

  final int total;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final successCount = goodCount + easyCount;
    final accuracyPct = total > 0 ? (successCount / total * 100).round() : 0;
    final color = accuracyPct >= 80
        ? Colors.green
        : accuracyPct >= 50
            ? Colors.orange
            : Colors.red;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(language.reviewCompleteLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$accuracyPct%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(language.correctCountLabel(successCount, total)),
          const SizedBox(height: 12),
          _GradeBreakdownRow(
            againCount: againCount,
            hardCount: hardCount,
            goodCount: goodCount,
            easyCount: easyCount,
            language: language,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onDone,
          child: Text(language.doneLabel),
        ),
      ],
    );
  }
}

class _GradeBreakdownRow extends StatelessWidget {
  const _GradeBreakdownRow({
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
    required this.language,
  });

  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _GradePill(count: againCount, color: Colors.red, label: language.reviewAgainLabel),
        _GradePill(count: hardCount, color: Colors.orange, label: language.reviewHardLabel),
        _GradePill(count: goodCount, color: Colors.blue, label: language.reviewGoodLabel),
        _GradePill(count: easyCount, color: Colors.green, label: language.reviewEasyLabel),
      ],
    );
  }
}

class _GradePill extends StatelessWidget {
  const _GradePill({
    required this.count,
    required this.color,
    required this.label,
  });

  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
