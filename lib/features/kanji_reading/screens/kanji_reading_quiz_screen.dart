import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';
import '../../../data/db/database_provider.dart';
import '../../progress/providers/review_forecast_provider.dart';
import '../../../core/services/fsrs_service.dart';
import '../models/kanji_reading_question.dart';

enum ReadingQuizCompletion { done, continueToWriting }

class KanjiReadingQuizScreen extends ConsumerStatefulWidget {
  const KanjiReadingQuizScreen({
    super.key,
    required this.questions,
    this.allowContinueToWriting = false,
  });
  final List<KanjiReadingQuestion> questions;
  final bool allowContinueToWriting;

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
  // For correct answers, _graded becomes true once the user picks Hard/Good/Easy.
  // For wrong answers, grade 1 is submitted automatically on answer tap.
  bool _graded = false;
  final FsrsService _fsrs = FsrsService();

  KanjiReadingQuestion get _question => widget.questions[_current];
  bool get _isLast => _current >= widget.questions.length - 1;

  Future<void> _handleOption(int index) async {
    if (_answered) return;
    final isCorrect = index == _question.correctIndex;
    if (isCorrect) _correct++;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      // Wrong answers are auto-graded; correct answers wait for user rating.
      _graded = !isCorrect;
    });
    if (!isCorrect) {
      // Fire-and-forget: grade 1 (Again) for wrong answers.
      _submitGrade(1);
    }
  }

  /// Writes the FSRS result to the DB.
  /// Captures [kanjiId] synchronously before the first await so that
  /// advancing to the next question cannot corrupt the reference.
  Future<void> _submitGrade(int grade) async {
    final kanjiId = _question.target.id;
    final db = ref.read(databaseProvider);
    final dao = db.kanjiSrsDao;
    // initializeSrsState uses insertOrIgnore — safe to call unconditionally.
    // This fixes the silent-skip bug where first-time kanji never entered SRS.
    await dao.initializeSrsState(kanjiId);
    final state = await dao.getSrsState(kanjiId);
    if (state == null || !mounted) return;
    final result = _fsrs.review(
      stability: state.stability,
      difficulty: state.difficulty,
      grade: grade,
      lastReviewedAt: state.lastReviewedAt,
    );
    await dao.updateSrsState(
      kanjiId: kanjiId,
      stability: result.stability,
      difficulty: result.difficulty,
      lastConfidence: grade,
      nextReviewAt: result.nextReviewAt,
    );
  }

  void _advance() {
    if (_isLast) {
      _showSummary();
    } else {
      setState(() {
        _current++;
        _selectedIndex = null;
        _answered = false;
        _graded = false;
      });
    }
  }

  /// Submits the FSRS grade (fire-and-forget) and immediately advances.
  void _rateAndAdvance(int grade) {
    _submitGrade(grade); // starts async; kanjiId captured before first await
    _advance();
  }

  void _showSummary() {
    // Invalidate so kanji hub SRS dots + due counts refresh after the session.
    final levelCode = _question.target.jlptLevel.trim();
    ref.invalidate(kanjiDueIdsProvider);
    ref.invalidate(kanjiSeenIdsProvider);
    if (levelCode.isNotEmpty) {
      ref.invalidate(kanjiHomeSummaryByLevelCodeProvider(levelCode));
    }
    ref.invalidate(kanjiHomeSummaryProvider);
    ref.invalidate(reviewForecastProvider);

    final language = ref.read(appLanguageProvider);
    final pct = (_correct / widget.questions.length * 100).round();
    final palette = context.appPalette;
    final scoreColor = pct >= 80
        ? palette.success
        : pct >= 50
        ? palette.warning
        : palette.error;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(language.quizCompleteTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(language.correctCountLabel(_correct, widget.questions.length)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(ReadingQuizCompletion.done);
            },
            child: Text(language.doneLabel),
          ),
          if (widget.allowContinueToWriting)
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(
                  context,
                ).pop(ReadingQuizCompletion.continueToWriting);
              },
              child: Text(language.kanjiPracticeWriteLabel()),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);

    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: JapaneseBackground(
          child: Center(
            child: Text(
              language.reviewEmptyLabel,
              style: TextStyle(
                color: palette.ink.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final progress = (_current + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_current + 1} / ${widget.questions.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: palette.outlineSoft,
            valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
          ),
        ),
      ),
      body: JapaneseBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [palette.elevated, palette.base],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                    border: Border.all(color: palette.outline),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primary.withValues(alpha: 0.08),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _question.promptLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.ink.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _question.prompt,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize:
                              _question.mode == KanjiQuizMode.kanjiToReading
                              ? 80
                              : 36,
                          fontWeight: FontWeight.bold,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _question.target.meaning,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: palette.ink.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 2.5,
                  children: List.generate(_question.options.length, (i) {
                    final isSelected = _selectedIndex == i;
                    final isCorrect = i == _question.correctIndex;
                    Color bgColor = palette.elevated;
                    Color borderColor = palette.outline;
                    Color optionColor = palette.ink;
                    if (_answered) {
                      if (isCorrect) {
                        bgColor = palette.success.withValues(alpha: 0.14);
                        borderColor = palette.success;
                        optionColor = palette.success;
                      } else if (isSelected) {
                        bgColor = palette.error.withValues(alpha: 0.14);
                        borderColor = palette.error;
                        optionColor = palette.error;
                      }
                    }
                    return Material(
                      color: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        side: BorderSide(color: borderColor, width: 2),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
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
                              color: optionColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (_answered) ...[
                  const SizedBox(height: AppSpacing.lg),
                  if (_question.target.examples.isNotEmpty) ...[
                    Text(
                      language.kanjiQuizCompoundWordsLabel(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.ink.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...(_question.target.examples
                        .take(3)
                        .map(
                          (ex) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: ex.word,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: palette.ink,
                                        ),
                                  ),
                                  TextSpan(
                                    text: '  ${ex.reading}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: palette.ink.withValues(
                                        alpha: 0.66,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  ${ex.meaning}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: palette.ink.withValues(
                                        alpha: 0.58,
                                      ),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  if (_graded)
                    SizedBox(
                      width: 160,
                      height: 48,
                      child: FilledButton(
                        onPressed: _advance,
                        child: Text(
                          _isLast
                              ? language.kanjiQuizFinishLabel()
                              : language.kanjiQuizNextLabel(),
                        ),
                      ),
                    )
                  else
                    _SrsRatingRow(
                      language: language,
                      onRate: _rateAndAdvance,
                      isLast: _isLast,
                    ),
                ] else
                  const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-button rating row shown after a correct answer.
/// Tapping any button submits the FSRS grade and advances in one action.
class _SrsRatingRow extends StatelessWidget {
  const _SrsRatingRow({
    required this.language,
    required this.onRate,
    required this.isLast,
  });

  final AppLanguage language;
  final void Function(int grade) onRate;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      children: [
        Text(
          switch (language) {
            AppLanguage.en => 'How well did you know it?',
            AppLanguage.vi => 'Bạn nhớ tốt đến đâu?',
            AppLanguage.ja => 'どのくらい覚えていましたか？',
          },
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.ink.withValues(alpha: 0.58),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RatingButton(
              label: language.kanjiGradeHardLabel(),
              grade: 2,
              color: palette.warning,
              onTap: onRate,
            ),
            const SizedBox(width: AppSpacing.sm),
            _RatingButton(
              label: language.kanjiGradeGoodLabel(),
              grade: 3,
              color: palette.success,
              onTap: onRate,
            ),
            const SizedBox(width: AppSpacing.sm),
            _RatingButton(
              label: language.kanjiGradeEasyLabel(),
              grade: 4,
              color: palette.info,
              onTap: onRate,
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.grade,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int grade;
  final Color color;
  final void Function(int grade) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 44,
      child: OutlinedButton(
        onPressed: () => onTap(grade),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
