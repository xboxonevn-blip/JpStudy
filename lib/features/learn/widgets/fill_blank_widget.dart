import 'package:flutter/material.dart';

import '../../../core/app_language.dart';
import '../models/question.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                widget.question.targetItem.term,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.question.expectsReading != true &&
                  widget.question.targetItem.hasDisplayReading) ...[
                const SizedBox(height: 8),
                Text(
                  widget.question.targetItem.reading!.trim(),
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                widget.question.questionText,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Answer input
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !widget.showResult,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
          decoration: InputDecoration(
            hintText: widget.language.typeYourAnswerHint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: widget.showResult
                ? (widget.isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1))
                : Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            suffixIcon: widget.showResult
                ? Icon(
                    widget.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: widget.isCorrect ? Colors.green : Colors.red,
                    size: 28,
                  )
                : null,
          ),
          onSubmitted: widget.showResult ? null : widget.onSubmit,
        ),
        const SizedBox(height: 16),

        // Hint button
        if (!widget.showResult &&
            widget.allowHint &&
            widget.question.hint != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showHint = true;
              });
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(
              _showHint
                  ? widget.language.hintWithValue(widget.question.hint!)
                  : widget.language.showHintLabel,
            ),
          ),

        // Show correct answer if wrong
        if (widget.showResult &&
            !widget.isCorrect &&
            widget.revealCorrectAnswer) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  widget.language.correctAnswerLabel,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.question.correctAnswer,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Submit button
        if (!widget.showResult)
          ElevatedButton(
            onPressed: () => widget.onSubmit(_controller.text),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.language.checkAnswerLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
