import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../flashcards/widgets/enhanced_flashcard.dart';
import '../../mistakes/repositories/mistake_repository.dart';

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
  int _gotItCount = 0;
  int _stillLearningCount = 0;

  VocabItem get _currentItem => widget.items[_currentIndex];
  bool get _isLast => _currentIndex >= widget.items.length - 1;

  void _handleFlip() => setState(() => _isFlipped = true);

  Future<void> _handleGotIt() async {
    final repo = ref.read(mistakeRepositoryProvider);
    await repo.markCorrect(type: 'vocab', itemId: _currentItem.id);
    setState(() => _gotItCount++);
    _advance();
  }

  Future<void> _handleStillLearning() async {
    setState(() => _stillLearningCount++);
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

  void _showSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SummaryDialog(
        total: widget.items.length,
        gotIt: _gotItCount,
        stillLearning: _stillLearningCount,
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // back to home
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final theme = Theme.of(context);
    final progress = (_currentIndex + 1) / widget.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👻 Vocab Review'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.error,
            ),
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
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: null, // tap the card to flip
                  icon: const Icon(Icons.touch_app_rounded),
                  label: const Text('Tap card to reveal'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _handleStillLearning,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          'Still learning',
                          style: TextStyle(color: Colors.orange),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _handleGotIt,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Got it!'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryDialog extends StatelessWidget {
  const _SummaryDialog({
    required this.total,
    required this.gotIt,
    required this.stillLearning,
    required this.onDone,
  });

  final int total;
  final int gotIt;
  final int stillLearning;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final accuracyPct = total > 0 ? (gotIt / total * 100).round() : 0;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Review complete! 👻'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$accuracyPct%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text('$gotIt / $total vocab cleared from mistake bank'),
          if (stillLearning > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$stillLearning still in your ghost queue',
              style: const TextStyle(color: Colors.orange),
            ),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onDone,
          child: const Text('Done'),
        ),
      ],
    );
  }
}
