import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../models/question.dart';
import 'question_surface.dart';

/// Fill in the blank question widget
class FillBlankWidget extends StatefulWidget {
  final Question question;
  final bool showResult;
  final bool isCorrect;
  final bool revealCorrectAnswer;
  final bool allowHint;
  final String? initialAnswer;
  final AppLanguage language;
  final Function(String) onSubmit;

  const FillBlankWidget({
    super.key,
    required this.question,
    this.showResult = false,
    this.isCorrect = false,
    this.revealCorrectAnswer = true,
    this.allowHint = true,
    this.initialAnswer,
    required this.language,
    required this.onSubmit,
  });

  @override
  State<FillBlankWidget> createState() => _FillBlankWidgetState();
}

class _FillBlankWidgetState extends State<FillBlankWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant FillBlankWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id ||
        oldWidget.initialAnswer != widget.initialAnswer) {
      _showHint = false;
      _syncController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accentColor = widget.question.expectsReading == true
        ? palette.secondary
        : palette.primary;
    final borderColor = widget.showResult
        ? (widget.isCorrect ? palette.success : palette.error)
        : accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionPromptCard(
          label: widget.language.fillBlankLabel,
          title: widget.question.targetItem.term,
          subtitle:
              widget.question.expectsReading != true &&
                  widget.question.targetItem.hasDisplayReading
              ? widget.question.targetItem.reading!.trim()
              : null,
          prompt: widget.question.questionText,
          icon: Icons.edit_note_rounded,
          accentColor: accentColor,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          widget.language.yourAnswerLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: palette.ink.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.showResult,
          autofocus: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
          decoration: InputDecoration(
            hintText: widget.language.typeYourAnswerHint,
            hintStyle: TextStyle(color: palette.ink.withValues(alpha: 0.34)),
            filled: true,
            fillColor: widget.showResult
                ? (widget.isCorrect
                      ? palette.success.withValues(alpha: 0.08)
                      : palette.error.withValues(alpha: 0.08))
                : palette.base,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide(
                color: borderColor.withValues(alpha: 0.24),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide(
                color: widget.showResult
                    ? borderColor.withValues(alpha: 0.24)
                    : palette.outlineSoft,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            suffixIcon: widget.showResult
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Icon(
                      widget.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: widget.isCorrect ? palette.success : palette.error,
                      size: 26,
                    ),
                  )
                : null,
          ),
          onSubmitted: widget.showResult ? null : widget.onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),

        if (!widget.showResult &&
            widget.allowHint &&
            widget.question.hint != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _showHint
                  ? null
                  : () {
                      setState(() {
                        _showHint = true;
                      });
                    },
              icon: Icon(
                _showHint
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
              ),
              label: Text(widget.language.showHintLabel),
            ),
          ),
          if (_showHint) ...[
            const SizedBox(height: AppSpacing.md),
            QuestionInfoCard(
              label: widget.language.showHintLabel,
              value: widget.question.hint!,
              icon: Icons.tips_and_updates_outlined,
              color: palette.warning,
            ),
          ],
        ],

        if (widget.showResult &&
            !widget.isCorrect &&
            widget.revealCorrectAnswer) ...[
          const SizedBox(height: AppSpacing.md),
          QuestionInfoCard(
            label: widget.language.correctAnswerLabel,
            value: widget.question.correctAnswer,
            icon: Icons.check_circle_outline_rounded,
            color: palette.success,
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        if (!widget.showResult)
          FilledButton.icon(
            onPressed: () => widget.onSubmit(_controller.text),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              widget.language.checkAnswerLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
      ],
    );
  }

  void _syncController() {
    final nextText = widget.initialAnswer ?? '';
    _controller
      ..text = nextText
      ..selection = TextSelection.collapsed(offset: nextText.length);
  }
}
