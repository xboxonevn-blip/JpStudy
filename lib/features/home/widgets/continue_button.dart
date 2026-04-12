import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

import '../providers/continue_provider.dart';

class ContinueButton extends ConsumerStatefulWidget {
  const ContinueButton({super.key});

  @override
  ConsumerState<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends ConsumerState<ContinueButton> {
  static final _nonDigitRe = RegExp(r'[^0-9]');

  ContinueAction? _lastAction;

  @override
  Widget build(BuildContext context) {
    final actionAsync = ref.watch(continueActionProvider);
    final language = ref.watch(appLanguageProvider);
    final latest = actionAsync.valueOrNull;
    if (latest != null) {
      _lastAction = latest;
    }
    final action = latest ?? _lastAction;
    if (action == null) {
      return const SizedBox.shrink();
    }
    return _buildCard(context, action, language);
  }

  Widget _buildCard(
    BuildContext context,
    ContinueAction action,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    final accent = _getAccentColor(action.type, palette);
    final icon = _getIcon(action.type);
    final isNextLesson = action.type == ContinueActionType.nextLesson;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, action),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.elevated, palette.base],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent.withValues(alpha: 0.26)),
              boxShadow: [
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isNextLesson
                ? _buildNextLessonStyle(action, language)
                : _buildCompactStyle(icon, accent, action, language),
          ),
        ),
      ),
    );
  }

  Widget _buildNextLessonStyle(ContinueAction action, AppLanguage language) {
    final palette = context.appPalette;
    final accent = _getAccentColor(action.type, palette);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.play_lesson_rounded, color: accent, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              language.nextStepLabel.toUpperCase(),
              style: TextStyle(
                color: palette.ink.withValues(alpha: 0.55),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                language.startPracticeLabel,
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          language.nextLessonSubtitle,
          style: TextStyle(
            color: palette.ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getLabel(action, language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.ink.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withValues(alpha: 0.84)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            language.startPracticeLabel.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactStyle(
    IconData icon,
    Color accent,
    ContinueAction action,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accent.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: accent, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(action.type, language),
                style: TextStyle(
                  color: accent.withValues(alpha: 0.92),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getLabel(action, language),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: accent.withValues(alpha: 0.92),
            size: 22,
          ),
        ),
      ],
    );
  }

  Color _getAccentColor(ContinueActionType type, AppThemePalette palette) {
    switch (type) {
      case ContinueActionType.grammarReview:
        return palette.accent;
      case ContinueActionType.vocabReview:
        return palette.info;
      case ContinueActionType.kanjiReview:
        return palette.secondary;
      case ContinueActionType.nextLesson:
        return palette.success;
      case ContinueActionType.fixMistakes:
        return palette.error;
      default:
        return palette.info;
    }
  }

  IconData _getIcon(ContinueActionType type) {
    switch (type) {
      case ContinueActionType.grammarReview:
        return Icons.auto_stories_rounded;
      case ContinueActionType.vocabReview:
        return Icons.style_rounded;
      case ContinueActionType.kanjiReview:
        return Icons.brush_rounded;
      case ContinueActionType.nextLesson:
        return Icons.play_lesson_rounded;
      case ContinueActionType.fixMistakes:
        return Icons.warning_amber_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  String _getTitle(ContinueActionType type, AppLanguage language) {
    switch (type) {
      case ContinueActionType.grammarReview:
        return language.reviewGrammarLabel.toUpperCase();
      case ContinueActionType.vocabReview:
        return language.reviewVocabLabel.toUpperCase();
      case ContinueActionType.kanjiReview:
        return language.reviewKanjiLabel.toUpperCase();
      case ContinueActionType.nextLesson:
        return language.continueJourneyLabel.toUpperCase();
      case ContinueActionType.fixMistakes:
        return language.fixMistakesLabel.toUpperCase();
      default:
        return language.nextStepLabel.toUpperCase();
    }
  }

  String _getLabel(ContinueAction action, AppLanguage language) {
    if (action.type == ContinueActionType.nextLesson) {
      final number = action.label.replaceAll(_nonDigitRe, '');
      if (number.isNotEmpty) {
        return '${language.lessonLabel} $number';
      }
      return action.label;
    }
    if (action.count != null && action.count! > 0) {
      return language.itemsCountLabel(action.count!);
    }
    return action.label;
  }

  void _handleNavigation(BuildContext context, ContinueAction action) {
    final language = ref.read(appLanguageProvider);
    final level = ref.read(studyLevelProvider);
    final levelCode = level?.shortLabel ?? 'N5';

    switch (action.type) {
      case ContinueActionType.grammarReview:
        context.openGrammar();
        break;
      case ContinueActionType.vocabReview:
        context.push(
          '/vocab/review',
          extra: VocabReviewArgs(
            source: 'daily_queue',
            levelCode: levelCode,
            title: language.vocabReviewTitle(levelCode),
            subtitle: switch (language) {
              AppLanguage.en => 'Today queue',
              AppLanguage.vi => 'Hàng đợi hôm nay',
              AppLanguage.ja => '今日のキュー',
            },
          ),
        );
        break;
      case ContinueActionType.kanjiReview:
        context.push(
          '/kanji/practice',
          extra: KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            levelCode: levelCode,
            source: 'due',
          ),
        );
        break;
      case ContinueActionType.fixMistakes:
        context.openMistakes();
        break;
      case ContinueActionType.nextLesson:
        if (action.data != null) {
          context.openLesson(action.data);
        } else {
          context.openHome();
        }
        break;
      default:
        break;
    }
  }
}
