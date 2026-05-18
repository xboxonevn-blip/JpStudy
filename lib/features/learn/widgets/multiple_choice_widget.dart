import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../quiz/widgets/shared_answer_selection.dart';
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
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final palette = context.appPalette;
        final compact =
            widget.forceCompact ||
            constraints.maxWidth < 520 ||
            _isCompactViewport(context);
        final options = widget.question.options ?? const <String>[];
        final selectedIndex = widget.selectedAnswer == null
            ? null
            : options.indexOf(widget.selectedAnswer!);
        final correctIndex = options.indexOf(widget.question.correctAnswer);

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
            SharedAnswerSelection(
              questionKey: widget.question.id,
              options: options,
              selectedIndex: selectedIndex != -1 ? selectedIndex : null,
              correctIndex: correctIndex != -1 ? correctIndex : null,
              revealResult: widget.showResult,
              enabled: !widget.showResult,
              forceCompact: compact,
              fillAvailable: false,
              keyPrefix: 'learn_mc',
              confirmLabel: widget.language.checkAnswerLabel,
              confirmMinHeight: compact ? 32 : 48,
              onConfirm: (index) => widget.onSelect(options[index]),
              optionBuilder: (context, option) =>
                  _buildOptionTile(palette, option),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionTile(AppThemePalette palette, SharedAnswerOption option) {
    return QuestionChoiceTile(
      key: option.key,
      title: option.label,
      leadingLabel: option.marker,
      accentColor: palette.primary,
      isSelected: option.isSelected,
      isCorrect: widget.revealCorrectAnswer && option.isCorrect,
      isWrong: option.isWrong,
      compact: option.compact,
      onTap: option.isRevealed ? null : option.onTap,
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
