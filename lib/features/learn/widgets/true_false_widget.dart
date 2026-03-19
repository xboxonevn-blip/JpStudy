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

  const TrueFalseWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.showResult = false,
    this.revealCorrectAnswer = false,
    required this.language,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
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
        ),
        const SizedBox(height: AppSpacing.lg),
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
              onTap: showResult ? null : () => onSelect(true),
            );
            final falseTile = QuestionChoiceTile(
              title: language.falseLabel,
              leadingIcon: Icons.close_rounded,
              accentColor: palette.error,
              isSelected: selectedAnswer == false,
              isCorrect: showResult && isCorrectFalse,
              isWrong: showResult && selectedAnswer == false && !isCorrectFalse,
              onTap: showResult ? null : () => onSelect(false),
            );

            if (vertical) {
              return Column(
                children: [
                  trueTile,
                  const SizedBox(height: AppSpacing.md),
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
}
