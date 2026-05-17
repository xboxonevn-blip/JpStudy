import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../models/question.dart';
import 'question_surface.dart';

/// Multiple choice question widget
class MultipleChoiceWidget extends StatefulWidget {
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
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  String? _pendingAnswer;

  @override
  void initState() {
    super.initState();
    _pendingAnswer = widget.selectedAnswer;
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id ||
        oldWidget.selectedAnswer != widget.selectedAnswer ||
        oldWidget.showResult != widget.showResult) {
      _pendingAnswer = widget.selectedAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final options = widget.question.options ?? const <String>[];
    final selected = widget.showResult ? widget.selectedAnswer : _pendingAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionPromptCard(
          label: widget.language.multipleChoiceLabel,
          title: widget.question.targetItem.term,
          subtitle: widget.question.targetItem.hasDisplayReading
              ? widget.question.targetItem.reading!.trim()
              : null,
          prompt: widget.question.questionText,
          icon: Icons.layers_rounded,
          accentColor: palette.info,
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var index = 0; index < options.length; index++) ...[
          QuestionChoiceTile(
            title: options[index],
            leadingLabel: String.fromCharCode(65 + index),
            accentColor: palette.primary,
            isSelected: selected == options[index],
            isCorrect:
                widget.revealCorrectAnswer &&
                options[index] == widget.question.correctAnswer,
            isWrong:
                widget.showResult &&
                widget.selectedAnswer == options[index] &&
                options[index] != widget.question.correctAnswer,
            onTap: widget.showResult
                ? null
                : () {
                    setState(() {
                      _pendingAnswer = options[index];
                    });
                  },
          ),
          if (index < options.length - 1) const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          key: const ValueKey('learn_mc_confirm'),
          onPressed: widget.showResult || _pendingAnswer == null
              ? null
              : () => widget.onSelect(_pendingAnswer!),
          child: Text(widget.language.checkAnswerLabel),
        ),
      ],
    );
  }
}
