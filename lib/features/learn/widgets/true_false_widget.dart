import 'package:flutter/material.dart';

import '../../../core/app_language.dart';
import '../models/question.dart';

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
    final isCorrectTrue =
        revealCorrectAnswer && question.isStatementTrue == true;
    final isCorrectFalse =
        revealCorrectAnswer && question.isStatementTrue == false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Statement
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // True/False buttons
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                label: language.trueLabel,
                icon: Icons.check_circle_outline,
                isSelected: selectedAnswer == true,
                isCorrect: showResult && isCorrectTrue,
                isWrong: showResult && selectedAnswer == true && !isCorrectTrue,
                color: Colors.green,
                onTap: showResult ? null : () => onSelect(true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AnswerButton(
                label: language.falseLabel,
                icon: Icons.cancel_outlined,
                isSelected: selectedAnswer == false,
                isCorrect: showResult && isCorrectFalse,
                isWrong:
                    showResult && selectedAnswer == false && !isCorrectFalse,
                color: Colors.red,
                onTap: showResult ? null : () => onSelect(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final Color color;
  final VoidCallback? onTap;

  const _AnswerButton({
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;

    if (isCorrect) {
      backgroundColor = color.withValues(alpha: 0.3);
      borderColor = color;
    } else if (isWrong) {
      backgroundColor = Colors.grey.withValues(alpha: 0.3);
      borderColor = Colors.grey;
    } else if (isSelected) {
      backgroundColor = color.withValues(alpha: 0.2);
      borderColor = color;
    } else {
      backgroundColor = Colors.grey.withValues(alpha: 0.1);
      borderColor = Colors.grey.withValues(alpha: 0.3);
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Column(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle
                    : (isWrong ? Icons.cancel : icon),
                size: 48,
                color: isCorrect || isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect || isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
