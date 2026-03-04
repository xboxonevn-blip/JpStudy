import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/database_provider.dart';
import '../../../core/services/fsrs_service.dart';
import '../models/kanji_reading_question.dart';

class KanjiReadingQuizScreen extends ConsumerStatefulWidget {
  const KanjiReadingQuizScreen({super.key, required this.questions});
  final List<KanjiReadingQuestion> questions;

  @override
  ConsumerState<KanjiReadingQuizScreen> createState() =>
      _KanjiReadingQuizScreenState();
}

class _KanjiReadingQuizScreenState
    extends ConsumerState<KanjiReadingQuizScreen> {
  int _current = 0;
  int _correct = 0;
  int? _selectedIndex;
  bool _answered = false;
  final FsrsService _fsrs = FsrsService();

  KanjiReadingQuestion get _question => widget.questions[_current];
  bool get _isLast => _current >= widget.questions.length - 1;

  Future<void> _handleOption(int index) async {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    final isCorrect = index == _question.correctIndex;
    if (isCorrect) _correct++;

    // Update kanji SRS
    final db = ref.read(databaseProvider);
    final kanjiSrsDao = db.kanjiSrsDao;
    final grade = isCorrect ? 3 : 1; // Good or Again
    final currentState = await kanjiSrsDao.getSrsState(_question.target.id);
    if (currentState != null) {
      final result = _fsrs.review(
        stability: currentState.stability,
        difficulty: currentState.difficulty,
        grade: grade,
        lastReviewedAt: currentState.lastReviewedAt,
      );
      await kanjiSrsDao.updateSrsState(
        kanjiId: _question.target.id,
        stability: result.stability,
        difficulty: result.difficulty,
        lastConfidence: grade,
        nextReviewAt: result.nextReviewAt,
      );
    }

    // Auto-advance after short delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (_isLast) {
      _showSummary();
    } else {
      setState(() {
        _current++;
        _selectedIndex = null;
        _answered = false;
      });
    }
  }

  void _showSummary() {
    final pct = (_correct / widget.questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: pct >= 80
                    ? Colors.green
                    : pct >= 50
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text('$_correct / ${widget.questions.length} correct'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // back to entry
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_current + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_current + 1} / ${widget.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Prompt label
              Text(
                _question.promptLabel,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // Main prompt (large kanji or reading)
              Text(
                _question.prompt,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize:
                      _question.mode == KanjiQuizMode.kanjiToReading ? 80 : 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Show meaning hint below
              const SizedBox(height: 8),
              Text(
                _question.target.meaning,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[500]),
              ),
              const Spacer(),
              // 2x2 option grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: List.generate(_question.options.length, (i) {
                  final isSelected = _selectedIndex == i;
                  final isCorrect = i == _question.correctIndex;
                  Color? bgColor;
                  Color? borderColor;
                  if (_answered) {
                    if (isCorrect) {
                      bgColor = Colors.green.withValues(alpha: 0.15);
                      borderColor = Colors.green;
                    } else if (isSelected) {
                      bgColor = Colors.red.withValues(alpha: 0.15);
                      borderColor = Colors.red;
                    }
                  }

                  return Material(
                    color: bgColor ?? theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: borderColor ?? const Color(0xFFE5E7EB),
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleOption(i),
                      child: Center(
                        child: Text(
                          _question.options[i],
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize:
                                _question.mode == KanjiQuizMode.readingToKanji
                                    ? 32
                                    : 18,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
