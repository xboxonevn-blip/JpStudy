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
  final bool forceCompact;

  const MultipleChoiceWidget({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final palette = context.appPalette;
        final compact =
            widget.forceCompact ||
            constraints.maxWidth < 520 ||
            MediaQuery.sizeOf(context).width < 700;
        final options = widget.question.options ?? const <String>[];
        final useGrid = !compact && constraints.maxWidth >= 720;
        final selected = widget.showResult
            ? widget.selectedAnswer
            : _pendingAnswer;

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
              compact: compact,
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
            if (useGrid)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 4.8,
                ),
                itemBuilder: (context, index) => _buildOptionTile(
                  palette,
                  options,
                  index,
                  selected,
                  compact: false,
                ),
              )
            else
              for (var index = 0; index < options.length; index++) ...[
                _buildOptionTile(
                  palette,
                  options,
                  index,
                  selected,
                  compact: compact,
                ),
                if (index < options.length - 1)
                  SizedBox(height: compact ? 4 : AppSpacing.md),
              ],
            SizedBox(height: compact ? AppSpacing.xs : AppSpacing.lg),
            FilledButton(
              key: const ValueKey('learn_mc_confirm'),
              style: FilledButton.styleFrom(
                minimumSize: Size.fromHeight(compact ? 32 : 48),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: widget.showResult || _pendingAnswer == null
                  ? null
                  : () => widget.onSelect(_pendingAnswer!),
              child: Text(widget.language.checkAnswerLabel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTile(
    AppThemePalette palette,
    List<String> options,
    int index,
    String? selected, {
    required bool compact,
  }) {
    final option = options[index];
    return QuestionChoiceTile(
      title: option,
      leadingLabel: String.fromCharCode(65 + index),
      accentColor: palette.primary,
      isSelected: selected == option,
      isCorrect:
          widget.revealCorrectAnswer && option == widget.question.correctAnswer,
      isWrong:
          widget.showResult &&
          widget.selectedAnswer == option &&
          option != widget.question.correctAnswer,
      compact: compact,
      onTap: widget.showResult
          ? null
          : () {
              setState(() {
                _pendingAnswer = option;
              });
            },
    );
  }
}
