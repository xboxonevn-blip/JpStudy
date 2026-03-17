import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../shared/widgets/confidence_rating.dart';
import '../../flashcards/widgets/enhanced_flashcard.dart';
import '../../../data/models/mistake_context.dart';
import '../../../core/services/fsrs_service.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import '../../common/widgets/compact_ui.dart';
import '../../../app/theme/app_theme_palette.dart';

class TermReviewScreen extends ConsumerStatefulWidget {
  const TermReviewScreen({super.key});

  @override
  ConsumerState<TermReviewScreen> createState() => _TermReviewScreenState();
}

class _TermReviewScreenState extends ConsumerState<TermReviewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSessionComplete = false;
  bool _sessionStarted = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final FsrsService _fsrsService = FsrsService();

  // Session stats
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final termsAsync = ref.watch(allDueTermsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(language.reviewAction),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: termsAsync.when(
        data: (terms) {
          if (terms.isEmpty) {
            return _buildEmptyState(language);
          }
          if (!_sessionStarted) {
            return _buildPreview(language, terms.length);
          }
          if (_isSessionComplete) {
            return _buildSummary(language, terms.length);
          }
          if (_currentIndex >= terms.length) {
            // Should be handled by _isSessionComplete, but just in case
            return _buildSummary(language, terms.length);
          }

          final currentTermData = terms[_currentIndex];
          // Map UserLessonTermData to VocabItem explicitly
          final vocabItem = VocabItem(
            id: currentTermData.id,
            term: currentTermData.term,
            reading: currentTermData.reading,
            meaning: currentTermData.definition,
            meaningEn: currentTermData.definitionEn,
            kanjiMeaning: currentTermData.kanjiMeaning,
            level: '', // Not strictly needed for flashcard display
          );
          final srsStateAsync = ref.watch(srsStateProvider(currentTermData.id));

          return Column(
            children: [
              // Progress
              LinearProgressIndicator(
                value: (_currentIndex + 1) / terms.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${_currentIndex + 1} / ${terms.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),

              // Flashcard Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: EnhancedFlashcard(
                      key: ValueKey(
                        vocabItem.id,
                      ), // Important for animation reset
                      item: vocabItem,
                      language: language,
                      // enableSwipeGestures removed
                      onFlip: () {
                        // Optional: could track flip count
                      },
                    ),
                  ),
                ),
              ),

              // Rating Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (srsStateAsync.valueOrNull != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRetrievability(
                          language,
                          srsStateAsync.valueOrNull!,
                        ),
                      ),
                    ConfidenceRatingWidget(
                      language: language,
                      onSelect: (level) => _handleRating(
                        level,
                        currentTermData,
                        terms.length,
                        language,
                      ),
                      showLabels: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(language.loadErrorLabel)),
      ),
    );
  }

  Widget _buildPreview(AppLanguage language, int termCount) {
    final estimatedMinutes = (termCount * 8 / 60).ceil();
    return AppPageShell(
      child: Column(
        children: [
          AppFeatureCard(
            icon: Icons.rate_review_rounded,
            title: language.reviewAction,
            subtitle: language.reviewReadyTitle,
            primaryLabel: language.startReviewButton,
            onPrimaryTap: () => setState(() => _sessionStarted = true),
            status: AppStatusChip(
              label: language.reviewTermsDueLabel(termCount),
              tone: AppStatusTone.warning,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPreviewChip(
                Icons.library_books_outlined,
                language.reviewTermsDueLabel(termCount),
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _buildPreviewChip(
                Icons.timer_outlined,
                language.reviewEstimateLabel(estimatedMinutes),
                Colors.orange[700]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLanguage language) {
    return AppPageShell(
      child: AppFeatureCard(
        icon: Icons.check_circle_outline_rounded,
        title: language.reviewEmptyLabel,
        subtitle: language.sessionCompleteTitle,
        secondaryLabel: MaterialLocalizations.of(context).backButtonTooltip,
        onSecondaryTap: () => context.pop(),
        status: const AppStatusChip(label: '0', tone: AppStatusTone.success),
      ),
    );
  }

  Widget _buildSummary(AppLanguage language, int total) {
    _animController.forward();
    final palette = context.appPalette;
    return AppPageShell(
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.celebration_rounded,
              size: 88,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: 20),
          AppFeatureCard(
            icon: Icons.check_circle_rounded,
            title: language.sessionCompleteTitle,
            subtitle: language.sessionReviewCountLabel(total),
            primaryLabel: language.doneLabel,
            onPrimaryTap: () => context.pop(),
            status: AppStatusChip(
              label: language.reviewGoodLabel,
              tone: AppStatusTone.success,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(language.reviewAgainLabel, _againCount, Colors.red),
          _buildSummaryRow(language.reviewHardLabel, _hardCount, Colors.orange),
          _buildSummaryRow(language.reviewGoodLabel, _goodCount, Colors.blue),
          _buildSummaryRow(language.reviewEasyLabel, _easyCount, Colors.green),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text('$count', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRetrievability(AppLanguage language, SrsStateData state) {
    final value = _fsrsService.retrievability(
      stability: state.stability,
      lastReviewedAt: state.lastReviewedAt,
    );
    final percent = (value * 100).round();
    return Text(
      language.retrievabilityPercentLabel(percent),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Colors.grey[700],
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _showNextReviewToast(
    DateTime? nextReviewAt,
    ConfidenceLevel level,
    AppLanguage language,
  ) {
    if (nextReviewAt == null || !mounted) return;
    final now = DateTime.now();
    final days = nextReviewAt.difference(now).inDays;
    final label = days == 0
        ? _toastToday(language)
        : days == 1
        ? _toastTomorrow(language)
        : _toastInDays(language, days);
    final color =
        level == ConfidenceLevel.again || level == ConfidenceLevel.hard
        ? Colors.orange
        : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_nextReviewToast(language, label)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _toastToday(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Today',
    AppLanguage.vi => 'Hôm nay',
    AppLanguage.ja => '今日',
  };

  String _toastTomorrow(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Tomorrow',
    AppLanguage.vi => 'Ngày mai',
    AppLanguage.ja => '明日',
  };

  String _toastInDays(AppLanguage language, int days) => switch (language) {
    AppLanguage.en => 'In $days days',
    AppLanguage.vi => '$days ngày nữa',
    AppLanguage.ja => '$days日後',
  };

  String _nextReviewToast(AppLanguage language, String label) =>
      switch (language) {
        AppLanguage.en => 'Next review: $label',
        AppLanguage.vi => 'Lần ôn tiếp theo: $label',
        AppLanguage.ja => '次回の復習: $label',
      };

  Future<void> _handleRating(
    ConfidenceLevel levelEnum,
    UserLessonTermData term,
    int totalTerms,
    AppLanguage language,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final mistakeRepo = ref.read(mistakeRepositoryProvider);

    final fsrsResult = await repo.saveTermReview(
      termId: term.id,
      quality: levelEnum.value,
    );
    _showNextReviewToast(fsrsResult?.nextReviewAt, levelEnum, language);

    if (levelEnum == ConfidenceLevel.again ||
        levelEnum == ConfidenceLevel.hard) {
      final prompt = term.reading.isNotEmpty
          ? '${term.term} ? ${term.reading}'
          : term.term;
      final correctAnswer = language == AppLanguage.en
          ? (term.definitionEn.isNotEmpty ? term.definitionEn : term.definition)
          : term.definition;
      await mistakeRepo.addMistake(
        type: 'vocab',
        itemId: term.id,
        context: MistakeContext(
          prompt: prompt,
          correctAnswer: correctAnswer,
          userAnswer: levelEnum.name,
          source: 'review',
          extra: {'confidence': levelEnum.name},
        ),
      );
    } else {
      await mistakeRepo.markCorrect(type: 'vocab', itemId: term.id);
    }

    setState(() {
      switch (levelEnum) {
        case ConfidenceLevel.again:
          _againCount++;
          break;
        case ConfidenceLevel.hard:
          _hardCount++;
          break;
        case ConfidenceLevel.good:
          _goodCount++;
          break;
        case ConfidenceLevel.easy:
          _easyCount++;
          break;
      }

      if (_currentIndex < totalTerms - 1) {
        _currentIndex++;
      } else {
        _isSessionComplete = true;
      }
    });
  }
}
