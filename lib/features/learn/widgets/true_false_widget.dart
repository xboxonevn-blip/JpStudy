import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../models/question.dart';
import 'question_surface.dart';

/// True/False question widget
class TrueFalseWidget extends StatelessWidget {
  final Question question;
  final bool? selectedAnswer;
  final bool showResult;
  final bool revealCorrectAnswer;
  final AppLanguage language;
  final Function(bool) onSelect;
  final bool forceCompact;

  const TrueFalseWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.showResult = false,
    this.revealCorrectAnswer = false,
    required this.language,
    required this.onSelect,
    this.forceCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final compact = forceCompact || _isCompactViewport(context);
    final isCorrectTrue =
        revealCorrectAnswer && question.isStatementTrue == true;
    final isCorrectFalse =
        revealCorrectAnswer && question.isStatementTrue == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionPromptCard(
          label: language.trueFalseChoiceLabel,
          title: question.targetItem.term,
          subtitle: question.targetItem.hasDisplayReading
              ? question.targetItem.reading!.trim()
              : null,
          prompt: question.questionText,
          icon: Icons.rule_rounded,
          accentColor: palette.accent,
          compact: compact,
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final vertical = constraints.maxWidth < 560;
            final trueTile = QuestionChoiceTile(
              title: language.trueLabel,
              leadingIcon: Icons.check_rounded,
              accentColor: palette.success,
              isSelected: selectedAnswer == true,
              isCorrect: showResult && isCorrectTrue,
              isWrong: showResult && selectedAnswer == true && !isCorrectTrue,
              compact: compact,
              onTap: showResult ? null : () => onSelect(true),
            );
            final falseTile = QuestionChoiceTile(
              title: language.falseLabel,
              leadingIcon: Icons.close_rounded,
              accentColor: palette.error,
              isSelected: selectedAnswer == false,
              isCorrect: showResult && isCorrectFalse,
              isWrong: showResult && selectedAnswer == false && !isCorrectFalse,
              compact: compact,
              onTap: showResult ? null : () => onSelect(false),
            );

            if (vertical && !compact) {
              return Column(
                children: [
                  trueTile,
                  SizedBox(height: compact ? AppSpacing.xs : AppSpacing.md),
                  falseTile,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: trueTile),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: falseTile),
              ],
            );
          },
        ),
      ],
    );
  }

  bool _isCompactViewport(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final view = View.of(context);
    final viewWidth = view.physicalSize.width / view.devicePixelRatio;
    final viewHeight = view.physicalSize.height / view.devicePixelRatio;
    return mediaSize.width < 700 ||
        mediaSize.height < 700 ||
        viewWidth < 700 ||
        viewHeight < 700;
  }
}
