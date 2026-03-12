import 'package:flutter/material.dart';

import '../../../core/app_language.dart';
import '../models/question.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question text
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                question.targetItem.term,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (question.targetItem.hasDisplayReading) ...[
                const SizedBox(height: 8),
                Text(
                  question.targetItem.reading!.trim(),
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Options
        ...question.options!.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionButton(
              text: option,
              isSelected: selectedAnswer == option,
              isCorrect:
                  revealCorrectAnswer && option == question.correctAnswer,
              isWrong:
                  showResult &&
                  selectedAnswer == option &&
                  option != question.correctAnswer,
              onTap: showResult ? null : () => onSelect(option),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.text,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrect) {
      backgroundColor = Colors.green.withValues(alpha: 0.2);
      borderColor = Colors.green;
      textColor = Colors.green[800]!;
    } else if (isWrong) {
      backgroundColor = Colors.red.withValues(alpha: 0.2);
      borderColor = Colors.red;
      textColor = Colors.red[800]!;
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.2);
      borderColor = Theme.of(context).primaryColor;
      textColor = Theme.of(context).primaryColor;
    } else {
      backgroundColor = Colors.grey.withValues(alpha: 0.1);
      borderColor = Colors.grey.withValues(alpha: 0.3);
      textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (isWrong) const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
