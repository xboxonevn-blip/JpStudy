import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../models/question.dart';
import 'question_surface.dart';

/// Multiple choice question widget
class MultipleChoiceWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showResult;
  final bool revealCorrectAnswer;
  final AppLanguage language;
  final Function(String) onSelect;

  const MultipleChoiceWidget({
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
    final options = question.options ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionPromptCard(
          label: language.multipleChoiceLabel,
          title: question.targetItem.term,
          subtitle: question.targetItem.hasDisplayReading
              ? question.targetItem.reading!.trim()
              : null,
          prompt: question.questionText,
          icon: Icons.layers_rounded,
          accentColor: palette.info,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < options.length; index++) ...[
          QuestionChoiceTile(
            title: options[index],
            leadingLabel: String.fromCharCode(65 + index),
            accentColor: palette.primary,
            isSelected: selectedAnswer == options[index],
            isCorrect:
                revealCorrectAnswer && options[index] == question.correctAnswer,
            isWrong:
                showResult &&
                selectedAnswer == options[index] &&
                options[index] != question.correctAnswer,
            onTap: showResult ? null : () => onSelect(options[index]),
          ),
          if (index < options.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
